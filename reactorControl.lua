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

	local status = 'OFF'
	if reactor.getActive() then
		status = 'ON'
	end
	print('Status:' .. status)

	print('Output: ' .. tostring(reactor.getEnergyProducedLastTick()))

	print('Storage: ' .. tostring(reactor.getEnergyStored()) .. ' RF')

	print('Fuel Temp: ' .. tostring(reactor.getFuelTemperature()) .. ' C')

	print('Casing Temp: ' .. tostring(reactor.getCasingTemperature()) .. ' C')

	print('Fuel: ' .. tostring(reactor.getFuelAmount()) .. ' mB')

	print('Fuel Reactivity: ' .. tostring(reactor.getFuelReactivity()) .. ' %')

	print('Waste: ' .. tostring(reactor.getWasteAmount()) .. ' mB')

	print('Max Fuel: ' .. tostring(reactor.getFuelAmountMax()) .. ' mB')


	local rodCount = reactor.getNumberOfControlRods()
	print(rodCount .. ' control rods:')
	for i = 1, rodCount do
		print('   ' .. i .. reactor.getControlRodName(i) .. ':' .. tostring(reactor.getControlRodLevel(i)) .. '%')
	end
end

printReport()