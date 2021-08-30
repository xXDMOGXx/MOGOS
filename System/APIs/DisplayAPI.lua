function log(message)
	term.native().write(message)
end

local function readFileData(path, line)
	local line = line or "all"
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
end

function emptyCheck()
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			if not (SettingsAPI.paintMap[row][column] == 0) then
				return false
			end
		end
	end
	return true
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
		for column = 1, SettingsAPI.sizeY do
			local isBreak = false
			for row = 1, SettingsAPI.sizeX do
				if not (SettingsAPI.paintMap[row][column] == 0) then
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
		for row = 1, SettingsAPI.sizeX do
			local isBreak = false
			for column = 1, SettingsAPI.sizeY do
				if not (SettingsAPI.paintMap[row][column] == 0) then
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
		for column = SettingsAPI.sizeY, 1, -1 do
			local isBreak = false
			for row = SettingsAPI.sizeX, 1, -1 do
				if not (SettingsAPI.paintMap[row][column] == 0) then
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
		for row = SettingsAPI.sizeX, 1, -1 do
			local isBreak = false
			for column = SettingsAPI.sizeY, 1, -1 do
				if not (SettingsAPI.paintMap[row][column] == 0) then
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
			if (SettingsAPI.paintMap[row][column] == nil) then
				nextColor = "0"
			else
				nextColor = tostring(SettingsAPI.paintMap[row][column])
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

function loadImage(path, x, y, isFake, line, isOPos, isPaint)
	local isFake = isFake or false
	local line = line or "all"
	local isOPos = isOPos or false
	local isPaint = isPaint or false
	local imageString = readFileData(path, line)
	local stringLength = #imageString
	local x = x or 1
	local y = y or 1
	local addColor = 0
	local firstColor = true
	local lastLetterPos = 1
	local arraySizeX = 0
	local arraySizeY = 0
	local tPosX = 0
	local tPosY = 0
	local bPosX = 0
	local bPosY = 0
	if (isOPos) then
		for loc = 1, stringLength do
			char = string.sub(imageString, loc, loc)
			if (char == "Y") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageString, loc - numberPos, loc - 1)
				x = tonumber(numberString)
				lastLetterPos = loc
			elseif (char == "W") then
				local numberPos = loc - (lastLetterPos + 1)
				local numberString = string.sub(imageString, loc - numberPos, loc - 1)
				y = tonumber(numberString)
				lastLetterPos = 0
			end
		end
	end
	local arrayPosX = x
	local arrayPosY = y
    local onScreen = true
	for loc = 1, stringLength do
		local char = string.sub(imageString, loc, loc)
		if (char == "C" and firstColor) then
			local numberPos = loc - (lastLetterPos + 1)
			local numberString = string.sub(imageString, loc - numberPos, loc - 1)
			local number = tonumber(numberString)
			bPosY = number
			arraySizeY = bPosY - tPosY
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
			local arrayEndY = y + arraySizeY
			while (number > 0) and (onScreen) do
				if not (addColor == 0) then
					if (arrayPosX == SettingsAPI.sizeX + 1) then
						onScreen = false
					else
						if not (isFake) then
							if (isPaint) then
								SettingsAPI.paintMap[arrayPosX][arrayPosY] = addColor
							else
								SettingsAPI.colorMap[arrayPosX][arrayPosY] = addColor
							end
						end
						paintutils.drawPixel(arrayPosX, arrayPosY, addColor)
					end
				end
				if (arrayPosY == arrayEndY) then
					arrayPosY = y
					arrayPosX = arrayPosX + 1
					number = number - 1
				else
					arrayPosY = arrayPosY + 1
					number = number - 1
				end
			end
			lastLetterPos = loc
		elseif (tonumber(char) == nil) then
			local numberPos = loc - (lastLetterPos + 1)
			local numberString = string.sub(imageString, loc - numberPos, loc - 1)
			local number = tonumber(numberString)
			if (char == "Y") then
				tPosX = number
			elseif (char == "W") then
				tPosY = number
			elseif (char == "Z") then
				bPosX = number
				arraySizeX = bPosX - tPosX
			end
			lastLetterPos = loc
		end
		if not (onScreen) then
			break
		end
	end
	term.setCursorPos(0, 0)
end

local function decompressMap(dataString)
	stringLength = #dataString
	lastLetterPos = 0
	lastLetter = nil
	firstValue = true
	inQuotes = false
	tPosX = 0
	tPosY = 0
	bPosX = 0
	bPosY = 0
	value = nil
	for loc = 1, stringLength do
		char = string.sub(dataString, loc, loc)
		if (tonumber(char) == nil) and not (char == "-") then
			if (tPosX < 0) then
				tPosX = (SettingsAPI.sizeX + tPosX) + 1
			end
			if (tPosY < 0) then
				tPosY = (SettingsAPI.sizeY + tPosY) + 1
			end
			if (bPosX < 0) then
				bPosX = (SettingsAPI.sizeX + bPosX) + 1
			end
			if (bPosY < 0) then
				bPosY = (SettingsAPI.sizeY + bPosY) + 1
			end
			if (char == "X" and firstValue) then
				firstValue = false
				lastLetterPos = loc
				lastLetter = "X"
			elseif (char == "\"") then
				if (inQuotes) then
					inQuotes = false
				else
					inQuotes = true
				end
			elseif (char == "X" or char == "E") and not (inQuotes) then
				if (lastLetter == "T" or lastLetter == "F" or lastLetter == "I") then
					numberPos = loc - (lastLetterPos + 2)
					valueString = string.sub(dataString, loc - numberPos, loc - 2)
					value = valueString
					if (lastLetter == "T") then
						SettingsAPI.textMap[tPosX][tPosY] = value
					elseif (lastLetter == "F") then
						for row = tPosX, bPosX do
							for column = tPosY, bPosY do
								SettingsAPI.functionMap[row][column] = value
							end
						end
					else
						SettingsAPI.imageMap[tPosX][tPosY] = value
					end
				else
					numberPos = loc - (lastLetterPos + 1)
					valueString = string.sub(dataString, loc - numberPos, loc - 1)
					value = tonumber(valueString)
					for row = tPosX, bPosX do
						for column = tPosY, bPosY do
							SettingsAPI.colorMap[row][column] = value
						end
					end
				end
				lastLetter = "X"
				lastLetterPos = loc
			elseif not (inQuotes) then
				numberPos = loc - (lastLetterPos + 1)
				numberString = string.sub(dataString, loc - numberPos, loc - 1)
				number = tonumber(numberString)
				lastLetterPos = loc
				if (char == "Y") then
					tPosX = number
					lastLetter = "Y"
				elseif (char == "W") then
					tPosY = number
					lastLetter = "W"
				elseif (char == "T") then
					tPosY = number
					lastLetter = "T"
				elseif (char == "Z") then
					bPosX = number
					lastLetter = "Z"
				elseif (char == "C") then
					bPosY = number
					lastLetter = "C"
				elseif (char == "F") then
					bPosY = number
					lastLetter = "F"
				elseif (char == "I") then
					tPosY = number
					lastLetter = "I"
				end
			end
		end
	end
end

function findParam(dataString)
	stringLength = #dataString
	func = nil
	param = nil
	for loc = 1, stringLength do
		char = string.sub(dataString, loc, loc)
		if (char == "(") then
			if (stringLength - loc > 1) then
				param = string.sub(dataString, loc + 1, stringLength - 1)
			end
			func = string.sub(dataString, 1, loc -1)
		end
	end
	return func, param
end

local function drawMaps()
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			if not (SettingsAPI.colorMap[row][column] == 0) then
				paintutils.drawPixel(row, column, SettingsAPI.colorMap[row][column])
			end
			if not (SettingsAPI.imageMap[row][column] == 0) then
				loadImage(SettingsAPI.imageMap[row][column], row, column)
			end
		end
	end
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			if not (SettingsAPI.textMap[row][column] == 0) then
				local stringLength = #SettingsAPI.textMap[row][column]
				local lastIndicatorPos = 0
				local textColor = 0
				local backgroundColor = 0
				for loc = 1, stringLength do
					char = string.sub(SettingsAPI.textMap[row][column], loc, loc)
					if (char == "`") then
						lastIndicatorPos = loc
					elseif (char == "~") then
						textColor = string.sub(SettingsAPI.textMap[row][column], lastIndicatorPos + 1, loc - 1)
						backgroundColor = string.sub(SettingsAPI.textMap[row][column], loc + 1, stringLength)
					end
				end
				local value = string.sub(SettingsAPI.textMap[row][column], 1, lastIndicatorPos - 1)
				term.setTextColor(tonumber(textColor))
				term.setBackgroundColor(tonumber(backgroundColor))
				term.setCursorPos(row, column)
				term.write(value)
				term.setTextColor(colors.white)
				term.setBackgroundColor(colors.black)
			end
		end
	end
	term.setCursorPos(0, 0)
end

function resetMaps()
	for row = 1, SettingsAPI.sizeX do
		SettingsAPI.colorMap[row] = {}
		SettingsAPI.textMap[row]= {}
		SettingsAPI.functionMap[row] = {}
		SettingsAPI.overrideFunctionMap[row] = {}
		SettingsAPI.imageMap[row] = {}
		for column = 1, SettingsAPI.sizeY do
			SettingsAPI.colorMap[row][column] = 0
			SettingsAPI.textMap[row][column] = 0
			SettingsAPI.functionMap[row][column] = 0
			SettingsAPI.overrideFunctionMap[row][column] = 0
			SettingsAPI.imageMap[row][column] = 0
		end
	end
end

function clearScreen()
	for row = 1, SettingsAPI.sizeX do
		for column = 1, SettingsAPI.sizeY do
			paintutils.drawPixel(row, column, colors.black)
		end
	end
end

function clearGUI()
	clearScreen()
	resetMaps()
end

function replaceGUI(mapPath, line)
	local line = line or "all"
	clearScreen()
	resetMaps()
	decompressMap(readFileData(mapPath, line))
	drawMaps()
end

function addGUI(mapPath, line)
	local line = line or "all"
	decompressMap(readFileData(mapPath, line))
	drawMaps()
end

function redrawGUI()
	clearScreen()
	drawMaps()
end

function drawText(text, x, y, textColor, backgroundColor)
	term.setCursorPos(x, y)
	term.setTextColor(textColor)
	if (backgroundColor == "keep") then
		for i = 1, #text do
			term.setBackgroundColor(SettingsAPI.colorMap[x][y])
			local char = string.sub(text, i, i)
			term.write(char)
		end
	else
		term.setBackgroundColor(backgroundColor)
		term.write(text)
	end
	term.setCursorPos(0, 0)
end
