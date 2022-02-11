local M = {
	[1]={
		type="fallback",
		mem=false,
		children=nil,
	},
	[2]={
		type="sequence",
		mem=false,
		children=nil,
	},
	[3]={
		type="fallback",
		mem=true,
		children=nil,
	},
	[4]={
		name="bt_holding_green_cube",
		type="condition",
		properties={
			["ud"] = "1",
		},
	},
	[5]={
		name="bt_close_to_cube",
		type="condition",
	},
	[6]={
		type="sequence",
		mem=true,
		children=nil,
	},
	[7]={
		name="bt_hand_free",
		type="condition",
		properties={
			["xyz"] = "1",
			["1"] = "2",
		},
	},
	[8]={
		name="bt_exist_free_trajectory",
		type="condition",
	},
	[9]={
		name="Repeater",
		type="decorator",
		properties={
			["maxLoop"] = "3",
		},
		children=nil,
	},
	[10]={
		name="bt_pick_cube",
		type="action",
	},
	[11]={
		name="bt_approach",
		type="action",
	},
}
M[1].children={M[4],M[9],}
M[2].children={M[8],M[11],}
M[3].children={M[5],M[2],}
M[6].children={M[7],M[3],M[10],}
M[9].children={M[6],}
return M[1]
