local isRunning = true
local mainMapPath = "MOGOS/System/Programs/Login/Assets/Maps/main"..Settings.mapExt
Settings.assetDict["barPic"] = "/MOGOS/System/Programs/Login/Assets/Images/bar"..Settings.picExt

local function checkPassword(password)
    local passPath = "MOGOS/User/"..Settings.user.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storage = string.sub(data, 1, 1)
    print("Please enter Password")
    term.write("> ")
    if (storage == "1") then
        local storedPass = string.sub(data, 2, -1)
        if (password == storedPass) then
            Settings.loggedIn = true
        else
            print("Incorrect Password!")
        end
    elseif (storage == "2") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(password, Settings.user, 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                Settings.loggedIn = true
            else
                print("Incorrect Password!")
            end
        else
            print("Incorrect Password!")
        end
    elseif (storage == "3") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(password, Settings.user..os.getComputerID(), 10)
        if (#enteredPass == #storedPass) then
            local correct = true
            for i=1, #storedPass do
                if (enteredPass[i] ~= storedPass[i]) then
                    correct = false
                end
            end
            if (correct) then
                Settings.loggedIn = true
            else
                print("Incorrect Password!")
            end
        else
            print("Incorrect Password!")
        end
    else
        print("ERROR: Password Has Been Corrupted!")
    end

end

function Exit()
    isRunning = false
    Display.clearGUI()
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
    Display.replaceGUI(mainMapPath, 1)
    touch()
end

start()