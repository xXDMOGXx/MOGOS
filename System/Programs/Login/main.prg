local function start()
    local passPath = "MOGOS/User/"..Settings.user.."/Settings/.password"
    local file = fs.open(passPath,"r")
    local data = file.readAll()
    local storage = string.sub(data, 1, 1)
    print("Please enter Password")
    term.write("> ")
    if (storage == "1") then
        local storedPass = string.sub(data, 2, -1)
        if (read() == storedPass) then
            Settings.loggedIn = true
        else
            print("Incorrect Password!")
        end
    elseif (storage == "2") then
        local storedPass = textutils.unserialize(string.sub(data, 2, -1))
        local enteredPass = CryptoNet.sha256.pbkdf2(read(), Settings.user, 10)
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
        local enteredPass = CryptoNet.sha256.pbkdf2(read(), Settings.user..os.getComputerID(), 10)
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

start()