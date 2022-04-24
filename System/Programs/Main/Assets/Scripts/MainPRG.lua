-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the criticism). Suggestions for improvement are appreciated though
-- !!While this line is here, this OS is an extreme work in progress!!
-- TO DO (Not in any specific order):
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
local mainMapPath = "MOGOS/System/Programs/Main/Assets/Maps/main.map"

function Exit()
    isRunning = false
    DisplayAPI.clearGUI()
end

function Open(path)
    shell.run(path)
    DisplayAPI.replaceGUI(mainMapPath)
end

function switchMode()
    DisplayAPI.clearGUI()
    SettingsAPI.switchMonitor()
    SettingsAPI.sizeX, SettingsAPI.sizeY = term.getSize()
    DisplayAPI.replaceGUI(mainMapPath)
end

local function touch()
    while isRunning do
        local event, _, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            if (SettingsAPI.overrideFunctions) and not (SettingsAPI.overrideFunctionMap[x][y] == 0 or SettingsAPI.overrideFunctionMap[x][y] == nil) then
                local func = load(SettingsAPI.overrideFunctionMap[x][y])
                setfenv(func, getfenv())
                func()
            elseif not (SettingsAPI.overrideFunctions) and not (SettingsAPI.functionMap[x][y] == 0 or SettingsAPI.functionMap[x][y] == nil) then
                local func = load(SettingsAPI.functionMap[x][y])
                setfenv(func, getfenv())
                func()
            end
        end
    end
end

local function start()
    DisplayAPI.replaceGUI(mainMapPath)
    touch()
end

start()