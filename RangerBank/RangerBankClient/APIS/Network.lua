local Network = {}

Network.ID = 0
Network.Error = nil

function Network.version()
    return "RangerBank 2.1"
end

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.open)
end

function Network.send(ID, SendId, Messages, Protocol)
    rednet.send(ID, SendId, Protocol)
    for _, Message in pairs(Messages) do
        rednet.send(ID, Message, Protocol)
    end
end

function Network.receive(Protocol, TimeOut)
    local id, send_id, protocol = rednet.receive(Protocol, TimeOut)

    if Network.ID == id then
        if send_id == "RangerBank: 1" then
            while true do
                local id, message = rednet.receive(Protocol, 1)

                if id ~= nil and message ~= nil then
                    if Network.ID == id then
                        return "Complete!", message
                    end
                else
                    break
                end
            end
        elseif send_id == "RangerBank: 2" then
            while true do
                local id, message = rednet.receive(Protocol, 1)

                if id ~= nil and message ~= nil then
                    if Network.ID == id then
                        return "Error", message
                    end
                else
                    break
                end
            end
        elseif send_id == "RangerBank: 3" then
            while true do
                local id, message = rednet.receive(Protocol, 1)

                if id ~= nil and message ~= nil then
                    if Network.ID == id then
                        return "Money", message
                    end
                else
                    break
                end
            end
        else
            return "Error", "Wrong send ID"
        end
    end
end

return Network
