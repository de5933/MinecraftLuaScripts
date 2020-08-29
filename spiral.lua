-- Spiral Skim
-- Spirals outward from startpoint mining the layer below
-- Also mines any obstacles in front
-- Useful for skimming obsidian from the top of lava

function main(x)
	for i = 1, x do
		print('Bend ', i)
		bend(i)
		bend(i)
	end
end

function bend(distance)
	local x = 0
	turtle.turnRight()
	while x < distance do
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then
			x = x + 1
		else
			print('Unable to move. Trying to refuel')
			tryRefuel()
		end
		if turtle.detectDown() then
			turtle.digDown()
		end
	end
end

function tryRefuel()
	if turtle.getFuelLevel() > 0 then
		return false
	end
	
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel() then
			print('Refuel successful')
			return true
		end
	end
	print('Out of fuel')
	return false
end

main(12)