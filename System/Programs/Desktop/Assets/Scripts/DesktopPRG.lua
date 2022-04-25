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
local mainMapPath = "MOGOS/System/Programs/Desktop/Assets/Maps/desktop"..SettingsAPI.mapExt
local appList = {}
local selectedApp = 0

function Exit()
    isRunning = false
    DisplayAPI.clearGUI()
end

local function searchApps()
    local programPath = "MOGOS/System/Programs/"
    local programs = fs.list(programPath)
    local extLength = #SettingsAPI.appExt
    for i = 1, #programs do
        if (string.sub(programs[i], -extLength, -1) == SettingsAPI.appExt) then
            local programName = string.sub(programs[i], 1, -extLength-1)
            local mainPath = programPath..programs[i].."/Assets/Scripts/"..programName..SettingsAPI.prgExt
            if (fs.exists(mainPath)) then
                local iconPath = programPath..programs[i].."/Assets/Images/icon"..SettingsAPI.picExt
                table.insert(appList, {programName, mainPath, iconPath})
            end
        end
    end
    SettingsAPI.varDict["appList"] = appList
end

local function addApps()
    if (#appList > 0) then
        for i = 1, #appList do
            local x = (i*5)-3
            local y = (i*4)-1
            DisplayAPI.loadImage(appList[i][3], x, y)
            for row = x, x+4 do
                for column = y, y+3 do
                    SettingsAPI.functionMap[row][column] = "selectApp("..tostring(i)..")"
                end
            end
        end
    end
end

local function unselectApp()
    selectedApp = 0
    DisplayAPI.replaceGUI(mainMapPath, 1)
    addApps()
end

function selectApp(app)
    if (selectedApp == tonumber(app)) then
        unselectApp()
    else
        selectedApp = tonumber(app)
        SettingsAPI.varDict["selectedApp"] = selectedApp
        DisplayAPI.addGUI(mainMapPath, 2)
    end
end

function switchMode()
    local monitor = peripheral.find("monitor")
    if (monitor) and not (pocket) then
        DisplayAPI.clearGUI()
        DisplayAPI.switchMonitor(monitor)
        SettingsAPI.sizeX, SettingsAPI.sizeY = term.getSize()
        unselectApp()
    end
end

function Open()
    shell.run(appList[selectedApp][2])
    SettingsAPI.assetDict = {}
    unselectApp()
end

function Edit()

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
    if (term.isColor()) then
        DisplayAPI.resetMaps()
        searchApps()
        unselectApp()
        touch()
    else
        print("Graphics must be able to be supported to use a graphics user interface. Install MOGOS again on an advanced device")
    end
end

start()