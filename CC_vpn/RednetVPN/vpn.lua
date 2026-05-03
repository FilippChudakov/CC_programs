print("Enter fake ID or\nX - disable\n-1 - use random id:")
fake_id = read()

if fake_id == "-1" then
    fake_id = math.random(10, rednet.MAX_ID_CHANNELS - 1)
end

if fake_id == "X" or fake_id == "x" then
    if _G.id then
        local real_id = _G.id
        function os.getComputerID()
            return real_id
        end

        function os.computerID()
            return real_id
        end

        _G.id = nil

        print("vpn disabled")
    else
        print("vpn disabled")
    end
elseif tonumber(fake_id) then
    fake_id = tonumber(fake_id)

    print("Using fake ID: " .. fake_id)

    if not _G.id then
        _G.id = os.getComputerID()
    end

    function os.getComputerID()
        return fake_id
    end

    function os.computerID()
        return fake_id
    end

end
