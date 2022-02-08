#!/bin/sh
./lua bt/import.lua $1 > tree.lua
./lua bt/compile.lua tree > jmp.lua
