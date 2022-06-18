local isRunning = true
local allowedPaint = true
local currentScreen = "power"
local infoPath = "MOGOS/System/Programs/Elevator.app/Assets/.Info/info.set"
local mainMapPath = "MOGOS/System/Programs/Elevator.app/Assets/Maps/elevator.map"
local playerList = {}

local function loadSettings()
	if (fs.exists(infoPath)) then
	end
end

function swapScreen(screen)
	if (screen == "power") then

	elseif (screen == "pairing") then

	elseif (screen == "help") then

	elseif (screen == "players") then

	elseif (screen == "logs") then

	end
end

function logPlayer(playerNum)

end

function suspendPlayer(playerNum)

end

function removePlayer(playerNum)

end

function pair()

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
	touch()
end

start()
