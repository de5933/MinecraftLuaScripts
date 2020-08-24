
function isSapling()
	local success, data = turtle.inspect()
	if (success) then
		return data.metadata == 'minecraft:sapling'
	end
	return nil
end

print(isSapling())
