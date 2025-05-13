peripheral.find("modem", rednet.open)

function ResetSavings()
    message = nil
    target_id = nil
    target_protocol = nil
    savemsg = nil
    saveprotocol = nil
end

function MessageHandler()
    print("Waiting for a message...")
    local id, msg, protocol = rednet.receive()
    session_id = id
    if msg == "VPN:redirect" and protocol == "VPN" then
        while true do
            print("Receiving...")
            local id, msg, protocol = rednet.receive("VPN", 1)
            savemsg = msg
            saveprotocol = protocol
            if session_id == id then
                print("Message received...")
                if message == nil then
                    message = msg
                elseif target_id == nil then
                    target_id = msg
                elseif target_protocol == nil then
                    target_protocol = msg
                    print("Redirecting message...")
                    rednet.send(target_id, message, target_protocol)
                    last_session_id = session_id
                    ResetSavings()
                    break
                end
            else
                printError("Message is too late")
                break
            end
        end
    elseif protocol ~= "VPN" then
        print("Sending to: "..last_session_id)
        rednet.send(last_session_id, msg, "VPN")
        print("From id: "..id)
        rednet.send(last_session_id, id, protocol)
        ResetSavings()
    end
end

while true do
    ResetSavings()
    local try = pcall(MessageHandler)
    if try == false then
        ResetSavings()
        print("")
        printError("Unknown Error")
        print("")
    end
end