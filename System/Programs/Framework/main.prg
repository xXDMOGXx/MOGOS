-- This is an OS for ComputerCraft. It's my first time, so please be gentle (On the harsh criticism). Suggestions for improvement are appreciated though
-- !!While this line is here, this OS is an extreme work in progress!!

-- TO DO (Not in any specific order):

-- !!!!Fix Clear Screen Function and ID issues
-- !!!Change rest of objects over to new format
-- !!!Fix Button Move
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

local function start()
    if (term.isColor()) then
        local loginScript = "MOGOS/System/Programs/Login/main.prg"
        local desktopScript = "MOGOS/System/Programs/Desktop/main.prg"
        shell.run(loginScript)
        if (Settings.loggedIn) then
            --shell.run(desktopScript)
        end
    else
        print("Graphics must be able to be supported to use a graphics user interface. Install MOGOS again on an advanced device")
    end
end

start()