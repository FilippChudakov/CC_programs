local crypto = {}

local function rand(max)
    return math.random(1, max)
end

local function toHex(str)
    return (str:gsub(".", function(c)
        return string.format("%02X", c:byte())
    end))
end

local function fromHex(hex)
    return (hex:gsub("%x%x", function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

function crypto.xor(data, key)
    local result = ""
    for i = 1, #data do
        local k = key:byte((i - 1) % #key + 1)
        local d = data:byte(i)
        result = result .. string.char(bit32.bxor(d, k))
    end
    return result
end

function crypto.encrypt(message, key)
    local raw = crypto.xor(message, key)
    return toHex(raw)
end

function crypto.decrypt(message, key)
    local raw = fromHex(message)
    return crypto.xor(raw, key)
end

function crypto.generateKey(len)
    local key = ""
    for i = 1, len do
        key = key .. string.char(rand(255))
    end
    return key
end

function crypto.generateKeyPair()
    local private = crypto.generateKey(16)
    local public = crypto.xor(private, "public_seed")
    return public, private
end

function crypto.encryptWithPublic(data, public)
    return crypto.xor(data, public)
end

function crypto.decryptWithPrivate(data, private)
    local public = crypto.xor(private, "public_seed")
    return crypto.xor(data, public)
end

return crypto
