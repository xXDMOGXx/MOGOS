-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the criticism)
-- !!While this line is here, this OS is an extreme work in progress!!
-- TO DO:
-- 1. Move Functions into separate corresponding API's
-- 2. Create an Installer
-- 3. Add a File System GUI with selection, deletion, and moving
-- 4. Add Settings
-- 5. Recode my paint program to fit in with new gui display and optimize loading for more versatile image position placement
-- 6. Add default programs to come with the computer, or be installed like an app store?
-- 7. Program Ideas: A Clock, Wireless Multiplayer Chess, Casino Games, Pixel RPG
-- 8. Allow putting apps on a desktop with personalized background
-- 9. Create specialized versions of the OS designed to use only 1 program
-- 10. Create Custom Engine for making programs on the OS. This will allow anyone with the OS installed on the computer to make programs

os.loadAPI("MOGOS/System/APIs/SettingsAPI.lua")
os.loadAPI("MOGOS/System/APIs/DisplayAPI.lua")
local isRunning = true
local mainMapPath = "MOGOS/System/Programs/Main/Assets/Maps/mainMAP"

function Exit()
    isRunning = false
    DisplayAPI.clearGUI()
end

function Open(path)
    shell.run(path)
    --	DisplayAPI.replaceGUI(mainMapPath)
end

function switchMode()
    DisplayAPI.clearGUI()
    SettingsAPI.switchMonitor()
    SettingsAPI.sizeX, SettingsAPI.sizeY = term.getSize()
    DisplayAPI.replaceGUI(mainMapPath)
end

local function Touch()
    while isRunning do
        local event, _, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            if not (SettingsAPI.functionMap[x][y] == 0 or SettingsAPI.functionMap[x][y] == nil) then
                local func, param = ""
                if (SettingsAPI.overrideFunctions) and not (SettingsAPI.overrideFunctionMap[x][y] == 0 or SettingsAPI.overrideFunctionMap[x][y] == nil) then
                    func, param = DisplayAPI.findParam(SettingsAPI.overrideFunctionMap[x][y])
                else
                    func, param = DisplayAPI.findParam(SettingsAPI.functionMap[x][y])
                end
                if (param == nil) then
                    _ENV[func]()
                else
                    _ENV[func](param)
                end
            end
        end
    end
end

local function Start()
    DisplayAPI.replaceGUI(mainMapPath)
    Touch()
end

Start()