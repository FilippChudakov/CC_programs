peripheral.find("modem", rednet.open)

function MessageHandler()
    print("\nWaiting for a message...")
    local id, msg, protocol = rednet.receive()
    if protocol == "VPN" then
        if msg[1] == "VPN:redirect" then
            print("Redirecting message...")
            rednet.send(msg[2], msg[3], msg[4])
            last_session_id = id
            print("Complete!\n")
        end
    elseif protocol ~= "VPN" then
        print("Sending to: "..last_session_id)
        print("From id: "..id.."\n")
        rednet.send(last_session_id, {id, msg, protocol}, "VPN")
    end
end

while true do
    local try = pcall(MessageHandler)
    if try == false then
        print("")
        printError("Unknown Error")
        print("")
    end
end
