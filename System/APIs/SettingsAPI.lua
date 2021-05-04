monitorMode = false
monitor = nil
_old = nil
sizeX, sizeY = term.getSize()

function switchMonitor()
    if (SettingsAPI.monitorMode) then
        term.redirect(_old)
        SettingsAPI.monitorMode = false
    else
        monitor = peripheral.wrap("top")
        _old = term.redirect(monitor)
        monitor.setTextScale(.5)
        sizeX, sizeY = term.getSize()
        SettingsAPI.monitorMode = true
    end
end

isLowSpace = false
colorMap = {}
textMap = {}
functionMap = {}
paintMap = {}
imageMap = {}
user = "xXDMOGXx"

for row = 1, sizeX do
    colorMap[row] = {}
    textMap[row]= {}
    functionMap[row] = {}
    paintMap[row] = {}
    imageMap[row] = {}
    for column = 1, sizeY do
        colorMap[row][column] = 0
        textMap[row][column] = 0
        functionMap[row][column] = 0
        paintMap[row][column] = 0
        imageMap[row][column] = 0
    end
end