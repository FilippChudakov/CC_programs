local original_rednet_receive = rednet.receive

function rednet.receive(protocol_filter, timeout)
    local id, msg, protocol = original_rednet_receive(protocol_filter, timeout)

    local file = fs.open("BanIData/ID.txt", "r")
    local ids = file.readAll()
    file.close()

    id_list = {}

    for id in ids:gmatch("%S+") do
        table.insert(id_list, id)
    end

    ban = false

    for i, value in ipairs(id_list) do
        if tonumber(value) == id then
            ban = true
        end
    end

    if ban then
        print("ID: "..id.." Banned")
        return nil, nil, nil
    else
        return id, msg, protocol
    end
end