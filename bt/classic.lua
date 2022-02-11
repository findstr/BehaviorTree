local node = {}

local function exec(func)
	return function(root, actions, ctx)
		local mem = root.mem
		if mem then
			local c = ctx[root]
			if c then
				local res = node[c.type](c, actions, ctx)
				if res ~= nil then
					ctx[root] = nil
				end
				return res
			end
		end
		local res, c = func(root, actions, ctx)
		if mem then
			ctx[root] = c
		end
		return res
	end
end

node.sequence = exec(function(root, actions, ctx)
	local children = root.children
	for i = 1, #children do
		local c = children[i]
		local res = node[c.type](c, actions, ctx)
		if res == nil then
			return nil, c
		elseif res == false then
			return false, nil
		end
	end
	return true, nil
end)

node.fallback = exec(function(root, actions, ctx)
	local children = root.children
	for i = 1, #children do
		local c = children[i]
		local res = node[c.type](c, actions, ctx)
		if res == nil then
			return nil, c
		elseif res == true then
			return true, nil
		end
	end
	return false, nil
end)

node.decorator = function(root, actions, ctx)
	local child = root.children[1]
	local res = node[child.type](child, actions, ctx)
	local func = actions[root.name]
	local res = func(ctx, root.properties, res)
	return res
end

node.action = function(root, actions, ctx)
	local func = actions[root.name]
	local res = func(ctx, root.properties)
	print(root.name, res)
	return res
end

node.condition = node.action

local function tick(tree, actions, ctx)
	node[tree.type](tree, actions, ctx)
end

return tick

