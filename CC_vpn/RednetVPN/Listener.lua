function Write(text, filepath)
    local file = fs.open(filepath, "a")
    file.write(text)
    file.close()
end

fs.delete("listen.txt")

local modem = peripheral.find("modem")
if not modem then
    error("No modem found")
end

-- Close all previously opened channels to avoid "Too many open channels"
modem.closeAll()

print("Enter ID to listen or:".."\nX to scan radius of ID's")
local serverID = read()

if serverID == "x" or serverID == "X" then
    print("Enter the beginning of radius:")
    local serverID = tonumber(read())

    if not serverID or serverID < 0 or serverID > 65535 then
        printError("Wrong argument!")
        return
    end

    for i = serverID, serverID + 127 do
        print("Opening channel: " .. i)
        modem.open(i)
    end
    print("Sniffer active on channels: " .. serverID .. "-" .. serverID+127)
elseif not tonumber(serverID) or tonumber(serverID) < 0 or tonumber(serverID) > 65535 then
    printError("Wrong argument!")
    return
else
    modem.open(serverID)
    print("Sniffer active on channel: " .. serverID)
end

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    print("\n--- Message Caught --- \n Distance: " .. distance)

    local text = "\n--- Message Caught ---" .. "\nFrom Channel: " .. channel .. "\nReply Channel: " .. replyChannel.. "\nDistance: " .. distance
    
    if type(message) == "table" then
        text = text .. "\nContent: " .. textutils.serialize(message)
    else
        text = text .. "\nContent: " .. tostring(message)
    end
    text = text .. "\n----------------------\n"

    Write(text, "listen.txt")
end
