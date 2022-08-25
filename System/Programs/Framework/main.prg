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

os.loadAPI("MOGOS/System/APIs/Settings.lua")
os.loadAPI("MOGOS/System/APIs/Display.lua")
os.loadAPI("MOGOS/System/APIs/CryptoNet.lua")

local loginScript = "MOGOS/System/Programs/Login/main.prg"
local desktopScript = "MOGOS/System/Programs/Desktop/main.prg"

local function start()
    if (term.isColor()) then
        shell.run(desktopScript)
--        shell.run(loginScript)
--        if (Settings.loggedIn) then
--            shell.run(desktopScript)
--        end
    else
        print("Graphics must be able to be supported to use a graphics user interface. Install MOGOS again on an advanced device")
    end
end

start()