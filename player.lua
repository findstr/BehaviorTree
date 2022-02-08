local M = {}

function M:bt_holding_green_cube(properties, _)
	return "failure"
end

function M:bt_close_to_cube(properties, first)
	return "failure"
end

function M:bt_exist_free_trajectory(properties, first)
	local n
	local n = (self.n or 0) + 1
	self.n = n
	if n < 4 then
		return "running"
	else
		return "success"
	end
end

function M:bt_approach(properties)
	return "success"
end

function M:bt_pick_cube(properties)
	return "success"
end

function M:bt_hand_free(properities)
	return "success"
end

function M:Repeater(properties, result)
	return result
end

return M



