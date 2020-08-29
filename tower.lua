-- tower.lua
-- Builds a 5x5 cylindrical tower
-- Includes a spiral staircase
--[[ Cross Section:
			 WWW 
			W SLW
			W C W
			W   W
			 WWW 
--]]

-- Use these values to customize the blocks
-- Each level requires 9 walls, 1 landing, 1 stair, and 1 column
wallName = 'minecraft:cobblestone'
landingName = 'minecraft:cobblestone'
stairName = 'minecraft:stone_stairs'
columnName = 'minecraft:cobblestone'

function findItem(name)
	for i = 1, 16 do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		end
	end
	print('Could not find item: ', name)
	return nil
end

function placeWall()
	turtle.select(findItem(wallName))
	turtle.place()
end

function placeStair()
	turtle.select(findItem(stairName))
	turtle.place()
end

function placeLanding()
	turtle.select(findItem(landingName))
	turtle.place()
end

function placeColumn()
	turtle.select(findItem(columnName))
	turtle.placeDown()
end

function buildWall()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	placeWall()
	turtle.turnLeft()
	turtle.turnLeft()
	placeWall()
	turtle.turnRight()
	turtle.back()
	placeWall()
	turtle.back()
end

function buildStairs()
	turtle.forward()
	turtle.turnRight()
	placeLanding()
	turtle.back()
	placeStair()
	turtle.turnLeft()
	turtle.back()
	turtle.turnLeft()
	turtle.back()
	turtle.turnRight()
	turtle.turnRight()
end

function buildAllWalls()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	buildStairs()
	turtle.up()
	placeColumn()
end

function buildTower(height)
	for i = 1, height do
		print('Level ', i)
		buildAllWalls()
	end
end

buildTower(3)