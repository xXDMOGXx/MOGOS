-- Unfinished! OS Being created on GitHub at https://github.com/xXDMOGXx/MOGOS

local setup = 1
local length = 5
local name = tostring(math.random(25565))
for i=1, length-#name do
    name = "0"..name
end
local passPath = "/tempPass"
local cert = ""
local preInstalls = {}

function clear()
    term.clear()
    term.setCursorPos(1,1)
end

function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function startInstall()
    clear()
    print("Downloading System Files")
    if (setup == 1) then
        shell.run("pastebin get MP1fCGU8 MOGOS/System/APIs/Settings.lua")
        shell.run("pastebin get ezy3eZ11 MOGOS/System/APIs/Display.lua")
        shell.run("pastebin get skSLv9sj MOGOS/System/APIs/CryptoNet.lua")
        shell.run("pastebin get sM4w8V6Z MOGOS/System/APIs/Wireless.lua")
        shell.run("pastebin get 41qPd7bg MOGOS/System/Programs/Framework/desktopMain.prg")
        shell.run("pastebin get XJMRu7M7 MOGOS/System/Programs/Login/desktopMain.prg")
        shell.run("pastebin get bKPyH6mz MOGOS/System/Programs/Desktop/desktopMain.prg")
        shell.run("pastebin get pJuEeR2E MOGOS/System/Programs/Desktop/Assets/Maps/main.map")
        shell.run("pastebin get 5JUZYdyG MOGOS/System/Programs/Paint.app/desktopMain.prg")
        shell.run("pastebin get Xre5RUKC MOGOS/System/Programs/Paint.app/info.set")
        shell.run("pastebin get qizK0n4z MOGOS/System/Programs/Paint.app/Assets/Maps/main.map")
        shell.run("pastebin get kS5cvcMb MOGOS/System/Programs/Paint.app/Assets/Images/icon.pic")
        shell.run("pastebin get 5D02sdht MOGOS/System/Programs/Paint.app/Assets/Images/selector.pic")
        shell.run("pastebin get eniq0ZmU MOGOS/System/Programs/Paint.app/Assets/Images/eraser.pic")
        shell.run("pastebin get 6yFxq7rY MOGOS/System/Programs/Paint.app/Assets/Images/colorpicker.pic")
        fs.makeDir("MOGOS/User/"..name.."/Storage/Images")
        if (fs.exists(passPath)) then
            fs.copy(passPath, "MOGOS/User/"..name.."/Settings/.password")
        end
    end
    os.unloadAPI("/CryptoNet.lua")
    for i=1, #preInstalls do
        fs.delete(preInstalls[i])
    end
    clear()
    print("MOGOS Download Complete. Restart Now?")
    print("")
    print("1: Yes")
    print("2: No")
    print("")
    term.write("> ")
    local answer = read()
    if (answer == "1") then
        print("Restarting...")
        os.reboot()
    elseif (answer == "2") then
        clear()
        print("Not Restarting. OS will run on next boot")
        os.sleep(3)
        clear()
    else
        clear()
        print("Invalid Answer")
        print("Not Restarting. OS will run on next boot")
        os.sleep(3)
        clear()
    end
end

local function checkCancel(string)
    string = string or "cancel"
    if (string.lower(string) == "cancel") then
        print("Canceling Install...")
        os.unloadAPI("/CryptoNet.lua")
        for i=1, #preInstalls do
            fs.delete(preInstalls[i])
        end
        os.sleep(1)
        os.reboot()
    end
end

local function preCheck()
    if (fs.exists("MOGOS")) then
        clear()
        print("Previous Install Detected!")
        print("Reinstalling will delete all current MOGOS files on the computer!")
        print("")
        print("1: Continue")
        print("2: Cancel")
        print("")
        term.write("> ")
        local continue = read()
        if (continue == "1") then
            print("Type YES to confirm")
            print("")
            term.write("> ")
            local yes = read()
            if (string.lower(yes) == "yes") then
                print("Deleting Old Files...")
                fs.delete("MOGOS")
                return true
            else
                print("Invalid Answer")
                checkCancel()
            end
        elseif (continue == "2") then
            checkCancel()
        else
            print("Invalid Answer")
            checkCancel()
        end
    else
        return true
    end
end

local function installCert()
    local subAnswer
    print("Do you have a certificate to install? (From a trusted source!)")
    print("")
    print("1: Yes")
    print("2: No")
    print("")
    term.write("> ")
    local cert = read()
    checkCancel(cert)
    clear()
    if (cert == "1") then
        print("Please insert a signed certificate in a floppy disk on disk/, then type OK")
        print("")
        term.write("> ")
        local OK = read()
        checkCancel(OK)
        clear()
        if (string.lower(OK) == "ok") then
            print("Copying...")
            print("Copied!")
            subAnswer = "Loaded"
            os.sleep(1)
        end
    elseif (cert == "2") then
        subAnswer = "None"
    else
        print("Invalid Answer")
        checkCancel()
    end
    clear()
    return subAnswer
end

local function createPassword(name, forced)
    local override = forced or false
    local subAnswerList = {}
    local set
    if (override) then
        set = "1"
    else
        print("")
        print("1: Yes")
        print("2: No")
        print("")
        term.write("> ")
        set = read()
        checkCancel(set)
    end
    clear()
    if (set == "1") then
        local stored
        if (override) then
            stored = override
        else
            print("How do you want the password to be stored?")
            print("")
            print("1: Plaintext")
            print("2: Hash")
            print("3: Hash, ID Locked (Computer Specific)")
            print("   ^^ (Recommended!) ^^")
            print("")
            term.write("> ")
            stored = read()
            checkCancel(stored)
        end
        clear()
        if (stored == "1") then
            table.insert(subAnswerList, "Password Storage: Plaintext")
            print("Please enter a password (Whatever you want)")
            print("")
            term.write("> ")
            local password = read()
            table.insert(subAnswerList, "Password: "..password)
            local file = fs.open(passPath,"w")
            file.write("1")
            file.write(password)
            file.close()
            table.insert(preInstalls, passPath)
        elseif (stored == "2") then
            table.insert(subAnswerList, "Password Storage: Hash")
            print("Please enter a password (Whatever you want)")
            print("")
            term.write("> ")
            local password = read()
            table.insert(subAnswerList, "Password: "..password)
            local file = fs.open(passPath,"w")
            print("Hashing (May take a while) ...")
            file.write("2")
            file.write(textutils.serialize(CryptoNet.sha256.pbkdf2(password, name, 10)))
            file.close()
            table.insert(preInstalls, passPath)
        elseif (stored == "3") then
            table.insert(subAnswerList, "Password Storage: Hash, ID Locked")
            print("Please enter a password (Whatever you want)")
            print("")
            term.write("> ")
            local password = read()
            table.insert(subAnswerList, "Password: "..password)
            local file = fs.open(passPath,"w")
            print("Hashing (May take a while) ...")
            file.write("3")
            file.write(textutils.serialize(CryptoNet.sha256.pbkdf2(password, name..os.getComputerID(), 10)))
            file.close()
            table.insert(preInstalls, passPath)
        else
            print("Invalid Answer")
            checkCancel()
        end
    elseif (set == "2") then
        table.insert(subAnswerList, "Password: None")
    else
        print("Invalid Answer")
        checkCancel()
    end
    clear()
    return subAnswerList
end

local function createUsername()
    print("What name would you like the initial user to be called? (Whatever you want)")
    print("")
    term.write("> ")
    local name = read()
    clear()
    return name
end

if (preCheck()) then
    shell.run("pastebin get skSLv9sj /CryptoNet.lua")
    os.loadAPI("/CryptoNet.lua")
    table.insert(preInstalls, "/CryptoNet.lua")
    clear()
    clear()
    local answerList = {}
    print("Welcome to the MOGOS installer!")
    print("Type Cancel at any option to end installation.")
    print("")
    print("Do you want to enter the advanced setup?")
    print("")
    print("1: Yes")
    print("2: No")
    print("")
    term.write("> ")
    local advanced = read()
    checkCancel(advanced)
    clear()
    if (advanced == "1") then
        table.insert(answerList, "Setup Mode: Advanced")
        print("What type of device are you setting up?")
        print("")
        print("1: General PC")
        print("2: Standalone Program")
        print("3: Server")
        print("4: Certificate Authority")
        print("")
        term.write("> ")
        local device = read()
        checkCancel(device)
        clear()
        if (device == "1") then
            setup = 1
            table.insert(answerList, "Device: General PC")
            name = createUsername()
            table.insert(answerList, "User's Name: "..name)
            print("Would you like to set a password? (Recommended)")
            tableConcat(answerList, createPassword(name))
            table.insert(answerList, "Certificate: "..installCert())
        elseif (device == "2") then
            setup = 2
            table.insert(answerList, "Device: Standalone Program")
            clear()
            print("Will login be enabled?")
            print("")
            print("1: Yes")
            print("2: No")
            print("")
            term.write("> ")
            local login = read()
            checkCancel(login)
            clear()
            if (login == "1") then
                table.insert(answerList, "Login: Enabled")
                name = createUsername()
                table.insert(answerList, "User's Name: "..name)
                print("Would you like to set a password?")
                tableConcat(answerList, createPassword(name))
            elseif (login == "2") then
                table.insert(answerList, "Login: Disabled")
            else
                print("Invalid Answer")
                checkCancel()
            end
            clear()
            print("How will the program be stored?")
            print("")
            print("1: Stay On Floppy Disk")
            print("2: Copied To Computer")
            print("")
            term.write("> ")
            local stored = read()
            checkCancel(stored)
            clear()
            if (stored == "1") then
                table.insert(answerList, "Storage: Stay On Floppy Disk")
                print("Whenever computer starts up, if a valid .app program is in a floppy disk on disk/, it will be loaded")
            elseif (stored == "2") then
                table.insert(answerList, "Storage: Copied To Computer")
                print("Please insert a valid .app program in a floppy disk on disk/, then type OK")
                print("")
                term.write("> ")
                local OK = read()
                checkCancel(OK)
                clear()
                if (string.lower(OK) == "ok") then
                    print("Checking Validity...")
                    print("Copied!")
                    table.insert(answerList, "Program: Loaded")
                    os.sleep(1)
                else
                    print("Invalid Answer")
                    checkCancel()
                end
            else
                print("Invalid Answer")
                checkCancel()
            end
            clear()
            table.insert(answerList, "Certificate: "..installCert())
        elseif (device == "3") then
            setup = 3
            table.insert(answerList, "Device: Server")
            print("What is the server's public name? (Whatever you want)")
            print("")
            term.write("> ")
            name = read()
            table.insert(answerList, "Server Name: "..name)
            clear()
            print("Would you like to set a password? (Highly Recommended!)")
            tableConcat(answerList, createPassword(name))
            print("Do you want to create a certificate to be signed?")
            print("")
            print("1: Yes")
            print("2: No")
            print("")
            term.write("> ")
            local cert = read()
            checkCancel(cert)
            clear()
            if (cert == "1") then
                print("Please insert a floppy disk on disk/, then type OK")
                print("")
                term.write("> ")
                local OK = read()
                checkCancel(OK)
                clear()
                if (string.lower(OK) == "ok") then
                    print("Creating unsigned certificate...")
                    print("Created!")
                    print("Give this floppy to a trusted certificate authority for approval")
                    os.sleep(5)
                    table.insert(answerList, "Certificate: Created")
                end
            elseif (cert == "2") then
                print("Certificate can be created later in settings")
                os.sleep(3)
                table.insert(answerList, "Certificate: Not Created")
            else
                print("Invalid Answer")
                checkCancel()
            end
        elseif (device == "4") then
            setup = 4
            table.insert(answerList, "Device: Certificate Authority")
            print("What is the authority's public name? (Whatever you want)")
            print("")
            term.write("> ")
            name = read()
            table.insert(answerList, "Authority Name: "..name)
            clear()
            print("Would you like to set a password? (Highly Recommended!)")
            tableConcat(answerList, createPassword(name))
            print("Never sign untrusted certificates!")
            print("Creating signiture...")
            os.sleep(3)
            print("Created!")
            os.sleep(3)
        else
            print("Invalid Answer")
            checkCancel()
        end
    elseif (advanced == "2") then
        setup = 1
        table.insert(answerList, "Setup Mode: Simple")
        print("What name would you like to be called? (Whatever you want)")
        print("")
        term.write("> ")
        name = read()
        table.insert(answerList, "Name: "..name)
        clear()
        print("Would you like to set a password? (Recommended)")
        print("")
        print("1: Yes")
        print("2: No")
        print("")
        term.write("> ")
        local set = read()
        checkCancel(set)
        clear()
        if (set == "1") then
            tableConcat(answerList, createPassword(name, "3"))
        elseif (set ~= "2") then
            print("Invalid Answer")
            checkCancel()
        end
    else
        print("Invalid Answer")
        checkCancel()
    end
    clear()
    for i = 1, #answerList do
        print(answerList[i])
    end
    print("")
    print("Is this correct?")
    print("Type YES to confirm")
    print("")
    term.write("> ")
    local yes = read()
    if (string.lower(yes) == "yes") then
        print("Beginning Install...")
        startInstall()
    else
        print("Invalid Answer")
        checkCancel()
    end
end

