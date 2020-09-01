--Requirements
local component = require("component")
local gpu = component.gpu
local gui = require("gui")
--Configuration junk
local args = {...}
local prgName = "Nanomachine Control v0.01a"
local version = gui.Version()
local port = 14 --port to communicate to your nanomachines on.

if args[1] == "-h" then
  print("Useage: -h : See this help text.")
  print("        -s : Skip Nanomachine innitializationn")
  os.exit()
end

--Initialize modem and speak to the nanomachines.
local modem = component.modem
	modem.open(port)
	modem.broadcast(port, "nanomachines", "setResponsePort", port)

local function send(command, ...)
  component.modem.broadcast(port, "nanomachines", command, ...)
end

--Button Callbacks from myGui

function exitCallback(guiID, id)
  local result = gui.getYesNo("", "Do you really want to exit?", "")
  if result == true then
    gui.exit()
  end
  gui.displayGui(myGui)
end

function i01_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i01_Off, true)
	send("setInput", 1, true)
end

function i01_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i01_On, true)
	send("setInput", 1, false)
end

function i02_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i02_Off, true)
	send("setInput", 2, true)
end

function i02_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i02_On, true)
	send("setInput", 2, false)
end

function i03_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i03_Off, true)
	send("setInput", 3, true)
end

function i03_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i03_On, true)
	send("setInput", 3, false)
end

function i04_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i04_Off, true)
	send("setInput", 4, true)
end

function i04_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i04_On, true)
	send("setInput", 4, false)
end

function i05_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i05_Off, true)
	send("setInput", 5, true)
end

function i05_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i05_On, true)
	send("setInput", 5, false)
end

function i06_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i06_Off, true)
	send("setInput", 6, true)
end

function i06_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i06_On, true)
	send("setInput", 6, false)
end

function i07_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i07_Off, true)
	send("setInput", 7, true)
end

function i07_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i07_On, true)
	send("setInput", 7, false)
end

function i08_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i08_Off, true)
	send("setInput", 8, true)
end

function i08_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i08_On, true)
	send("setInput", 8, false)
end

function i09_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i09_Off, true)
	send("setInput", 9, true)
end

function i09_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i09_On, true)
	send("setInput", 9, false)
end

function i10_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i10_Off, true)
	send("setInput", 10, true)
end

function i10_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i10_On, true)
	send("setInput", 10, false)
end

function i11_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i11_Off, true)
	send("setInput", 11, true)
end

function i11_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i11_On, true)
	send("setInput", 11, false)
end

function i12_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i12_Off, true)
	send("setInput", 12, true)
end

function i12_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i12_On, true)
	send("setInput", 12, false)
end

function i13_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i13_Off, true)
	send("setInput", 13, true)
end

function i13_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i13_On, true)
	send("setInput", 13, false)
end

function i14_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i14_Off, true)
	send("setInput", 14, true)
end

function i14_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i14_On, true)
	send("setInput", 14, false)
end

function i15_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i15_Off, true)
	send("setInput", 15, true)
end

function i15_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i15_On, true)
	send("setInput", 15, false)
end

function i16_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i16_Off, true)
	send("setInput", 16, true)
end

function i16_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i16_On, true)
	send("setInput", 16, false)
end

function i17_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i17_Off, true)
	send("setInput", 17, true)
end

function i17_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i17_On, true)
	send("setInput", 17, false)
end

function i18_OnCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i18_Off, true)
	send("setInput", 18, true)
end

function i18_OffCallback(guiID, id)
	gui.setEnable(guiID, id, false)
	gui.setEnable(guiID, i18_On, true)
	send("setInput", 18, false)
end

function aboutCallback(guiID, id)
	local msg1 = "Nanomachine Control"
	local msg2 = "Version 0.01a"
	local msg3 = "By RandomRedMage"
	gui.showMsg(msg1, msg2, msg3)
	gui.displayGui(myGui)
end

function initOver(guiID, id)
	gui.clearScreen()
	gui.displayGui(myGui)
	gui.setTop(prgName)
	gui.setBottom("libGui v" .. version)
	while true do
		gui.runGui(myGui)
	end
end

--GUI features.

myGui = gui.newGui(2, 2, 78, 23, true, "Main")

nanoInfo = gui.newFrame(myGui, 2, 1, 31, 11, "Information.")
label1 = gui.newLabel(myGui, 4, 3, "  Nanomachines son, you can")
label2 = gui.newLabel(myGui, 4, 4, "activate and deactivate the")
label3 = gui.newLabel(myGui, 4, 5, "different  index  positions")
label4 = gui.newLabel(myGui, 4, 6, "to aquire different effects")
label5 = gui.newLabel(myGui, 4, 7, "ranging from Night Vision, ")
label6 = gui.newLabel(myGui, 4, 8, "to fire resistence and more")
label7 = gui.newLabel(myGui, 4, 9, " use at own risk.")

i01_On = gui.newButton(myGui, 46, 1, "Input 01 ON", i01_OnCallback)
i01_Off = gui.newButton(myGui, 60, 1, "Input 01 OFF", i01_OffCallback)
gui.setEnable(myGui, i01_Off, false)

i02_On = gui.newButton(myGui, 46, 2, "Input 02 ON", i02_OnCallback)
i02_Off = gui.newButton(myGui, 60, 2, "Input 02 OFF", i02_OffCallback)
gui.setEnable(myGui, i02_Off, false)

i03_On = gui.newButton(myGui, 46, 3, "Input 03 ON", i03_OnCallback)
i03_Off = gui.newButton(myGui, 60, 3, "Input 03 OFF", i03_OffCallback)
gui.setEnable(myGui, i03_Off, false)

i04_On = gui.newButton(myGui, 46, 4, "Input 04 ON", i04_OnCallback)
i04_Off = gui.newButton(myGui, 60, 4, "Input 04 OFF", i04_OffCallback)
gui.setEnable(myGui, i04_Off, false)

i05_On = gui.newButton(myGui, 46, 5, "Input 05 ON", i05_OnCallback)
i05_Off = gui.newButton(myGui, 60, 5, "Input 05 OFF", i05_OffCallback)
gui.setEnable(myGui, i05_Off, false)

i06_On = gui.newButton(myGui, 46, 6, "Input 06 ON", i06_OnCallback)
i06_Off = gui.newButton(myGui, 60, 6, "Input 06 OFF", i06_OffCallback)
gui.setEnable(myGui, i06_Off, false)

i07_On = gui.newButton(myGui, 46, 7, "Input 07 ON", i07_OnCallback)
i07_Off = gui.newButton(myGui, 60, 7, "Input 07 OFF", i07_OffCallback)
gui.setEnable(myGui, i07_Off, false)

i08_On = gui.newButton(myGui, 46, 8, "Input 08 ON", i08_OnCallback)
i08_Off = gui.newButton(myGui, 60, 8, "Input 08 OFF", i08_OffCallback)
gui.setEnable(myGui, i08_Off, false)

i09_On = gui.newButton(myGui, 46, 9, "Input 09 ON", i09_OnCallback)
i09_Off = gui.newButton(myGui, 60, 9, "Input 09 OFF", i09_OffCallback)
gui.setEnable(myGui, i09_Off, false)

i10_On = gui.newButton(myGui, 46, 10, "Input 10 ON", i10_OnCallback)
i10_Off = gui.newButton(myGui, 60, 10, "Input 10 OFF", i10_OffCallback)
gui.setEnable(myGui, i10_Off, false)

i11_On = gui.newButton(myGui, 46, 11, "Input 11 ON", i11_OnCallback)
i11_Off = gui.newButton(myGui, 60, 11, "Input 11 OFF", i11_OffCallback)
gui.setEnable(myGui, i11_Off, false)

i12_On = gui.newButton(myGui, 46, 12, "Input 12 ON", i12_OnCallback)
i12_Off = gui.newButton(myGui, 60, 12, "Input 12 OFF", i12_OffCallback)
gui.setEnable(myGui, i12_Off, false)

i13_On = gui.newButton(myGui, 46, 13, "Input 13 ON", i13_OnCallback)
i13_Off = gui.newButton(myGui, 60, 13, "Input 13 OFF", i13_OffCallback)
gui.setEnable(myGui, i13_Off, false)

i14_On = gui.newButton(myGui, 46, 14, "Input 14 ON", i14_OnCallback)
i14_Off = gui.newButton(myGui, 60, 14, "Input 14 OFF", i14_OffCallback)
gui.setEnable(myGui, i14_Off, false)

i15_On = gui.newButton(myGui, 46, 15, "Input 15 ON", i15_OnCallback)
i15_Off = gui.newButton(myGui, 60, 15, "Input 15 OFF", i15_OffCallback)
gui.setEnable(myGui, i15_Off, false)

i16_On = gui.newButton(myGui, 46, 16, "Input 16 ON", i16_OnCallback)
i16_Off = gui.newButton(myGui, 60, 16, "Input 16 OFF", i16_OffCallback)
gui.setEnable(myGui, i16_Off, false)

i17_On = gui.newButton(myGui, 46, 17, "Input 17 ON", i17_OnCallback)
i17_Off = gui.newButton(myGui, 60, 17, "Input 17 OFF", i17_OffCallback)
gui.setEnable(myGui, i17_Off, false)

i18_On = gui.newButton(myGui, 46, 18, "Input 18 ON", i18_OnCallback)
i18_Off = gui.newButton(myGui, 60, 18, "Input 18 OFF", i18_OffCallback)
gui.setEnable(myGui, i18_Off, false)


aboutButton = gui.newButton(myGui, 56, 21, "About", aboutCallback)
exitButton = gui.newButton(myGui, 65, 21, "Exit", exitCallback)

initGui = gui.newGui(2, 2, 78, 23, true)
initInfo = gui.newFrame(initGui, 28, 9, 22, 5, "Loading...")
initProgress = gui.newProgress(initGui, "center", 11, 18, 18, 0, initOver, true)

-- Starting Point

gui.clearScreen()
gui.setTop(prgName)
gui.setBottom("libGui v" .. version)
local counter = 0

if args[1] == "-s" then
  counter = 18
end

while counter <=18 do
	gui.runGui(initGui)
	counter = counter + 1
	send("setInput", counter, false)
	gui.setValue(initGui, initProgress, counter)
	os.sleep(1)
end