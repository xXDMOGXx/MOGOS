local isRunning = false
local clickBindings = {}
local charBindings = {}
local keyBindings = {}
local timers = {}
local loggedEventInfo = {}
local selectedTextBox = 0

function returnEventLog()
    return loggedEventInfo
end

function setSelectedTextBox(id)
    if (type(id) ~= "number") then error("Expected number for parameter #1, got "..type(id), 2) end
    if (id == 0) then selectedTextBox = 0
    else
        local o = Display.returnObject(id)
        if (o == nil) then error("'id' is invalid: ID "..id.." is not assigned to a current object ", 2) end
        if (o.objectName ~= "TextBox") then error("Expected TextBox for parameter #1, got "..o.objectName, 2) end
        selectedTextBox = o.id
    end
end

function unselectTextBox()
    if (selectedTextBox ~= 0) then
        local textBox = Display.returnObject(selectedTextBox)
        if (textBox == nil) then selectedTextBox = 0
        else textBox:unselect() end
    end
end

function startTimer(time, func)
    local newTimer = os.startTimer(time)
    timers[newTimer] = func
end

local function drawClickBinding(id, x1, y1, x2, y2, override)
    for row = x1, x2 do
        for column = y1, y2 do
            if (override) then Settings.overrideFunctionMap[row][column] = id
            else Settings.functionMap[row][column] = id end
        end
    end
end

local function eraseClickBinding(id, x1, y1, x2, y2, override)
    local x1 = x1 or 1
    local y1 = y1 or 1
    local x2 = x2 or Settings.sizeX
    local y2 = y2 or Settings.sizeX
    for row = x1, x2 do
        for column = y1, y2 do
            if (override) then
                if (Settings.overrideFunctionMap[row][column] == id) then Settings.overrideFunctionMap[row][column] = 0 end
            elseif (Settings.functionMap[row][column] == id) then Settings.functionMap[row][column] = 0
            end
        end
    end
end

function bindClickEvent(o, func, allowDrag, override)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    if (type(func) ~= "function") then error("Expected function for parameter #2, got "..type(func), 2) end
    local allowDrag = allowDrag or false
    if (type(allowDrag) ~= "boolean") then error("Expected boolean for parameter #3, got "..type(allowDrag), 2) end
    local override = override or false
    if (type(override) ~= "boolean") then error("Expected boolean for parameter #4, got "..type(override), 2) end
    local bounds = {o.x, o.sizeX, o.y, o.sizeY}
    clickBindings[o.id] = {func, allowDrag}
    drawClickBinding(o.id, bounds[1], bounds[3], bounds[1] + bounds[2] - 1, bounds[3] + bounds[4] - 1, override)
end

function unbindClickEvent(o, override)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    local override = override or false
    if (type(override) ~= "boolean") then error("Expected boolean for parameter #2, got "..type(override), 2) end
    local bounds = {o.x, o.sizeX, o.y, o.sizeY}
    eraseClickBinding(o.id, bounds[1], bounds[3], bounds[1] + bounds[2] - 1, bounds[3] + bounds[4] - 1, override)
    clickBindings[o.id] = nil
end

function bindCharEvent(o, func, allowdDupe)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    if (type(func) ~= "function") then error("Expected function for parameter #2, got "..type(func), 2) end
    allowdDupe = allowdDupe or false
    if (type(allowdDupe) == "boolean") then
        if not (allowdDupe) then
            for i = 1, #charBindings do
                if (charBindings[i][1] == o.id) and (charBindings[i][2] == func) then return end
            end
        end
    else error("Expected boolean for parameter #3, got "..type(allowdDupe), 2) end
    table.insert(charBindings, {o.id, func})
end

function unbindCharEvent(o)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    for i = #charBindings, 1, -1 do
        if (charBindings[i][1] == o.id) then table.remove(charBindings, i) end
    end
end

function bindKeyEvent(o, key, func, allowdDupe)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    if (type(key) ~= "number") then error("Expected number for parameter #2, got "..type(key), 2) end
    if (type(func) ~= "function") then error("Expected function for parameter #3, got "..type(func), 2) end
    allowdDupe = allowdDupe or false
    if (keyBindings[key] == nil) then keyBindings[key] = {}
    elseif (type(allowdDupe) == "boolean") then
        if not (allowdDupe) then
            for i = 1, #keyBindings[key] do
                if (keyBindings[key][i][1] == o.id) then return end
            end
        end
    else error("Expected boolean for parameter #4, got "..type(allowdDupe), 2) end
    table.insert(keyBindings[key], {o.id, func})
end

function unbindKeyEvent(o, key)
    if (type(o) ~= "table") then error("Expected table for parameter #1, got "..type(o), 2) end
    if (type(key) ~= "number") then error("Expected number for parameter #2, got "..type(key), 2) end
    if (keyBindings[key] ~= nil) and (keyBindings[key] ~= {}) then
        if (#keyBindings[key] == 1) then
            if (keyBindings[key][1][1] == o.id) then keyBindings[key] = nil end
        else
            for i = #keyBindings[key], 1, -1 do
                if (keyBindings[key][i][1] == o.id) then table.remove(keyBindings[key], i) end
            end
        end
    end
end

local function runtime()
    while isRunning do
        local event, p1, x, y = os.pullEvent()
        if (event == "monitor_touch") or (event == "mouse_click") then
            loggedEventInfo = {event, p1, x, y}
            unselectTextBox()
            if (Settings.overrideFunctions) and not (Settings.overrideFunctionMap[x][y] == 0 or Settings.overrideFunctionMap[x][y] == nil) then
                clickBindings[Settings.overrideFunctionMap[x][y]][1]()
            elseif not (Settings.overrideFunctions) and not (Settings.functionMap[x][y] == 0 or Settings.functionMap[x][y] == nil) then
                clickBindings[Settings.functionMap[x][y]][1]()
            end
        elseif (event == "mouse_drag") then
            loggedEventInfo = {event, p1, x, y}
            if (Settings.overrideFunctions) and not (Settings.overrideFunctionMap[x][y] == 0 or Settings.overrideFunctionMap[x][y] == nil) then
                if (clickBindings[Settings.overrideFunctionMap[x][y]][2]) then clickBindings[Settings.overrideFunctionMap[x][y]][1]() end
            elseif not (Settings.overrideFunctions) and not (Settings.functionMap[x][y] == 0 or Settings.functionMap[x][y] == nil) then
                if (clickBindings[Settings.functionMap[x][y]][2]) then clickBindings[Settings.functionMap[x][y]][1]() end
            end
        elseif (event == "char") then
            loggedEventInfo = {event, p1}
            for i = 1, #charBindings do charBindings[i][2]() end
        elseif (event == "key") then
            loggedEventInfo = {event, p1}
            if (keyBindings[p1] ~= nil) then
                for i = 1, #keyBindings[p1] do keyBindings[p1][i][2]() end
            end
        elseif (event == "timer") then
            if (timers[p1] ~= nil) then
                timers[p1]()
                timers[p1] = nil
            end
        end
    end
end

function startRuntime()
    isRunning = true
    runtime()
end

function stopRuntime()
    isRunning = false
end
