
function isSapling()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == 'minecraft:sapling'
	end
	return nil
end

function find(name)
	for i = 1, 16 do
		local data = turtle.getItemDetail(i)
		if data ~= nil and data.name == name then
			return i
		end
	end
	return nil
end

print(find('minecraft:sapling'))
