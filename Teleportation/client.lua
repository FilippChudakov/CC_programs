local places = {}
local places_keys = {}
local temp = {}

local UI = {}

UI.screenWidth, UI.screenHeight = term.getSize()
UI.selected = 1
UI.scrollOffsets = {}
UI.screens = {}
UI.currentScreen = 1
UI.running = false
UI.BGtheme = colors.black
UI.button_Theme = {}
UI.button_Theme["bg"] = colors.black
UI.button_Theme["light_bg"] = colors.gray
UI.button_Theme["text"] = colors.white
UI.button_array_Theme = {}
UI.button_array_Theme["border"] = colors.gray
UI.button_array_Theme["light_border"] = colors.lightGray
UI.button_array_Theme["bg"] = colors.black
UI.button_array_Theme["light_bg"] = colors.gray
UI.button_array_Theme["text"] = colors.white
UI.button_array_Theme["infield"] = colors.black
UI.pasteTextFunction = function(text) return text end
UI.key_function = function() return end
UI.key = nil


function UI.exit()
    UI.running = false
end

-- Создание нового экрана
function UI.createScreen()
    local screen = {
        buttons = {},
        inputs = {},
        labels = {},
        buttonArrays = {}
    }
    table.insert(UI.screens, screen)
    return #UI.screens
end

-- Переключение на экран по ID
function UI.setScreen(id)
    local screen = UI.screens[UI.currentScreen]
    for _, inp in ipairs(screen.inputs) do
        if not inp.isPlaceholder then
            inp.text = inp.Placeholder
            inp.isPlaceholder = true
            inp.cursorPos = 1
        end
    end
    if id >= 1 and id <= #UI.screens then
        UI.currentScreen = id
        UI.selected = 1
        return true
    end
    return false
end

function UI.addButton(screenId, button)
    table.insert(UI.screens[screenId].buttons, button)
end

function UI.addInput(screenId, input)
    table.insert(UI.screens[screenId].inputs, input)
end

function UI.addLabel(screenId, label)
    table.insert(UI.screens[screenId].labels, label)
end

function UI.addButtonArray(screenId, buttonArray)
    table.insert(UI.screens[screenId].buttonArrays, buttonArray)
end

function UI.createLabel(text, x, y, fgColor, bgColor)
    return {
        type = "label",
        text = text,
        x = x,
        y = y,
        fgColor = fgColor or colors.white,
        bgColor = bgColor or colors.black,
        visible = true
    }
end

-- Создание кнопки
function UI.createButton(text, x, y, w, h, onClick)
    return {
        type = "button",
        text = text,
        x = x,
        y = y,
        width = w or (#text + 4),
        height = h or 3,
        onClick = onClick,
        selected = false,
        bgColor = UI.button_Theme["bg"],
        lightbgColor = UI.button_Theme["light_bg"],
        textColor = UI.button_Theme["text"]
    }
end

-- Создание массива кнопок
function UI.createButtonArray(x, y, w, h, filePath, visibleRows, onClickHandler)
    local buttons = {}
    if fs.exists(filePath) then
        for line in io.lines(filePath) do
            if line and line ~= "" then
                -- Создаем замыкание для каждой кнопки
                local buttonText = line
                table.insert(buttons, {
                    text = buttonText,
                    onClick = function()
                        if onClickHandler then
                            onClickHandler(buttonText) -- Передаем корректный текст
                        end
                    end,
                    selected = false,
                    isButtonArrayItem = true
                })
            end
        end
    end
    
    return {
        type = "buttonArray",
        x = x,
        y = y,
        width = w,
        height = h,
        buttons = buttons,
        visibleRows = visibleRows or math.max(1, h - 2),
        scrollOffset = 0,
        selected = false,
        isNavigatingInside = false,
        internalSelected = 1,
        onClickHandler = onClickHandler,
        borderColor = UI.button_array_Theme["border"],
        lightborderColor = UI.button_array_Theme["light_border"],
        bgColor = UI.button_array_Theme["bg"],
        lightbgColor = UI.button_array_Theme["light_bg"],
        textColor = UI.button_array_Theme["text"],
        infieldColor = UI.button_array_Theme["infield"]
    }
end

function UI.updateButtonArray(buttonArray, filePath)
    if not buttonArray or buttonArray.type ~= "buttonArray" then
        error("Expected ButtonArray object", 2)
    end

    local newButtons = {}
    if fs.exists(filePath) then
        for line in io.lines(filePath) do
            if line and line ~= "" then
                local buttonText = line
                table.insert(newButtons, {
                    text = buttonText,
                    onClick = function()
                        if buttonArray.onClickHandler then
                            buttonArray.onClickHandler(buttonText)
                        end
                    end,
                    selected = false,
                    isButtonArrayItem = true
                })
            end
        end
    end

    buttonArray.buttons = newButtons
    return buttonArray
end

-- Создание поля ввода
function UI.createInput(x, y, w, h, default, max_sym, is_secret)
    return {
        type = "input",
        text = default or "",
        x = x,
        y = y,
        width = w or 20,
        height = h or 3,
        active = false,
        selected = false,
        cursorPos = 1,
        isPlaceholder = default ~= nil,
        Placeholder = default or "",
        max_symbols = max_sym or 20,
        is_secret = is_secret or false
    }
end

-- Отрисовка интерфейса
function UI.draw(buttons, inputs, labels, buttonArrays)
    term.setBackgroundColor(UI.BGtheme)
    term.clear()
    
    -- Отрисовка текстовых виджетов
    for i, label in ipairs(labels or {}) do
        if label.visible then
            term.setTextColor(label.fgColor)
            term.setBackgroundColor(label.bgColor)
            term.setCursorPos(label.x, label.y)
            term.write(label.text)
        end
    end
    
    -- Отрисовка кнопок
    for i, btn in ipairs(buttons or {}) do
        local bg = btn.selected and btn.lightbgColor or btn.bgColor
        term.setBackgroundColor(bg)
        
        for dy = 0, btn.height - 1 do
            term.setCursorPos(btn.x, btn.y + dy)
            term.write((" "):rep(btn.width))
        end
        
        term.setBackgroundColor(bg)
        term.setTextColor(btn.textColor)
        term.setCursorPos(
            btn.x + math.floor((btn.width - #btn.text)/2),
            btn.y + math.floor(btn.height/2)
        )
        term.write(btn.text)
    end
    
    -- Отрисовка полей ввода
    for i, inp in ipairs(inputs) do
        local border = inp.active and colors.orange or inp.selected and colors.lime or colors.gray
        term.setBackgroundColor(border)
        
        -- Рамка поля
        for dy = 0, inp.height - 1 do
            term.setCursorPos(inp.x, inp.y + dy)
            term.write((" "):rep(inp.width))
        end
        
        -- Внутренняя область
        term.setBackgroundColor(colors.white)
        for dy = 1, inp.height - 2 do
            term.setCursorPos(inp.x + 1, inp.y + dy)
            term.write((" "):rep(inp.width - 2))
        end
        
        -- Отображение текста с учетом позиции курсора
        local displayText = inp.text
        local textOffset = 0
        
        local maxVisible = inp.width - 4
        local textOffset = math.max(0, inp.cursorPos - maxVisible)
        if inp.cursorPos > maxVisible then
            displayText = inp.text:sub(textOffset + 1, textOffset + maxVisible)
        else
            displayText = inp.text:sub(1, maxVisible)
        end

        if inp.is_secret and not inp.isPlaceholder then
            displayText = string.rep("*", #displayText)
        end
        
        term.setCursorPos(inp.x + 2, inp.y + 1)
        term.setBackgroundColor(colors.white)
        term.setTextColor(inp.isPlaceholder and colors.gray or colors.black)
        term.write(displayText)
        
        -- Курсор (если поле активно)
        if inp.active then
            local cursorX = inp.x + 2 + (inp.cursorPos - textOffset - 1)
            if cursorX >= inp.x + 2 and cursorX < inp.x + inp.width - 2 then
                term.setCursorPos(cursorX, inp.y + 1)
                term.setBackgroundColor(colors.red)
                term.write(" ")
            end
        end
    end

        -- Отрисовка массивов кнопок
    for i, array in ipairs(buttonArrays or {}) do
        local border = array.selected and array.lightborderColor or array.borderColor
        term.setBackgroundColor(border)

        -- Рамка
        for dy = 0, array.height - 1 do
            term.setCursorPos(array.x, array.y + dy)
            term.write((" "):rep(array.width))
        end

        -- Внутренняя область
        term.setBackgroundColor(array.infieldColor)
        for dy = 1, array.height - 2 do
            term.setCursorPos(array.x + 1, array.y + dy)
            term.write((" "):rep(array.width - 2))
        end

        -- Отрисовка видимых кнопок
        for i = 1, array.visibleRows do
            local btnIndex = i + array.scrollOffset
            if btnIndex <= #array.buttons then
                local btn = array.buttons[btnIndex]
                local btnY = array.y + 1 + (i-1)

                if btnY < array.y + array.height - 1 then
                    local bg = (btn.selected and array.lightbgColor) or 
                               (array.isNavigatingInside and btnIndex == array.internalSelected and colors.orange) or 
                               array.bgColor
                    term.setBackgroundColor(bg)
                    term.setCursorPos(array.x + 1, btnY)
                    term.write((" "):rep(array.width - 2))

                    term.setTextColor(array.textColor)
                    term.setCursorPos(
                        array.x + math.floor((array.width - #btn.text)/2),
                        btnY
                    )
                    term.write(btn.text)
                end
            end
        end
    end
end

-- Обработка текстового ввода
function UI.handleTextInput(input, buttons, inputs, labels, buttonArrays)
    -- Очистка плейсхолдера при первом клике
    if input.isPlaceholder then
        input.text = ""
        input.isPlaceholder = false
    end
    
    input.active = true
    
    while input.active do
        UI.draw(buttons, inputs, labels, buttonArrays)
        
        local event, key, x, y = os.pullEvent()
        
        if event == "char" and input.max_symbols >= #input.text then
            -- Всегда разрешаем ввод
            input.text = input.text:sub(1, input.cursorPos - 1) .. key .. input.text:sub(input.cursorPos)
            input.cursorPos = input.cursorPos + 1
        elseif event == "key" then
            if key == 257 then -- Enter
                input.active = false
                if input.text == "" then
                    input.text = input.Placeholder
                    input.isPlaceholder = true
                end
            elseif key == 259 then -- Backspace
                if input.cursorPos > 1 then
                    -- Удаление символа перед курсором
                    input.text = input.text:sub(1, input.cursorPos - 2) .. input.text:sub(input.cursorPos)
                    input.cursorPos = input.cursorPos - 1
                end
            elseif key == 263 then -- Left arrow
                if input.cursorPos > 1 then
                    input.cursorPos = input.cursorPos - 1
                end
            elseif key == 262 then -- Right arrow
                if input.cursorPos <= #input.text then
                    input.cursorPos = input.cursorPos + 1
                end
            end
            
        elseif event == "mouse_click" then
            -- Проверяем, был ли клик вне поля ввода
            if x < input.x or x >= input.x + input.width or
               y < input.y or y >= input.y + input.height then
                input.active = false
                if input.text == "" then
                    input.text = input.Placeholder
                    input.isPlaceholder = true
                end
            else
                -- Устанавливаем курсор в позицию клика
                local clickPos = x - input.x - 1
                input.cursorPos = math.max(1, math.min(clickPos, #input.text + 1))
            end
        end
    end
end


-- Основной цикл обработки событий (исправленная часть)
function UI.run()
    UI.running = true

    if #UI.screens == 0 then
        UI.createScreen()
    end
    
    local screen = UI.screens[UI.currentScreen]
    UI.selected = 1
    
    -- Сброс всех выделений перед установкой нового
    for _, btn in ipairs(screen.buttons) do btn.selected = false end
    for _, inp in ipairs(screen.inputs) do inp.selected = false end
    for _, array in ipairs(screen.buttonArrays) do 
        array.selected = false
        array.isNavigatingInside = false
        for _, btn in ipairs(array.buttons) do btn.selected = false end
    end
    
    -- Установка правильного начального выделения
    if #screen.buttons > 0 then
        screen.buttons[1].selected = true
    elseif #screen.inputs > 0 then
        screen.inputs[1].selected = true
    elseif #screen.buttonArrays > 0 then
        screen.buttonArrays[1].selected = true
    end

    UI.draw(screen.buttons, screen.inputs, screen.labels, screen.buttonArrays)
    
    while UI.running do
        local event, key, x, y = os.pullEvent()
        local screen = UI.screens[UI.currentScreen] -- Получаем текущий экран
        
        -- Получаем текущий выделенный массив кнопок (если есть)
        local currentArray
        if UI.selected > #screen.buttons + #screen.inputs then
            local arrayIndex = UI.selected - #screen.buttons - #screen.inputs
            if arrayIndex >= 1 and arrayIndex <= #screen.buttonArrays then
                currentArray = screen.buttonArrays[arrayIndex]
            end
        end

        if event == "paste" then
            local pasteText = key
            pasteText = pasteText:gsub("\n", " "):gsub("\r", "")

            UI.pasteTextFunction(pasteText)
        elseif event == "mouse_click" then
            -- Сброс режима навигации для всех массивов кнопок
            for _, array in ipairs(screen.buttonArrays) do
                array.isNavigatingInside = false
                for _, btn in ipairs(array.buttons) do
                    btn.selected = false
                end
            end
            
            -- Обработка кликов по кнопкам
            for i, btn in ipairs(screen.buttons) do
                if x >= btn.x and x < btn.x + btn.width and
                   y >= btn.y and y < btn.y + btn.height then
                    UI.selected = i
                    if btn.onClick then btn.onClick() end
                end
            end
            
            -- Обработка кликов по полям ввода
            for i, inp in ipairs(screen.inputs) do
                if x >= inp.x and x < inp.x + inp.width and
                   y >= inp.y and y < inp.y + inp.height then
                    UI.selected = #screen.buttons + i
                    UI.handleTextInput(inp, screen.buttons, screen.inputs, screen.labels)
                end
            end
            
            -- Обработка кликов по массивам кнопок
            local clickedOnArray = false
            for i, array in ipairs(screen.buttonArrays) do
                if x >= array.x and x < array.x + array.width and
                   y >= array.y and y < array.y + array.height then
                    UI.selected = #screen.buttons + #screen.inputs + i
                    clickedOnArray = true
                    
                    -- Проверяем клик по конкретной кнопке
                    local relativeY = y - array.y
                    local btnIndex = array.scrollOffset + relativeY
                    if btnIndex >= 1 and btnIndex <= #array.buttons then
                        array.internalSelected = btnIndex
                        array.isNavigatingInside = true
                        array.buttons[btnIndex].onClick()
                    end
                end
            end
            
            -- Если клик был вне всех виджетов, сбрасываем выделения
            if not clickedOnArray and 
               not (UI.selected <= #screen.buttons and 
                    x >= screen.buttons[UI.selected].x and x < screen.buttons[UI.selected].x + screen.buttons[UI.selected].width and
                    y >= screen.buttons[UI.selected].y and y < screen.buttons[UI.selected].y + screen.buttons[UI.selected].height) and
               not (UI.selected > #screen.buttons and UI.selected <= #screen.buttons + #screen.inputs and
                    x >= screen.inputs[UI.selected - #screen.buttons].x and x < screen.inputs[UI.selected - #screen.buttons].x + screen.inputs[UI.selected - #screen.buttons].width and
                    y >= screen.inputs[UI.selected - #screen.buttons].y and y < screen.inputs[UI.selected - #screen.buttons].y + screen.inputs[UI.selected - #screen.buttons].height) then
                
                if currentArray then
                    currentArray.isNavigatingInside = false
                    for _, btn in ipairs(currentArray.buttons) do
                        btn.selected = false
                    end
                end
            end
        
        elseif event == "key" then
            -- Доп. действие
            if key == UI.key and UI.key then
                UI.key_function()
            end
            -- Обработка навигации внутри массива кнопок
            if currentArray and currentArray.isNavigatingInside then
                if key == keys.down or key == keys.s then -- Down/S
                    currentArray.internalSelected = math.min(currentArray.internalSelected + 1, #currentArray.buttons)
                    -- Прокрутка если нужно
                    if currentArray.internalSelected > currentArray.scrollOffset + currentArray.visibleRows then
                        currentArray.scrollOffset = currentArray.scrollOffset + 1
                    end
                elseif key == keys.up or key == keys.w then -- Up/W
                    currentArray.internalSelected = math.max(currentArray.internalSelected - 1, 1)
                    -- Прокрутка если нужно
                    if currentArray.internalSelected < currentArray.scrollOffset + 1 then
                        currentArray.scrollOffset = math.max(0, currentArray.scrollOffset - 1)
                    end
                elseif key == keys.enter then -- Enter
                    if currentArray.buttons[currentArray.internalSelected].onClick then
                        currentArray.buttons[currentArray.internalSelected].onClick()
                    end
                elseif key == keys.x then -- X - выход из режима навигации
                    currentArray.isNavigatingInside = false
                    for _, btn in ipairs(currentArray.buttons) do
                        btn.selected = false
                    end
                end
            else
                -- Обычная навигация между элементами
                if key == keys.down or key == keys.s then -- Down/S
                    local total = #screen.buttons + #screen.inputs + #screen.buttonArrays
                    UI.selected = (UI.selected % total) + 1
                elseif key == keys.up or key == keys.w then -- Up/W
                    local total = #screen.buttons + #screen.inputs + #screen.buttonArrays
                    UI.selected = ((UI.selected - 2) % total) + 1
                elseif key == keys.enter then -- Enter
                    if UI.selected <= #screen.buttons then
                        if screen.buttons[UI.selected].onClick then 
                            screen.buttons[UI.selected].onClick() 
                        end
                    elseif UI.selected <= #screen.buttons + #screen.inputs then
                        local inp = screen.inputs[UI.selected - #screen.buttons]
                        UI.handleTextInput(inp, screen.buttons, screen.inputs, screen.labels)
                    elseif currentArray then
                        -- Вход в режим навигации по массиву кнопок
                        currentArray.isNavigatingInside = true
                        currentArray.internalSelected = math.min(currentArray.scrollOffset + 1, #currentArray.buttons)
                    end
                end
            end
        
        elseif event == "mouse_scroll" then
            -- Обработка прокрутки только для выделенного массива кнопок
            if UI.selected > #screen.buttons + #screen.inputs then
                local arrayIndex = UI.selected - #screen.buttons - #screen.inputs
                if arrayIndex >= 1 and arrayIndex <= #screen.buttonArrays then
                    local array = screen.buttonArrays[arrayIndex]
                    if array and #array.buttons > 0 then  -- Добавляем проверку на наличие кнопок
                        if key == -1 then -- Прокрутка вверх
                            array.scrollOffset = math.max(0, array.scrollOffset - 1)
                            if array.isNavigatingInside then
                                array.internalSelected = math.max(1, array.internalSelected - 1)
                            end
                        elseif key == 1 then -- Прокрутка вниз
                            -- Исправляем расчет максимального смещения
                            local maxOffset = math.max(0, #array.buttons - array.visibleRows)
                            array.scrollOffset = math.min(maxOffset, array.scrollOffset + 1)
                            if array.isNavigatingInside then
                                array.internalSelected = math.min(#array.buttons, array.internalSelected + 1)
                            end
                        end
                    end
                end
            end
        end
        
        -- Обновление выделения
        for i, btn in ipairs(screen.buttons) do
            btn.selected = (i == UI.selected)
        end
        for i, inp in ipairs(screen.inputs) do
            inp.selected = (i + #screen.buttons == UI.selected)
        end
        for i, array in ipairs(screen.buttonArrays) do
            array.selected = (i + #screen.buttons + #screen.inputs == UI.selected)
            
            -- Обновление выделения внутренних кнопок
            if array.isNavigatingInside then
                for j, btn in ipairs(array.buttons) do
                    btn.selected = (j == array.internalSelected)
                end
            else
                for _, btn in ipairs(array.buttons) do
                    btn.selected = false
                end
            end
        end
        
        UI.draw(screen.buttons, screen.inputs, screen.labels, screen.buttonArrays)
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

local crypto = {}

math.randomseed(os.epoch and os.epoch("utc") or os.time())

local function rand(max)
    return math.random(1, max)
end

local function toHex(str)
    return (str:gsub(".", function(c)
        return string.format("%02X", c:byte())
    end))
end

local function fromHex(hex)
    return (hex:gsub("%x%x", function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

function crypto.rc4(data, key)
    key = tostring(key)
    if not key or not data then
        return
    end
    local S = {}
    for i = 0, 255 do S[i] = i end
    local j = 0
    for i = 0, 255 do
        j = (j + S[i] + key:byte((i % #key) + 1)) % 256
        S[i], S[j] = S[j], S[i]
    end
    local i = 0
    j = 0
    local chars = {}
    for k = 1, #data do
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        local K = S[(S[i] + S[j]) % 256]
        table.insert(chars, string.char(bit32.bxor(data:byte(k), K)))
    end
    return table.concat(chars)
end

function crypto.encrypt(message, key)
    local raw = crypto.rc4(message, key)
    return toHex(raw)
end

function crypto.decrypt(message, key)
    local raw = fromHex(message)
    return crypto.rc4(raw, key)
end

local P = 16777213
local G = 2

local function modPow(b, e, m)
    local result = 1
    b = b % m
    while e > 0 do
        if e % 2 == 1 then
            result = (result * b) % m
        end
        e = math.floor(e / 2)
        b = (b * b) % m
    end
    return result
end

function crypto.generateKeyPair()
    local private = rand(P - 2)
    local public = modPow(G, private, P)
    return public, private
end

function crypto.getSharedSecret(others_public, my_private)
    local base = tonumber(others_public)
    if not base then 
        error("Public isn't a number!")
    end
    
    local secret_num = modPow(base, my_private, P)
    return toHex(tostring(secret_num))
end

Short = {}

function Short.Write(text, filepath)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

function Short.Read(filepath)
    local file = fs.open(filepath, "r")
    if file == nil then
        return nil
    end
    local text = file.readAll()
    file.close()
    return text
end

function Short.Load_places()
    local filePath = "AppData/places.txt"
    if fs.exists(filePath) then
        local content = Short.Read(filePath)
        if content then
            local success, data = pcall(textutils.unserialize, content)
            if success and type(data) == "table" then
                places = data
            else
                printError("Failed to load places (invalid format)")
            end
        end
    end
end

function Short.Update_names()
    local numeratelog = ""

    i = 1
    for name, _ in pairs(places) do
        numeratelog = numeratelog..i..". "..name.."\n"
        i = i + 1
    end

    Short.Write(numeratelog, "AppData/place_names.txt")
end

local pub, priv
if not fs.exists("AppData/public.key") or not fs.exists("AppData/private.key") then
    pub, priv = crypto.generateKeyPair()
    pub = tostring(pub)
    priv = tostring(priv)
    Short.Write(pub, "AppData/public.key")
    Short.Write(priv, "AppData/private.key")
else
    pub = Short.Read("AppData/public.key")
    priv = Short.Read("AppData/private.key")
end

if fs.exists("AppData/places.txt") then
    Short.Load_places()
else
    Short.Write(textutils.serialize(places), "AppData/places.txt")
end

local Network = {}

Network.counters = {}
Network.sessionKeys = {}

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.close)
end

function Network.handshake(ID, Protocol)
    rednet.send(ID, "key_request", Protocol)
    local id, serverPub = rednet.receive(Protocol, 2)

    if not id then
        print("Error: No response from server.")
        return false
    end

    local clientPub, clientPriv = crypto.generateKeyPair()

    Network.sessionKeys[id] = crypto.getSharedSecret(serverPub, clientPriv)
    Network.counters[id] = 0
    rednet.send(id, {"key", clientPub}, Protocol)
    return true
end

function Network.send(ID, data, Protocol, key)
    Network.counters[ID] =
        (Network.counters[ID] or 0) + 1

    local packet = {
        counter = Network.counters[ID],
        data = data
    }

    local serialized = textutils.serialize(packet)

    local encrypted = crypto.encrypt(serialized,key)

    rednet.send(ID, encrypted, protocol)
end

function Network.enc_send(ID, Message, Protocol)
    local data = crypto.encrypt(textutils.serialize(Message), Network.sessionKeys[ID], false)
    rednet.send(ID, data, Protocol)
end

Network.open()

UI.BGtheme = colors.cyan
UI.button_Theme["bg"] = colors.lightGray
UI.button_Theme["light_bg"] = colors.white
UI.button_Theme["text"] = colors.black
UI.button_array_Theme["border"] = colors.gray
UI.button_array_Theme["light_border"] = colors.lightGray
UI.button_array_Theme["bg"] = colors.lightGray
UI.button_array_Theme["light_bg"] = colors.white
UI.button_array_Theme["text"] = colors.black
UI.button_array_Theme["infield"] = colors.white

UI.key = keys.rightBracket

local main_screen = UI.createScreen()
local newtp_screen = UI.createScreen()
local tp_screen = UI.createScreen()
local confirm_screen = UI.createScreen()
local list_screen = UI.createScreen()
local debug_screen = UI.createScreen()

local version = "teleport v1.0"

UI.addLabel(main_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))
UI.addLabel(newtp_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))
UI.addLabel(tp_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))
UI.addLabel(confirm_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))
UI.addLabel(list_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))
UI.addLabel(debug_screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.cyan))

UI.addLabel(main_screen, UI.createLabel("", 1, 1, colors.black, colors.cyan))
UI.addLabel(debug_screen, UI.createLabel("", 1, 1, colors.black, colors.cyan))

UI.addLabel(list_screen, UI.createLabel("id:", (UI.screenWidth/2)-9, 3, colors.black, colors.cyan))
UI.addLabel(list_screen, UI.createLabel("pub:", (UI.screenWidth/2)-9, 4, colors.black, colors.cyan))
UI.addLabel(list_screen, UI.createLabel("counter:", (UI.screenWidth/2)-9, 5, colors.black, colors.cyan))

UI.key_function = function()
    UI.screens[list_screen].labels[2].text = "id:"
    UI.screens[list_screen].labels[3].text = "pub:"
    UI.screens[list_screen].labels[4].text = "counter:"
    UI.setScreen(debug_screen)
end

-- Main screen
UI.addButton(main_screen, UI.createButton("Teleport", math.floor(UI.screenWidth/2)-6, math.floor(UI.screenHeight/2)-1-5, 12, 3, function()
    UI.screens[main_screen].labels[2].text = ""
    UI.setScreen(tp_screen)
end))

UI.addButton(main_screen, UI.createButton("New tp", math.floor(UI.screenWidth/2)-6, math.floor(UI.screenHeight/2)-1+0, 12, 3, function()
    UI.screens[main_screen].labels[2].text = ""
    UI.setScreen(newtp_screen)
end))

UI.addButton(main_screen, UI.createButton("Quit", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+5, 8, 3, function()
    Network.close()
    UI.exit()
end))

UI.addButton(main_screen, UI.createButton("List", math.floor(UI.screenWidth/2)-13, math.floor(UI.screenHeight/2)-1+10, 8, 3, function()
    Short.Update_names()
    UI.updateButtonArray(UI.screens[list_screen].buttonArrays[1], "AppData/place_names.txt")
    UI.screens[main_screen].labels[2].text = ""
    UI.setScreen(list_screen)
end))

-- Teleport screen
UI.addInput(tp_screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-6, 16, 3, "Enter Place", 10))
UI.addInput(tp_screen, UI.createInput(math.floor(UI.screenWidth/2)-7, math.floor(UI.screenHeight/2)-1-2, 14, 3, "Enter Pass", 10, true))

UI.addButton(tp_screen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+2, 8, 3, function()
    local Place = UI.screens[tp_screen].inputs[1].text
    local Pass = UI.screens[tp_screen].inputs[2].text


    if UI.screens[tp_screen].inputs[1].isPlaceholder or
        UI.screens[tp_screen].inputs[2].isPlaceholder then
        return
    end

    if not places[Place] then
        UI.screens[main_screen].labels[2].text = "No such place!"
        UI.screens[main_screen].labels[2].fgColor = colors.red
        UI.setScreen(main_screen)
        return
    end

    places_keys[Place] = crypto.getSharedSecret(places[Place].server_pub, tonumber(priv))

    local data = {"teleport", ["password"] = Pass}


    local message = crypto.encrypt(textutils.serialize(data), places_keys[Place]+(places[Place]["counter"] or 0))
    rednet.send(places[Place].server_id, message, "Teleport")
    
    temp["Place"] = Place
    UI.setScreen(confirm_screen)
end))

UI.addButton(tp_screen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.setScreen(main_screen)
end))

-- New teleport screen
UI.addInput(newtp_screen, UI.createInput(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-7, 18, 3, "Enter Place", 10))
UI.addInput(newtp_screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-4, 16, 3, "Enter ID", 10))
UI.addInput(newtp_screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-1, 16, 3, "Enter Pub", 10))

UI.addButton(newtp_screen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+3, 8, 3, function()
    local Place = UI.screens[newtp_screen].inputs[1].text
    local id = UI.screens[newtp_screen].inputs[2].text
    local pub = UI.screens[newtp_screen].inputs[3].text
    if UI.screens[newtp_screen].inputs[1].isPlaceholder or
        UI.screens[newtp_screen].inputs[2].isPlaceholder or
        UI.screens[newtp_screen].inputs[3].isPlaceholder then
        return
    end

    places[Place] = {}
    places[Place].server_id = tonumber(id)
    places[Place].server_pub = tonumber(pub)

    Short.Write(textutils.serialize(places), "AppData/places.txt")

    UI.screens[main_screen].labels[2].text = "Complete!"
    UI.screens[main_screen].labels[2].fgColor = colors.lime
    UI.setScreen(main_screen)
end))

UI.addButton(newtp_screen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.setScreen(main_screen)
end))

-- Confirm screen
UI.addLabel(confirm_screen, UI.createLabel("Is it teleported you?", math.floor(UI.screenWidth/2)-10, math.floor(UI.screenHeight/2)-1-2, colors.black, colors.cyan))
UI.addButton(confirm_screen, UI.createButton("Yes", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+1, 12, 3, function()
    places[temp["Place"]]["counter"] = (places[temp["Place"]]["counter"] or 0)+1
    Short.Write(textutils.serialize(places), "AppData/places.txt")
    temp["Place"] = nil

    UI.screens[main_screen].labels[2].text = "Sended!"
    UI.screens[main_screen].labels[2].fgColor = colors.lime
    UI.setScreen(main_screen)
end))
UI.addButton(confirm_screen, UI.createButton("No", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+5, 12, 3, function()
    temp["Place"] = nil
    UI.screens[main_screen].labels[2].text = "Error!"
    UI.screens[main_screen].labels[2].fgColor = colors.red
    UI.setScreen(main_screen)
end))

-- List screen
UI.addButtonArray(list_screen, UI.createButtonArray(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-1, 18, 7, "AppData/place_names.txt", 5, 
    function(selectedText)
        local record = string.match(selectedText, "%d+%.%s*(.*)")
        if not record then return end
        
        local place = places[record]
            
        UI.screens[list_screen].labels[2].text = "id: "..place.server_id
        UI.screens[list_screen].labels[3].text = "pub: "..place.server_pub
        UI.screens[list_screen].labels[4].text = "counter: " ..(place.counter or 0)
    end
))

UI.addButton(list_screen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.screens[list_screen].labels[2].text = "id:"
    UI.screens[list_screen].labels[3].text = "pub:"
    UI.screens[list_screen].labels[4].text = "counter:"
    UI.setScreen(main_screen)
end))

-- Debug screen
UI.addInput(debug_screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-6, 16, 3, "Enter Place", 10))

UI.addButton(debug_screen, UI.createButton("+1 to Counter", math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-3, 16, 3, function()
    local Place = UI.screens[debug_screen].inputs[1].text
    if places[Place] then
        places[Place]["counter"] = (places[Place]["counter"] or 0) + 1
        Short.Write(textutils.serialize(places), "AppData/places.txt")
        UI.screens[debug_screen].labels[2].text = "Counter: "..places[Place]["counter"]
        UI.screens[debug_screen].labels[2].fgColor = colors.lime
    else
        UI.screens[debug_screen].labels[2].text = "No such place!"
        UI.screens[debug_screen].labels[2].fgColor = colors.red
    end
end))

UI.addButton(debug_screen, UI.createButton("Reset Counter", math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1, 16, 3, function()
    local Place = UI.screens[debug_screen].inputs[1].text
    if places[Place] then
        if places[Place]["counter"] then
            places[Place]["counter"] = nil
            Short.Write(textutils.serialize(places), "AppData/places.txt")
            UI.screens[debug_screen].labels[2].text = "Counter Reset!"
            UI.screens[debug_screen].labels[2].fgColor = colors.lime
        else
            UI.screens[debug_screen].labels[2].text = "Counter is already 0!"
            UI.screens[debug_screen].labels[2].fgColor = colors.yellow
        end
    else
        UI.screens[debug_screen].labels[2].text = "No such place!"
        UI.screens[debug_screen].labels[2].fgColor = colors.red
    end
end))

UI.addButton(debug_screen, UI.createButton("Delete", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+3, 8, 3, function()
    local Place = UI.screens[debug_screen].inputs[1].text
    if places[Place] then
        places[Place] = nil
        Short.Write(textutils.serialize(places), "AppData/places.txt")
        UI.screens[debug_screen].labels[2].text = "Deleted!"
        UI.screens[debug_screen].labels[2].fgColor = colors.lime
    else
        UI.screens[debug_screen].labels[2].text = "No such place!"
        UI.screens[debug_screen].labels[2].fgColor = colors.red
    end
end))

UI.addButton(debug_screen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.screens[debug_screen].labels[2].text = ""
    UI.setScreen(main_screen)
end))


local function gpsConnect()
    local gpsID = rednet.lookup("GPS", "GPS_Server")
    if gpsID then
        Network.handshake(gpsID, "GPS")
    end
    return gpsID
end

local function gpsTracker()
    local gpsID = gpsConnect()
    gpsTimer = os.startTimer(20)
    while true do
        local event, key, x, y = os.pullEvent()
        if event == "timer" and key == gpsTimer then
            if gpsID then
                local x, y, z = gps.locate(1, false)


                if x or y or z then
                    local data = {"GPS:save", {x, y, z}}
                    Network.enc_send(gpsID, data, "GPS")
                end
            else
                local gpsID = gpsConnect()
            end
            gpsTimer = os.startTimer(10)
            
        end
    end
end

parallel.waitForAny(UI.run, gpsTracker)

Network.close()
