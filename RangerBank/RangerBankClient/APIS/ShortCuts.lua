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

function Short.serialize(v)
    return textutils.serialize(v)
end

function Short.deserialize(str)
    return textutils.unserialize(str)
end

function Short.NumerateLog(logpath, filepath)
    local log = Short.deserialize(Short.Read(logpath))
    local numeratelog = ""

    for i, value in ipairs(log) do
        numeratelog = numeratelog..i..". "..Short.deserialize(value)["type"].."\n"
    end

    Short.Write(numeratelog, filepath)
end

return Short
