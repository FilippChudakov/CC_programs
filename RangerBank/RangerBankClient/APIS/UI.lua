local UI = {}

-- Настройки экрана
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
function UI.createInput(x, y, w, h, default, max_sym)
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
        max_symbols = max_sym or 20
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
    
    -- Начальное выделение для текущего экрана (исправлено)
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
        
        if event == "mouse_click" then
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
            -- Обработка навигации внутри массива кнопок
            if currentArray and currentArray.isNavigatingInside then
                if key == 264 or key == 83 then -- Down/S
                    currentArray.internalSelected = math.min(currentArray.internalSelected + 1, #currentArray.buttons)
                    -- Прокрутка если нужно
                    if currentArray.internalSelected > currentArray.scrollOffset + currentArray.visibleRows then
                        currentArray.scrollOffset = currentArray.scrollOffset + 1
                    end
                elseif key == 265 or key == 87 then -- Up/W
                    currentArray.internalSelected = math.max(currentArray.internalSelected - 1, 1)
                    -- Прокрутка если нужно
                    if currentArray.internalSelected < currentArray.scrollOffset + 1 then
                        currentArray.scrollOffset = math.max(0, currentArray.scrollOffset - 1)
                    end
                elseif key == 257 then -- Enter
                    if currentArray.buttons[currentArray.internalSelected].onClick then
                        currentArray.buttons[currentArray.internalSelected].onClick()
                    end
                elseif key == 88 then -- X - выход из режима навигации
                    currentArray.isNavigatingInside = false
                    for _, btn in ipairs(currentArray.buttons) do
                        btn.selected = false
                    end
                end
            else
                -- Обычная навигация между элементами
                if key == 264 or key == 83 then -- Down/S
                    local total = #screen.buttons + #screen.inputs + #screen.buttonArrays
                    UI.selected = (UI.selected % total) + 1
                elseif key == 265 or key == 87 then -- Up/W
                    local total = #screen.buttons + #screen.inputs + #screen.buttonArrays
                    UI.selected = ((UI.selected - 2) % total) + 1
                elseif key == 257 then -- Enter
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

return UI
