local UI = dofile("APIS/UI.lua")
local Network = dofile("APIS/Network.lua")
local Short = dofile("APIS/ShortCuts.lua")

Network.open()

UI.BGtheme = colors.blue
UI.button_Theme["bg"] = colors.green
UI.button_Theme["light_bg"] = colors.lime
UI.button_Theme["text"] = colors.black
UI.button_array_Theme["border"] = colors.gray
UI.button_array_Theme["light_border"] = colors.lime
UI.button_array_Theme["bg"] = colors.green
UI.button_array_Theme["light_bg"] = colors.lime
UI.button_array_Theme["text"] = colors.black
UI.button_array_Theme["infield"] = colors.black

local logregScreen = UI.createScreen()
local registerScreen = UI.createScreen()
local loginScreen = UI.createScreen()
local mainScreen = UI.createScreen()
local accountScreen = UI.createScreen()
local delaccScreen = UI.createScreen()
local changepassScreen = UI.createScreen()
local moneyScreen = UI.createScreen()
local transferScreen = UI.createScreen()
local logsScreen = UI.createScreen()

local version = Network.version()

UI.addLabel(logregScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(registerScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(loginScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(mainScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(accountScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(delaccScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(changepassScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(moneyScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(transferScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))

UI.addLabel(logregScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(mainScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(accountScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(delaccScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(changepassScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(moneyScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(transferScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel("", 1, 1, colors.black, colors.blue))

UI.addLabel(logsScreen, UI.createLabel("type:", (UI.screenWidth/2)-9, 2, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel("date:", (UI.screenWidth/2)-9, 3, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel("id:", (UI.screenWidth/2)-9, 4, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel("data1:", (UI.screenWidth/2)-9, 5, colors.black, colors.blue))
UI.addLabel(logsScreen, UI.createLabel("data2:", (UI.screenWidth/2)-9, 6, colors.black, colors.blue))


UI.addLabel(mainScreen, UI.createLabel("", UI.screenWidth-13, UI.screenHeight-1, colors.black, colors.blue))


-- logreg screen
UI.addButton(logregScreen, UI.createButton("Register", math.floor(UI.screenWidth/2)-6, math.floor(UI.screenHeight/2)-1-5, 12, 3, function()
    UI.screens[logregScreen].labels[2].text = ""
    UI.setScreen(registerScreen)
end))

UI.addButton(logregScreen, UI.createButton("Login", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+0, 10, 3, function()
    UI.screens[logregScreen].labels[2].text = ""
    UI.setScreen(loginScreen)
end))

UI.addButton(logregScreen, UI.createButton("Quit", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+5, 8, 3, function()
    Network.close()
    UI.exit()
end))


-- register screen
UI.addInput(registerScreen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-6, 16, 3, "Enter Login", 10))
UI.addInput(registerScreen, UI.createInput(math.floor(UI.screenWidth/2)-7, math.floor(UI.screenHeight/2)-1-2, 14, 3, "Enter Pass", 10))

UI.addButton(registerScreen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+2, 8, 3, function()
    local Login = UI.screens[registerScreen].inputs[1].text
    local Pass = UI.screens[registerScreen].inputs[2].text
    Network.send(Network.ID, "RangerBank:register", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        Short.Write(Login, "RangerBankData/Account.txt")
        Short.Write(Pass, "RangerBankData/Password.txt")
        UI.screens[mainScreen].labels[2].text = "Account created!"
        UI.screens[mainScreen].labels[2].fgColor = colors.lime
        UI.setScreen(mainScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[logregScreen].labels[2].text = Network.Error
        UI.screens[logregScreen].labels[2].fgColor = colors.red
        UI.setScreen(logregScreen)
    else
        UI.screens[logregScreen].labels[2].text = "Error"
        UI.screens[logregScreen].labels[2].fgColor = colors.red
        UI.setScreen(logregScreen)
    end
end))

UI.addButton(registerScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+6, 8, 3, function()
    UI.setScreen(logregScreen)
end))


-- login screen
UI.addInput(loginScreen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-6, 16, 3, "Enter Login", 10))
UI.addInput(loginScreen, UI.createInput(math.floor(UI.screenWidth/2)-7, math.floor(UI.screenHeight/2)-1-2, 14, 3, "Enter Pass", 10))

UI.addButton(loginScreen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+2, 8, 3, function()
    local Login = UI.screens[loginScreen].inputs[1].text
    local Pass = UI.screens[loginScreen].inputs[2].text
    Network.send(Network.ID, "RangerBank:login", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        Short.Write(Login, "RangerBankData/Account.txt")
        Short.Write(Pass, "RangerBankData/Password.txt")
        Network.send(Network.ID, "RangerBank:first_login_log", {Login}, "RangerBank")
        UI.screens[mainScreen].labels[2].text = "Successfully logined!"
        UI.screens[mainScreen].labels[2].fgColor = colors.lime
        UI.setScreen(mainScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[logregScreen].labels[2].text = Network.Error
        UI.screens[logregScreen].labels[2].fgColor = colors.red
        UI.setScreen(logregScreen)
    else
        UI.screens[logregScreen].labels[2].text = "Error"
        UI.screens[logregScreen].labels[2].fgColor = colors.red
        UI.setScreen(logregScreen)
    end
end))

UI.addButton(loginScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+6, 8, 3, function()
    UI.setScreen(logregScreen)
end))


-- main screen
UI.addButton(mainScreen, UI.createButton("Account", math.floor(UI.screenWidth/2)-6, math.floor(UI.screenHeight/2)-1-5, 12, 3, function()
    UI.screens[mainScreen].labels[2].text = ""
    UI.screens[accountScreen].labels[2].text = Short.Read("RangerBankData/Account.txt")
    UI.setScreen(accountScreen)
end))

UI.addButton(mainScreen, UI.createButton("Money", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+0, 10, 3, function()
    local Pass = Short.Read("RangerBankData/Password.txt")
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:get_money", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Money" then
        UI.screens[mainScreen].labels[2].text = ""
        UI.screens[moneyScreen].labels[2].text = message
        UI.setScreen(moneyScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(mainScreen, UI.createButton("Quit", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+5, 8, 3, function()
    Network.close()
    UI.exit()
end))


-- account screen
UI.addButton(accountScreen, UI.createButton("Change Password", math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-6, 18, 3, function()
    UI.screens[changepassScreen].labels[2].text = Short.Read("RangerBankData/Account.txt")
    UI.setScreen(changepassScreen)
end))

UI.addButton(accountScreen, UI.createButton("Delete Account", math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-2, 18, 3, function()
    UI.screens[delaccScreen].labels[2].text = Short.Read("RangerBankData/Account.txt")
    UI.setScreen(delaccScreen)
end))

UI.addButton(accountScreen, UI.createButton("Logout", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+2, 10, 3, function()
    fs.delete("RangerBankData/Account.txt")
    fs.delete("RangerBankData/Password.txt")
    UI.screens[logregScreen].labels[2].text = "Logout successfully!"
    UI.screens[logregScreen].labels[2].fgColor = colors.lime
    UI.setScreen(logregScreen)
end))

UI.addButton(accountScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+6, 8, 3, function()
    UI.setScreen(mainScreen)
end))

UI.addButton(accountScreen, UI.createButton("Secure", 0, UI.screenHeight-1, 8, 3, function()
    local Secure = Short.Read("RangerBankData/Secure.txt")
    if Secure == "1" then
        Short.Write("0", "RangerBankData/Secure.txt")
        UI.screens[mainScreen].labels[3].text = "Secure: false"
        UI.setScreen(mainScreen)
    else
        Short.Write("1", "RangerBankData/Secure.txt")
        UI.screens[mainScreen].labels[3].text = "Secure: true"
        UI.setScreen(mainScreen)
    end
end))


-- change password screen
UI.addInput(changepassScreen, UI.createInput(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-6, 18, 3, "Enter old Pass", 10))
UI.addInput(changepassScreen, UI.createInput(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-2, 18, 3, "Enter new Pass", 10))

UI.addButton(changepassScreen, UI.createButton("Change", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+2, 10, 3, function()
    local OldPass = UI.screens[changepassScreen].inputs[1].text
    local NewPass = UI.screens[changepassScreen].inputs[2].text
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:change_password", {OldPass, NewPass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        Short.Write(NewPass, "RangerBankData/Password.txt")
        UI.screens[mainScreen].labels[2].text = message
        UI.screens[mainScreen].labels[2].fgColor = colors.lime
        UI.setScreen(mainScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(changepassScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+6, 8, 3, function()
    UI.setScreen(mainScreen)
end))


-- delete account screen
UI.addInput(delaccScreen, UI.createInput(math.floor(UI.screenWidth/2)-7, math.floor(UI.screenHeight/2)-1-4, 14, 3, "Enter Pass", 10))

UI.addButton(delaccScreen, UI.createButton("Delete", math.floor(UI.screenWidth/2)-5, math.floor(UI.screenHeight/2)-1+1, 10, 3, function()
    local Pass = UI.screens[delaccScreen].inputs[1].text
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:delete_account", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        fs.delete("RangerBankData/Account.txt")
        fs.delete("RangerBankData/Password.txt")
        UI.screens[logregScreen].labels[2].text = message
        UI.screens[logregScreen].labels[2].fgColor = colors.lime
        UI.setScreen(logregScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(delaccScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+6, 8, 3, function()
    UI.setScreen(mainScreen)
end))


-- money screen
UI.addButton(moneyScreen, UI.createButton("Account History", math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-5, 18, 3, function()
    local Pass = Short.Read("RangerBankData/Password.txt")
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:get_money", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Money" then
        UI.screens[logsScreen].labels[2].text = message
        Network.send(Network.ID, "RangerBank:get_log", {Pass, Login}, "RangerBank")
        local status, message = Network.receive("RangerBank", 1)
        if status == "Complete!" then
            Short.Write(message, "RangerBankData/logs.txt")
            Short.NumerateLog("RangerBankData/logs.txt", "RangerBankData/logs_names.txt")
            UI.updateButtonArray(UI.screens[logsScreen].buttonArrays[1], "RangerBankData/logs_names.txt")
            UI.setScreen(logsScreen)
        elseif status == "Error" then
            Network.Error = message
            UI.screens[mainScreen].labels[2].text = Network.Error
            UI.screens[mainScreen].labels[2].fgColor = colors.red
        else
            UI.screens[mainScreen].labels[2].text = "Error"
            UI.screens[mainScreen].labels[2].fgColor = colors.red
            UI.setScreen(mainScreen)
        end
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(moneyScreen, UI.createButton("Transfer Money", math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1+0, 18, 3, function()
    local Pass = Short.Read("RangerBankData/Password.txt")
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:get_money", {Pass, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Money" then
        UI.screens[transferScreen].labels[2].text = message
        UI.setScreen(transferScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(moneyScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+5, 8, 3, function()
    UI.setScreen(mainScreen)
end))


-- transfer screen
UI.addInput(transferScreen, UI.createInput(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-7, 18, 3, "Enter Receiver", 10))
UI.addInput(transferScreen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-4, 16, 3, "Enter Pass", 10))
UI.addInput(transferScreen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-1-1, 16, 3, "Enter Summ", 10))

UI.addButton(transferScreen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+3, 8, 3, function()
    local Receiver = UI.screens[transferScreen].inputs[1].text
    local Pass = UI.screens[transferScreen].inputs[2].text
    local Summ = UI.screens[transferScreen].inputs[3].text
    local Login = Short.Read("RangerBankData/Account.txt")
    Network.send(Network.ID, "RangerBank:transfer_money", {Pass, Summ, Receiver, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        UI.screens[mainScreen].labels[2].text = message
        UI.screens[mainScreen].labels[2].fgColor = colors.lime
        UI.setScreen(mainScreen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[mainScreen].labels[2].text = Network.Error
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    else
        UI.screens[mainScreen].labels[2].text = "Error"
        UI.screens[mainScreen].labels[2].fgColor = colors.red
        UI.setScreen(mainScreen)
    end
end))

UI.addButton(transferScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.setScreen(mainScreen)
end))


-- logs screen
UI.addButtonArray(logsScreen, UI.createButtonArray(math.floor(UI.screenWidth/2)-9, math.floor(UI.screenHeight/2)-1-1, 18, 7, "RangerBankData/logs_names.txt", 5, 
    function(selectedText)
        local recordNum = tonumber(selectedText:match("^(%d+)"))
        if not recordNum then return end
        
        local logsContent = Short.Read("RangerBankData/logs.txt")
        local allLogs = Short.deserialize(logsContent)
        local logEntry = allLogs[recordNum]
        
        local log = Short.deserialize(logEntry)
            
        if log.type ~= "Transfer" and log.type ~= "Receive" then
            UI.screens[logsScreen].labels[3].text = "type: "..log.type
            UI.screens[logsScreen].labels[4].text = "date: "..log.date
            UI.screens[logsScreen].labels[5].text = "id: "..Short.deserialize(log.data)[1]
            UI.screens[logsScreen].labels[6].text = "data1:"
            UI.screens[logsScreen].labels[7].text = "data2:"
        else
            UI.screens[logsScreen].labels[3].text = "type: "..log.type
            UI.screens[logsScreen].labels[4].text = "date: "..log.date
            UI.screens[logsScreen].labels[5].text = "id: "..Short.deserialize(log.data)[3]
            UI.screens[logsScreen].labels[6].text = "data1: "..Short.deserialize(log.data)[1]
            UI.screens[logsScreen].labels[7].text = "data2: "..Short.deserialize(log.data)[2]
        end

    end
))

UI.addButton(logsScreen, UI.createButton("Back", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)-1+7, 8, 3, function()
    UI.setScreen(mainScreen)
end))


--- Launch ---
local Secure = Short.Read("RangerBankData/Secure.txt")
if Secure == "1" then
    fs.delete("RangerBankData/Account.txt")
    fs.delete("RangerBankData/Password.txt")
elseif Secure ~= "0" then
    Short.Write("0", "RangerBankData/Secure.txt")
end

local login = Short.Read("RangerBankData/Account.txt")
local password = Short.Read("RangerBankData/Password.txt")
if login ~= nil and password ~= nil and Secure ~= "1" then
    Network.send(Network.ID, "RangerBank:login", {password, login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        UI.screens[mainScreen].labels[2].text = "Successfully logined!"
        UI.screens[mainScreen].labels[2].fgColor = colors.lime
        UI.setScreen(mainScreen)
    elseif status == "Error" then
        Network.Error = message
        if Network.Error == "Wrong password!" or Network.Error == "Account doesn't exist!" then
            fs.delete("RangerBankData/Account.txt")
            fs.delete("RangerBankData/Password.txt")
        end
        UI.screens[logregScreen].labels[2].text = Network.Error
        UI.screens[logregScreen].labels[2].fgColor = colors.red
    else
        UI.screens[logregScreen].labels[2].text = "Error"
        UI.screens[logregScreen].labels[2].fgColor = colors.red
    end
end

UI.run()

Network.close()
