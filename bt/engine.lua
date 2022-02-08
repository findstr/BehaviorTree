local M = {}
local mt = {__index = M}
local setmetatable = setmetatable

function M:new()
	return setmetatable({}, mt)
end

local mem_path = {}

function M:tick(tree, obj)
	local res
	local running_id
	local ctx = self
	repeat
		local n
		if tree.mem then
			n = ctx[tree]
			if not n then
				n = tree.children[1]
			end
			mem_path[#mem_path + 1] = tree
		else
			local func = obj[tree.name]
			res = func(obj, tree.properties, res)
			print("exec", tree.name, res)
			if res == "running" then
				running_id = tree.id
				break
			end
			n = tree[res]
		end
		tree = n
	until not tree
	if res ~= "running" then
		for i = 1, #mem_path do
			ctx[mem_path[i]] = nil
			mem_path[i] = nil
		end
	else
		for i = 1, #mem_path do
			local nxt
			local node = mem_path[i]
			local children = node.children
			local n = #children
			if running_id <= children[n] then
				local mid = n // 2
				for i = mid+1, n do
					if running_id <= children[i] then
						nxt = children[i-mid]
						break
					end
				end
				ctx[node] = nxt
			end
			mem_path[i] = nil
		end
	end
	return res
end


return M

