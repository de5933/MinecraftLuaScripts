
function isSapling()
	local success, data = turtle.inspect()
	if (success) then
		return data.name == 'minecraft:sapling'
	end
	return nil
end

print(isSapling())
