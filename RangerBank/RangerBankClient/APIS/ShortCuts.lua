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

function Short.serialize(v)
    local t = type(v)

    if t == "number" or t == "boolean" then
        return tostring(v)

    elseif t == "string" then
        return '"' .. v:gsub('"', '\\"') .. '"'

    elseif t == "table" then
        local out = {}

        for k, val in pairs(v) do
            out[#out+1] =
                "[" .. Short.serialize(k) .. "]=" .. Short.serialize(val)
        end

        return "{" .. table.concat(out, ";") .. "}"
    end

    return "nil"
end

function Short.deserialize(str)
    local i = 1

    local function skip()
        while str:sub(i,i):match("%s") do
            i = i + 1
        end
    end

    local function parse_value()
        skip()
        local c = str:sub(i,i)

        -- число
        if c:match("[%d%-]") then
            local start = i
            while str:sub(i,i):match("[%d%.%-]") do
                i = i + 1
            end
            return tonumber(str:sub(start, i-1))

        -- строка
        elseif c == '"' then
            i = i + 1
            local result = ""

            while true do
                local ch = str:sub(i,i)

                if ch == '"' then
                    i = i + 1
                    break
                elseif ch == "\\" then
                    local next = str:sub(i+1,i+1)
                    if next == '"' then
                        result = result .. '"'
                    elseif next == "\\" then
                        result = result .. "\\"
                    else
                        result = result .. next
                    end
                    i = i + 2
                else
                    result = result .. ch
                    i = i + 1
                end
            end

            return result

        -- boolean
        elseif str:sub(i, i+3) == "true" then
            i = i + 4
            return true
        elseif str:sub(i, i+4) == "false" then
            i = i + 5
            return false
        elseif str:sub(i, i+2) == "nil" then
            i = i + 3
            return nil

        -- массив
        elseif c == "[" then
            i = i + 1
            local arr = {}

            skip()
            if str:sub(i,i) == "]" then
                i = i + 1
                return arr
            end

            while true do
                arr[#arr+1] = parse_value()
                skip()

                local ch = str:sub(i,i)
                if ch == "]" then
                    i = i + 1
                    break
                end

                if ch ~= "," then
                    error("Expected ',' in array")
                end
                i = i + 1
            end

            return arr

        -- таблица
        elseif c == "{" then
            i = i + 1
            local obj = {}

            skip()
            if str:sub(i,i) == "}" then
                i = i + 1
                return obj
            end

            while true do
                skip()

                if str:sub(i,i) ~= "[" then
                    error("Expected '[' for key")
                end
                i = i + 1

                local key = parse_value()

                if str:sub(i,i) ~= "]" then
                    error("Expected ']' after key")
                end
                i = i + 1

                skip()
                if str:sub(i,i) ~= "=" then
                    error("Expected '=' after key")
                end
                i = i + 1

                local val = parse_value()
                obj[key] = val

                skip()
                local ch = str:sub(i,i)

                if ch == "}" then
                    i = i + 1
                    break
                end

                if ch ~= ";" then
                    error("Expected ';' between entries")
                end
                i = i + 1
            end

            return obj
        end

        error("Unexpected character: " .. c)
    end

    return parse_value()
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
