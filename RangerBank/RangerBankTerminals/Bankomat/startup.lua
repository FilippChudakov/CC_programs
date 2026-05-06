os.pullEvent = os.pullEventRaw

local UI = dofile("APIS/UI.lua")
local Network = dofile("APIS/Network.lua")
local Short = dofile("APIS/ShortCuts.lua")
local version = Network.version()

Network.open()
Network.handshake(Network.ID, "RangerBank")

local pass = Short.Read("RangerBankData/SecretPass.txt")
if not pass or pass == "" then
    term.clear()
    term.setCursorPos(1,1)
    print("Error: SecretPass not found or corrupted.")
    return 
end

-- Find peripheral devices
local function findPeripheral(periphType)
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        if peripheral.getType(name) == periphType then
            return peripheral.wrap(name), name
        end
    end
    return nil
end

local function Move_money()
    local barrel, barrelName = findPeripheral("minecraft:barrel")
    local chest, chestName = findPeripheral("supplementaries:safe")
    
    if not barrel or not chest then return 0 end
    
    local totalMoved = 0
    local contents = barrel.list()
    
    for slot, item in pairs(contents) do
        if item.name == "minecraft:diamond" then
            local remaining = item.count
            while remaining > 0 do
                local amountToMove = math.min(remaining, 64)
                local transferred = barrel.pushItems(chestName, slot, amountToMove)
                if transferred == 0 then break end
                totalMoved = totalMoved + transferred
                remaining = remaining - transferred
            end
        end
    end
    
    return totalMoved
end

local function Move_diamond(a)
    local barrel, barrelName = findPeripheral("minecraft:barrel")
    local chest, chestName = findPeripheral("supplementaries:safe")
    
    if not barrel or not chest then return 0 end
    
    local amountToMove = tonumber(a)
    if not amountToMove or amountToMove <= 0 then return 0 end
    
    local totalMoved = 0
    local contents = chest.list()
    
    for slot, item in pairs(contents) do
        if item.name == "minecraft:diamond" and amountToMove > 0 then
            local available = item.count
            while available > 0 and amountToMove > 0 do
                local transferSize = math.min(available, amountToMove, 64)
                local transferred = chest.pushItems(barrelName, slot, transferSize)
                if transferred == 0 then break end
                totalMoved = totalMoved + transferred
                amountToMove = amountToMove - transferred
                available = available - transferred
            end
        end
        if amountToMove <= 0 then break end
    end
    
    return totalMoved
end

UI.BGtheme = colors.blue
UI.button_Theme["bg"] = colors.green
UI.button_Theme["light_bg"] = colors.lime
UI.button_Theme["text"] = colors.black

local screen = UI.createScreen()
local diamond = UI.createScreen()
local exit = UI.createScreen()

-- CoinScreen

UI.addLabel(screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(screen, UI.createLabel("", 1, 1, colors.black, colors.blue))

UI.addInput(screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-2, 17, 3, "Enter Login", 10))

UI.addButton(screen, UI.createButton("Add Coins", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)+2, 11, 3, function()
    local Login = UI.screens[screen].inputs[1].text
    local SecretPass = Short.Read("RangerBankData/SecretPass.txt")
    
    local movedCount = Move_money() 
    
    if movedCount > 0 then
        Network.send(Network.ID, "RangerBank:add_money", {Login, movedCount, SecretPass}, "RangerBank")
        local status, message = Network.receive("RangerBank", 1)
        if status == "Complete!" then
            UI.screens[screen].labels[2].text = message.." add: "..movedCount.." money"
            UI.screens[screen].labels[2].fgColor = colors.lime
        elseif status == "Error" then
            Move_diamond(movedCount) 
            Network.Error = message
            UI.screens[screen].labels[2].text = Network.Error 
            UI.screens[screen].labels[2].fgColor = colors.red
        else
            Move_diamond(movedCount)
            UI.screens[screen].labels[2].text = "Error"
            UI.screens[screen].labels[2].fgColor = colors.red
        end
    else
        UI.screens[screen].labels[2].text = "No items or Safe FULL"
        UI.screens[screen].labels[2].fgColor = colors.red
    end
    
    UI.screens[screen].inputs[1].text = "Enter Login"
    UI.screens[screen].inputs[1].cursorPos = 1
    UI.screens[screen].inputs[1].isPlaceholder = ""
end))

UI.addButton(screen, UI.createButton("Exit", 0, UI.screenHeight-1, 8, 3, function()
    UI.screens[screen].labels[2].text = ""
    UI.setScreen(exit)
end))

UI.addButton(screen, UI.createButton(" Diamond", math.floor(UI.screenWidth)-8, 1, 9, 3, function()
    UI.screens[screen].labels[2].text = ""
    UI.setScreen(diamond)
end))


-- DiamondScreen

UI.addInput(diamond, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-5, 17, 3, "Enter Login", 10))
UI.addInput(diamond, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-2, 17, 3, "Enter Pass", 10, true))
UI.addInput(diamond, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)+1, 17, 3, "Enter Summ", 10))

UI.addButton(diamond, UI.createButton("Get Diamonds", math.floor(UI.screenWidth/2)-7, math.floor(UI.screenHeight/2)+5, 15, 3, function()
    local Login = UI.screens[diamond].inputs[1].text
    local Pass = UI.screens[diamond].inputs[2].text
    local requested = tonumber(UI.screens[diamond].inputs[3].text)
    local SecretPass = Short.Read("RangerBankData/SecretPass.txt")
    
    if not requested or requested <= 0 then
        UI.screens[diamond].labels[2].text = "Invalid Summ"
        UI.screens[diamond].labels[2].fgColor = colors.red
        return
    end

    Network.send(Network.ID, "RangerBank:login", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    
    if status == "Complete!" then
        Network.send(Network.ID, "RangerBank:minus_money", {Login, requested, SecretPass}, "RangerBank")
        status, message = Network.receive("RangerBank", 1)
        
        if status == "Complete!" then
            local moved = Move_diamond(requested)
            
            if moved < requested then
                local refund = requested - moved
                -- Если бочка забилась, возвращаем неполученную разницу обратно в банк
                Network.send(Network.ID, "RangerBank:add_money", {Login, refund, SecretPass}, "RangerBank")
                Network.receive("RangerBank", 1) -- Ждем обработки сетью
                
                if moved > 0 then
                    UI.screens[diamond].labels[2].text = "Barrel Full! Got: "..moved..", Refund: "..refund
                else
                    UI.screens[diamond].labels[2].text = "Barrel Full! Refunded: "..refund
                end
                UI.screens[diamond].labels[2].fgColor = colors.orange
            else
                UI.screens[diamond].labels[2].text = message.." get: "..moved.." diamonds"
                UI.screens[diamond].labels[2].fgColor = colors.lime
            end
        elseif status == "Error" then
            Network.Error = message
            UI.screens[diamond].labels[2].text = Network.Error
            UI.screens[diamond].labels[2].fgColor = colors.red
        else
            UI.screens[diamond].labels[2].text = "Error"
            UI.screens[diamond].labels[2].fgColor = colors.red
        end
    elseif status == "Error" then
        Network.Error = message
        UI.screens[diamond].labels[2].text = Network.Error
        UI.screens[diamond].labels[2].fgColor = colors.red
    else
        UI.screens[diamond].labels[2].text = "Error"
        UI.screens[diamond].labels[2].fgColor = colors.red
    end
    
    UI.screens[diamond].inputs[1].text = "Enter Login"
    UI.screens[diamond].inputs[2].text = "Enter Pass"
    UI.screens[diamond].inputs[3].text = "Enter Summ"
    UI.screens[diamond].inputs[1].cursorPos = 1
    UI.screens[diamond].inputs[2].cursorPos = 1
    UI.screens[diamond].inputs[3].cursorPos = 1
    UI.screens[diamond].inputs[1].isPlaceholder = ""
    UI.screens[diamond].inputs[2].isPlaceholder = ""
    UI.screens[diamond].inputs[3].isPlaceholder = ""
end))

UI.addButton(diamond, UI.createButton("Exit", 0, UI.screenHeight-1, 8, 3, function()
    UI.screens[diamond].labels[2].text = ""
    UI.setScreen(exit)
end))

UI.addButton(diamond, UI.createButton("Coins", math.floor(UI.screenWidth)-8, 1, 9, 3, function()
    UI.screens[diamond].labels[2].text = ""
    UI.setScreen(screen)
end))

UI.addLabel(diamond, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(diamond, UI.createLabel("", 1, 1, colors.black, colors.blue))

-- ExitScreen

UI.addLabel(exit, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(exit, UI.createLabel("", 1, 1, colors.black, colors.blue))

UI.addInput(exit, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-2, 16, 3, "Enter Pass", 10))

UI.addButton(exit, UI.createButton("Exit", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)+2, 8, 3, function()
    if Short.Read("RangerBankData/SecretPass.txt") == UI.screens[exit].inputs[1].text then
        Network.close()
        UI.exit()
    else
        UI.screens[exit].labels[2].text = "Incorrect pass!"
        UI.screens[exit].labels[2].fgColor = colors.red
    end
    UI.screens[exit].inputs[1].text = "Enter Pass"
    UI.screens[exit].inputs[1].cursorPos = 1
    UI.screens[exit].inputs[1].isPlaceholder = ""
end))

UI.addButton(exit, UI.createButton("Back", 0, UI.screenHeight-1, 8, 3, function()
    UI.screens[exit].labels[2].text = ""
    UI.setScreen(screen)
end))

UI.run()
