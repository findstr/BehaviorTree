local tree = require "tree"
local jmp = require "jmp"
local player = require "player"
--local tree = jmp
--local bt = require "bt.engine"
local bt = require "bt.classic"
for i = 1, 5 do
	print("++++Tick:")
	bt(tree, player, player)
end


