local M = {}
local mem_path = {}
local tick_count = setmetatable({}, {__mode = "k"})

local function tick(tree, actions, ctx)
	local result
	local n = tick_count[ctx] or 0 + 1
	ctx.__tick = n
	local last = ctx.__running
	if last then
		local n = ctx.__downclock
		if n > 0 then
			ctx.__downclock = n - 1
			tree = last
		end
		ctx.__running = nil
	end
	local running
	tick_count[ctx] = n
	repeat
		local n
		if tree.mem then
			n = ctx[tree]
			if not n then
				n = tree.children[1]
			end
			mem_path[#mem_path + 1] = tree
		else
			local func = actions[tree.name]
			if tree.type == "decorator" then
				result = func(ctx, tree.properties, result)
			else
				result = func(ctx, tree.properties)
			end
			print("exec", tree.name, result)
			if result == nil then
				running = tree
				break
			end
			if result then
				n = tree.success
			else
				n = tree.failure
			end
		end
		tree = n
	until not tree
	if result ~= nil then
		for i = 1, #mem_path do
			ctx[mem_path[i]] = false --prevent rehash
			mem_path[i] = nil
		end
	else
		local running_id = running.id
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
		if running ~= last then
			ctx.__running = running
			ctx.__downclock = 10
		end
	end
	return result
end

return tick

