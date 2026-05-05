local crypto = {}

math.randomseed(os.epoch and os.epoch("utc") or os.time())

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

function crypto.rc4(data, key)
    if not key or not data then
        return
    end
    local S = {}
    for i = 0, 255 do S[i] = i end
    local j = 0
    for i = 0, 255 do
        j = (j + S[i] + key:byte((i % #key) + 1)) % 256
        S[i], S[j] = S[j], S[i]
    end
    local i = 0
    j = 0
    local chars = {}
    for k = 1, #data do
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        local K = S[(S[i] + S[j]) % 256]
        table.insert(chars, string.char(bit32.bxor(data:byte(k), K)))
    end
    return table.concat(chars)
end

function crypto.encrypt(message, key)
    local raw = crypto.rc4(message, key)
    return toHex(raw)
end

function crypto.decrypt(message, key)
    local raw = fromHex(message)
    return crypto.rc4(raw, key)
end

local P = 16777213 
local G = 2        

local function modPow(b, e, m)
    local result = 1
    b = b % m
    while e > 0 do
        if e % 2 == 1 then
            result = (result * b) % m
        end
        e = math.floor(e / 2)
        b = (b * b) % m
    end
    return result
end

function crypto.generateKeyPair()
    local private = rand(P - 2)
    local public = modPow(G, private, P)
    return public, private
end

-- В файле APIS/Crypto.lua
function crypto.getSharedSecret(others_public, my_private)
    -- Добавляем tonumber(), чтобы строка превратилась в число перед вычислениями
    local base = tonumber(others_public)
    if not base then 
        error("Критическая ошибка: получен некорректный публичный ключ (не число)")
    end
    
    local secret_num = modPow(base, my_private, P)
    return toHex(tostring(secret_num))
end

return crypto
