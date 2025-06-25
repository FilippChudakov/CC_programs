local original_rednet_send = rednet.send
local original_rednet_receive = rednet.receive

function rednet.send(receiver, message, protocol)
    local fake_receiver = 0

    original_rednet_send(fake_receiver, {"VPN:redirect", receiver, message, protocol}, "VPN")
end

function rednet.receive(protocol_filter, timeout)
    local id, msg, protocol = original_rednet_receive(nil, timeout)
    if protocol == "VPN" then
        return tonumber(msg[1]), msg[2], msg[3]
    else
        return id, msg, protocol
    end
end
