local isRunning = true
local userPos = 1
local startX = math.ceil(Settings.sizeX / 2) - 11
local startY = math.ceil(Settings.sizeY / 2)
local currentUser = ""

local function acceptPassword()
    Display.clearScreen()
    Settings.user = currentUser
    Settings.loggedIn = true
    isRunning = false
end

local function denyPassword(denyMessage)
    denyMessage = denyMessage or "Incorrect Password!"
    term.setTextColor(16384)
    term.setBackgroundColor(256)
    term.setCursorPos(startX, startY+2)
    term.write(denyMessage)
end

local function checkPassword(object)
    local text = object.text
    local passPath = "MOGOS/User/"..currentUser.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storage = string.sub(data, 1, 1)
    object:unselect()
    if (storage == "1") then
        local storedPass = string.sub(data, 2, -1)
        if (text == storedPass) then
            acceptPassword()
        else
            denyPassword()
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
                acceptPassword()
            else
                denyPassword()
            end
        else
            acceptPassword()
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
                acceptPassword()
            else
                denyPassword()
            end
        else
            denyPassword()
        end
    else
        denyPassword("ERROR: Password Has Been Corrupted!")
    end
end

local userList = {}

local function swapScreen(screen)
    if (screen == "login") then
        local midX = math.ceil(Settings.sizeX / 2)
        Display.clearScreen()

        local returnButton = Display.Button:new(1, 1, 1, 1)
        returnButton:setBackgroundToNone()
        returnButton:setText("<", 128, 256)
        returnButton:onClick(function() swapScreen("users") end)

        local passwordBarImage = Display.Image:new(Settings.midX-12, Settings.midY-1)
        passwordBarImage:setImage("/MOGOS/System/Programs/Login/Assets/Images/bar"..Settings.picExt)

        local passwordTextBox = Display.TextBox:new(Settings.midX-11, Settings.midY, 19, 1)
        passwordTextBox:setText("Enter Password", 128, 1, true)
        passwordTextBox:setText("", 32768, 1)
        passwordTextBox:setScroll("manual")
        passwordTextBox:setEditable(true)
        passwordTextBox:onEnter(function() checkPassword(passwordTextBox) end)

        local enterButton = Display.Button:new(Settings.midX+8, Settings.midY, 3, 1)
        enterButton:setBackgroundToNone()
        enterButton:onClick(function() checkPassword(passwordTextBox) end)

        local currentUserText = Display.TextBox:new(midX - math.floor(#currentUser / 2), startY - 4, #currentUser, 1)
        currentUserText:setText(currentUser, 1, 128)

        returnButton:show()
        passwordBarImage:show()
        passwordTextBox:show()
        enterButton:show()
        currentUserText:show()
    elseif (screen == "users") then
        Display.clearScreen()
        currentUser = ""
        userList:listUsers()
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
        isRunning = false
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
        local midX = math.ceil(Settings.sizeX / 2)
        local midY = math.ceil(Settings.sizeY / 2)
        if (#users == 2) then
            local userButton1 = Display.Button:new(midX - 9, midY - 3, 19, 3)
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[1], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[1]) end)

            local userButton2 = Display.Button:new(midX - 9, midY + 1, 19, 3)
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[2], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[2]) end)

            userButton1:show()
            userButton2:show()
        elseif (#users == 3) then
            local userButton1 = Display.Button:new(midX - 9, midY - 5, 19, 3)
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[1], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[1]) end)

            local userButton2 = Display.Button:new(midX - 9, midY - 1, 19, 3)
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[2], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[2]) end)

            local userButton3 = Display.Button:new(midX - 9, midY + 3, 19, 3)
            userButton3:setBackgroundToFill(128)
            userButton3:setText(users[3], 1, 128)
            userButton3:onClick(function() userList:selectUser(users[3]) end)

            userButton1:show()
            userButton2:show()
            userButton3:show()
        else
            local userButton1 = Display.Button:new(midX - 9, midY - 5, 19, 3)
            userButton1:setBackgroundToFill(128)
            userButton1:setText(users[userPos], 1, 128)
            userButton1:onClick(function() userList:selectUser(users[userPos]) end)

            local userButton2 = Display.Button:new(midX - 9, midY - 1, 19, 3)
            userButton2:setBackgroundToFill(128)
            userButton2:setText(users[userPos+1], 1, 128)
            userButton2:onClick(function() userList:selectUser(users[userPos+1]) end)

            local userButton3 = Display.Button:new(midX - 9, midY + 3, 19, 3)
            userButton3:setBackgroundToFill(128)
            userButton3:setText(users[userPos+2], 1, 128)
            userButton3:onClick(function() userList:selectUser(users[userPos+2]) end)

            userButton1:show()
            userButton2:show()
            userButton3:show()
            if (userPos > 1) then
                local upButton = Display.Button:new(midX - 1, midY - 8, 3, 2)
                upButton:setBackgroundToImage("/MOGOS/System/Programs/Login/Assets/Images/up"..Settings.picExt)
                upButton:setText(users[userPos+2], 1, 128)
                upButton:onClick(function() userList:scrollUp() end)
            end
            if (userPos + 2 < #users) then
                local upButton = Display.Button:new(midX - 1, midY + 7, 3, 2)
                upButton:setBackgroundToImage("/MOGOS/System/Programs/Login/Assets/Images/down"..Settings.picExt)
                upButton:setText(users[userPos+2], 1, 128)
                upButton:onClick(function() userList:scrollDown() end)
            end
        end
    else
        userList:selectUser(users[1])
    end
end

local function start()
    Display.resetMaps()
    Display.setBackgroundColor(256)
    swapScreen("users")
    Event.startRuntime()
end

start()
