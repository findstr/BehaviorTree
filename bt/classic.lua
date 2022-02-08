local M = {}
local mt = {__index = M}
local setmetatable = setmetatable

local node = {}

local function exec(func)
	return function(ctx, root, obj)
		local mem = root.mem
		if mem then
			local c = ctx[root]
			if c then
				local res = node[c.type](ctx, c, obj)
				if res ~= "running" then
					ctx[root] = nil
				end
				return res
			end
		end
		local res, c = func(ctx, root, obj)
		if mem then
			ctx[root] = c
		end
		return res
	end
end

node.sequence = exec(function(ctx, root, obj)
	local children = root.children
	for i = 1, #children do
		local c = children[i]
		local res = node[c.type](ctx, c, obj)
		if res == "running" then
			return "running", c
		elseif res == "failure" then
			return "failure", nil
		end
	end
	return "success", nil
end)

node.fallback = exec(function(ctx, root, obj)
	local children = root.children
	for i = 1, #children do
		local c = children[i]
		local res = node[c.type](ctx, c, obj)
		if res == "running" then
			return "running", c
		elseif res == "success" then
			return "success", nil
		end
	end
	return "failure", nil
end)

node.decorator = function(ctx, root, obj)
	local child = root.children[1]
	local res = node[child.type](ctx, child, obj)
	local func = obj[root.name]
	local res = func(obj, root.properties, res)
	return res
end

node.action = function(ctx, root, obj)
	local func = obj[root.name]
	local res = func(obj, root.properties)
	return res
end

node.condition = node.action

function M:new()
	return setmetatable({}, mt)
end

function M:tick(tree, obj)
	node[tree.type](self, tree, obj, true)
end


return M

