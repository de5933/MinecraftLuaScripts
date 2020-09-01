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
