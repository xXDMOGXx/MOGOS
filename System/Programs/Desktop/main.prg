local isRunning = true
local mainMapPath = "MOGOS/System/Programs/Desktop/Assets/Maps/main"..Settings.mapExt
local appList = {}
local selectedApp = 0

function Exit()
    isRunning = false
    Display.clearGUI()
end

local function searchApps()
    local programPath = "MOGOS/System/Programs/"
    local programs = fs.list(programPath)
    local extLength = #Settings.appExt
    for i = 1, #programs do
        if (string.sub(programs[i], -extLength, -1) == Settings.appExt) then
            local programName
            local runPath
            local iconPath
            local file = io.open(programPath..programs[i].."/info"..Settings.setExt, "r")
            local count = 0
            for line in file:lines() do
                if string.sub(line, 1, 2) == "N:" then
                    programName = string.sub(line, 3, -1)
                elseif string.sub(line, 1, 2) == "R:" then
                    runPath = programPath..programs[i]..string.sub(line, 3, -1)
                elseif string.sub(line, 1, 2) == "I:" then
                    iconPath = programPath..programs[i]..string.sub(line, 3, -1)
                end
            end
            file:close()
            if (fs.exists(runPath)) then
                table.insert(appList, {programName, runPath, iconPath})
            end
        end
    end
    Settings.varDict["appList"] = appList
end

local function addApps()
    if (#appList > 0) then
        local y = Settings.sizeY-2
        for i = 1, #appList do
            local x = (i*5)-3
            Display.loadImage(appList[i][3], x, y)
            for row = x, x+3 do
                for column = y, y+2 do
                    Settings.functionMap[row][column] = "selectApp("..tostring(i)..")"
                end
            end
        end
    end
end

local function unselectApp()
    selectedApp = 0
    Display.replaceGUI(mainMapPath, 1)
    addApps()
end

function selectApp(app)
    if (selectedApp == tonumber(app)) then
        unselectApp()
    else
        selectedApp = tonumber(app)
        Settings.varDict["selectedApp"] = selectedApp
        Display.addGUI(mainMapPath, 2)
    end
end

function switchMode()
    local monitor = peripheral.find("monitor")
    if (monitor) and not (pocket) then
        Display.clearGUI()
        Display.switchMonitor(monitor)
        Settings.sizeX, Settings.sizeY = term.getSize()
        unselectApp()
    end
end

function Open()
    shell.run(appList[selectedApp][2])
    Settings.assetDict = {}
--    unselectApp()
end

function Edit()
end

local function touch()
    while isRunning do
        local event, _, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            if (Settings.overrideFunctions) and not (Settings.overrideFunctionMap[x][y] == 0 or Settings.overrideFunctionMap[x][y] == nil) then
                local func = load(Settings.overrideFunctionMap[x][y])
                setfenv(func, getfenv())
                func()
            elseif not (Settings.overrideFunctions) and not (Settings.functionMap[x][y] == 0 or Settings.functionMap[x][y] == nil) then
                local func = load(Settings.functionMap[x][y])
                setfenv(func, getfenv())
                func()
            end
        end
    end
end

local function start()
    Display.resetMaps()
    searchApps()
    unselectApp()
    touch()
end

start()