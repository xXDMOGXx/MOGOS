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
local DEFAULT_SAVE_DIRECTORY = "MOGOS/User/"..SettingsAPI.user.."/Storage/Images/"
local saveDirectory = DEFAULT_SAVE_DIRECTORY
local mainMapPath = "MOGOS/System/Programs/Paint/Assets/Maps/paintMAP"
local tempPicSave = "MOGOS/System/Programs/Paint/Assets/Saves/tempIMG"
local tempSetSave = "MOGOS/System/Programs/Paint/Assets/Saves/tempSET"
local tempSaveMode = 0

local function drawPaintMap()
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			if not (SettingsAPI.paintMap[row][column] == 0) then
				paintutils.drawPixel(row, column, SettingsAPI.paintMap[row][column])
			end
		end
	end
end

local function resetPaintMap()
	SettingsAPI.paintMap = {}
	for row = 1, SettingsAPI.sizeX do
		SettingsAPI.paintMap[row] = {}
		for column = 1, SettingsAPI.sizeY do
			SettingsAPI.paintMap[row][column] = 0
		end
	end
end

local function redraw()
	DisplayAPI.clearGUI()
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			paintutils.drawPixel(row, column, backgroundColor)
		end
	end
	DisplayAPI.addGUI(mainMapPath, 1)
	DisplayAPI.drawText(currentTool, 40, 5, 1, 128)
	paintutils.drawFilledBox(30, 2, 33, 4, color1)
	paintutils.drawFilledBox(35, 2, 38, 4, color2)
	drawPaintMap()
end

local function paint(x, y)
	if (currentTool == "Color 1") then
		paintutils.drawPixel(x, y, color1)
		SettingsAPI.paintMap[x][y] = color1
	elseif (currentTool == "Color 2") then
		paintutils.drawPixel(x, y, color2)
		SettingsAPI.paintMap[x][y] = color2
	elseif (currentTool == "Eraser") then
		paintutils.drawPixel(x, y, backgroundColor)
		SettingsAPI.paintMap[x][y] = 0
	elseif (currentTool == "Color Picker") and not (SettingsAPI.paintMap[x][y] == 0) then
		color2 = SettingsAPI.paintMap[x][y]
		paintutils.drawFilledBox(41, 2, 44, 4, color2)
		selectTool("Color 2")
	elseif (currentTool == "Selector") then
		local selectColor = 0
		if (SettingsAPI.paintMap[x][y] == 0) then
			if (backgroundColor == 32768 or backgroundColor == 128) then
				selectColor = 1
			else
				selectColor = 32768
			end
		elseif (SettingsAPI.paintMap[x][y] == 32768 or SettingsAPI.paintMap[x][y] == 128) then
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
		DisplayAPI.loadImage(saveDirectory..currentSlot, x, y, false, "all", false, true)
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
			SettingsAPI.paintMap[row][column] = color
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
	paintutils.drawFilledBox(40, 5, SettingsAPI.sizeX, 5, 256)
	DisplayAPI.drawText(currentTool, 40, 5, 1, 128)
end

function swapScreen(screen)
	if (screen == "settings") then
		allowedPaint = false
		DisplayAPI.replaceGUI(mainMapPath, 2)
		currentScreen = "settings"
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		DisplayAPI.drawText(currentSlot, 10, 2, 1, 128)
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

function Exit()
	isRunning = false
	if (tempSaveMode > 0) then
		DisplayAPI.saveImage(tempPicSave)
	end
end

function resetToDefaults()
	resetPaintMap()
	color1 = DEFAULT_COLOR_1
	color2 = DEFAULT_COLOR_2
	currentTool = DEFAULT_TOOL
	backgroundColor = DEFAULT_BACKGROUND_COLOR
	saveDirectory = DEFAULT_SAVE_DIRECTORY
	currentSlot = "None"
	redraw()
end

function selectSlot(slot)
	if (currentSlot == slot) then
		currentSlot = "None"
	else
		currentSlot = slot
	end
	paintutils.drawFilledBox(10, 2, 20, 2, 256)
	DisplayAPI.drawText(currentSlot, 10, 2, 1, 128)
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

function save()
	if not (currentSlot == "None") and not (DisplayAPI.emptyCheck()) then
		if (selectStage == 2) then
			DisplayAPI.saveImage(saveDirectory..currentSlot, math.min(sX1, sX2), math.min(sY1, sY2), math.max(sX1, sX2),  math.max(sY1, sY2), true)
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			DisplayAPI.drawText("Saved", 10, 2, 1, 128)
		else
			DisplayAPI.saveImage(saveDirectory..currentSlot)
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			DisplayAPI.drawText("Saved", 10, 2, 1, 128)
		end
	end
end

function load(mode)
	if not (currentSlot == "None") then
		if (fs.exists(saveDirectory..currentSlot)) then
			if (mode == "new") then
				swapScreen("paint")
				DisplayAPI.loadImage(saveDirectory..currentSlot, 1, 1, false, "all", true, true)
			elseif (mode == "add") then
				currentTool = "Load"
				swapScreen("paint")
			end
		else
			paintutils.drawFilledBox(10, 2, 20, 2, 256)
			DisplayAPI.drawText("Empty", 10, 2, 1, 128)
		end
	end
end

function wipeSlot()
	if (fs.exists(saveDirectory..currentSlot)) and not (currentSlot == "None") then
		fs.delete(saveDirectory..currentSlot)
		paintutils.drawFilledBox(10, 2, 20, 2, 256)
		DisplayAPI.drawText("Wiped", 10, 2, 1, 128)
	end
end

local function Touch()
	while isRunning do
		local event, _, x, y = os.pullEvent()
		if (event == "monitor_touch") or (event == "mouse_click") then
			if not (SettingsAPI.functionMap[x][y] == 0 or SettingsAPI.functionMap[x][y] == nil) then
				local func, param = DisplayAPI.findParam(SettingsAPI.functionMap[x][y])
				if (param == nil) then
					_ENV[func]()
				else
					_ENV[func](param)
				end
			elseif (y > 5) and allowedPaint then
				paint(x, y)
			end
		elseif (event == "mouse_drag") then
			if (y > 5) and allowedPaint then
				paint(x, y)
			end
		end
	end
end

local function Start()
	resetPaintMap()
	redraw()
	Touch()
end

Start()
