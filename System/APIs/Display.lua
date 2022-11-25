local takenIDs = {}
local objectList = {}

function log(path, message)
	local file = fs.open(path,"a")
	file.write(message)
	file.close()
end

function switchMonitor(monitor)
	if (Settings.monitorMode) then
		term.redirect(term.native())
		Settings.monitorMode = false
	else
		term.redirect(monitor)
		monitor.setTextScale(.5)
		Settings.monitorMode = true
	end
	Settings.sizeX, Settings.sizeY = term.getSize()
	Settings.midX = math.ceil(Settings.sizeX / 2)
	Settings.midY = math.ceil(Settings.sizeY / 2)
end

function setBackgroundColor(color)
	Settings.backgroundColor = color
	paintutils.drawFilledBox(1, 1, Settings.sizeX, Settings.sizeY, Settings.backgroundColor)
	drawScreen()
end

local function readFileData(path, line)
	local line = line or "all"
	if (fs.exists(path)) then
		local file = fs.open(path,"r")
		local data
		if (line == "all") then
			data = file.readAll()
		else
			for _ = 1, line do
				data = file.readLine()
			end
		end
		file.close()
		return data
	else
		return false
	end
end

function findParam(dataString)
	local stringLength = #dataString
	local func
	local param
	for loc = 1, stringLength do
		local char = string.sub(dataString, loc, loc)
		if (char == "(") then
			if (stringLength - loc > 1) then
				param = string.sub(dataString, loc + 1, stringLength - 1)
			end
			func = string.sub(dataString, 1, loc -1)
		end
	end
	return func, param
end

function emptyCheck()
	for row = 1, Settings.sizeX do
		for column = 1, Settings.sizeY do
			if not (Settings.paintMap[row][column] == 0) then
				return false
			end
		end
	end
	return true
end

function resetMaps()
	for row = 1, Settings.sizeX do
		Settings.colorMap[row] = {}
		Settings.functionMap[row] = {}
		Settings.overrideFunctionMap[row] = {}
		for column = 1, Settings.sizeY do
			Settings.colorMap[row][column] = 0
			Settings.functionMap[row][column] = 0
			Settings.overrideFunctionMap[row][column] = 0
		end
	end
end

local function assignObjectID()
	local id = 1
	local foundID = false
	local increment = false
	while not foundID do
		for i=1, #takenIDs do
			if (takenIDs[i] == id) then
				increment = true
				break
			end
		end
		if (increment) then
			id = id + 1
			increment = false
		else foundID = true end
	end
	return id
end

local function addToObjectList(object)
	table.insert(takenIDs, object.id)
	objectList[object.id] = object
end

function returnObject(id)
	return objectList[id]
end

function checkCollisions(checkObject, objectList)
	local collisions = {}
	for i=1, #objectList do
		if (objectList[i][3] >= checkObject[3]) and (objectList[i][3] <= checkObject[3] + checkObject[4] - 1) then
			if (objectList[i][1] >= checkObject[1]) and (objectList[i][1] <= checkObject[1] + checkObject[2] - 1) then
				table.insert(collisions, objectList[i])
			elseif (objectList[i][1] + objectList[i][2] >= checkObject[1]) and (objectList[i][1] + objectList[i][2] <= checkObject[1] + checkObject[2] - 1) then
				table.insert(collisions, objectList[i])
			end
		elseif (objectList[i][3] + objectList[i][4] >= checkObject[3]) and (objectList[i][3] + objectList[i][4] <= checkObject[3] + checkObject[4] - 1) then
			if (objectList[i][1] >= checkObject[1]) and (objectList[i][1] <= checkObject[1] + checkObject[2] - 1) then
				table.insert(collisions, objectList[i])
			elseif (objectList[i][1] + objectList[i][2] >= checkObject[1]) and (objectList[i][1] + objectList[i][2] <= checkObject[1] + checkObject[2] - 1) then
				table.insert(collisions, objectList[i])
			end
		end
	end
	return collisions
end

function drawObject(id)
	objectList[id]:draw()
end

function deleteObject(id)
	objectList[id]:delete()
end

function drawScreen()
	for i=1, #takenIDs do
		if not (objectList[takenIDs[i]].hidden) then
			objectList[takenIDs[i]]:draw()
		end
	end
end

function clearScreen()
	local numIDs = #takenIDs
	for i=#takenIDs, 1, -1 do
		local temp = numIDs
		objectList[takenIDs[i]]:delete(true)
		numIDs = #takenIDs
		while (temp == numIDs) do
			if (objectList[takenIDs[i]] == nil) then table.remove(takenIDs, i)
			else objectList[takenIDs[i]]:delete(true) end
			numIDs = #takenIDs
		end
	end
	resetMaps()
	paintutils.drawFilledBox(1, 1, Settings.sizeX, Settings.sizeY, Settings.backgroundColor)
end

local function redrawUnderlaps(id)
	local bounds = {objectList[id].x, objectList[id].sizeX, objectList[id].y, objectList[id].sizeY}
	local checkList = {}
	local underlaps = {}
	if (takenIDs[1] ~= id) then
		for i=1, #takenIDs do
			if (takenIDs[i] == id) then break end
			local checkObject = objectList[takenIDs[i]]
			if not (checkObject.hidden) then
				table.insert(checkList, {checkObject.x, checkObject.sizeX, checkObject.y, checkObject.sizeY, takenIDs[i]})
			end
		end
		if (#checkList >= 1) then
			underlaps = checkCollisions(bounds, checkList)
			for i=1, #underlaps do
				objectList[underlaps[i][5]]:draw()
			end
		end
	end
end

local function redrawOverlaps(id)
	local bounds = {objectList[id].x, objectList[id].sizeX, objectList[id].y, objectList[id].sizeY}
	local checkList = {}
	local overlaps = {}
	if (objectList[-1] ~= id) then
		for i=#takenIDs , 1, -1 do
			if (takenIDs[i] == id) then break end
			local checkObject = objectList[takenIDs[i]]
			if not (checkObject.hidden) then
				table.insert(checkList, {checkObject.x, checkObject.sizeX, checkObject.y, checkObject.sizeY, takenIDs[i]})
			end
		end
		if (#checkList >= 1) then
			overlaps = checkCollisions(bounds, checkList)
			for i=1, #overlaps do
				objectList[overlaps[i][5]]:draw()
			end
		end
	end
end

function saveImage(path, x, y, w, z, isSelImage)
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
				if not (Settings.paintMap[row][column] == 0) then
					tColorY = column
					isBreak = true
					break
				end
				if (isBreak) then
					break
				end
			end
			if (isBreak) then
				break
			end
		end
		for row = 1, Settings.sizeX do
			local isBreak = false
			for column = 1, Settings.sizeY do
				if not (Settings.paintMap[row][column] == 0) then
					tColorX = row
					isBreak = true
					break
				end
				if (isBreak) then
					break
				end
			end
			if (isBreak) then
				break
			end
		end
		for column = Settings.sizeY, 1, -1 do
			local isBreak = false
			for row = Settings.sizeX, 1, -1 do
				if not (Settings.paintMap[row][column] == 0) then
					bColorY = column
					isBreak = true
					break
				end
				if (isBreak) then
					break
				end
			end
			if (isBreak) then
				break
			end
		end
		for row = Settings.sizeX, 1, -1 do
			local isBreak = false
			for column = Settings.sizeY, 1, -1 do
				if not (Settings.paintMap[row][column] == 0) then
					bColorX = row
					isBreak = true
					break
				end
				if (isBreak) then
					break
				end
			end
			if (isBreak) then
				break
			end
		end
	end
	file.write("X"..tColorX.."Y"..tColorY.."W"..bColorX.."Z"..bColorY)
	for row = tColorX, bColorX do
		for column = tColorY, bColorY do
			if (Settings.paintMap[row][column] == nil) then
				nextColor = "0"
			else
				nextColor = tostring(Settings.paintMap[row][column])
			end
			if (color == nextColor) then
				numColor = numColor + 1
			elseif not (color == nil) then
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

--[[
Decompresses a .pic image into a color matrix image
imageString (String): A string of compressed image data (Without original location data)
sizeX (Int): The horizontal size of the image
sizeY (Int): The vertical size of the image
--]]
local function decompressImage(imageString, sizeX, sizeY)
	local addColor = 0
	local firstColor = true
	local lastLetterPos = 1
	local arrayPosX = 1
	local arrayPosY = 1
	local image = {}
	for row = 1, sizeX do image[row] = {}
		for column = 1, sizeY do
			image[row][column] = 0
		end
	end
	for loc = 1, #imageString do
		local char = string.sub(imageString, loc, loc)
		if (char == "C" and firstColor) then
			firstColor = false
			lastLetterPos = loc
		elseif (char == "N") then
			local numberPos = loc - (lastLetterPos + 1)
			local numberString = string.sub(imageString, loc - numberPos, loc - 1)
			addColor = tonumber(numberString)
			lastLetterPos = loc
		elseif (char == "C" or char == "E") then
			local numberPos = loc - (lastLetterPos + 1)
			local numberString = string.sub(imageString, loc - numberPos, loc - 1)
			local number = tonumber(numberString)
			while (number > 0) do
				if (addColor ~= 0) then image[arrayPosX][arrayPosY] = addColor end
				if (arrayPosY == sizeY) then
					arrayPosY = 1
					arrayPosX = arrayPosX + 1
					number = number - 1
				else
					arrayPosY = arrayPosY + 1
					number = number - 1
				end
			end
			lastLetterPos = loc
		end
	end
	return image
end


--[[
Allows you to display a rectangle of color
That's pretty much it.... just a rectangle of color
--]]
Fill = {}

--[[
Creates a new instance of a Fill object
x (Int): The horizontal pixel amount from the top left of the screen, to the top left of the image
y (Int): The vertical pixel amount from the top left of the screen, to the top left of the image
sizeX (Int): Horizontal length of the fill
sizeY (Int): Vertical length of the fill
--]]
function Fill:new(x, y, sizeX, sizeY, anchorX, anchorY)
	self.__index = self
	if (type(x) ~= "number") then error("Expected number for arg #1, got "..type(x), 2) end
	if (type(y) ~= "number") then error("Expected number for arg #2, got "..type(y), 2) end
	if (type(sizeX) ~= "number") then error("Expected number for arg #3, got "..type(sizeX), 2) end
	if (type(sizeY) ~= "number") then error("Expected number for arg #4, got "..type(sizeY), 2) end
	anchorX = anchorX or "left"
	if (type(anchorX) ~= "string") then error("Expected string for arg #5, got "..type(anchorX), 2) end
	local lowerAX = string.lower(anchorX)
	if (lowerAX == "middle") then x = Settings.midX + x
	elseif (lowerAX == "right") then x = Settings.sizeX + x
	elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
	anchorY = anchorY or "top"
	if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
	local lowerAY = string.lower(anchorY)
	if (lowerAY == "middle") then y = Settings.midY + y
	elseif (lowerAY == "bottom") then y = Settings.sizeY + y
	elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	local o = setmetatable({
		x = x,
		y = y,
		sizeX = sizeX,
		sizeY = sizeY,
		fillColor = 0,
		hidden = true,
		objectName = "Fill",
		id = assignObjectID()
	}, self)
	addToObjectList(o)
	return o
end

-- fillColor (Int): Color of the fill
function Fill:setFillColor(fillColor)
	if (type(fillColor) == "number") then self.fillColor = fillColor
	else error("Expected number for arg #1, got "..type(fillColor), 2) end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Fill:resize(sizeX, sizeY)
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
	end
	sizeX = sizeX or 1
	if (type(sizeX) == "number") then self.sizeX = sizeX
	else error("Expected number for parameter #1, got "..type(sizeX), 2) end
	sizeY = sizeY or 1
	if (type(sizeY) == "number") then self.sizeY = sizeY
	else error("Expected number for parameter #2, got "..type(sizeY), 2) end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Fill:move(x, y, relative, anchorX, anchorY)
	relative = relative or false
	if (type(relative) == "boolean") then
	else error("Expected boolean for parameter #3, got "..type(relative), 2) end
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
	end
	if (relative) then
		x = x or 0
		if (type(x) == "number") then self.x = self.x + x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 0
		if (type(y) == "number") then self.y = self.y + y
		else error("Expected number for parameter #2, got "..type(y), 2) end
	else
		x = x or 1
		if (type(x) == "number") then self.x = x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 1
		if (type(y) == "number") then self.y = y
		else error("Expected number for parameter #2, got "..type(y), 2) end
		anchorX = anchorX or "left"
		if (type(anchorX) ~= "string") then error("Expected string for arg #4, got "..type(anchorX), 2) end
		local lowerAX = string.lower(anchorX)
		if (lowerAX == "middle") then x = Settings.midX + x
		elseif (lowerAX == "right") then x = Settings.sizeX + x
		elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
		anchorY = anchorY or "top"
		if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
		local lowerAY = string.lower(anchorY)
		if (lowerAY == "middle") then y = Settings.midY + y
		elseif (lowerAY == "bottom") then y = Settings.sizeY + y
		elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Fill:show()
	if (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
		self.hidden = false
	end
end

function Fill:hide()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
		self.hidden = true
	end
end

function Fill:redraw()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		redrawUnderlaps(self.id)
		self:draw()
		redrawOverlaps(self.id)
	end
end

-- Draws the Fill object onto the screen at its current location
function Fill:draw()
	if (self.fillColor ~= 0) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, self.fillColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = self.fillColor
			end
		end
	end
end

-- Draws a part of the Fill object onto the screen at its current location
function Fill:partialDraw(x1, y1, x2, y2)
	if (type(x1) ~= "number") then error("Expected number for arg #1, got "..type(x1), 2) end
	if (type(y1) ~= "number") then error("Expected number for arg #2, got "..type(y1), 2) end
	if (type(x2) ~= "number") then error("Expected number for arg #3, got "..type(x2), 2) end
	if (type(y2) ~= "number") then error("Expected number for arg #4, got "..type(y2), 2) end
	if (self.fillColor ~= 0) then
		local dx1, dy1, dx2, dy2
		if (x1 >= self.x) then dx1 = self.x else dx1 = x1 end
		if (y1 >= self.y) then dy1 = self.y else dy1 = y1 end
		if (x2 >= self.x + self.sizeX - 1) then dx2 = self.x + self.sizeX - 1 else dx2 = x2 end
		if (y2 >= self.y + self.sizeY - 1) then dy2 = self.y + self.sizeY - 1 else dy2 = y2 end
		paintutils.drawFilledBox(dx1, dy1, dx2, dy2, self.fillColor)
		for row = dx1, dx2 do
			for column = dy1, dy2 do
				Settings.colorMap[row][column] = self.fillColor
			end
		end
	end
end

-- Deletes the Fill object from the global object list and will redraw colliding objects if not overridden
function Fill:delete(overrideRedraw)
	overrideRedraw = overrideRedraw or false
	if (type(overrideRedraw) ~= "boolean") then error("Expected boolean for parameter #1, got "..type(overrideRedraw), 2) end
	if not (overrideRedraw) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
	end
	objectList[self.id] = nil
	for i=1, #takenIDs do
		if (takenIDs[i] == self.id) then table.remove(takenIDs, i) end
	end
end


--[[
Allows you to display an image as an object
An image is a variable sized matrix of color values that get interpreted and drawn
--]]
Image = {}

--[[
Creates a new instance of an Image object
x (Int): The horizontal pixel amount from the top left of the screen, to the top left of the image
y (Int): The vertical pixel amount from the top left of the screen, to the top left of the image
--]]
function Image:new(x, y, anchorX, anchorY)
	self.__index = self
	if (type(x) ~= "number") then error("Expected number for arg #1, got "..type(x), 2) end
	if (type(y) ~= "number") then error("Expected number for arg #2, got "..type(y), 2) end
	anchorX = anchorX or "left"
	if (type(anchorX) ~= "string") then error("Expected string for arg #3, got "..type(anchorX), 2) end
	local lowerAX = string.lower(anchorX)
	if (lowerAX == "middle") then x = Settings.midX + x
	elseif (lowerAX == "right") then x = Settings.sizeX + x
	elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
	anchorY = anchorY or "top"
	if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
	local lowerAY = string.lower(anchorY)
	if (lowerAY == "middle") then y = Settings.midY + y
	elseif (lowerAY == "bottom") then y = Settings.sizeY + y
	elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	local o = setmetatable({
		x = x,
		y = y,
		sizeX = 1,
		sizeY = 1,
		image = nil,
		hidden = true,
		objectName = "Image",
		id = assignObjectID()
	}, self)
	addToObjectList(o)
	return o
end

-- imagePath (String): A directory path starting from root "/" that points to the image
function Image:setImage(imagePath)
	imagePath = imagePath or ""
	if (type(imagePath) == "string") then self.imagePath = imagePath
	else error("Expected string for arg #1, got "..type(imagePath), 2) end
	local imageData = readFileData(imagePath)
	local ix, iy, image
	if (imageData == "") then error("Image 'imagePath' failed to load: File is empty", 2)
	elseif (imageData) then
		if not (self.hidden) then
			paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
			for row = self.x, self.x + self.sizeX - 1 do
				for column = self.y, self.y + self.sizeY - 1 do
					Settings.colorMap[row][column] = 0
				end
			end
			redrawUnderlaps(self.id)
		end
		local lastLetterPos = 1
		local ox, oy
		for loc = 1, #imageData do
			local char = string.sub(imageData, loc, loc)
			if (char == "Y") then
				local numberString = string.sub(imageData, 2, loc - 1)
				ox = tonumber(numberString)
				lastLetterPos = loc
			elseif (char == "W") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				oy = tonumber(numberString)
				lastLetterPos = loc
			elseif (char == "Z") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				ix = tonumber(numberString) - ox + 1
				lastLetterPos = loc
			elseif (char == "C") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				iy = tonumber(numberString) - oy + 1
				self.image = decompressImage(string.sub(imageData, loc - 1, -1), ix, iy)
				break
			end
		end
	else error("Image 'imagePath' failed to load: File doesn't exist", 2) end
	self.sizeX = ix
	self.sizeY = iy
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Image:move(x, y, relative, anchorX, anchorY)
	relative = relative or false
	if (type(relative) == "boolean") then
	else error("Expected boolean for parameter #3, got "..type(relative), 2) end
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
	end
	if (relative) then
		x = x or 0
		if (type(x) == "number") then self.x = self.x + x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 0
		if (type(y) == "number") then self.y = self.y + y
		else error("Expected number for parameter #2, got "..type(y), 2) end
	else
		x = x or 1
		if (type(x) == "number") then self.x = x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 1
		if (type(y) == "number") then self.y = y
		else error("Expected number for parameter #2, got "..type(y), 2) end
		anchorX = anchorX or "left"
		if (type(anchorX) ~= "string") then error("Expected string for arg #4, got "..type(anchorX), 2) end
		local lowerAX = string.lower(anchorX)
		if (lowerAX == "middle") then x = Settings.midX + x
		elseif (lowerAX == "right") then x = Settings.sizeX + x
		elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
		anchorY = anchorY or "top"
		if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
		local lowerAY = string.lower(anchorY)
		if (lowerAY == "middle") then y = Settings.midY + y
		elseif (lowerAY == "bottom") then y = Settings.sizeY + y
		elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Image:show()
	if (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
		self.hidden = false
	end
end

function Image:hide()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
		self.hidden = true
	end
end

function Image:redraw()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		redrawUnderlaps(self.id)
		self:draw()
		redrawOverlaps(self.id)
	end
end

-- Draws the Image object onto the screen at its current location
function Image:draw()
	if (self.image ~= nil) then
		for row = 1, self.sizeX do
			for column = 1, self.sizeY do
				if (self.image[row][column] ~= 0) then
					paintutils.drawPixel(self.x + row - 1, self.y + column - 1, self.image[row][column])
					Settings.colorMap[self.x + row - 1][self.y + column - 1] = self.image[row][column]
				end
			end
		end
	end
end

-- Draws the part of the Image object that intersects with the given coordinates onto the screen
function Image:partialDraw(x1, y1, x2, y2)
	if (type(x1) ~= "number") then error("Expected number for arg #1, got "..type(x1), 2) end
	if (type(y1) ~= "number") then error("Expected number for arg #2, got "..type(y1), 2) end
	if (type(x2) ~= "number") then error("Expected number for arg #3, got "..type(x2), 2) end
	if (type(y2) ~= "number") then error("Expected number for arg #4, got "..type(y2), 2) end
	if (self.image ~= nil) then
		local dx1, dy1, dx2, dy2
		if (x1 >= self.x) then dx1 = self.x else dx1 = x1 end
		if (y1 >= self.y) then dy1 = self.y else dy1 = y1 end
		if (x2 >= self.x + self.sizeX - 1) then dx2 = self.x + self.sizeX - 1 else dx2 = x2 end
		if (y2 >= self.y + self.sizeY - 1) then dy2 = self.y + self.sizeY - 1 else dy2 = y2 end
		for row = dx1, dx2 do
			for column = dy1, dy2 do
				if (self.image[row][column] ~= 0) then
					paintutils.drawPixel(row, column, self.image[row - self.sizeX + 1][column - self.sizeY + 1])
					Settings.colorMap[row][column] = self.image[row - self.sizeX + 1][column - self.sizeY + 1]
				end
			end
		end
	end
end

-- Deletes the Image object from the global object list and will redraw colliding objects if not overridden
function Image:delete(overrideRedraw)
	overrideRedraw = overrideRedraw or false
	if (type(overrideRedraw) ~= "boolean") then error("Expected boolean for parameter #1, got "..type(overrideRedraw), 2) end
	if not (overrideRedraw) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
	end
	objectList[self.id] = nil
	for i=1, #takenIDs do
		if (takenIDs[i] == self.id) then table.remove(takenIDs, i) end
	end
end


--[[
Allows you to display text as an object
Text can be displayed and interacted with in various different ways
- Static Text (EX: Showing a name, player health, etc)
- Scrollable Text (EX: A long description, etc)
- Editable Text (EX: An input field, a word game, etc)
--]]
TextBox = {}

--[[
Creates a new instance of a TextBox object
x (Int): The horizontal pixel amount from the top left of the screen, to the top left of the image
y (Int): The vertical pixel amount from the top left of the screen, to the top left of the image
sizeX (Int): Horizontal length of the text box
sizeY (Int): Vertical length of the text box
textColor (Int): Color of the text in the box
boxColor (Int): Color of the box behind the text (0 makes box transparent)
text (String): Text that is already typed into the box
editable (Boolean): Determines whether a user can delete and add text in the box
func (String): A string of the global function that will be run when the enter button is clicked, and the text box is selected
env (Table): The environment of the script where the object is created. (Required to run functions) (Get by running getfenv() as the parameter)
defaultText (String): Text that is displayed in the box, and disappears when box is selected
defaultTextColor (Int): Color of the default text in the box
allowScroll (Boolean): Determines whether text is allowed to scroll in the box, or it it is capped at the box size
scrollMode (String): Determines how overflow text will be handled when allowScroll is on
"vertical" causes text to scroll upwards when text reaches end of last line
"horizontal" causes text to scroll left when text reaches end of line (Locked to sizeY of 1)
lifetime (Int): Determines how long text box will appear before deleting itself (0 disables lifetime)
overrideObject (Boolean): Doesn't add object to the global object list (Useful for sub-objects or third party display functions)
--]]
function TextBox:new(x, y, sizeX, sizeY, anchorX, anchorY)
	self.__index = self
	if (type(x) ~= "number") then error("Expected number for arg #1, got "..type(x), 2) end
	if (type(y) ~= "number") then error("Expected number for arg #2, got "..type(y), 2) end
	if (type(sizeX) ~= "number") then error("Expected number for arg #3, got "..type(sizeX), 2) end
	if (type(sizeY) ~= "number") then error("Expected number for arg #4, got "..type(sizeY), 2) end
	anchorX = anchorX or "left"
	if (type(anchorX) ~= "string") then error("Expected string for arg #5, got "..type(anchorX), 2) end
	local lowerAX = string.lower(anchorX)
	if (lowerAX == "middle") then x = Settings.midX + x
	elseif (lowerAX == "right") then x = Settings.sizeX + x
	elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
	anchorY = anchorY or "top"
	if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
	local lowerAY = string.lower(anchorY)
	if (lowerAY == "middle") then y = Settings.midY + y
	elseif (lowerAY == "bottom") then y = Settings.sizeY + y
	elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	local o = setmetatable({
		x = x,
		y = y,
		sizeX = sizeX,
		sizeY = sizeY,
		maxLength = sizeX - 1,
		cursorPos = 1,
		stringPos = 1,
		text = "",
		defaultText = "",
		editable = false,
		scrollMode = "none",
		hidden = true,
		objectName = "TextBox",
		id = assignObjectID()
	}, self)
	addToObjectList(o)
	return o
end

function TextBox:setText(text, textColor, textBoxColor, default)
	default = default or false
	if (type(default) ~= "boolean") then error("Expected boolean for arg #4, got "..type(default), 2) end
	text = text or ""
	if (type(text) == "string") then
		if (default) then
			if (#text >= self.maxLength) then error("String 'text' failed to load: Default text must be shorter than sizeX", 2) end
			self.defaultText = text
		else
			self.text = text
			self.stringPos = 1
			if (self.scrollMode == "none") then self.visibleText = text
			else
				if (#text > self.maxLength) then self.visibleText = string.sub(self.text, 1, self.maxLength)..">"
				else
					self.visibleText = text
					if (self.cursorPos > #text + 1) then self.cursorPos = #text + 1 end
				end
			end
		end
	else error("Expected string for arg #1, got "..type(text), 2) end
	textColor = textColor or 1
	if (type(textColor) == "number") then
		if (default) then self.defaultTextColor = textColor
		else self.textColor = textColor end
		self.textColor = textColor
	else error("Expected number for arg #2, got "..type(textColor), 2) end
	textBoxColor = textBoxColor or 32768
	if (type(textBoxColor) == "number") then self.textBoxColor = textBoxColor
	else error("Expected number for arg #3, got "..type(textBoxColor), 2) end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function TextBox:setEditable(editable)
	editable = editable or false
	if (type(editable) == "boolean") then self.editable = editable
	else error("Expected boolean for arg #1, got "..type(editable), 2) end
	if (editable) then Event.bindClickEvent(self, function() self:select() end)
	else
		Event.unbindClickEvent(self)
		self:unselect()
	end
end

function TextBox:setScroll(mode, direction)
	mode = mode or "none"
	if (type(mode) == "string") then self.scrollMode = mode
	else error("Expected string for arg #1, got "..type(mode), 2) end
	direction = direction or "horizontal"
	if (type(direction) == "string") then self.scrollDir = direction
	else error("Expected string for arg #1, got "..type(direction), 2) end
end

-- Called whenever a user clicks on the text box
-- Binds edit specific events if text box is editable
-- Will only run if text box allows scrolling or is editable
function TextBox:select()
	if not (self.selected) then
		if (self.defaultText ~= "") and (self.text == "") then paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, self.textBoxColor) end
		term.setTextColor(self.textColor)
		term.setBackgroundColor(self.textBoxColor)
		if (self.cursorPos > self.maxLength) then self.cursorPos = 1 end
		term.setCursorPos(self.x + self.cursorPos - 1, self.y)
		term.setCursorBlink(true)
		self.selected = true
		if (self.editable) then
			Event.bindCharEvent(self, function() self:addChar(Event.returnEventLog()[2]) end)
			Event.bindKeyEvent(self, keys.backspace, function() self:deleteChar() end)
			Event.bindKeyEvent(self, keys.left, function() self:cursorLeft() end)
			Event.bindKeyEvent(self, keys.right, function() self:cursorRight() end)
			if (self.func ~= nil) then Event.bindKeyEvent(self, keys.enter, self.func) end
		end
	end
end

-- Called whenever a user clicks off the text box
-- Unbinds edit specific events if text box is editable
function TextBox:unselect()
	if (self.selected) then
		term.setCursorBlink(false)
		self.selected = false
		if (self.editable) then
			Event.unbindCharEvent(self)
			Event.unbindKeyEvent(self, keys.backspace)
			Event.unbindKeyEvent(self, keys.left)
			Event.unbindKeyEvent(self, keys.right)
			if (self.func ~= nil) then Event.unbindKeyEvent(self, keys.enter) end
			if (self.defaultText ~= "") and (self.text == "") then self:draw() end
			term.setCursorPos(0, 0)
		end
	end
end

-- Called whenever a user enters a valid character keystroke while text box is selected
-- Adds a character in front of the current cursor position, and scrolls the text if necessary
-- Will not add character if allowScroll is disabled, and adding a character would require the text to scroll
function TextBox:addChar(char)
	if (type(char) ~= "string") then error("Expected string for arg #1, got "..type(char), 2) end
	if (self.editable) then
		local preString
		local postString
		if (self.stringPos >= 2) then
			local preTypeString = string.sub(self.text, 1, self.stringPos + self.cursorPos - 3)
			local postTypeString = string.sub(self.text, self.stringPos + self.cursorPos - 2, -1)
			if (self.cursorPos == 2) then
				postString = string.sub(self.text, self.stringPos, self.stringPos + self.maxLength - 2)
				self.text = preTypeString..char..postTypeString
				if (self.stringPos + self.maxLength <= #self.text) then self.visibleText = "<"..postString..">"
				else self.visibleText = "<"..postString end
			else
				preString = string.sub(self.text, self.stringPos + 1, self.stringPos + self.cursorPos - 3)
				if (self.stringPos + self.cursorPos - 2 > #self.text) then postString = ""
				else postString = string.sub(self.text, self.stringPos + self.cursorPos - 2, self.stringPos + self.maxLength - 2) end
				self.text = preTypeString..char..postTypeString
				if (self.stringPos + self.maxLength <= #self.text) then self.visibleText = "<"..preString..char..postString..">"
				else self.visibleText = "<"..preString..char..postString end
			end
			self.stringPos = self.stringPos + 1
		elseif (self.scrollMode == "manual") then
			if (self.cursorPos == 1) then preString = ""
			else preString = string.sub(self.text, 1, self.cursorPos - 1) end
			if (self.cursorPos > #self.text) then postString = ""
			else postString = string.sub(self.text, self.cursorPos, -1) end
			self.text = preString..char..postString
			if (#self.text >= self.maxLength) then
				if (#self.text > self.maxLength) then self.visibleText = "<"..string.sub(self.text, 2, self.maxLength)..">"
				else self.visibleText = "<"..string.sub(self.text, 2, self.maxLength) end
				self.stringPos = self.stringPos + 1
			else self.visibleText = self.text end
			if (self.cursorPos <= self.maxLength) then self.cursorPos = self.cursorPos + 1 end
		elseif (#self.text < self.maxLength) then
			if (self.cursorPos == 1) then preString = ""
			else preString = string.sub(self.text, 1, self.cursorPos - 1) end
			if (self.cursorPos > #self.text) then postString = ""
			else postString = string.sub(self.text, self.cursorPos, -1) end
			self.text = preString..char..postString
			self.visibleText = self.text
			self.cursorPos = self.cursorPos + 1
		end
		self:draw()
		redrawOverlaps(self.id)
		term.setCursorPos(self.x + self.cursorPos - 1, self.y)
	end
end

-- Called whenever a user presses backspace while text box is selected
-- Deletes the character in front of the current cursor position, and scrolls the text if necessary
function TextBox:deleteChar()
	if (self.editable) then
		local preString
		local postString
		if (self.stringPos > 2) then
			preString = string.sub(self.text, self.stringPos - 1, self.stringPos + self.cursorPos - 4)
			if (self.stringPos + self.cursorPos - 2 > #self.text) then postString = ""
			else postString = string.sub(self.text, self.stringPos + self.cursorPos - 2, self.stringPos + self.maxLength - 2) end
			local preTypeString = string.sub(self.text, 1, self.stringPos + self.cursorPos - 4)
			local postTypeString = string.sub(self.text, self.stringPos + self.cursorPos - 2, -1)
			self.text = preTypeString..postTypeString
			if (self.stringPos + self.maxLength - 1 <= #self.text) then self.visibleText = "<"..preString..postString..">"
			else self.visibleText = "<"..preString..postString end
			self.stringPos = self.stringPos - 1
		else
			if (self.cursorPos ~= 1) then
				if (self.cursorPos == 2) then preString = ""
				else preString = string.sub(self.text, 1, self.cursorPos - 2) end
				if (self.cursorPos > #self.text) then
					postString = ""
					self.text = preString
				else
					if (#self.text > self.maxLength) then
						postString = string.sub(self.text, self.cursorPos, self.maxLength + 1)
						local postTypeString = string.sub(self.text, self.cursorPos, -1)
						self.text = preString..postTypeString
					else
						postString = string.sub(self.text, self.cursorPos, -1)
						self.text = preString..postString
					end
				end
				if (#self.text >= self.maxLength) then self.visibleText = preString..postString..">"
				else
					self.visibleText = self.text
					self.stringPos = 1
				end
				self.cursorPos = self.cursorPos - 1
			end
		end
		self:draw()
		redrawOverlaps(self.id)
		term.setCursorPos(self.x + self.cursorPos - 1, self.y)
	end
end

-- Moves the cursor one character to the left, and scrolls the text if necessary
function TextBox:cursorLeft()
	term.setTextColor(colors.black)
	if (self.cursorPos ~= 1) then
		if (self.cursorPos == 2) then
			if (self.stringPos == 2) then
				self.visibleText = string.sub(self.text, 1, self.maxLength)..">"
				self.stringPos = 1
				self:draw()
				redrawOverlaps(self.id)
			elseif (self.stringPos > 2) then
				local subString = string.sub(self.text, self.stringPos - 1, self.stringPos + self.maxLength - 3)
				self.stringPos = self.stringPos - 1
				self.visibleText = "<"..subString..">"
				self:draw()
				redrawOverlaps(self.id)
			else self.cursorPos = self.cursorPos - 1 end
		else self.cursorPos = self.cursorPos - 1 end
		term.setCursorPos(self.x + self.cursorPos - 1, self.y)
	end
end

-- Moves the cursor one character to the right, and scrolls the text if necessary
function TextBox:cursorRight()
	if (self.cursorPos <= self.maxLength) then
		if (self.cursorPos == self.maxLength) and (self.cursorPos <= #self.text) then
			if (self.stringPos + self.cursorPos - 1 == #self.text) then
				local subString = string.sub(self.text, self.stringPos + 1, -1)
				self.visibleText = "<"..subString
				self.stringPos = self.stringPos + 1
				self:draw()
				redrawOverlaps(self.id)
			elseif (self.stringPos + self.cursorPos - 1 < #self.text) then
				local subString = string.sub(self.text, self.stringPos + 1, self.stringPos + self.maxLength - 1)
				self.visibleText = "<"..subString..">"
				self.stringPos = self.stringPos + 1
				self:draw()
				redrawOverlaps(self.id)
			else self.cursorPos = self.cursorPos + 1 end
		elseif (self.cursorPos <= #self.text) then self.cursorPos = self.cursorPos + 1 end
		term.setCursorPos(self.x + self.cursorPos - 1, self.y)
	end
end

function TextBox:onEnter(func)
	if (self.func ~= nil) then Event.unbindKeyEvent(self, keys.enter) end
	if (func == nil) or (type(func) == "function") then
		self.func = func
		if (self.selected) then Event.bindKeyEvent(self, keys.enter, self.func) end
	else error("Expected function for arg #1, got "..type(func), 2) end
end

function TextBox:resize(sizeX, sizeY)
	if not (self.hidden) then
		Event.unbindClickEvent(self)
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		self:unselect()
		redrawUnderlaps(self.id)
	end
	sizeX = sizeX or 3
	if (type(sizeX) == "number") then
		if (sizeX > 2) then
			self.sizeX = sizeX
			self.maxLength = sizeX - 1
		else error("Number 'sizeX' failed to load: SizeX must be at least 3", 2) end
	else error("Expected number for parameter #1, got "..type(sizeX), 2) end
	sizeY = sizeY or 1
	if (type(sizeY) == "number") then self.sizeY = sizeY
	else error("Expected number for parameter #2, got "..type(sizeY), 2) end
	local newPos = sizeX - #self.text
	self.stringPos = 1
	if (#self.text > self.maxLength) then
		self.visibleText = string.sub(self.text, 1, self.maxLength)..">"
		if (self.cursorPos > self.maxLength) then self.cursorPos = self.maxLength end
	else
		self.visibleText = self.text
		if (self.cursorPos > #self.text) then self.cursorPos = #self.text + 1 end
	end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function TextBox:move(x, y, relative, anchorX, anchorY)
	relative = relative or false
	if (type(relative) == "boolean") then
	else error("Expected boolean for parameter #3, got "..type(relative), 2) end
	if not (self.hidden) then
		Event.unbindClickEvent(self)
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		self:unselect()
		redrawUnderlaps(self.id)
	end
	if (relative) then
		x = x or 0
		if (type(x) == "number") then self.x = self.x + x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 0
		if (type(y) == "number") then self.y = self.y + y
		else error("Expected number for parameter #2, got "..type(y), 2) end
	else
		x = x or 1
		if (type(x) == "number") then self.x = x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 1
		if (type(y) == "number") then self.y = y
		else error("Expected number for parameter #2, got "..type(y), 2) end
		anchorX = anchorX or "left"
		if (type(anchorX) ~= "string") then error("Expected string for arg #4, got "..type(anchorX), 2) end
		local lowerAX = string.lower(anchorX)
		if (lowerAX == "middle") then x = Settings.midX + x
		elseif (lowerAX == "right") then x = Settings.sizeX + x
		elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
		anchorY = anchorY or "top"
		if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
		local lowerAY = string.lower(anchorY)
		if (lowerAY == "middle") then y = Settings.midY + y
		elseif (lowerAY == "bottom") then y = Settings.sizeY + y
		elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function TextBox:show()
	if (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
		self.hidden = false
	end
end

function TextBox:hide()
	if not (self.hidden) then
		Event.unbindClickEvent(self)
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		self:unselect()
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
		self.hidden = true
	end
end

function TextBox:redraw()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		redrawUnderlaps(self.id)
		self:draw()
		redrawOverlaps(self.id)
	end
end

-- Draws the TextBox object onto the screen at its current location
function TextBox:draw()
	if (self.editable) or (self.scrollMode == "manual") then Event.bindClickEvent(self, function() self:select() end) end
	if (self.textBoxColor == 0) then
		if (self.defaultText ~= "") and (self.text == "") and (self.selected) then
			term.setTextColor(self.defaultTextColor)
			for i=1, #self.defaultText do
				term.setBackgroundColor(Setting.colorMap[i][self.y])
				term.setCursorPos(self.x + i - 1, self.y)
				term.write(string.sub(self.defaultText, i, i))
			end
		else
			term.setTextColor(self.textColor)
			for i=1, #self.visibleText do
				term.setBackgroundColor(Setting.colorMap[i][self.y])
				term.setCursorPos(self.x + i - 1, self.y)
				term.write(string.sub(self.visibleText, i, i))
			end
		end
	else
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, self.textBoxColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = self.textBoxColor
			end
		end
		term.setBackgroundColor(self.textBoxColor)
		if (self.defaultText ~= "") and (self.text == "") and not (self.selected) then
			term.setTextColor(self.defaultTextColor)
			term.setCursorPos(self.x, self.y)
			term.write(self.defaultText)
		elseif (self.text ~= "") then
			term.setTextColor(self.textColor)
			term.setCursorPos(self.x, self.y)
			term.write(self.visibleText)
		end
	end
	term.setCursorPos(self.x + self.cursorPos - 1, self.y)
end

-- Deletes the TextBox object from the global object list and will redraw colliding objects if not overridden
function TextBox:delete(overrideRedraw)
	overrideRedraw = overrideRedraw or false
	if (type(overrideRedraw) ~= "boolean") then error("Expected boolean for parameter #1, got "..type(overrideRedraw), 2) end
	if (self.editable) then self:unselect() end
	Event.unbindClickEvent(self)
	if not (overrideRedraw) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
	end
	objectList[self.id] = nil
	for i=1, #takenIDs do
		if (takenIDs[i] == self.id) then table.remove(takenIDs, i) end
	end
end


--[[
Allows you to display a custom button that sends a function on click
A Button object can either have an Image or Fill object as its background, and can have a Text object as its foreground
--]]
Button = {}

--[[
Creates a new instance of a Button object
x (Int): The horizontal pixel amount from the top left of the screen, to the top left of the image
y (Int): The vertical pixel amount from the top left of the screen, to the top left of the image
sizeX (Int): Horizontal length of the button
sizeY (Int): Vertical length of the button
func (String): A string of the fglobal unction that will be run when the button object is clicked
env (Table): The environment of the script where the object is created. (Required to run functions) (Get by running getfenv() as the parameter)
textColor (Int): Color of the text on the button
textBoxColor (Int): Color of the box behind the button text (0 makes box transparent)
text (String): Text that is displayed on the button (Empty text will disble text)
backgroundObject (String): The object used as the button background
"fill" creates a solid color rectangle as the button background
"image" display an image as the button background
"none" will disable background
fillColor (Int): Color of the Fill object (When using "fill" as background)
path (String): Path to an image file (When using "image" as background)
lifetime (Int): Determines how long button will appear before deleting itself (0 disables lifetime)
overrideObject (Boolean): Doesn't add object to the global object list (Useful for sub-objects or third party display functions)
--]]
function Button:new(x, y, sizeX, sizeY, anchorX, anchorY)
	self.__index = self
	if (type(x) ~= "number") then error("Expected number for arg #1, got "..type(x), 2) end
	if (type(y) ~= "number") then error("Expected number for arg #2, got "..type(y), 2) end
	if (type(sizeX) ~= "number") then error("Expected number for arg #3, got "..type(sizeX), 2) end
	if (type(sizeY) ~= "number") then error("Expected number for arg #4, got "..type(sizeY), 2) end
	anchorX = anchorX or "left"
	if (type(anchorX) ~= "string") then error("Expected string for arg #5, got "..type(anchorX), 2) end
	local lowerAX = string.lower(anchorX)
	if (lowerAX == "middle") then x = Settings.midX + x
	elseif (lowerAX == "right") then x = Settings.sizeX + x
	elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
	anchorY = anchorY or "top"
	if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
	local lowerAY = string.lower(anchorY)
	if (lowerAY == "middle") then y = Settings.midY + y
	elseif (lowerAY == "bottom") then y = Settings.sizeY + y
	elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	local o = setmetatable({
		x = x,
		y = y,
		sizeX = sizeX,
		sizeY = sizeY,
		background = "none",
		hidden = true,
		objectName = "Button",
		id = assignObjectID()
	}, self)
	addToObjectList(o)
	return o
end

function Button:onClick(func)
	if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
	if (type(func) == "function") then
		self.func = func
		Event.bindClickEvent(objectList[self.id], self.func)
	else error("Expected function for arg #1, got "..type(func), 2) end
end

function Button:setText(text, textColor, textBoxColor)
	text = text or ""
	if (text == "") then
		self.text = nil
		self.textColor = nil
		self.textBoxColor = nil
	else
		if (type(text) == "string") then self.text = text
		else error("Expected string for arg #1, got "..type(text), 2) end
		textColor = textColor or 1
		if (type(textColor) == "number") then self.textColor = textColor
		else error("Expected number for arg #2, got "..type(textColor), 2) end
		textBoxColor = textBoxColor or 32768
		if (type(textBoxColor) == "number") then self.textBoxColor = textBoxColor
		else error("Expected number for arg #3, got "..type(textBoxColor), 2) end
		if not (self.hidden) then
			self:draw()
			redrawOverlaps(self.id)
		end
	end
end

function Button:setBackgroundToFill(fillColor)
	if (type(fillColor) == "number") then self.fillColor = fillColor
	else error("Expected number for arg #1, got "..type(fillColor), 2) end
	if (self.background == "image") then self.image = nil end
	self.background = "fill"
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Button:setBackgroundToImage(imagePath, keepButtonSize)
	if (type(imagePath) ~= "string") then error("Expected string for arg #1, got "..type(imagePath), 2) end
	keepButtonSize = keepButtonSize or false
	if (type(keepButtonSize) ~= "boolean") then error("Expected boolean for arg #2, got "..type(keepButtonSize), 2) end
	local imageData = readFileData(imagePath)
	local ix, iy
	if (imageData == "") then error("Image 'imagePath' failed to load: File is empty", 2)
	elseif (imageData) then
		local lastLetterPos = 1
		local ox, oy
		for loc = 1, #imageData do
			local char = string.sub(imageData, loc, loc)
			if (char == "Y") then
				local numberString = string.sub(imageData, 2, loc - 1)
				ox = tonumber(numberString)
				lastLetterPos = loc
			elseif (char == "W") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				oy = tonumber(numberString)
				lastLetterPos = loc
			elseif (char == "Z") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				ix = tonumber(numberString) - ox + 1
				lastLetterPos = loc
			elseif (char == "C") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageData, loc - numberPos, loc - 1)
				iy = tonumber(numberString) - oy + 1
				self.image = decompressImage(string.sub(imageData, loc - 1, -1), ix, iy)
				break
			end
		end
	else error("Image 'imagePath' failed to load: File doesn't exist", 2) end
	if (self.background == "fill") then self.fillColor = nil end
	self.background = "image"
	if not (keepButtonSize) then
		if not (self.hidden) then
			if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
			paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
			for row = self.x, self.x + self.sizeX - 1 do
				for column = self.y, self.y + self.sizeY - 1 do
					Settings.colorMap[row][column] = 0
				end
			end
			redrawUnderlaps(self.id)
		end
		self.sizeX = ix
		self.sizeY = iy
		if not (self.hidden) then
			self:draw()
			redrawOverlaps(self.id)
		end
	end
end

function Button:setBackgroundToNone()
	if (self.background == "fill") then self.fillColor = nil
	elseif (self.background == "image") then self.image = nil end
	self.background = "none"
	if not (self.hidden) then self:redraw() end
end

function Button:resize(sizeX, sizeY)
	if not (self.hidden) then
		if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
	end
	sizeX = sizeX or 1
	if (type(sizeX) == "number") then self.sizeX = sizeX
	else error("Expected number for parameter #1, got "..type(sizeX), 2) end
	sizeY = sizeY or 1
	if (type(sizeY) == "number") then self.sizeY = sizeY
	else error("Expected number for parameter #2, got "..type(sizeY), 2) end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Button:move(x, y, relative, anchorX, anchorY)
	relative = relative or false
	if (type(relative) == "boolean") then
	else error("Expected boolean for parameter #3, got "..type(relative), 2) end
	if not (self.hidden) then
		if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
	end
	if (relative) then
		x = x or 0
		if (type(x) == "number") then self.x = self.x + x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 0
		if (type(y) == "number") then self.y = self.y + y
		else error("Expected number for parameter #2, got "..type(y), 2) end
	else
		x = x or 1
		if (type(x) == "number") then self.x = x
		else error("Expected number for parameter #1, got "..type(x), 2) end
		y = y or 1
		if (type(y) == "number") then self.y = y
		else error("Expected number for parameter #2, got "..type(y), 2) end
		anchorX = anchorX or "left"
		if (type(anchorX) ~= "string") then error("Expected string for arg #4, got "..type(anchorX), 2) end
		local lowerAX = string.lower(anchorX)
		if (lowerAX == "middle") then x = Settings.midX + x
		elseif (lowerAX == "right") then x = Settings.sizeX + x
		elseif (lowerAX ~= "left") then error(anchorX.." is not an accepted x axis anchor", 2) end
		anchorY = anchorY or "top"
		if (type(anchorY) ~= "string") then error("Expected string for arg #6, got "..type(anchorY), 2) end
		local lowerAY = string.lower(anchorY)
		if (lowerAY == "middle") then y = Settings.midY + y
		elseif (lowerAY == "bottom") then y = Settings.sizeY + y
		elseif (lowerAY ~= "top") then error(anchorY.." is not an accepted y axis anchor", 2) end
	end
	if not (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
	end
end

function Button:show()
	if (self.hidden) then
		self:draw()
		redrawOverlaps(self.id)
		self.hidden = false
	end
end

function Button:hide()
	if not (self.hidden) then
		if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
		self.hidden = true
	end
end

function Button:redraw()
	if not (self.hidden) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		redrawUnderlaps(self.id)
		self:draw()
		redrawOverlaps(self.id)
	end
end

-- Draws the Button object onto the screen at its current location
function Button:draw()
	if (self.x <= Settings.sizeX) and (self.y <= Settings.sizeY) then
		if (self.background ~= "none") then
			if (self.background == "fill") then
				paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, self.fillColor)
				for row = self.x, self.x + self.sizeX - 1 do
					for column = self.y, self.y + self.sizeY - 1 do
						Settings.colorMap[row][column] = self.fillColor
					end
				end
			elseif (self.background == "image") and (self.image ~= nil) then
				for row = 1, self.sizeX do
					for column = 1, self.sizeY do
						if (self.image[row][column] ~= 0) then
							paintutils.drawPixel(self.x + row - 1, self.y + column - 1, self.image[row][column])
							Settings.colorMap[self.x + row - 1][self.y + column - 1] = self.image[row][column]
						end
					end
				end
			end
		end
		if (self.text ~= nil) then
			local midX = self.x + math.ceil(self.sizeX / 2) - 1
			local midY = self.y + math.ceil(self.sizeY / 2) - 1
			local textX = midX - math.floor(#self.text / 2)
			if (self.text ~= "") and not (textX + #self.text - 1 > Settings.sizeX) then
				term.setTextColor(self.textColor)
				term.setBackgroundColor(self.textBoxColor)
				term.setCursorPos(textX, midY)
				term.write(self.text)
				for i = 1, #self.text do Settings.colorMap[textX + i - 1][midY] = self.textBoxColor end
			end
		end
		if (self.func ~= nil) then Event.bindClickEvent(objectList[self.id], self.func) end
	end
end

-- Deletes the Button object from the global object list and will redraw colliding objects if not overridden
function Button:delete(overrideRedraw)
	overrideRedraw = overrideRedraw or false
	if (type(overrideRedraw) ~= "boolean") then error("Expected boolean for parameter #1, got "..type(overrideRedraw), 2) end
	if (self.func ~= nil) then Event.unbindClickEvent(objectList[self.id]) end
	if not (overrideRedraw) then
		paintutils.drawFilledBox(self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, Settings.backgroundColor)
		for row = self.x, self.x + self.sizeX - 1 do
			for column = self.y, self.y + self.sizeY - 1 do
				Settings.colorMap[row][column] = 0
			end
		end
		redrawUnderlaps(self.id)
		redrawOverlaps(self.id)
	end
	objectList[self.id] = nil
	for i=1, #takenIDs do
		if (takenIDs[i] == self.id) then table.remove(takenIDs, i) end
		break
	end
end
