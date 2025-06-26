os.pullEvent = os.pullEventRaw

local UI = dofile("APIS/UI.lua")
local Network = dofile("APIS/Network.lua")
local Short = dofile("APIS/ShortCuts.lua")
local version = Network.version()

Network.open()
UI.BGtheme = colors.blue
UI.button_Theme["bg"] = colors.green
UI.button_Theme["light_bg"] = colors.lime
UI.button_Theme["text"] = colors.black

local name = Short.Read("RangerBankData/Login.txt")
local screen = UI.createScreen()
local exit = UI.createScreen()

-- MainScreen

UI.addLabel(screen, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))
UI.addLabel(screen, UI.createLabel("", 1, 1, colors.black, colors.blue))
UI.addLabel(screen, UI.createLabel("Transfer to: ".. name, UI.screenWidth-12-#name, 1, colors.black, colors.blue))

UI.addInput(screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-6, 16, 3, "Enter Login", 10))
UI.addInput(screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-2, 16, 3, "Enter Pass", 10))
UI.addInput(screen, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)+2, 16, 3, "Enter Summ", 10))

UI.addButton(screen, UI.createButton("Enter", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)+6, 8, 3, function()
    local Login = UI.screens[screen].inputs[1].text
    local Pass = UI.screens[screen].inputs[2].text
    local Summ = UI.screens[screen].inputs[3].text
    local Receiver = Short.Read("RangerBankData/Login.txt")
    Network.send(Network.ID, "RangerBank:transfer_money", {Pass, Summ, Receiver, Login}, "RangerBank")
    local status, message = Network.receive("RangerBank", 1)
    if status == "Complete!" then
        UI.screens[screen].labels[2].text = message
        UI.screens[screen].labels[2].fgColor = colors.lime
        UI.setScreen(screen)
    elseif status == "Error" then
        Network.Error = message
        UI.screens[screen].labels[2].text = Network.Error
        UI.screens[screen].labels[2].fgColor = colors.red
        UI.setScreen(screen)
    else
        UI.screens[screen].labels[2].text = "Error"
        UI.screens[screen].labels[2].fgColor = colors.red
        UI.setScreen(screen)
    end
end))

UI.addButton(screen, UI.createButton("Exit", 0, UI.screenHeight-1, 8, 3, function()
    UI.setScreen(exit)
end))

-- ExitScreen

UI.addLabel(exit, UI.createLabel(version, UI.screenWidth+1-#version, UI.screenHeight, colors.black, colors.blue))

UI.addInput(exit, UI.createInput(math.floor(UI.screenWidth/2)-8, math.floor(UI.screenHeight/2)-2, 16, 3, "Enter Pass", 10))

UI.addButton(exit, UI.createButton("Exit", math.floor(UI.screenWidth/2)-4, math.floor(UI.screenHeight/2)+2, 8, 3, function()
    if Short.Read("RangerBankData/QuitPass.txt") == UI.screens[exit].inputs[1].text then
        Network.close()
        UI.exit()
    else
        UI.screens[screen].labels[2].text = "Incorrect pass!"
        UI.screens[screen].labels[2].fgColor = colors.red
        UI.setScreen(screen)
    end
end))

UI.addButton(exit, UI.createButton("Back", 0, UI.screenHeight-1, 8, 3, function()
    UI.setScreen(screen)
end))


UI.run()
