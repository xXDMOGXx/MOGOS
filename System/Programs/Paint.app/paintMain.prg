local color1 = colors.black
local color2 = colors.white
local backgroundColor = colors.white
local allowedPaint = true
local smallMode = true
local sX1, sY1, sX2, sY2 = 0
local selectColor1 = 0
local selectColor2 = 0
local selectStage = 0
local currentTool = "None"
local currentSlot = "None"
local numSlots = 8
local tempSaveMode = 0
local paintMap = {}
local toolMenu = {}
local appName = "Paint"..Settings.appExt
local scriptPath = shell.getRunningProgram()
local appPath = string.sub(scriptPath, 1, string.find(scriptPath, "%"..appName) + #appName)
local saveDirectory = appPath.."Saves/"
local settingsFunctions = {}
local settingsSlotText = {}
local loadImage = {}

local function exit()
	Event.stopRuntime()
end

local function saveImage(path, x, y, w, z, isSelImage)
	local tColorX = x or 0
	local tColorY = y or 0
	local bColorX = w or 0
	local bColorY = z or 0
	local isFullImage = isSelImage or false
	local color
	local nextColor
	local numColor = 1
	local file = fs.open(path,"w")
	if not (isFullImage) then
		for column = 1, Settings.sizeY do
			local isBreak = false
			for row = 1, Settings.sizeX do
				if (paintMap[row][column] ~= 0) then
					tColorY = column
					isBreak = true
					break
				end
			end
			if (isBreak) then break end
		end
		for row = 1, Settings.sizeX do
			local isBreak = false
			for column = 1, Settings.sizeY do
				if (paintMap[row][column] ~= 0) then
					tColorX = row
					isBreak = true
					break
				end
			end
			if (isBreak) then break end
		end
		for column = Settings.sizeY, 1, -1 do
			local isBreak = false
			for row = Settings.sizeX, 1, -1 do
				if (paintMap[row][column] ~= 0) then
					bColorY = column
					isBreak = true
					break
				end
			end
			if (isBreak) then break end
		end
		for row = Settings.sizeX, 1, -1 do
			local isBreak = false
			for column = Settings.sizeY, 1, -1 do
				if (paintMap[row][column] ~= 0) then
					bColorX = row
					isBreak = true
					break
				end
			end
			if (isBreak) then break end
		end
	end
	file.write("X"..tColorX.."Y"..tColorY.."W"..bColorX.."Z"..bColorY)
	for row = tColorX, bColorX do
		for column = tColorY, bColorY do
			if (paintMap[row][column] == nil) then nextColor = "0"
			else nextColor = tostring(paintMap[row][column]) end
			if (color == nextColor) then numColor = numColor + 1
			elseif (color ~= nil) then
				file.write("C"..color)
				file.write("N"..tostring(numColor))
				numColor = 1
			end
			color = nextColor
		end
	end
	file.write("C"..color)
	file.write("N"..tostring(numColor))
	file.write("E")
	file.close()
end

local function paintImage(x, y, image)
	for row = 1, #image do
		for column = 1, #image[row] do
			if (image[row][column] ~= 0) then
				if ((row + x - 1) <= Settings.sizeX) and ((column + y - 1) <= Settings.sizeY) then
					paintutils.drawPixel(row+ x - 1, column + y - 1, image[row][column])
					paintMap[row + x - 1][column + y - 1] = image[row][column]
				end
			end
		end
	end
end

local function drawPaintMap()
	for row = 1, Settings.sizeX do
		for column = 1, Settings.sizeY do
			if (paintMap[row][column] ~= 0) then
				paintutils.drawPixel(row, column, paintMap[row][column])
			end
		end
	end
end

local function resetPaintMap()
	paintMap = {}
	for row = 1, Settings.sizeX do
		paintMap[row] = {}
		for column = 1, Settings.sizeY do
			paintMap[row][column] = 0
		end
	end
end

function settingsFunctions:loadSettings()
	if (fs.exists(tempSetSave)) then
-- 		tempSaveMode = tonumber(Display.readFileData(tempSetSave, 1))
--		saveDirectory = Display.readFileData(tempSetSave, 2)
--		color1 = tonumber(Display.readFileData(tempSetSave, 3))
--		color2 = tonumber(Display.readFileData(tempSetSave, 4))
--		backgroundColor = tonumber(Display.readFileData(tempSetSave, 5))
	end
end

function settingsFunctions:saveSettings()
	local file = fs.open(tempSetSave,"w")
	file.writeLine(tempSaveMode)
	file.writeLine(saveDirectory)
	file.writeLine(color1)
	file.writeLine(color2)
	file.writeLine(backgroundColor)
	file.close()
	if not (Display.emptyCheck(paintMap)) then saveImage(tempPicSave) end
end

local function fill(x1, y1, x2, y2, color)
	for row = math.min(x1, x2), math.max(x1, x2) do
		for column = math.min(y1, y2), math.max(y1, y2) do
			if (color == 0) then paintutils.drawPixel(row, column, backgroundColor)
			else paintutils.drawPixel(row, column, color) end
			paintMap[row][column] = color
		end
	end
end

local function selectTool(tool)
	if (currentTool == "Load") then loadImage = {} end
	if (currentTool == tool) or (tool == "None") then
		currentTool = "None"
		if (selectStage == 1) then
			if (paintMap[sX1][sY1] == 0) then paintutils.drawPixel(sX1, sY1, backgroundColor)
			else paintutils.drawPixel(sX1, sY1, paintMap[sX1][sY1]) end
			sX1, sY1 = 0
			selectStage = 0
		elseif (selectStage == 2) then
			if (paintMap[sX1][sY1] == 0) then paintutils.drawPixel(sX1, sY1, backgroundColor)
			else paintutils.drawPixel(sX1, sY1, paintMap[sX1][sY1]) end
			if (paintMap[sX2][sY2] == 0) then paintutils.drawPixel(sX2, sY2, backgroundColor)
			else paintutils.drawPixel(sX2, sY2, paintMap[sX2][sY2]) end
			sX1, sY1, sX2, sY2 = 0
			selectStage = 0
		end
	elseif (currentTool == "Selector") then
		if (selectStage == 2) then
			if (tool == "Color 1") then fill(sX1, sY1, sX2, sY2, color1)
			elseif (tool == "Color 2") then fill(sX1, sY1, sX2, sY2, color2)
			elseif (tool == "Eraser") then fill(sX1, sY1, sX2, sY2, 0) end
		else
			currentTool = tool
			if (selectStage == 1) then
				paintutils.drawPixel(sX1, sY1, backgroundColor)
				sX1, sY1 = 0
				selectStage = 0
			end
		end
		selectStage = 0
	else currentTool = tool end
	toolMenu.toolText:hide()
	toolMenu.toolText:resize(#currentTool, 1)
	toolMenu.toolText:setText(currentTool, colors.white, colors.gray)
	toolMenu.toolText:show()
end

local function paint()
	if (allowedPaint) then
		local event = Event.returnEventLog()
		local x = event[3]
		local y = event[4]
		if (currentTool == "Color 1") then
			paintutils.drawPixel(x, y, color1)
			paintMap[x][y] = color1
		elseif (currentTool == "Color 2") then
			paintutils.drawPixel(x, y, color2)
			paintMap[x][y] = color2
		elseif (currentTool == "Eraser") then
			paintutils.drawPixel(x, y, backgroundColor)
			paintMap[x][y] = 0
		elseif (currentTool == "Picker") and (paintMap[x][y] ~= 0) then
			color2 = paintMap[x][y]
			toolMenu.color2Button:setBackgroundToFill(color2)
			selectTool("Color 2")
		elseif (currentTool == "Selector") then
			local selectColor = 0
			if (paintMap[x][y] == 0) then
				if (backgroundColor == 32768 or backgroundColor == 128) then selectColor = 1
				else selectColor = 32768 end
			elseif (paintMap[x][y] == 32768 or paintMap[x][y] == 128) then selectColor = 1
			else selectColor = 32768 end
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
				if (paintMap[sX1][sY1] == 0) then paintutils.drawPixel(sX1, sY1, backgroundColor)
				else paintutils.drawPixel(sX1, sY1, paintMap[sX1][sY1]) end
				if (paintMap[sX2][sY2] == 0) then paintutils.drawPixel(sX2, sY2, backgroundColor)
				else paintutils.drawPixel(sX2, sY2, paintMap[sX2][sY2]) end
				sX1 = x
				sY1 = y
				sX2, sY2 = 0
				selectStage = 1
				paintutils.drawPixel(x, y, selectColor)
				selectColor1 = selectColor
				selectColor2 = 0
			end
		elseif (currentTool == "Load") then paintImage(x, y, loadImage) end
		if (tempSaveMode == 2) then saveSettings() end
	end
end

local function swapScreen(screen)
	if (screen == "settings") then
		allowedPaint = false
		settingsSlotText = {}
		if (currentTool ~= "Load") then currentSlot = "None" end
		Display.clearScreen()
		Display.setBackgroundColor(colors.lightGray)
		local returnButton = Display.Button:new(1, 1, 1, 1)
		returnButton:setBackgroundToNone()
		returnButton:setText("<", colors.gray, colors.lightGray)
		returnButton:onClick(function() swapScreen("paint") end)
		returnButton:show()
		local newButton = Display.Button:new(1, 3, 6, 3)
		newButton:setBackgroundToFill(colors.gray)
		newButton:setText("New", colors.white, colors.gray)
		newButton:onClick(function() settingsFunctions:resetToDefaults() end)
		newButton:show()
		local saveButton = Display.Button:new(1, 7, 6, 3)
		saveButton:setBackgroundToFill(colors.gray)
		saveButton:setText("Save", colors.white, colors.gray)
		saveButton:onClick(function() settingsFunctions:save() end)
		saveButton:show()
		local loadButton = Display.Button:new(1, 10, 6, 3)
		loadButton:setBackgroundToFill(colors.gray)
		loadButton:setText("Load", colors.white, colors.gray)
		loadButton:onClick(function() settingsFunctions:load("reg") end)
		loadButton:show()
		local addButton = Display.Button:new(1, 13, 6, 3)
		addButton:setBackgroundToFill(colors.gray)
		addButton:setText("Add", colors.white, colors.gray)
		addButton:onClick(function() settingsFunctions:load("add") end)
		addButton:show()
		local wipeButton = Display.Button:new(1, 17, 6, 3)
		wipeButton:setBackgroundToFill(colors.gray)
		wipeButton:setText("Wipe", colors.white, colors.gray)
		wipeButton:onClick(function() settingsFunctions:wipeSlot() end)
		wipeButton:show()
		local slotString = "Current Slot"
		local slotText = Display.TextBox:new(8, 1, #slotString, 1)
		slotText:setText(slotString, colors.black, colors.lightGray)
		slotText:show()
		settingsSlotText = Display.TextBox:new(8, 2, #currentSlot, 1)
		settingsSlotText:setText(currentSlot, colors.gray, colors.lightGray)
		settingsSlotText:show()
		for i=1, numSlots do
			local slotButton = Display.Button:new(8, (i*2)+2, 8, 1)
			slotButton:setBackgroundToFill(colors.gray)
			slotButton:setText("Slot "..i, colors.white, colors.gray)
			slotButton:onClick(function() settingsFunctions:selectSlot("Slot "..i) end)
			slotButton:show()
		end
		local x = 1
		local y = 1
		for i=0, 15 do
			if (x > 4) then
				x = 1
				y = y + 1
			end
			local currentColor = 2^i
			local colorButton = Display.Button:new((x*3)+14, (y*3)+1, 3, 3)
			colorButton:setBackgroundToFill(currentColor)
			colorButton:onClick(function() settingsFunctions:selectColor(currentColor) end)
			colorButton:show()
			x = x + 1
		end
	elseif (screen == "paint") then
		toolMenu = {}
		Display.clearScreen()
		Display.setBackgroundColor(Settings.backgroundColor)
		local canvas
		if (smallMode) then
			toolMenu.toolBar = Display.Fill:new(1, 1, Settings.sizeX, 1)
			toolMenu.toolText = Display.TextBox:new(17, 1, #currentTool, 1)
			toolMenu.selectorButton = Display.Button:new(4, 1, 2, 1)
			toolMenu.selectorButton:setBackgroundToNone()
			toolMenu.selectorButton:setText("[]", colors.white, colors.black)
			toolMenu.eraserButton = Display.Button:new(6, 1, 2, 1)
			toolMenu.eraserButton:setBackgroundToNone()
			toolMenu.eraserButton:setText("--", colors.black, colors.pink)
			toolMenu.pickerButton = Display.Button:new(8, 1, 2, 1)
			toolMenu.pickerButton:setBackgroundToNone()
			toolMenu.pickerButton:setText("O-", colors.black, colors.white)
			toolMenu.color1Button = Display.Button:new(12, 1, 2, 1)
			toolMenu.color2Button = Display.Button:new(14, 1, 2, 1)
			canvas = Display.Button:new(1, 2, Settings.sizeX, Settings.sizeY - 1)
		else
			toolMenu.toolBar = Display.Fill:new(1, 1, Settings.sizeX, 4)
			toolMenu.toolText = Display.TextBox:new(33, 3, #currentTool, 1)
			toolMenu.selectorButton = Display.Button:new(4, 1, 4, 3)
			toolMenu.selectorButton:setBackgroundToImage(appPath.."Assets/Images/selector"..Settings.picExt)
			toolMenu.eraserButton = Display.Button:new(9, 1, 5, 3)
			toolMenu.eraserButton:setBackgroundToImage(appPath.."Assets/Images/eraser"..Settings.picExt)
			toolMenu.pickerButton = Display.Button:new(15, 1, 4, 3)
			toolMenu.pickerButton:setBackgroundToImage(appPath.."Assets/Images/picker"..Settings.picExt)
			toolMenu.color1Button = Display.Button:new(21, 1, 5, 3)
			toolMenu.color2Button = Display.Button:new(27, 1, 5, 3)
			canvas = Display.Button:new(1, 5, Settings.sizeX, Settings.sizeY - 4)
		end
		toolMenu.toolBar:setFillColor(colors.lightGray)
		toolMenu.toolBar:show()
		toolMenu.toolText:setText(currentTool, colors.white, colors.gray)
		toolMenu.toolText:show()
		toolMenu.selectorButton:onClick(function() selectTool("Selector") end)
		toolMenu.selectorButton:show()
		toolMenu.eraserButton:onClick(function() selectTool("Eraser") end)
		toolMenu.eraserButton:show()
		toolMenu.pickerButton:onClick(function() selectTool("Picker") end)
		toolMenu.pickerButton:show()
		toolMenu.color1Button:setBackgroundToFill(color1)
		toolMenu.color1Button:onClick(function() selectTool("Color 1") end)
		toolMenu.color1Button:show()
		toolMenu.color2Button:setBackgroundToFill(color2)
		toolMenu.color2Button:onClick(function() selectTool("Color 2") end)
		toolMenu.color2Button:show()
		canvas:setBackgroundToFill(backgroundColor)
		canvas:onClick(function() paint() end, true)
		canvas:show()
		local settingsButton = Display.Button:new(1, 1, 1, 1)
		settingsButton:setBackgroundToNone()
		settingsButton:setText("O", colors.white, colors.lightBlue)
		settingsButton:onClick(function() swapScreen("settings") end)
		settingsButton:show()
		local exitButton = Display.Button:new(-1, 1, 1, 1, "right")
		exitButton:setBackgroundToNone()
		exitButton:setText("X", colors.white, colors.red)
		exitButton:onClick(function() exit() end)
		exitButton:show()
		drawPaintMap()
		if (selectStage == 1) then paintutils.drawPixel(sX1, sY1, selectColor1)
		elseif (selectStage == 2) then
			paintutils.drawPixel(sX1, sY1, selectColor1)
			paintutils.drawPixel(sX2, sY2, selectColor2)
		end
		allowedPaint = true
	end
end

function settingsFunctions:resetToDefaults()
	color1 = colors.black
	color2 = colors.white
	backgroundColor = colors.white
	selectTool("None")
	resetPaintMap()
	swapScreen("paint")
end

function settingsFunctions:changeSlotText(text)
	settingsSlotText:hide()
	settingsSlotText:resize(#text, 1)
	settingsSlotText:setText(text, colors.gray, colors.lightGray)
	settingsSlotText:show()
end

function settingsFunctions:selectColor(color)
	if (currentTool == "Color 1") then color1 = color
	elseif (currentTool == "Color 2") then color2 = color
	else backgroundColor = color end
	swapScreen("paint")
end

function settingsFunctions:selectSlot(slot)
	if (currentSlot == slot) then currentSlot = "None"
	else currentSlot = slot end
	settingsFunctions:changeSlotText(currentSlot)
end

function settingsFunctions:wipeSlot()
	if (currentSlot ~= "None") then
		if (fs.exists(saveDirectory..currentSlot..Settings.picExt)) then
			fs.delete(saveDirectory..currentSlot..Settings.picExt)
			settingsFunctions:changeSlotText("Wiped")
			Event.startTimer(1, function() settingsFunctions:changeSlotText(currentSlot) end)
		else
			settingsFunctions:changeSlotText("Empty")
			Event.startTimer(1, function() settingsFunctions:changeSlotText(currentSlot) end)
		end
	end
end

function settingsFunctions:save()
	if (currentSlot ~= "None") and not (Display.emptyCheck(paintMap)) then
		local slotFileName = string.lower(string.sub(currentSlot, 1, 4)..string.sub(currentSlot, 6, -1))
		local path = saveDirectory..slotFileName..Settings.picExt
		if (selectStage == 2) then
			saveImage(path, math.min(sX1, sX2), math.min(sY1, sY2), math.max(sX1, sX2),  math.max(sY1, sY2), true)
		else saveImage(path) end
		settingsFunctions:changeSlotText("Saved")
		Event.startTimer(1, function() settingsFunctions:changeSlotText(currentSlot) end)
	end
end

function settingsFunctions:load(mode)
	if (currentSlot ~= "None") then
		local slotFileName = string.lower(string.sub(currentSlot, 1, 4)..string.sub(currentSlot, 6, -1))
		local path = saveDirectory..slotFileName..Settings.picExt
		if (fs.exists(path)) then
			if (mode == "reg") then
				local data = Display.loadRawImage(path, true)
				swapScreen("paint")
				paintImage(data[1], data[2], data[3])
			elseif (mode == "add") then
				loadImage = Display.loadRawImage(path)
				currentTool = "Load"
				swapScreen("paint")
			end
		else
			settingsFunctions:changeSlotText("Empty")
			Event.startTimer(1, function() settingsFunctions:changeSlotText(currentSlot) end)
		end
	end
end

local function start()
	--loadSettings()
	resetPaintMap()
	swapScreen("paint")
	Event.startRuntime()
	--if (fs.exists(tempPicSave)) then Display.loadImage(tempPicSave, 1, 1, false, "all", true, true) end
end

start()
