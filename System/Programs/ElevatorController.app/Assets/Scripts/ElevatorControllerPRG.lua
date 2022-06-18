local isRunning = true
local allowedPaint = true
local currentScreen = "list"
local infoPath = "MOGOS/System/Programs/ElevatorController.app/Assets/.Info/info.set"
local mainMapPath = "MOGOS/System/Programs/ElevatorController.app/Assets/Maps/elevatorcontroller.map"
local elevatorList = {{"xXDMOGXx"}}
local selectedElevator = 0
SettingsAPI.assetDict["up"] = "MOGOS/System/Programs/ElevatorController.app/Assets/Images/up.cpic"
SettingsAPI.assetDict["halt"] = "MOGOS/System/Programs/ElevatorController.app/Assets/Images/halt.cpic"
SettingsAPI.assetDict["down"] = "MOGOS/System/Programs/ElevatorController.app/Assets/Images/down.cpic"

function Exit()
	isRunning = false
end

local function loadSettings()
	if (fs.exists(infoPath)) then
	end
end

local function redraw()
	DisplayAPI.clearGUI()
	DisplayAPI.addGUI(mainMapPath, 1)
end

function swapScreen(screen)
	if (screen == "list") then
		redraw()
		currentScreen = "list"
	elseif (screen == "elevator") then
		DisplayAPI.replaceGUI(mainMapPath, 2)
		DisplayAPI.drawText(elevatorList[selectedElevator][1].."'s Elevator", 3, 1, 1, SettingsAPI.uiColor2)
		currentScreen = "elevator"
	elseif (screen == "add") then

	elseif (screen == "select") then

	elseif (screen == "wait") then

	end
end

function selectElevator(elevatorNum)
	selectedElevator = tonumber(elevatorNum)
	swapScreen("elevator")
end

function addElevator()

end

function elevatorUp()

end

function elevatorDown()

end

function elevatorHalt()

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
	loadSettings()
	redraw()
	touch()
end

start()
