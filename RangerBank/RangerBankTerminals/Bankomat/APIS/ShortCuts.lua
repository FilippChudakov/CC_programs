Short = {}

local hardwareKey = "K" .. tostring(os.getComputerID()) .. "B" 

function Short.Crypt(data, key)
    if not key or key == "" then return data end
    local output = {}
    for i = 1, #data do
        local b = data:byte(i)
        local k = key:byte((i - 1) % #key + 1)
        output[i] = string.char(bit.bxor(b, k))
    end
    return table.concat(output)
end

function Short.Write(text, filepath)
    local encrypted = Short.Crypt(tostring(text), hardwareKey)
    local file = fs.open(filepath, "w")
    file.write(encrypted)
    file.close()
end

function Short.Read(filepath)
    local file = fs.open(filepath, "r")
    if file == nil then return nil end
    local text = file.readAll()
    file.close()
    return Short.Crypt(text, hardwareKey)
end

function Short.is_in_table(table, v)
    local found = false

    for key, _ in pairs(table) do
        if key == v then
            found = true
            break
        end
    end
    return found
end

function Short.NumerateLog(logpath, filepath)
    local log = textutils.unserialize(Short.Read(logpath))
    local numeratelog = ""

    for i, value in ipairs(log) do
        numeratelog = numeratelog..i..". "..textutils.unserialize(value)["type"].."\n"
    end

    Short.Write(numeratelog, filepath)
end

return Short
