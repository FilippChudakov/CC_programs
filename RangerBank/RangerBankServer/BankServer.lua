Network = dofile("APIS/Network.lua")

Network.open()
local version = Network.version()
print(version[1].." "..version[2])

--- Main while true ---
while true do
    --Network.MessageHandler()
    local try = pcall(Network.MessageHandler)
    if try == false then
        print("")
        printError("Unknown Error")
        print("")
    end
end
