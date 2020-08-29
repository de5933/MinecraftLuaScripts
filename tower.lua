
COBBLESTONE = 'minecraft:cobblestone'
COBBLESTONE_STAIR = 'minecraft:stone_stairs'
wallName = COBBLESTONE
landingName = COBBLESTONE
stairName = COBBLESTONE_STAIR
columnName = COBBLESTONE

function findItem(name)
	for i = 1, 16 do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		else
			print('Could not find item: ', name)
		end
	end
	return nil
end

function placeWall()
	turtle.select(findItem(wallName))
	turtle.place()
end

function placeStair()
	turtle.select(findItem(stairName))
	turtle.placeDown()
end

function placeLanding()
	turtle.select(findItem(landingName))
	turtle.placeDown()
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
	turtle.turnLeft()
	turtle.forward()
	turtle.turnRight()
	placeStair()
	turtle.forward()
	placeLanding()
	turtle.turnRight()
	turtle.forward()
	turtle.turnRight()
	turtle.forward()
	turtle.turnLeft()
end

function buildAllWalls()
	buildStairs()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	buildWall()
	turtle.turnRight()
	turtle.up()
	placeColumn()
end

function buildTower(height)
	for i = 0, height do
		print('Level ', i)
		buildAllWalls()
	end
end

buildTower(3)