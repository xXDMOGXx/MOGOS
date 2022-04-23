function switchMonitor()
    if (monitorMode) then
        term.redirect(term.native())
        monitorMode = false
    else
        monitor = peripheral.wrap("top")
        term.redirect(monitor)
        monitor.setTextScale(.5)
        monitorMode = true
    end
end

overrideFuncions = false
monitorMode = false
monitor = nil
sizeX, sizeY = term.getSize()
isLowSpace = false
DEFAULT_BACKGROUND_COLOR = 1
backgroundColor = DEFAULT_BACKGROUND_COLOR
DEFAULT_UI_COLOR_1 = 256
uiColor1 = DEFAULT_UI_COLOR_1
DEFAULT_UI_COLOR_2 = 128
uiColor2 = DEFAULT_UI_COLOR_2
wifiOn = false
soundOn = false
user = "xXDMOGXx"
colorMap = {}
textMap = {}
functionMap = {}
overrideFunctionMap = {}
imageMap = {}
paintMap = {}

for row = 1, sizeX do
    colorMap[row] = {}
    textMap[row]= {}
    functionMap[row] = {}
    overrideFunctionMap[row] = {}
    imageMap[row] = {}
    paintMap[row] = {}
    for column = 1, sizeY do
        colorMap[row][column] = 0
        textMap[row][column] = 0
        functionMap[row][column] = 0
        overrideFunctionMap[row][column] = 0
        imageMap[row][column] = 0
        paintMap[row][column] = 0
    end
end