SAPLING = 'minecraft:sapling'
LOG = 'minecraft:log'

function isSapling()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == SAPLING
	end
	return nil
end

function isLog()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == LOG
	end
	return nil
end

function isEmpty()
	local success, data = turtle.inspect()
	return ~success
end

function findItem(name)
	for i = 1, 16 do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		end
	end
	return nil
end

print(isSapling())
print(isLog())
print(isEmpty())
