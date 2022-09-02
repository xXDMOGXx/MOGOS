local isRunning = true
local barSelected = false
local typedString = ""
local stringPos = 1
local cursorPos = 1
local userPos = 1
local maxLength = 19
local startX = math.ceil(Settings.sizeX / 2) - 11
local startY = math.ceil(Settings.sizeY / 2)
local currentUser = ""
local currentScreen = "users"
local mainMapPath = "MOGOS/System/Programs/Login/Assets/Maps/main"..Settings.mapExt
Settings.assetDict["barPic"] = "/MOGOS/System/Programs/Login/Assets/Images/bar"..Settings.picExt

function checkPassword()
    local passPath = "MOGOS/User/"..currentUser.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storage = string.sub(data, 1, 1)
    if (storage == "1") then
        local storedPass = string.sub(data, 2, -1)
        if (typedString == storedPass) then
            unselectBar()
            Settings.user = currentUser
            Settings.loggedIn = true
            isRunning = false
        else
            unselectBar()
            term.setTextColor(16384)
            term.setBackgroundColor(256)
            term.setCursorPos(startX, startY+2)
            term.write("Incorrect Password!")
        end
    elseif (storage == "2") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(typedString, currentUser, 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                unselectBar()
                Settings.user = currentUser
                Settings.loggedIn = true
                isRunning = false
            else
                unselectBar()
                term.setTextColor(16384)
                term.setBackgroundColor(256)
                term.setCursorPos(startX, startY+2)
                term.write("Incorrect Password!")
            end
        else
            unselectBar()
            term.setTextColor(16384)
            term.setBackgroundColor(256)
            term.setCursorPos(startX, startY+2)
            term.write("Incorrect Password!")
        end
    elseif (storage == "3") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(typedString, currentUser..os.getComputerID(), 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                unselectBar()
                Settings.user = currentUser
                Settings.loggedIn = true
                isRunning = false
            else
                unselectBar()
                term.setTextColor(16384)
                term.setBackgroundColor(256)
                term.setCursorPos(startX, startY+2)
                term.write("Incorrect Password!")
            end
        else
            unselectBar()
            term.setTextColor(16384)
            term.setBackgroundColor(256)
            term.setCursorPos(startX, startY+2)
            term.write("Incorrect Password!")
        end
    else
        unselectBar()
        term.setTextColor(16384)
        term.setBackgroundColor(256)
        term.setCursorPos(startX, startY+2)
        term.write("ERROR: Password Has Been Corrupted!")
    end
end

function selectBar()
    paintutils.drawFilledBox(startX, startY+2, startX + maxLength - 1, startY+2, 256)
    term.setTextColor(32768)
    term.setBackgroundColor(1)
    term.setCursorPos(startX + cursorPos - 1, startY)
    term.setCursorBlink(true)
    barSelected = true
end

function unselectBar()
    term.setCursorBlink(false)
    barSelected = false
end

local function addChar(char)
    local preString
    local postString
    if (#typedString == maxLength - 2) then
        if (cursorPos == 1) then
            preString = ""
        else
            preString = string.sub(typedString, 1, cursorPos - 1)
        end
        if (cursorPos > #typedString) then
            postString = ""
        else
            postString = string.sub(typedString, cursorPos, -1)
        end
        typedString = preString..char..postString
        stringPos = 2
        paintutils.drawFilledBox(startX + cursorPos - 1, startY, startX + maxLength - 1, startY, 1)
        term.setCursorPos(startX + cursorPos - 1, startY)
        term.write(char..postString)
        term.setCursorPos(startX, startY)
        term.write("<")
        cursorPos = cursorPos + 1
    elseif (stringPos >= 2) then
        if (cursorPos == 2) then
            preString = ""
        else
            preString = string.sub(typedString, stringPos + 1, stringPos + cursorPos - 3)
        end
        if (stringPos + cursorPos - 1 > #typedString) then
            postString = ""
        else
            postString = string.sub(typedString, stringPos + cursorPos - 2, stringPos + maxLength - 3)
        end
        local preTypeString = string.sub(typedString, 1, stringPos + cursorPos - 3)
        local postTypeString = string.sub(typedString, stringPos + cursorPos - 2, -1)
        typedString = preTypeString..char..postTypeString
        paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
        term.setCursorPos(startX, startY)
        stringPos = stringPos + 1
        if (stringPos + maxLength - 2 <= #typedString) then
            term.write("<"..preString..char..postString..">")
        else
            term.write("<"..preString..char..postString)
        end
    else
        if (cursorPos == 1) then
            preString = ""
        else
            preString = string.sub(typedString, 1, cursorPos - 1)
        end
        if (cursorPos > #typedString) then
            postString = ""
        else
            if (#typedString >= maxLength - 1) then
                postString = string.sub(typedString, cursorPos, maxLength - 2)
            else
                postString = string.sub(typedString, cursorPos, -1)
            end
        end
        typedString = preString..char..postString
        paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
        term.setCursorPos(startX, startY)
        if (#typedString >= maxLength - 1) then
            term.write(preString..char..postString..">")
        else
            term.write(preString..char..postString)
        end
        cursorPos = cursorPos + 1
    end
    term.setCursorPos(startX + cursorPos - 1, startY)
end

local function deleteChar()
    if (#typedString == maxLength) then
        local preString
        local postString
        if (cursorPos == 2) then
            preString = ""
        else
            preString = string.sub(typedString, 1, stringPos + cursorPos - 4)
        end
        if (stringPos + cursorPos - 1 > #typedString) then
            postString = ""
        else
            postString = string.sub(typedString, stringPos + cursorPos - 2, -1)
        end
        typedString = preString..postString
        paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
        term.setCursorPos(startX, startY)
        term.write(preString..postString)
        stringPos = 1
    elseif (stringPos >= 2) then
        local preString
        local postString
        preString = string.sub(typedString, stringPos - 1, stringPos + cursorPos - 4)
        if (stringPos + cursorPos - 1 > #typedString) then
            postString = ""
        else
            postString = string.sub(typedString, stringPos + cursorPos - 2, stringPos + maxLength - 3)
        end
        local preTypeString = string.sub(typedString, 1, stringPos + cursorPos - 4)
        local postTypeString = string.sub(typedString, stringPos + cursorPos - 2, -1)
        typedString = preTypeString..postTypeString
        paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
        term.setCursorPos(startX, startY)
        stringPos = stringPos - 1
        if (stringPos + maxLength - 2 <= #typedString) then
            term.write("<"..preString..postString..">")
        else
            term.write("<"..preString..postString)
        end
    else
        if (cursorPos ~= 1) then
            local preString
            local postString
            if (cursorPos == 2) then
                preString = ""
            else
                preString = string.sub(typedString, 1, cursorPos - 2)
            end
            if (cursorPos > #typedString) then
                postString = ""
            else
                if (#typedString >= maxLength - 1) then
                    postString = string.sub(typedString, cursorPos, maxLength)
                else
                    postString = string.sub(typedString, cursorPos, -1)
                end
            end
            typedString = preString..postString
            paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
            cursorPos = cursorPos - 1
            term.setCursorPos(startX, startY)
            if (#typedString >= maxLength - 1) then
                term.write(preString..postString..">")
            else
                term.write(preString..postString)
            end
        end
    end
    term.setCursorPos(startX + cursorPos - 1, startY)
end

local function moveLeft()
    if (cursorPos ~= 1) then
        if (cursorPos == 2) then
            if (stringPos == 2) then
                local subString = string.sub(typedString, stringPos - 1, stringPos + maxLength - 3)
                paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
                term.setCursorPos(startX, startY)
                term.write(subString..">")
                stringPos = stringPos - 1
            elseif (stringPos > 2) then
                local subString = string.sub(typedString, stringPos - 1, stringPos + maxLength - 4)
                paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
                term.setCursorPos(startX, startY)
                term.write("<"..subString..">")
                stringPos = stringPos - 1
            else
                cursorPos = cursorPos - 1
            end
        else
            cursorPos = cursorPos - 1
        end
        term.setCursorPos(startX + cursorPos - 1, startY)
    end
end

local function moveRight()
    if (cursorPos ~= maxLength) then
        if (cursorPos == maxLength - 1) then
            if (stringPos + cursorPos - 1 == #typedString) then
                local subString = string.sub(typedString, stringPos - 1, stringPos + maxLength - 4)
                paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
                term.setCursorPos(startX, startY)
                term.write("<"..subString)
                stringPos = stringPos + 1
            elseif (stringPos + cursorPos - 1 < #typedString) then
                local subString
                if (stringPos == 1) then
                    term.setCursorPos(startX, startY)
                    term.write("<")
                else
                    subString = string.sub(typedString, stringPos - 1, stringPos + maxLength - 4)
                    paintutils.drawFilledBox(startX, startY, startX + maxLength - 1, startY, 1)
                    term.setCursorPos(startX, startY)
                    term.write("<"..subString..">")
                end
                stringPos = stringPos + 1
            else
                cursorPos = cursorPos + 1
            end
        else
            if (cursorPos <= #typedString) then
                cursorPos = cursorPos + 1
            end
        end
        term.setCursorPos(startX + cursorPos - 1, startY)
    end
end

local function listUsers()
    local userPath = "MOGOS/User/"
    local users = fs.list(userPath)
    if (#users > 1) then
        local midX = math.ceil(Settings.sizeX / 2)
        local midY = math.ceil(Settings.sizeY / 2)
        if (#users == 2) then
            paintutils.drawFilledBox(midX - 9, midY - 3, midX + 9, midY - 1, 128)
            Display.drawText(users[1], midX - math.floor(#users[1] / 2), midY - 2, 1, 128)
            Display.drawFunction("selectUser("..users[1]..")", midX - 9, midY - 3, midX + 9, midY - 1)
            paintutils.drawFilledBox(midX - 9, midY + 1, midX + 9, midY + 3, 128)
            Display.drawText(users[2], midX - math.floor(#users[2] / 2), midY + 2, 1, 128)
            Display.drawFunction("selectUser("..users[2]..")", midX - 9, midY + 1, midX + 9, midY + 3)
        elseif (#users == 3) then
            paintutils.drawFilledBox(midX - 9, midY - 5, midX + 9, midY - 3, 128)
            Display.drawText(users[1], midX - math.floor(#users[1] / 2), midY - 4, 1, 128)
            Display.drawFunction("selectUser("..users[1]..")", midX - 9, midY - 5, midX + 9, midY - 3)
            paintutils.drawFilledBox(midX - 9, midY - 1, midX + 9, midY + 1, 128)
            Display.drawText(users[2], midX - math.floor(#users[2] / 2), midY, 1, 128)
            Display.drawFunction("selectUser("..users[2]..")", midX - 9, midY - 1, midX + 9, midY + 1)
            paintutils.drawFilledBox(midX - 9, midY + 3, midX + 9, midY + 5, 128)
            Display.drawText(users[3], midX - math.floor(#users[3] / 2), midY + 4, 1, 128)
            Display.drawFunction("selectUser("..users[3]..")", midX - 9, midY + 3, midX + 9, midY + 5)
        else
            paintutils.drawFilledBox(midX - 9, midY - 5, midX + 9, midY - 3, 128)
            Display.drawText(users[userPos], midX - math.floor(#users[userPos] / 2), midY - 4, 1, 128)
            Display.drawFunction("selectUser("..users[userPos]..")", midX - 9, midY - 5, midX + 9, midY - 3)
            paintutils.drawFilledBox(midX - 9, midY - 1, midX + 9, midY + 1, 128)
            Display.drawText(users[userPos+1], midX - math.floor(#users[userPos+1] / 2), midY, 1, 128)
            Display.drawFunction("selectUser("..users[userPos+1]..")", midX - 9, midY - 1, midX + 9, midY + 1)
            paintutils.drawFilledBox(midX - 9, midY + 3, midX + 9, midY + 5, 128)
            Display.drawText(users[userPos+2], midX - math.floor(#users[userPos+2] / 2), midY + 4, 1, 128)
            Display.drawFunction("selectUser("..users[userPos+2]..")", midX - 9, midY + 3, midX + 9, midY + 5)
            if (userPos > 1) then
                paintutils.drawPixel(midX - 1, midY - 7, 32768)
                paintutils.drawPixel(midX, midY - 8, 32768)
                paintutils.drawPixel(midX + 1, midY - 7, 32768)
                Display.drawFunction("scrollUp()", midX - 1, midY - 8, midX + 1, midY - 7)
            end
            if (userPos + 2 < #users) then
                paintutils.drawPixel(midX - 1, midY + 7, 32768)
                paintutils.drawPixel(midX, midY + 8, 32768)
                paintutils.drawPixel(midX + 1, midY + 7, 32768)
                Display.drawFunction("scrollDown()", midX - 1, midY + 7, midX + 1, midY + 8)
            end
        end
    else
        selectUser(users[1])
    end
end

function scrollUp()
    userPos = userPos - 1
    swapScreen("users")
end

function scrollDown()
    userPos = userPos + 1
    swapScreen("users")
end

function selectUser(user)
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

function swapScreen(screen)
    if (screen == "login") then
        Display.replaceGUI(mainMapPath, 2)
        currentScreen = "login"
        local midX = math.ceil(Settings.sizeX / 2)
        Display.drawText(currentUser, midX - math.floor(#currentUser / 2), startY - 4, 1, 128)
    elseif (screen == "users") then
        unselectBar()
        Display.replaceGUI(mainMapPath, 1)
        currentUser = ""
        currentScreen = "users"
        listUsers()
    end
end

local function touch()
    while isRunning do
        local event, key, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            if (Settings.overrideFunctions) and not (Settings.overrideFunctionMap[x][y] == 0 or Settings.overrideFunctionMap[x][y] == nil) then
                local func, param = Display.findParam(Settings.overrideFunctionMap[x][y])
                if (param == nil) then _ENV[func]()
                else _ENV[func](param) end
            elseif not (Settings.overrideFunctions) and not (Settings.functionMap[x][y] == 0 or Settings.functionMap[x][y] == nil) then
                local func, param = Display.findParam(Settings.functionMap[x][y])
                if (param == nil) then _ENV[func]()
                else _ENV[func](param) end
            else
                unselectBar()
            end
        elseif (event == "char") and (barSelected) then
            addChar(key)
        elseif (event == "key") and (barSelected) then
            if (key == keys.enter) then
                checkPassword()
            elseif (key == keys.backspace) then
                deleteChar()
            elseif (key == keys.left) then
                moveLeft()
            elseif (key == keys.right) then
                moveRight()
            end
        end
    end
end

local function start()
    Display.replaceGUI(mainMapPath, 1)
    listUsers()
    touch()
end

start()