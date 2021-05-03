-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the criticism)
-- !!While this line is here, this OS is an extreme work in progress!!
-- TO DO:
-- 1. Move Functions into separate corresponding API's
-- 2. Create an Installer
-- 3. Add a File System GUI with selection, deletion, and moving
-- 4. Add Settings
-- O. Recode my paint program to fit in with new gui display and optimize loading for more versatile image position placement
-- 6. Add default programs to come with the computer, or be installed like an app store?
-- 6. Program Ideas: A Clock, Wireless Multiplayer Pong, Casino Games, Pixel RPG
-- 7. Allow putting apps on a desktop with personalized background
-- 8. Create specialized versions of the OS designed to use only 1 program
-- 9. Create Custom Engine for making programs on my OS. This will allow anyone with the OS installed on the computer to make programs

os.loadAPI("MOGOS/System/APIs/SettingsAPI")
os.loadAPI("MOGOS/System/APIs/DisplayAPI")
local isRunning = true
local mainMapPath = "MOGOS/System/Programs/Main/Assets/Maps/main.map"

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
    DisplayAPI.replaceGUI(mainMapPath)
    term.setCursorPos(10, 1)
    term.setTextColor(1)
    print("("..SettingsAPI.sizeX..", "..SettingsAPI.sizeY.."): MonitorMode = "..SettingsAPI.monitorMode)
    term.setCursorPos(0, 0)
end

local function Touch()
    while isRunning do
        local event, extra, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            if not (SettingsAPI.functionMap[x][y] == 0 or SettingsAPI.functionMap[x][y] == nil) then
                local func, param = DisplayAPI.findParam(SettingsAPI.functionMap[x][y])
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