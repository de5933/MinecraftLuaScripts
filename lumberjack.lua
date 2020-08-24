function checkGrowth()
	local success, data = turtle.inspect()
	print("Block name: ", data.name)
	print("Block metadata: ", data.metadata)
end

checkGrowth()
