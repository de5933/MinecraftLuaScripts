--[[]
Read reactor information
Eventually this will be a startup script

Set the control rod positions for max efficiency.
MVP: Text readout of data on one monitor
Stretch Goal: Dual monitor setup with graphical readouts
Slowly adjust control rods until the target conditions are met
TargetTemperature?
TargetOutput?
TargetStorage?
]]--

REACTOR_POSITION = 'back'

reactor = peripheral.wrap(REACTOR_POSITION)

function printReport()
	print('Status: ' .. reactor.getActive())

	print('Output: ' .. reactor.getEnergyProducedLastTick())

	print('Storage: ' .. reactor.getEnergyStored() .. ' RF')

	print('Fuel Temp: ' .. reactor.getFuelTemperature() .. ' C')

	print('Casing Temp: ' .. reactor.getCasingTemperature() .. ' C')

	print('Fuel: ' .. reactor.getFuelAmount() .. ' mB')

	print('Fuel Reactivity: ' .. reactor.getFuelReactivity() .. ' %')

	print('Waste: ' .. reactor.getWasteAmount() .. ' mB')

	print('Max Fuel: ' .. reactor.getFuelAmountMax() .. ' mB')


	local rodCount = reactor.getNumberOfControlRods()
	print(rodCount .. ' control rods:')
	for i = 1, rodCount do
		print('   ' .. i .. ' : ' .. reactor.getControlRodLocation(i) .. ':' .. reactor.getControlRodName(i) .. reactor.getControlRodLevel(i) .. '%')
	end
end

printReport()