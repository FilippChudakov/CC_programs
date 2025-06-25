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

function Short.serialize(t, indent, visited)
    indent = indent or 0
    visited = visited or {}
    local spaces = string.rep(" ", indent)
    
    if type(t) == "table" then
        if visited[t] then return '"[[CIRCULAR_REFERENCE]]"' end
        visited[t] = true
        
        local is_array = true
        local max_index = 0
        for k, _ in pairs(t) do
            if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
                is_array = false
                break
            end
            if k > max_index then max_index = k end
        end
        
        local result = {}
        table.insert(result, "{\n")
        
        if is_array then
            -- Сериализация как массива с сохранением порядка
            for i = 1, max_index do
                if t[i] ~= nil then
                    table.insert(result, spaces .. "  ")
                    table.insert(result, Short.serialize(t[i], indent + 2, visited))
                    table.insert(result, ",\n")
                end
            end
        else
            -- Сериализация как таблицы с сохранением порядка
            local keys = {}
            for k, _ in pairs(t) do table.insert(keys, k) end
            table.sort(keys, function(a, b)
                if type(a) == type(b) then return a < b end
                return tostring(a) < tostring(b)
            end)
            
            for _, k in ipairs(keys) do
                table.insert(result, spaces .. "  [")
                table.insert(result, Short.serialize(k, indent + 2, visited))
                table.insert(result, "] = ")
                table.insert(result, Short.serialize(t[k], indent + 2, visited))
                table.insert(result, ",\n")
            end
        end
        
        table.insert(result, spaces .. "}")
        return table.concat(result)
    elseif type(t) == "string" then
        return string.format("%q", t)
    else
        return tostring(t)
    end
end

function Short.deserialize(str)
    local chunk, err = load("return " .. str)
    if not chunk then
        chunk, err = load(str)
    end
    if chunk then
        return chunk()
    else
        error("Failed to deserialize: " .. (err or "unknown error"))
    end
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