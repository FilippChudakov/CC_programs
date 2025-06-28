local Network = {}

Network.ID = 0
Network.Error = nil

function Network.version()
    return "RangerBank 2.6"
end

function Network.changelog(version)
    if version == "2.0" then
        return "Reworked graphics and add protocol"
    elseif version == "2.1" then
        return "Fixed some bugs"
    elseif version == "2.5" then
        return "Reworked rednet use"
    elseif version == "2.6" then
        return "Fixed some bugs"
    else
        return "not a version"
    end
end

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.close)
end

function Network.send(ID, SendId, Messages, Protocol)
    local message = {}
    for _, Message in pairs(Messages) do
        table.insert(message, Message)
    end
    local data = Network.BankTable(SendId, message)
    rednet.send(ID, data, Protocol)
end

function Network.receive(Protocol, TimeOut)
    local id, message, protocol = rednet.receive(Protocol, TimeOut)

    if Network.ID == id then
        if message[1] == "RangerBank: 1" then
            return "Complete!", message[2]
        elseif message[1] == "RangerBank: 2" then
            return "Error", message[2]
        elseif message[1] == "RangerBank: 3" then
            return "Money", message[2]
        else
            return "Error", "Wrong send ID"
        end
    end
end

function Network.BankTable(SendId, data)
    local new_data = {SendId}
    if SendId == "RangerBank:get_money" or SendId == "RangerBank:login" or SendId == "RangerBank:register" or SendId == "RangerBank:delete_account" or SendId == "RangerBank:get_log" or SendId == "RangerBank:first_login_log" or SendId == "RangerBank:delete_login_logs" then
        new_data["password"] = data[1]
        new_data["account"] = data[2]
    elseif SendId == "RangerBank:minus_money" or SendId == "RangerBank:add_money" then
        new_data["account"] = data[1]
        new_data["summ"] = data[2]
        new_data["secret_pass"] = data[3]
    elseif SendId == "RangerBank:change_password" then
        new_data["password"] = data[1]
        new_data["new_pass"] = data[2]
        new_data["account"] = data[3]
    elseif SendId == "RangerBank:transfer_money" then
        new_data["password"] = data[1]
        new_data["summ"] = data[2]
        new_data["receiver"] = data[3]
        new_data["account"] = data[4]
    elseif SendId == "RangerBank:OFF" then
        new_data["secret_pass"] = data[1]
    end
    return new_data
end

return Network
