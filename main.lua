local tree = require "tree"
local jmp = require "jmp"
local player = require "player"
local bt
if true then
	tree = jmp
	bt = require "bt.engine"
else
	bt = require "bt.classic"
end
local ctx = bt:new()

for i = 1, 5 do
	print("++++Tick:")
	ctx:tick(tree[1], player)
end


