local tree  = require (...)
local error = error
local pairs = pairs
local ipairs = ipairs
local assert = assert
local concat = table.concat
local leaf = {}
local leaf_parent = {}
local leaf_id = {}
local function build_leaf(root)
	local children = root.children
	if not children then
		leaf[#leaf + 1] = root
		return
	end
	if root.mem then
		assert(root.type ~= "decorator")
		leaf[#leaf + 1] = root
	end
	for i = 1, #children do
		local c = children[i]
		leaf_parent[c] = root
		build_leaf(c)
	end
	if root.type == "decorator" then
		leaf[#leaf + 1] = root
	end
end

local function build_leaf_id()
	for i = 1, #leaf do
		leaf_id[leaf[i]] = i
	end
end

local function next_slot(children, n)
	for k, v in ipairs(children) do
		if v == n then
			return k + 1
		end
	end
	error("invliad child")
end

local function can_exec(node)
	return node.mem or (not node.children)
end

local function down_left(node)
	if not node then
		return nil
	end
	local children = node.children
	if can_exec(node) then
		return node
	end
	return down_left(children[1])
end

local function max_leaf_id(node)
	local children = node.children
	if not children then
		return assert(leaf_id[node])
	end
	local id = leaf_id[node] or 0
	for i = 1, #children do
		local c = children[i]
		local n = max_leaf_id(c)
		if n > id then
			id = n
		end
	end
	return id
end

local function find_ok_path(node)
	local p = leaf_parent[node]
	repeat
		local t = p.type
		if t == "decorator" then
			return p
		elseif t == "sequence" then
			local children = p.children
			local n = down_left(children[next_slot(children, node)])
			if n then
				return n
			end
			node = p
		elseif t == "fallback" then
			node = p
		else
			error(t)
		end
		p = leaf_parent[node]
	until not p
	return nil
end

local function find_fail_path(node)
	local p = leaf_parent[node]
	repeat
		local t = p.type
		if t == "decorator" then
			return p
		elseif t == "sequence" then
			node = p
		elseif t == "fallback" then
			local children = p.children
			local n = down_left(children[next_slot(children, node)])
			if n then
				return n
			end
			node = p
		end
		p = leaf_parent[node]
	until not p
	return nil
end

build_leaf(tree[1])
build_leaf_id()

for i = 1, #leaf do
	local n = leaf[i]
	if not n.mem then
		n.ok = find_ok_path(n)
		n.fail = find_fail_path(n)
	end
end

for i = 1, #leaf do
	local n = leaf[i]
	if n.mem then
		local t = {}
		local children = n.children
		for i = 1, #children do
			t[#t + 1] = down_left(children[i])
		end
		for i = 1, #children do
			t[#t + 1] = max_leaf_id(children[i])
		end
		n.children = t
	end
end

local field = {
	"type",
	"name",
	"mem",
	"properties"
}

local buf = {}
buf[1] = 'local M = {'
local format = string.format
for i = 1, #leaf do
	local n = leaf[i]
	local line = {}
	line[1] = format('[%s] = {', i)
	line[2] = format('\tid = %d,', i)
	for _, name in ipairs(field) do
		local v = n[name]
		if v then
			local t = type(v)
			if t == "boolean" then
				line[#line + 1] = format('\t["%s"] = %s,', name, v)
			elseif t ~= "table" then
				line[#line + 1] = format('\t["%s"] = "%s",', name, v)
			else
				line[#line + 1] = format('\t["%s"] = {', name)
				for k, v in pairs(v) do
					line[#line + 1] = format('\t\t["%s"] = %s,', k, v)
				end
				line[#line + 1] = "\t},"
			end
		end
	end
	if n.ok then
		line[#line + 1] = "\tsuccess = nil,"
	end
	if n.fail then
		line[#line + 1] = "\tfailure = nil,"
	end
	if n.mem then
		line[#line + 1] = "\tchildren=nil,"
	end
	line[#line + 1] = "},"
	buf[#buf + 1]  = concat(line, "\n")
end
buf[#buf + 1] = '}'

for i = 1, #leaf do
	local n = leaf[i]
	if n.ok then
		buf[#buf + 1] = format("M[%d].success = M[%d]", i, leaf_id[n.ok])
	end
	if n.fail then
		buf[#buf + 1] = format("M[%d].failure = M[%d]", i, leaf_id[n.fail])
	end
	if n.mem then
		local line = {}
		local children = n.children
		assert(#children % 2 == 0)
		for i = 1, #children // 2 do
			local c = children[i]
			line[#line + 1] = format("M[%s]", leaf_id[children[i]])
		end
		for i = #children // 2 + 1, #children do
			line[#line + 1] = format("%s", children[i])
		end
		buf[#buf + 1] = format("M[%d].children={%s}", i, table.concat(line, ","))
	end
end

buf[#buf + 1] = 'return M'

print(concat(buf, "\n"))

