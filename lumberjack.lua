
function isSapling()
	local success, data = turtle.inspect()
	if (success)
		return data.metadata == 'minecraft:sapling'
	end
	return nil
end

isSapling()
