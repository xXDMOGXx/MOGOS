-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the harsh criticism). Suggestions for improvement are appreciated though
-- !!While this line is here, this OS is an extreme work in progress!!

-- TO DO (Not in any specific order):

-- !!!Add More context menu options
-- !!Finish Paint app
-- !!Implement partial draw for Text box and Button
-- !!Prevent objects from trying to draw offscreen
-- !!Text box vertical scrolling and sizeY > 1
-- !!Fix Text box growing to text length with setText
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
local userFunctions = {}
local itemFunctions = {}
local itemList = {}
local contextMenu = {}
local numUsers = 0
local selectedItem = 0

local function exit()
    Event.stopRuntime()
    Display.setBackgroundColor(colors.black)
    Display.clearScreen()
end

local function switchMode()
    local monitor = peripheral.find("monitor")
    if (monitor) and not (pocket) then
        Display.clearScreen()
        Display.switchMonitor(monitor)
        itemFunctions:unselectItem()
    end
end

local function swapScreen(screen)
    if (screen == "login") then
        Display.clearScreen()
        if (numUsers > 1) then
            local returnButton = Display.Button:new(1, 1, 1, 1)
            returnButton:setBackgroundToNone()
            returnButton:setText("<", colors.gray, colors.lightGray)
            returnButton:onClick(function() swapScreen("users") end)
            returnButton:show()
        end
        local passwordBarImage = Display.Image:new(-12, -1, "middle", "middle")
        passwordBarImage:setImage("/MOGOS/System/Programs/Framework/Assets/Images/bar"..Settings.picExt)
        passwordBarImage:show()
        local passwordTextBox = Display.TextBox:new(-11, 0, 19, 1, "middle", "middle")
        passwordTextBox:setText("Enter Password", colors.gray, colors.white, true)
        passwordTextBox:setText("", colors.black, colors.white)
        passwordTextBox:setScroll("manual")
        passwordTextBox:setEditable(true)
        passwordTextBox:onEnter(function() passwordFunctions:checkPassword(passwordTextBox) end)
        passwordTextBox:show()
        local enterButton = Display.Button:new(8, 0, 3, 1, "middle", "middle")
        enterButton:setBackgroundToNone()
        enterButton:onClick(function() passwordFunctions:checkPassword(passwordTextBox) end)
        enterButton:show()
        local currentUserText = Display.TextBox:new(-math.floor(#currentUser / 2), startY - 4, #currentUser, 1, "middle")
        currentUserText:setText(currentUser, colors.white, colors.gray)
        currentUserText:show()
    elseif (screen == "users") then
        currentUser = ""
        Display.clearScreen()
        userFunctions:listUsers()
    elseif (screen == "desktop") then
        selectedItem = 0
        itemList = {}
        Display.clearScreen()
        local infoBar = Display.Fill:new(1, 1, Settings.sizeX, 1)
        infoBar:setFillColor(Settings.uiColor1)
        infoBar:show()
        local quickBar = Display.Fill:new(1, -3, Settings.sizeX, 3, "left", "bottom")
        quickBar:setFillColor(Settings.uiColor1)
        quickBar:show()
        local settingsButton = Display.Button:new(1, 1, 1, 1)
        settingsButton:setBackgroundToNone()
        settingsButton:setText("O", colors.white, colors.lightBlue)
        settingsButton:onClick(function() swapScreen("settings") end)
        settingsButton:show()
        local modeButton = Display.Button:new(3, 1, 1, 1)
        modeButton:setBackgroundToNone()
        modeButton:setText("^", colors.white, colors.magenta)
        modeButton:onClick(function() switchMode() end)
        modeButton:show()
        local wifiIndicator = Display.Fill:new(-7, 1, 1, 1, "right")
        if (Settings.wifiOn) then wifiIndicator:setFillColor(colors.lime)
        else wifiIndicator:setFillColor(colors.red) end
        wifiIndicator:show()
        local soundIndicator = Display.Fill:new(-9, 1, 1, 1, "right")
        if (Settings.soundOn) then soundIndicator:setFillColor(colors.lime)
        else soundIndicator:setFillColor(colors.red) end
        soundIndicator:show()
        local currentUserText = Display.TextBox:new(5, 1, #currentUser, 1)
        currentUserText:setText(currentUser, colors.white, colors.gray)
        currentUserText:show()
        local exitButton = Display.Button:new(-1, 1, 1, 1, "right")
        exitButton:setBackgroundToNone()
        exitButton:setText("X", colors.white, colors.red)
        exitButton:onClick(function() exit() end)
        exitButton:show()
        itemFunctions:addDesktopItems()
    end
end

function passwordFunctions:acceptPassword()
    Settings.user = currentUser
    Settings.loggedIn = true
    swapScreen("desktop")
end

function passwordFunctions:denyPassword(denyMessage)
    denyMessage = denyMessage or "Incorrect Password!"
    term.setTextColor(colors.red)
    term.setBackgroundColor(colors.lightGray)
    term.setCursorPos(startX, startY+2)
    term.write(denyMessage)
end

function passwordFunctions:checkPassword(object)
    object:unselect()
    local text = object.text
    local passPath = "MOGOS/User/"..currentUser.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storedPass = textutils.unserialize(data)
    local enteredPass = CryptoNet.sha256.pbkdf2(text, currentUser..os.getComputerID(), 10)
    if (#enteredPass == #storedPass) then
        local correct = true
        for i=1, #storedPass do
            if (enteredPass[i] ~= storedPass[i]) then correct = false end
        end
        if (correct) then passwordFunctions:acceptPassword()
        else passwordFunctions:denyPassword() end
    else passwordFunctions:denyPassword() end
end

function userFunctions:selectUser(user)
    local userPath = "/MOGOS/User/"
    currentUser = user
    if (fs.exists(userPath..currentUser.."/Settings/.password")) then swapScreen("login")
    else
        Settings.user = currentUser
        Settings.loggedIn = true
        swapScreen("desktop")
    end
end

function userFunctions:scrollDown()
    userPos = userPos + 1
    swapScreen("users")
end

function userFunctions:scrollUp()
    userPos = userPos - 1
    swapScreen("users")
end

function userFunctions:listUsers()
    local userPath = "MOGOS/User/"
    local users = fs.list(userPath)
    numUsers = #users
    if (numUsers > 1) then
        if (numUsers == 2) then
            local userButton1 = Display.Button:new(-9, -3, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(colors.gray)
            userButton1:setText(users[1], colors.white, colors.gray)
            userButton1:onClick(function() userFunctions:selectUser(users[1]) end)
            userButton1:show()
            local userButton2 = Display.Button:new(-9, 1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(colors.gray)
            userButton2:setText(users[2], colors.white, colors.gray)
            userButton2:onClick(function() userFunctions:selectUser(users[2]) end)
            userButton2:show()
        elseif (numUsers == 3) then
            local userButton1 = Display.Button:new(-9, -5, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(colors.gray)
            userButton1:setText(users[1], colors.white, colors.black)
            userButton1:onClick(function() userFunctions:selectUser(users[1]) end)
            userButton1:show()
            local userButton2 = Display.Button:new(-9, -1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(colors.gray)
            userButton2:setText(users[2], colors.white, colors.gray)
            userButton2:onClick(function() userFunctions:selectUser(users[2]) end)
            userButton2:show()
            local userButton3 = Display.Button:new(-9, 3, 19, 3, "middle", "middle")
            userButton3:setBackgroundToFill(colors.gray)
            userButton3:setText(users[3], colors.white, colors.gray)
            userButton3:onClick(function() userFunctions:selectUser(users[3]) end)
            userButton3:show()
        else
            local userButton1 = Display.Button:new(-9, -5, 19, 3, "middle", "middle")
            userButton1:setBackgroundToFill(colors.gray)
            userButton1:setText(users[userPos], colors.white, colors.gray)
            userButton1:onClick(function() userFunctions:selectUser(users[userPos]) end)
            userButton1:show()
            local userButton2 = Display.Button:new(-9, -1, 19, 3, "middle", "middle")
            userButton2:setBackgroundToFill(colors.gray)
            userButton2:setText(users[userPos+1], colors.white, colors.gray)
            userButton2:onClick(function() userFunctions:selectUser(users[userPos+1]) end)
            userButton2:show()
            local userButton3 = Display.Button:new(-9, 3, 19, 3, "middle", "middle")
            userButton3:setBackgroundToFill(colors.gray)
            userButton3:setText(users[userPos+2], colors.white, colors.gray)
            userButton3:onClick(function() userFunctions:selectUser(users[userPos+2]) end)
            userButton3:show()
            if (userPos > 1) then
                local upButton = Display.Button:new(-1, -8, 3, 2, "middle", "middle")
                upButton:setBackgroundToImage("/MOGOS/System/Programs/Framework/Assets/Images/up"..Settings.picExt)
                upButton:onClick(function() userFunctions:scrollUp() end)
                upButton:show()
            end
            if (userPos + 2 < numUsers) then
                local downButton = Display.Button:new(-1, 7, 3, 2, "middle", "middle")
                downButton:setBackgroundToImage("/MOGOS/System/Programs/Framework/Assets/Images/down"..Settings.picExt)
                downButton:onClick(function() userFunctions:scrollDown() end)
                downButton:show()
            end
        end
    else
        userFunctions:selectUser(users[1])
    end
end

function itemFunctions:returnExt(itemName)
    local ext
    local extLoc
    for i = #itemName, 2, -1 do
        local char = string.sub(itemName, i, i)
        if (char == ".") then extLoc = i end
    end
    if (extLoc ~= nil) then ext = string.sub(itemName, extLoc, -1) end
    return ext
end

function itemFunctions:displayItem(name, path, icon, type, ext)
    ext = ext or ""
    if (type == "folder") then
        if (ext == "") then table.insert(itemList, {true, name, path})
        else table.insert(itemList, {true, name, path, ext}) end
    elseif (type == "runnable") then table.insert(itemList, {false, name, path, ext}) end
    local itemNumber = #itemList
    local bWidth = 5
    local bHeight = 3
    local locX = 1 + (((itemNumber - 1) % 7) + 1) * (bWidth + 1) - bWidth
    local locY = 2 + math.ceil(itemNumber / 7) * (bHeight + 1) - bHeight
    local itemButton = Display.Button:new(locX, locY, bWidth, bHeight)
    if (icon == "") then itemButton:setBackgroundToFill(colors.white)
    else itemButton:setBackgroundToImage(icon) end
    itemButton:onClick(function() itemFunctions:selectItem(itemNumber) end)
    itemButton:show()
end

function itemFunctions:addDesktopItems()
    local desktopPath = "MOGOS/User/"..currentUser.."/Storage/Desktop/"
    local folderIconPath = ""
    local fileIconPath = ""
    if (fs.exists(desktopPath)) then
        local items = fs.list(desktopPath)
        local numItems = #items
        if (numItems > 21) then numItems = 21 end
        for i = 1, numItems do
            local ext = itemFunctions:returnExt(items[i])
            if (fs.isDir(desktopPath..items[i])) then
                if (ext == Settings.appExt) then
                    local name, iconPath
                    local runPath = ""
                    local file = io.open(desktopPath..items[i].."/info"..Settings.setExt, "r")
                    for line in file:lines() do
                        if string.sub(line, 1, 2) == "N:" then name = string.sub(line, 3, -1)
                        elseif string.sub(line, 1, 2) == "R:" then runPath = desktopPath..items[i]..string.sub(line, 3, -1)
                        elseif string.sub(line, 1, 2) == "I:" then iconPath = desktopPath..items[i]..string.sub(line, 3, -1) end
                    end
                    file:close()
                    if (fs.exists(runPath)) then itemFunctions:displayItem(name, runPath, iconPath, "runnable", ext) end
                else itemFunctions:displayItem(items[i], desktopPath..items[i].."/", folderIconPath, "folder") end
            elseif (ext == Settings.navExt) then
                local file = fs.open(desktopPath..items[i], "r")
                local data = file.readAll()
                file.close()
                if (fs.exists(data)) then
                    local navExt = itemFunctions:returnExt(data)
                    if (fs.isDir(data)) then
                        if (navExt == Settings.appExt) then
                            local name, iconPath
                            local runPath = ""
                            local file = io.open(data.."/info"..Settings.setExt, "r")
                            for line in file:lines() do
                                if string.sub(line, 1, 2) == "N:" then name = string.sub(line, 3, -1)
                                elseif string.sub(line, 1, 2) == "R:" then runPath = data..string.sub(line, 3, -1)
                                elseif string.sub(line, 1, 2) == "I:" then iconPath = data..string.sub(line, 3, -1) end
                            end
                            file:close()
                            if (fs.exists(runPath)) then itemFunctions:displayItem(name, runPath, iconPath, "runnable", ext) end
                        else itemFunctions:displayItem(string.sub(items[i], 1, -1 - #ext), data, folderIconPath, "folder", ext) end
                    else itemFunctions:displayItem(string.sub(items[i], 1, -1 - #ext), data, folderIconPath, "runnable", navExt) end
                end
            elseif (ext ~= nil) then
                itemFunctions:displayItem(string.sub(items[i], 1, -1 - #ext), desktopPath..items[i], fileIconPath, "runnable", ext)
            end
        end
    end
end

function itemFunctions:unselectItem()
    swapScreen("desktop")
end

function itemFunctions:selectItem(item)
    if (selectedItem == item) then itemFunctions:unselectItem()
    else
        itemFunctions:unselectItem()
        selectedItem = item
        local length = Settings.sizeX-11
        if (#itemList[item][2] <= length) then length = #itemList[item][2] end
        contextMenu.nameText = Display.TextBox:new(1, -4, length, 1, "left", "bottom")
        contextMenu.nameText:setText(itemList[item][2], colors.white, colors.gray)
        contextMenu.nameText:setScroll("manual")
        contextMenu.nameText:show()
        if (itemList[item][4] ~= nil) then
            contextMenu.extText = Display.TextBox:new(length + 2, -4, 4, 1, "left", "bottom")
            contextMenu.extText:setText(itemList[item][4], colors.white, colors.gray)
            contextMenu.extText:setScroll("manual")
            contextMenu.extText:show()
        end
        contextMenu.contextBar = Display.Fill:new(-6, 2, 6, Settings.sizeY - 4, "right")
        contextMenu.contextBar:setFillColor(Settings.uiColor2)
        contextMenu.contextBar:show()
        contextMenu.openButton = Display.Button:new(-6, 2, 6, 3, "right")
        contextMenu.openButton:setBackgroundToFill(Settings.uiColor2)
        contextMenu.openButton:setText("Open", colors.black, colors.white)
        contextMenu.openButton:onClick(function() itemFunctions:open() end)
        contextMenu.openButton:show()
    end
end

function itemFunctions:open()
    if (itemList[selectedItem][1]) then return
    else
        Display.clearScreen()
        Event.stopRuntime()
        shell.run(itemList[selectedItem][3])
        --swapScreen('desktop')
        --Event.startRuntime()
    end
end

function itemFunctions:edit()
end

local function start()
    if (term.isColor()) then
        Display.resetMaps()
        Display.setBackgroundColor(Settings.backgroundColor)
        swapScreen("users")
        Event.startRuntime()
    else print("Graphics must be able to be supported to use a graphical user interface. Install MOGOS again on an advanced device") end
end

start()