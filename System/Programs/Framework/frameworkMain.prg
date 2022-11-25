-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the harsh criticism). Suggestions for improvement are appreciated though
-- !!While this line is here, this OS is an extreme work in progress!!

-- TO DO (Not in any specific order):

-- !!!!!Solve issue of insecure password storage
-- !!!Change rest of scripts over to new format
-- !!Prevent objects from trying to draw offscreen
-- !!Text box vertical scrolling and sizeY > 1
-- Add a File System GUI with selection, deletion, and moving
-- Add Persistant Settings
-- Add default programs to come with the computer, or be installed like an app store
-- Program Ideas: A Clock, Wireless Multiplayer Chess, Casino Games, Pixel RPG
-- Allow putting apps on a desktop with personalized background
-- Per User Desktop Apps
-- Create specialized versions of the OS designed to use only 1 program
-- Create Server and certificate authority installation options
-- Create Custom Engine for making programs on the OS. This will allow anyone with the OS installed on the computer to make programs
-- Create startup script with animated splash screen

os.loadAPI("MOGOS/System/APIs/Settings.lua")
os.loadAPI("MOGOS/System/APIs/Event.lua")
os.loadAPI("MOGOS/System/APIs/Display.lua")
os.loadAPI("MOGOS/System/APIs/CryptoNet.lua")

local userPos = 1
local startX = Settings.midX - 11
local startY = Settings.midY
local currentUser = ""
local passwordFunctions = {}
local userList = {}
local appList = {}
local selectedApp = 0

local function exit()
    Event.endRuntime()
    Display.setBackgroundColor(colors.black)
    Display.clearScreen()
end

local function switchMode()
    local monitor = peripheral.find("monitor")
    if (monitor) and not (pocket) then
        Display.clearScreen()
        Display.switchMonitor(monitor)
        unselectApp()
    end
end

local function swapScreen(screen)
    if (screen == "login") then
        Display.clearScreen()
        local returnButton = Display.Button:new(1, 1, 1, 1)
        returnButton:setBackgroundToNone()
        returnButton:setText("<", 128, 256)
        returnButton:onClick(function() swapScreen("users") end)
        local passwordBarImage = Display.Image:new(-12, -1, "middle", "middle")
        passwordBarImage:setImage("/MOGOS/System/Programs/Framework/Assets/Images/bar"..Settings.picExt)
        local passwordTextBox = Display.TextBox:new(-11, 0, 19, 1, "middle", "middle")
        passwordTextBox:setText("Enter Password", 128, 1, true)
        passwordTextBox:setText("", 32768, 1)
        passwordTextBox:setScroll("manual")
        passwordTextBox:setEditable(true)
        passwordTextBox:onEnter(function() passwordFunctions:checkPassword(passwordTextBox) end)
        local enterButton = Display.Button:new(8, 0, 3, 1, "middle", "middle")
        enterButton:setBackgroundToNone()
        enterButton:onClick(function() passwordFunctions:checkPassword(passwordTextBox) end)
        local currentUserText = Display.TextBox:new(-math.floor(#currentUser / 2), startY - 4, #currentUser, 1, "middle")
        currentUserText:setText(currentUser, 1, 128)

        returnButton:show()
        passwordBarImage:show()
        passwordTextBox:show()
        enterButton:show()
        currentUserText:show()
    elseif (screen == "users") then
        currentUser = ""
        Display.clearScreen()
        userList:listUsers()
    elseif (screen == "desktop") then
        Display.clearScreen()
        local infoBar = Display.Fill:new(1, 1, Settings.sizeX, 1)
        infoBar:setFillColor(Settings.uiColor1)
        local quickBar = Display.Fill:new(1, -2, Settings.sizeX, 3, "left", "bottom")
        quickBar:setFillColor(Settings.uiColor1)
        local contextBar = Display.Fill:new(-5, 2, 6, Settings.sizeY - 4, "right")
        contextBar:setFillColor(Settings.uiColor2)
        local settingsButton = Display.Button:new(1, 1, 1, 1)
        settingsButton:setBackgroundToNone()
        settingsButton:setText("O", 1, 8)
        settingsButton:onClick(function() swapScreen("settings") end)
        local modeButton = Display.Button:new(3, 1, 1, 1)
        modeButton:setBackgroundToNone()
        modeButton:setText("^", 1, 4)
        modeButton:onClick(function() switchMode() end)
        local wifiIndicator = Display.Fill:new(-6, 1, 1, 1, "right")
        if (Settings.wifiOn) then wifiIndicator:setFillColor(32)
        else wifiIndicator:setFillColor(16384) end
        local soundIndicator = Display.Fill:new(-8, 1, 1, 1, "right")
        if (Settings.soundOn) then soundIndicator:setFillColor(32)
        else soundIndicator:setFillColor(16384) end
        local currentUserText = Display.TextBox:new(5, 1, #currentUser, 1)
        currentUserText:setText(currentUser, 1, 128)
        local exitButton = Display.Button:new(0, 1, 1, 1, "right")
        exitButton:setBackgroundToNone()
        exitButton:setText("X", 1, 16384)
        exitButton:onClick(function() exit() end)

        infoBar:show()
        quickBar:show()
        contextBar:show()
        settingsButton:show()
        modeButton:show()
        wifiIndicator:show()
        soundIndicator:show()
        currentUserText:show()
        exitButton:show()
    end
end

function passwordFunctions:acceptPassword()
    Settings.user = currentUser
    Settings.loggedIn = true
    swapScreen("desktop")
end

function passwordFunctions:denyPassword(denyMessage)
    denyMessage = denyMessage or "Incorrect Password!"
    term.setTextColor(16384)
    term.setBackgroundColor(256)
    term.setCursorPos(startX, startY+2)
    term.write(denyMessage)
end

function passwordFunctions:checkPassword(object)
    local text = object.text
    local passPath = "MOGOS/User/"..currentUser.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storage = string.sub(data, 1, 1)
    object:unselect()
    if (storage == "1") then
        local storedPass = string.sub(data, 2, -1)
        if (text == storedPass) then
            passwordFunctions:acceptPassword()
        else
            passwordFunctions:denyPassword()
        end
    elseif (storage == "2") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(text, currentUser, 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                passwordFunctions:acceptPassword()
            else
                passwordFunctions:denyPassword()
            end
        else
            passwordFunctions:acceptPassword()
        end
    elseif (storage == "3") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(text, currentUser..os.getComputerID(), 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                passwordFunctions:acceptPassword()
            else
                passwordFunctions:denyPassword()
            end
        else
            passwordFunctions:denyPassword()
        end
    else
        passwordFunctions:denyPassword("ERROR: Password Has Been Corrupted!")
    end
end

function userList:selectUser(user)
    local userPath = "/MOGOS/User/"
    currentUser = user
    if (fs.exists(userPath..currentUser.."/Settings/.password")) then
        swapScreen("login")
    else
        Settings.user = currentUser
        Settings.loggedIn = true
        swapScreen("desktop")
    end
end

function userList:scrollDown()
    userPos = userPos + 1
    swapScreen("users")
end

function userList:scrollUp()
    userPos = userPos - 1
    swapScreen("users")
end

function userList:listUsers()
    local userPath = "MOGOS/User/"
    local users = fs.list(userPath)
    if (#users > 1) then
        if (#users == 2) then
            local userButton1 = Display.Button:new(-9, -3, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[1], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[1]) end)
            local userButton2 = Display.Button:new(-9, 1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[2], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[2]) end)

            userButton1:show()
            userButton2:show()
        elseif (#users == 3) then
            local userButton1 = Display.Button:new(-9, -5, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[1], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[1]) end)
            local userButton2 = Display.Button:new(-9, -1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[2], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[2]) end)
            local userButton3 = Display.Button:new(-9, 3, 19, 3, "middle", "middle")
            userButton3:setBackgroundToFill(128)
            userButton3:setText(users[3], 1, 128)
            userButton3:onClick(function() userList:selectUser(users[3]) end)

            userButton1:show()
            userButton2:show()
            userButton3:show()
        else
            local userButton1 = Display.Button:new(-9, -5, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[userPos], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[userPos]) end)
            local userButton2 = Display.Button:new(-9, -1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[userPos+1], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[userPos+1]) end)
            local userButton3 = Display.Button:new(-9, 3, 19, 3, "middle", "middle")
            userButton3:setBackgroundToFill(128)
            userButton3:setText(users[userPos+2], 1, 128)
            userButton3:onClick(function() userList:selectUser(users[userPos+2]) end)

            userButton1:show()
            userButton2:show()
            userButton3:show()
            if (userPos > 1) then
                local upButton = Display.Button:new(-1, -8, 3, 2, "middle", "middle")
                upButton:setBackgroundToImage("/MOGOS/System/Programs/Framework/Assets/Images/up"..Settings.picExt)
                upButton:onClick(function() userList:scrollUp() end)
                upButton:show()
            end
            if (userPos + 2 < #users) then
                local downButton = Display.Button:new(-1, 7, 3, 2, "middle", "middle")
                downButton:setBackgroundToImage("/MOGOS/System/Programs/Framework/Assets/Images/down"..Settings.picExt)
                downButton:onClick(function() userList:scrollDown() end)
                downButton:show()
            end
        end
    else
        userList:selectUser(users[1])
    end
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

function Open()
    shell.run(appList[selectedApp][2])
    Settings.assetDict = {}
    --    unselectApp()
end

function Edit()
end

local function start()
    if (term.isColor()) then
        Display.resetMaps()
        Display.setBackgroundColor(Settings.backgroundColor)
        swapScreen("users")
        Event.startRuntime()
    else
        print("Graphics must be able to be supported to use a graphical user interface. Install MOGOS again on an advanced device")
    end
end

start()