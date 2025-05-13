local original_rednet_send = rednet.send
local original_rednet_receive = rednet.receive

function rednet.send(receiver, message, protocol)
    local fake_receiver = 11

    original_rednet_send(fake_receiver, "VPN:redirect", "VPN")
    original_rednet_send(fake_receiver, message, "VPN")
    original_rednet_send(fake_receiver, receiver, "VPN")
    original_rednet_send(fake_receiver, protocol, "VPN")
end

function rednet.receive(protocol_filter, timeout)
    local id, msg, protocol = original_rednet_receive(protocol_filter, timeout)
    if protocol == "VPN" then
        savemsg = msg
        id, msg, protocol = original_rednet_receive(nil, 1)
        return tonumber(msg), savemsg, protocol
    else
        return id, msg, protocol
    end
end
