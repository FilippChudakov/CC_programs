local expect = dofile("rom/modules/main/cc/expect.lua").expect
local rednet_open = rednet.open

local received_messages = {}
local hostnames = {}
local prune_received_timer

print("Enter fake ID:")
fake_id = tonumber(read())

local function id_as_channel(id)
    return (id or fake_id) % rednet.MAX_ID_CHANNELS
end

function rednet.open(modem)
    if modem then
        rednet_open(modem)
        peripheral.call(modem, "close", os.getComputerID())
        peripheral.call(modem, "open", fake_id)
    end
end

function rednet.close(modem)
    if modem then
        peripheral.call(modem, "close", fake_id)
        peripheral.call(modem, "close", rednet.CHANNEL_BROADCAST)
    end
end

function rednet.send(recipient, message, protocol)
    expect(1, recipient, "number")
    expect(3, protocol, "string", "nil")
    -- Generate a (probably) unique message ID
    -- We could do other things to guarantee uniqueness, but we really don't need to
    -- Store it to ensure we don't get our own messages back
    local message_id = math.random(1, 2147483647)
    received_messages[message_id] = os.clock() + 9.5
    if not prune_received_timer then prune_received_timer = os.startTimer(10) end

    -- Create the message
    local reply_channel = id_as_channel()
    local message_wrapper = {
        nMessageID = message_id,
        nRecipient = recipient,
        nSender = fake_id,
        message = message,
        sProtocol = protocol,
    }

    local sent = false
    if recipient == fake_id then
        -- Loopback to ourselves
        os.queueEvent("rednet_message", fake_id, message, protocol)
        sent = true
    else
        -- Send on all open modems, to the target and to repeaters
        if recipient ~= rednet.CHANNEL_BROADCAST then
            recipient = id_as_channel(recipient)
        end

        for _, modem in ipairs(peripheral.getNames()) do
            if rednet.isOpen(modem) then
                peripheral.call(modem, "transmit", recipient, reply_channel, message_wrapper)
                peripheral.call(modem, "transmit", rednet.CHANNEL_REPEAT, reply_channel, message_wrapper)
                sent = true
            end
        end
    end

    return sent
end

function rednet.receive(protocol_filter, timeout)
    if type(protocol_filter) == "number" and timeout == nil then
        protocol_filter, timeout = nil, protocol_filter
    end
    expect(1, protocol_filter, "string", "nil")
    expect(2, timeout, "number", "nil")

    -- Start the timer
    local timer = nil
    local event_filter = nil
    if timeout then
        timer = os.startTimer(timeout)
        event_filter = nil
    else
        event_filter = "modem_message"
    end

    -- Wait for events
    while true do
        local event, p1, p2, p3, message = os.pullEventRaw(event_filter)
        if event == "modem_message" then
            received_messages[message.nMessageID] = os.clock() + 9.5
            if not prune_received_timer then prune_received_timer = os.startTimer(10) end
            local sender_id, message, protocol = message.nSender or p3, message.message, message.sProtocol
            if protocol_filter == nil or protocol == protocol_filter then
                return sender_id, message, protocol
            end
        elseif event == "timer" then
            -- Return nil if we timeout
            if p1 == timer then
                return nil
            end
        end
    end
end

function rednet.isOpen(modem)
    expect(1, modem, "string", "nil")
    if modem then
        -- Check if a specific modem is open
        if peripheral.getType(modem) == "modem" then
            return peripheral.call(modem, "isOpen", id_as_channel()) and peripheral.call(modem, "isOpen", rednet.CHANNEL_BROADCAST)
        end
    else
        -- Check if any modem is open
        for _, modem in ipairs(peripheral.getNames()) do
            if rednet.isOpen(modem) then
                return true
            end
        end
    end
    return false
end
