local isRunning = true
local allowedPaint = true
local currentScreen = "list"
local infoPath = "MOGOS/System/Programs/Elevator.app/Assets/.Info/info.set"
local mainMapPath = "MOGOS/System/Programs/Elevator.app/Assets/Maps/elevator.map"
local elevatorList = {}

function Exit()
	isRunning = false
end

local function loadSettings()
	for i = 1, #elevatorList do

	end
end

function swapScreen(screen)
	if (screen == "settings") then
		allowedPaint = false
		if not (currentTool == "Load") then currentSlot = "None" end
		DisplayAPI.replaceGUI(mainMapPath, 2)
		currentScreen = "settings"
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		DisplayAPI.drawText(currentSlot, 10, 2, 1, 128)
	elseif (screen == "paint") then
		redraw()
		currentScreen = "paint"
		if (selectStage == 1) then
			paintutils.drawPixel(sX1, sY1, selectColor1)
		elseif (selectStage == 2) then
			paintutils.drawPixel(sX1, sY1, selectColor1)
			paintutils.drawPixel(sX2, sY2, selectColor2)
		end
		allowedPaint = true
	end
end

function selectSlot(slot)
	if (currentSlot == slot) then
		currentSlot = "None"
	else
		currentSlot = slot
	end
	paintutils.drawFilledBox(10, 2, 20, 2, 256)
	DisplayAPI.drawText(currentSlot, 10, 2, 1, 128)
end

function wipeSlot()
	if (fs.exists(saveDirectory..currentSlot..picExt)) and not (currentSlot == "None") then
		fs.delete(saveDirectory..currentSlot..picExt)
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		DisplayAPI.drawText("Wiped", 10, 2, 1, 128)
	end
end

local function touch()
	while isRunning do
		local event, _, x, y = os.pullEvent()
		if (event == "monitor_touch") or (event == "mouse_click") then
			if (SettingsAPI.overrideFunctions) and not (SettingsAPI.overrideFunctionMap[x][y] == 0 or SettingsAPI.overrideFunctionMap[x][y] == nil) then
				local func, param = DisplayAPI.findParam(SettingsAPI.functionMap[x][y])
				if (param == nil) then _ENV[func]()
				else _ENV[func](param) end
			elseif not (SettingsAPI.overrideFunctions) and not (SettingsAPI.functionMap[x][y] == 0 or SettingsAPI.functionMap[x][y] == nil) then
				local func, param = DisplayAPI.findParam(SettingsAPI.functionMap[x][y])
				if (param == nil) then _ENV[func]()
				else _ENV[func](param) end
			end
		end
	end
end

local function start()
	if (fs.exists(infoPath)) then loadSettings() end
	touch()
end

start()
