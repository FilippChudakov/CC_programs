os.pullEvent = os.pullEventRaw
Network = dofile("APIS/Network.lua")

Network.open()
local version = Network.version()
print(version[1].." "..version[2])

--- Main while true ---
while true do
    --Network.MessageHandler()
    local try, err = pcall(Network.MessageHandler)
    if try == false then
        print("")
        printError("Error:")
        print("")
        printError(err)
        print("")
        sleep(0)
    end
end
