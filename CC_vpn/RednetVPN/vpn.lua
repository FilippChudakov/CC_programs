--print("Enter fake ID:")
--fake_id = tonumber(read())
fake_id = math.random(10, rednet.MAX_ID_CHANNELS - 1)
print("Using fake ID: " .. fake_id)

function os.getComputerID()
    return fake_id
end

function os.computerID()
    return fake_id
end
