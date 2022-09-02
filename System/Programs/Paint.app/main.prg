local DEFAULT_COLOR_1 = 32768
local color1 = DEFAULT_COLOR_1
local DEFAULT_COLOR_2 = 1
local color2 = DEFAULT_COLOR_2
local sX1, sY1, sX2, sY2 = 0
local selectColor1 = 0
local selectColor2 = 0
local selectStage = 0
local DEFAULT_TOOL = "None"
local currentTool = DEFAULT_TOOL
local currentSlot = "None"
local DEFAULT_BACKGROUND_COLOR = 1
local backgroundColor = DEFAULT_BACKGROUND_COLOR
local isRunning = true
local allowedPaint = true
local currentScreen = "paint"
local DEFAULT_SAVE_DIRECTORY = "MOGOS/User/"..Settings.user.."/Storage/Images/"
local saveDirectory = DEFAULT_SAVE_DIRECTORY
local picExt = Settings.picExt
local appExt = Settings.appExt
local mainMapPath = "MOGOS/System/Programs/Paint.app/Assets/Maps/main"..Settings.mapExt
local tempPicSave = "MOGOS/System/Programs/Paint"..appExt.."/Saves/temp"..picExt
local tempSetSave = "MOGOS/System/Programs/Paint"..appExt.."/Saves/temp"..Settings.setExt
local tempSaveMode = 0
Settings.assetDict["colorpickerPic"] = "/MOGOS/System/Programs/Paint"..appExt.."/Assets/Images/colorpicker"..picExt
Settings.assetDict["eraserPic"] = "/MOGOS/System/Programs/Paint"..appExt.."/Assets/Images/eraser"..picExt
Settings.assetDict["selectorPic"] = "/MOGOS/System/Programs/Paint"..appExt.."/Assets/Images/selector"..picExt

function Exit()
	if (tempSaveMode > 0) then
		saveSettings()
	end
	isRunning = false
end

local function drawPaintMap()
	for row = 1, Settings.sizeX do
		for column = 1, Settings.sizeY do
			if not (Settings.paintMap[row][column] == 0) then
				paintutils.drawPixel(row, column, Settings.paintMap[row][column])
			end
		end
	end
end

local function resetPaintMap()
	Settings.paintMap = {}
	for row = 1, Settings.sizeX do
		Settings.paintMap[row] = {}
		for column = 1, Settings.sizeY do
			Settings.paintMap[row][column] = 0
		end
	end
end

local function redraw()
	Display.clearGUI()
	for row = 1, Settings.sizeX do
		for column = 1, Settings.sizeY do
			paintutils.drawPixel(row, column, backgroundColor)
		end
	end
	Display.addGUI(mainMapPath, 1)
	Display.drawText(currentTool, 40, 5, 1, 128)
	paintutils.drawFilledBox(30, 2, 33, 4, color1)
	paintutils.drawFilledBox(35, 2, 38, 4, color2)
	drawPaintMap()
end

local function loadSettings()
	if (fs.exists(tempSetSave)) then
-- 		tempSaveMode = tonumber(Display.readFileData(tempSetSave, 1))
--		saveDirectory = Display.readFileData(tempSetSave, 2)
--		color1 = tonumber(Display.readFileData(tempSetSave, 3))
--		color2 = tonumber(Display.readFileData(tempSetSave, 4))
--		backgroundColor = tonumber(Display.readFileData(tempSetSave, 5))
	end
end

local function saveSettings()
	local file = fs.open(tempSetSave,"w")
	file.writeLine(tempSaveMode)
	file.writeLine(saveDirectory)
	file.writeLine(color1)
	file.writeLine(color2)
	file.writeLine(backgroundColor)
	file.close()
	if not (Display.emptyCheck()) then
		Display.saveImage(tempPicSave)
	end
end

function swapScreen(screen)
	if (screen == "settings") then
		allowedPaint = false
		if not (currentTool == "Load") then currentSlot = "None" end
		Display.replaceGUI(mainMapPath, 2)
		currentScreen = "settings"
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		Display.drawText(currentSlot, 10, 2, 1, 128)
	elseif (screen == "paint") then
		redraw()
		currentScreen = "paint"
		if (selectStage == 1) then
			paintutils.drawPixel(sX1, sY1, selectColor1)
		elseif (selectStage == 2) then
			paintutils.drawPixel(sX1, sY1, selectColor1)
			paintutils.drawPixel(sX2, sY2, selectColor2)
		end
		allowedPaint = true
	end
end

function resetToDefaults()
	resetPaintMap()
	color1 = DEFAULT_COLOR_1
	color2 = DEFAULT_COLOR_2
	currentTool = DEFAULT_TOOL
	backgroundColor = DEFAULT_BACKGROUND_COLOR
	currentSlot = "None"
	swapScreen("paint")
end

local function paint(x, y)
	if (currentTool == "Color 1") then
		paintutils.drawPixel(x, y, color1)
		Settings.paintMap[x][y] = color1
	elseif (currentTool == "Color 2") then
		paintutils.drawPixel(x, y, color2)
		Settings.paintMap[x][y] = color2
	elseif (currentTool == "Eraser") then
		paintutils.drawPixel(x, y, backgroundColor)
		Settings.paintMap[x][y] = 0
	elseif (currentTool == "Color Picker") and not (Settings.paintMap[x][y] == 0) then
		color2 = Settings.paintMap[x][y]
		paintutils.drawFilledBox(35, 2, 38, 4, color2)
		selectTool("Color 2")
	elseif (currentTool == "Selector") then
		local selectColor = 0
		if (Settings.paintMap[x][y] == 0) then
			if (backgroundColor == 32768 or backgroundColor == 128) then
				selectColor = 1
			else
				selectColor = 32768
			end
		elseif (Settings.paintMap[x][y] == 32768 or Settings.paintMap[x][y] == 128) then
			selectColor = 1
		else
			selectColor = 32768
		end
		if (selectStage == 0) then
			sX1 = x
			sY1 = y
			selectStage = 1
			paintutils.drawPixel(x, y, selectColor)
			selectColor1 = selectColor
		elseif (selectStage == 1) then
			sX2 = x
			sY2 = y
			selectStage = 2
			paintutils.drawPixel(x, y, selectColor)
			selectColor2 = selectColor
		elseif (selectStage == 2) then
			sX1 = x
			sY1 = y
			sX2, sY2 = 0
			selectStage = 1
			redraw()
			paintutils.drawPixel(x, y, selectColor)
			selectColor1 = selectColor
			selectColor2 = 0
		end
	elseif (currentTool == "Load") then
		Display.loadImage(saveDirectory..currentSlot..picExt, x, y, false, "all", false, true)
	end
end

local function fill(x1, y1, x2, y2, color)
	for row = math.min(x1, x2), math.max(x1, x2) do
		for column = math.min(y1, y2), math.max(y1, y2) do
			if (color == 0) then
				paintutils.drawPixel(row, column, backgroundColor)
			else
				paintutils.drawPixel(row, column, color)
			end
			Settings.paintMap[row][column] = color
		end
	end
end

function selectTool(tool)
	if (currentTool == tool) then
		currentTool = "None"
		if (selectStage > 0) then
			sX1, sY1, sX2, sY2 = 0
			selectStage = 0
			redraw()
		end
	elseif (currentTool == "Selector") then
		if (selectStage == 2) then
			if (tool == "Color 1") then
				fill(sX1, sY1, sX2, sY2, color1)
			elseif (tool == "Color 2") then
				fill(sX1, sY1, sX2, sY2, color2)
			elseif (tool == "Eraser") then
				fill(sX1, sY1, sX2, sY2, 0)
			end
		else
			currentTool = tool
			if (selectStage == 1) then
				sX1, sY1, sX2, sY2 = 0
				selectStage = 0
				redraw()
			end
		end
		selectStage = 0
	else
		currentTool = tool
	end
	paintutils.drawFilledBox(40, 5, Settings.sizeX, 5, 256)
	Display.drawText(currentTool, 40, 5, 1, 128)
end

function selectColor(color)
	if (currentTool == "Color 1") then
		color1 = tonumber(color)
	elseif (currentTool == "Color 2") then
		color2 = tonumber(color)
	else
		backgroundColor = tonumber(color)
	end
end

function selectSlot(slot)
	if (currentSlot == slot) then
		currentSlot = "None"
	else
		currentSlot = slot
	end
	paintutils.drawFilledBox(10, 2, 20, 2, 256)
	Display.drawText(currentSlot, 10, 2, 1, 128)
end

function wipeSlot()
	if (fs.exists(saveDirectory..currentSlot..picExt)) and not (currentSlot == "None") then
		fs.delete(saveDirectory..currentSlot..picExt)
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		Display.drawText("Wiped", 10, 2, 1, 128)
	end
end

function save()
	if not (currentSlot == "None") and not (Display.emptyCheck()) then
		if (selectStage == 2) then
			Display.saveImage(saveDirectory..currentSlot..picExt, math.min(sX1, sX2), math.min(sY1, sY2), math.max(sX1, sX2),  math.max(sY1, sY2), true)
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			Display.drawText("Saved", 10, 2, 1, 128)
		else
			Display.saveImage(saveDirectory..currentSlot..picExt)
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			Display.drawText("Saved", 10, 2, 1, 128)
		end
	end
end

function load(mode)
	if not (currentSlot == "None") then
		if (fs.exists(saveDirectory..currentSlot..picExt)) then
			if (mode == "reg") then
				swapScreen("paint")
				Display.loadImage(saveDirectory..currentSlot..picExt, 1, 1, false, "all", true, true)
			elseif (mode == "add") then
				currentTool = "Load"
				swapScreen("paint")
			end
		else
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			Display.drawText("Empty", 10, 2, 1, 128)
		end
	end
end

local function touch()
	while isRunning do
		local event, _, x, y = os.pullEvent()
		if (event == "monitor_touch") or (event == "mouse_click") then
			if (Settings.overrideFunctions) and not (Settings.overrideFunctionMap[x][y] == 0 or Settings.overrideFunctionMap[x][y] == nil) then
				local func, param = Display.findParam(Settings.overrideFunctionMap[x][y])
				if (param == nil) then _ENV[func]()
				else _ENV[func](param) end
			elseif not (Settings.overrideFunctions) and not (Settings.functionMap[x][y] == 0 or Settings.functionMap[x][y] == nil) then
				local func, param = Display.findParam(Settings.functionMap[x][y])
				if (param == nil) then _ENV[func]()
				else _ENV[func](param) end
			elseif (y > 5) and allowedPaint then
				paint(x, y)
				if (tempSaveMode == 2) then
					saveSettings()
				end
			end
		elseif (event == "mouse_drag") then
			if (y > 5) and allowedPaint then
				paint(x, y)
				if (tempSaveMode == 2) then
					saveSettings()
				end
			end
		end
	end
end

local function start()
	loadSettings()
	resetPaintMap()
	redraw()
	if (fs.exists(tempPicSave)) then Display.loadImage(tempPicSave, 1, 1, false, "all", true, true) end
	touch()
end

start()
