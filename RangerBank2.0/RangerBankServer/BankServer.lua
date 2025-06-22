Network = dofile("APIS/Network.lua")

--- Main while true ---
Network.open()

while true do
    --Network.MessageHandler()
    local try = pcall(Network.MessageHandler)
    if try == false then
        print("")
        printError("Unknown Error")
        print("")
    end
end
