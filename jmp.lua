local M = {
[1] = {
	id = 1,
	["type"] = "condition",
	["name"] = "bt_holding_green_cube",
	["properties"] = {
		["ud"] = 1,
	},
	failure = nil,
},
[2] = {
	id = 2,
	["type"] = "sequence",
	["mem"] = true,
	children=nil,
},
[3] = {
	id = 3,
	["type"] = "condition",
	["name"] = "bt_hand_free",
	["properties"] = {
		["1"] = 2,
		["xyz"] = 1,
	},
	success = nil,
	failure = nil,
},
[4] = {
	id = 4,
	["type"] = "fallback",
	["mem"] = true,
	children=nil,
},
[5] = {
	id = 5,
	["type"] = "condition",
	["name"] = "bt_close_to_cube",
	success = nil,
	failure = nil,
},
[6] = {
	id = 6,
	["type"] = "condition",
	["name"] = "bt_exist_free_trajectory",
	success = nil,
	failure = nil,
},
[7] = {
	id = 7,
	["type"] = "action",
	["name"] = "bt_approach",
	success = nil,
	failure = nil,
},
[8] = {
	id = 8,
	["type"] = "action",
	["name"] = "bt_pick_cube",
	success = nil,
	failure = nil,
},
[9] = {
	id = 9,
	["type"] = "decorator",
	["name"] = "Repeater",
	["properties"] = {
		["maxLoop"] = 3,
	},
},
}
M[1].failure = M[2]
M[2].children={M[3],M[4],M[8],3,7,8}
M[3].success = M[4]
M[3].failure = M[9]
M[4].children={M[5],M[6],5,7}
M[5].success = M[8]
M[5].failure = M[6]
M[6].success = M[7]
M[6].failure = M[9]
M[7].success = M[8]
M[7].failure = M[9]
M[8].success = M[9]
M[8].failure = M[9]
return M[1]
