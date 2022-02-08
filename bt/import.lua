local json = require "bt.json"
local f = io.open(..., "r")
local s = f:read("a")
local t = json.decode(s)
local next = next
local assert = assert
local concat = table.concat
local format = string.format

local type_transition = {
	["Sequence"] = {type = "sequence", mem = false, control = true},
	["MemSequence"] = {type = "sequence", mem = true, control = true},
	["Priority"] = {type = "fallback", mem = false, control = true},
	["MemPriority"] = {type = "fallback", mem = true, control = true},
	["Decorator"] = {type = "decorator"},
	["condition"] = {type = "condition"},
	["action"] = {type = "action"}
}

local nodes = {}
local node_id = {}

--build node type
for _, node in pairs(t.custom_nodes) do
	type_transition[node.name] = type_transition[node.category]
end
--build array
for k, node in pairs(t.nodes) do
	nodes[#nodes + 1] = node
end
local root = t.root
table.sort(nodes, function(a, b)
	if a.id == root then
		return true
	end
	if b.id == root then
		return false
	end
	return a.id < b.id
end)

for i = 1, #nodes do
	node_id[nodes[i].id] = i
end
--build child reference
for i = 1, #nodes do
	local n = nodes[i]
	local children = n.children
	if children then
		for i = 1, #children do
			children[i] = assert(node_id[children[i]])
		end
	end
	local child = n.child
	if child then
		n.child = assert(node_id[child])
	end
end
--export
local buf = {}
buf[1] = "local M = {"
for i = 1, #nodes do
	local n = nodes[i]
	local t = type_transition[n.name]
	local line = {}
	line[1] = format('\t[%d]={', i)
	local children = n.children
	local properties = n.properties
	if not t then
		if n.child then -- sequence or priority or decorator
			t = type_transition["Decorator"]
			children = {n.child}
			n.children = children
		end
	end
	if not t.control then
		line[2] = format('\t\tname="%s",', n.name)
	end
	line[#line + 1] = format('\t\ttype="%s",', t.type)
	if t.mem ~= nil then
		line[#line + 1] = format('\t\tmem=%s,', t.mem)
	end
	if next(properties) then
		line[#line + 1] = '\t\tproperties={'
		for k, v in pairs(properties) do
			line[#line + 1] = format('\t\t\t["%s"] = "%s",', k, v)
		end
		line[#line + 1] = '\t\t},'
	end
	if children then
		line[#line + 1] = '\t\tchildren=nil,'
	end
	line[#line + 1] = "\t},"
	buf[#buf + 1] = concat(line, "\n")
end
buf[#buf + 1] = "}"

for i = 1, #nodes do
	local n = nodes[i]
	local children = n.children
	if children then
		local line = {}
		line[1] = format('M[%s].children={', node_id[n.id])
		for i = 1, #children do
			line[#line + 1] = format('M[%s],', children[i])
		end
		line[#line + 1] = '}'
		buf[#buf + 1] = concat(line)
	end
end

buf[#buf + 1 ] = "return M"

print(concat(buf, "\n"))



