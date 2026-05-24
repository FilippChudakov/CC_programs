local debug = true
local fake_id = 123
local protocol = "Teleport"
local password = "123"
local need_message = "teleport"
local client_pub = 1047608

print("TP server is active.")

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
    key = tostring(key)
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


function crypto.getSharedSecret(others_public, my_private)
    local base = tonumber(others_public)
    if not base then 
        error("Критическая ошибка: получен некорректный публичный ключ (не число)")
    end
    
    local secret_num = modPow(base, my_private, P)
    return toHex(tostring(secret_num))
end

Short = {}

function Short.Write(text, filepath)
    local file = fs.open(filepath, "w")
    file.write(text)
    file.close()
end

function Short.Read(filepath)
    local file = fs.open(filepath, "r")
    if file == nil then
        return nil
    end
    local text = file.readAll()
    file.close()
    return text
end

function os.getComputerID()
    return fake_id
end

function os.computerID()
    return fake_id
end

local pub
local priv

if not fs.exists("public.key") or not fs.exists("private.key") then
    pub, priv = crypto.generateKeyPair()
    Short.Write(pub, "public.key")
    Short.Write(priv, "private.key")
else
    pub = tonumber(Short.Read("public.key"))
    priv = tonumber(Short.Read("private.key"))
end

local counter = 0
if not fs.exists("counter.txt") then
    Short.Write(counter, "counter.txt")
else
    counter = tonumber(Short.Read("counter.txt"))
end


client_pub = crypto.getSharedSecret(client_pub, priv)

if debug then
    print("Fake id: " .. tostring(fake_id))
    print("Public key: " .. tostring(pub))
    print("Private key: " .. tostring(priv))
    print("Shared secret: " .. tostring(client_pub))
end

local Network = {}

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.close)
end

function Network.MessageHandler()
    local session_id, message = rednet.receive(protocol)

    if type(message) ~= "string" then
        if debug then
            print("Received non-string message, ignoring.")
        end
        return
    else
        if debug then
            print("Raw message: " .. tostring(message))
        end
        message = crypto.decrypt(message, client_pub+counter)
    end

    if debug then
        print("Received message: " .. tostring(message))
        print("current counter: " .. tostring(counter))
    end

    if session_id ~= nil and message ~= nil then
        message = textutils.unserialize(message)

        if message[1] == need_message then
            if message["password"] == password then
                redstone.setAnalogOutput("top", 15)
                sleep(0.5)
                redstone.setAnalogOutput("top", 0)
                counter = counter + 1
                Short.Write(counter, "counter.txt")
            end
        end
    end
end

Network.open()

while true do
    local try, err = pcall(Network.MessageHandler)
    if err == "Terminated" then
        return
    elseif not try and debug then
        print("")
        printError("Error:")
        print("")
        printError(err)
        print("")
    end
    sleep(0)
end
