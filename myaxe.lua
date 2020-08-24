function main() 
	row(5, 10)
end

function dig()
	turtle.digUp()
	turtle.digDown()
	turtle.dig()
end

function go(x)
	for i = 0, x do
		turtle.forward()
		refuel()
	end
end

function back(x)
	for i = 0, x do
		turtle.back()
	end
end

function tl()
	turtle.turnLeft()
end

function tr()
	turtle.turnRight()
end

function line(x)
	for i = 0, x do
		dig()
		go(1)
	end
	back(x)
end

function row(x, y)
	for i = 0, y do
		tl()
		line(x)
		tr()
		tr()
		line(x)
		tl()
		dig()
		go(1)
	end
end

function refuel()
	if turtle.getFuelLevel() <= 1 then
		turtle.refuel(1)
	end
end

main()