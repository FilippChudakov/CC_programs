Short = {}

Short.commission = 1.00

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
        local is_array = true
        local i = 1
        for k in pairs(v) do
            if k ~= i then
                is_array = false
                break
            end
            i = i + 1
        end

        local result

        if is_array then
            local out = {}
            for i = 1, #v do
                out[#out+1] = Short.serialize(v[i])
            end
            result = "[" .. table.concat(out, ",") .. "]"
        else
            local out = {}
            for k, val in pairs(v) do
                out[#out+1] = k .. "=" .. Short.serialize(val)
            end
            result = "{" .. table.concat(out, ";") .. "}"
        end

        return result
    end

    return "nil"
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

function Short.CreateLog(filepath, log)
    local Full_log = {}
    local serialized_log = Short.serialize(log)
    table.insert(Full_log, serialized_log)

    local serialized_Full_log = Short.serialize(Full_log)
    Short.Write(serialized_Full_log, filepath)
end

function Short.GenerateLog(typed, data)
    local log = {}
    local date = os.date("%Y-%m-%d %H:%M")

    local serialized_data = Short.serialize(data)

    log["type"] = typed
    log["date"] = date
    log["data"] = serialized_data

    return log
end

function Short.AddInLog(filepath, log)
    local file = Short.Read(filepath)
    local Full_log = Short.deserialize(file)

    local serialized_log = Short.serialize(log)
    table.insert(Full_log, serialized_log)

    local serialized_Full_log = Short.serialize(Full_log)
    Short.Write(serialized_Full_log, filepath)
end

function Short.DeleteFullLog(filepath, typed)
    local file = Short.Read(filepath)
    local Full_log = Short.deserialize(file)

    local new_log = {}
    local find = false

    for i, value in ipairs(Full_log) do
        if typed ~= Short.deserialize(value)["type"] then
            table.insert(new_log, value)
        else
            find = true
        end
    end

    Short.Write(Short.serialize(new_log), filepath)

    return find
end

function Short.BanSymbols(data)
    local symbols = Short.Read("BankData/symbols.txt")

    symbols_list = {}

    for symbol in symbols:gmatch("%S+") do
        table.insert(symbols_list, symbol)
    end

    ban = false

    for i, value in ipairs(symbols_list) do
        if string.find(data, value) ~= nil then
            ban = true
        end
    end

    return ban
end

-- BankFunctions
function Short.GetMoney(AccName)
    print("Getting money from Account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return nil
    end

    if fs.exists(BankAccPATH) then
        print("Account exists...")
        local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
        
        money = Short.Read(MoneyPATH)
        
        print("Complete!\n")
        return money
    else
        printError("Account doesn't exists!\n")
        return nil
    end
end

function Short.GetMoney_Net(Accname, Password, id)
    local BankAccPath = "BankAccounts/"..Accname
    local BankPassPath = "BankAccounts/"..Accname.."/password.txt"

    if Short.BanSymbols(Accname) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPath) then
        local server_password = Short.Read(BankPassPath)
        if server_password == Password then
            if Password ~= nil then
                return true
            else
                printError("Password is nil!")
                return "nil_password"
            end
        else
            printError("Password incorrect!")
            return "password_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.AddAccount(AccName, Password, id)
    print("Adding account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPATH) == false then
        print("Account doesn't exists...")
        if #AccName <= 10 then
            if Password ~= nil then
                local PassPATH = "BankAccounts/"..AccName.."/password.txt"
                local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
                local LogsPATH = "BankAccounts/"..AccName.."/logs.txt"
            
                Short.Write(Password, PassPATH)
                print("Password.txt created...")
            
                Short.Write("0", MoneyPATH)
                print("Money.txt created...")

                Short.CreateLog(LogsPATH, Short.GenerateLog("Created", {id}))
                print("Logs.txt created...")
            
                print("Account created!")
                return true
            else
                printError("Password is nil!")
                return "nil_password"
            end
        else
            printError("Too many characters!")
            return "too_many_characters"
        end
    else
        printError("Account already exists!")
        return "account_already_exists"
    end
end

function Short.DeleteAccount(AccName, Password, id)
    print("Deleting Account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local pass = Short.Read(PassPATH)
        
        if pass == Password and Password ~= nil then
            print("Password correct...")
            local BankAccPATH = "BankAccounts/"..AccName
            local BankMoneyPATH = "BankData/money.txt"
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
            
            local money1 = Short.Read(MoneyPATH)
            local money2 = Short.Read(BankMoneyPATH)

            local NewMoney = tonumber(money2) + tonumber(money1)
            
            Short.Write(NewMoney, BankMoneyPATH)
        
            fs.delete(BankAccPATH)
        
            print("Account Deleted!")
            return true
        else
            printError("Password incorrect!")
            return "password_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.ChangePassword(AccName, OldPassword, NewPassword, id)
    print("Change password for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPATH) == true then
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local pass = Short.Read(PassPATH)
        
        if OldPassword == pass and OldPassword ~= nil then
            print("Password correct...")
            local PassPATH = "BankAccounts/"..AccName.."/password.txt"
            
            Short.Write(NewPassword, PassPATH)
            
            print("Password changed!")
            return true
        else
            printError("Password incorrect!")
            return "password_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.AddMoney(AccName, Summ, SecretPass, id)
    Summ = math.floor(Summ)
    print("Adding money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPATH) == true then
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local Secret = Short.Read(SecretPATH)
        
        if SecretPass == Secret then
            if Summ > 0 then
                print("SecretPass correct...")
                local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
                local BankMoneyPATH = "BankData/money.txt"
    
                local money = Short.Read(MoneyPATH)
                local bank_money = Short.Read(BankMoneyPATH)

                local new_money = tonumber(money) + Summ
                local new_bank_money = tonumber(bank_money) - Summ

                Short.Write(new_money, MoneyPATH)
                Short.Write(new_bank_money, BankMoneyPATH)

                print("Complete!")
                return true
            else
                printError("Not enough money!")
                return "not_enough_money"
            end
        else
            printError("SecretPass incorrect!")
            return "secretpass_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.MinusMoney(AccName, Summ, SecretPass, id)
    Summ = math.floor(Summ)
    print("Minusing money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName

    if Short.BanSymbols(AccName) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local Secret = Short.Read(SecretPATH)
        
        if SecretPass == Secret then
            print("SecretPass correct...")
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
            
            local money = Short.Read(MoneyPATH)

            if Summ > 0 then
                if tonumber(money) >= tonumber(Summ) then
                    local BankMoneyPATH = "BankData/money.txt"

                    local money = Short.Read(MoneyPATH)
                    local bank_money = Short.Read(BankMoneyPATH)

                    local new_money = tonumber(money) - Summ
                    local new_bank_money = tonumber(bank_money) + Summ

                    Short.Write(new_money, MoneyPATH)
                    Short.Write(new_bank_money, BankMoneyPATH)
                            
                    print("Complete!")
                    return true
                else
                    printError("Not enough money!")
                    return "not_enough_money"
                end
            else
                printError("Not enough money!")
                return "not_enough_money"
            end
        else
            printError("SecretPass incorrect!")
            return "secretpass_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.TransferMoney(Sender, Receiver, Password, Summ, id)
    Summ = math.floor(Summ * 100) / 100
    print("Transferring money from account: "..Sender.." to account: "..Receiver.."...")
    local BankFirstAccPATH = "BankAccounts/"..Sender

    if Short.BanSymbols(Sender) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if Short.BanSymbols(Receiver) then
        printError("Illegal characters!")
        return "illegal_characters"
    end

    if fs.exists(BankFirstAccPATH) == true then
    
        print("First account exists...")
        local BankSecondAccPATH = "BankAccounts/"..Receiver
        if fs.exists(BankSecondAccPATH) == true then

            print("Second account exists...")
            if Sender ~= Receiver then

                local PassPATH = "BankAccounts/"..Sender.."/password.txt"
                local password = Short.Read(PassPATH)
                
                if Password == password and Password ~= nil then
                    print("Password correct...")
                    local MoneyPATH1 = "BankAccounts/"..Sender.."/money.txt"
        
                    local money = Short.Read(MoneyPATH1)

                    if Summ > 0 then
                        if tonumber(money) >= Summ then
                            print("Money enough...")
                            local MoneyPATH2 = "BankAccounts/"..Receiver.."/money.txt"
                            local BankMoneyPATH = "BankData/money.txt"

                            local money1 = Short.Read(MoneyPATH1)
                            local money2 = Short.Read(MoneyPATH2)
                            local bank_money = Short.Read(BankMoneyPATH)

                            local new_money1 = tonumber(money1) - Summ
                            local new_bank_money = tonumber(bank_money) + Summ - (Summ*Short.commission)

                            Short.Write(new_money1, MoneyPATH1)
                            Short.Write(tonumber(money2) + (Summ*Short.commission), MoneyPATH2)
                            Short.Write(new_bank_money, BankMoneyPATH)

                            local LogTXT = fs.open("BankData/TransferLogs.txt", "a")
                            LogTXT.write("Transferring "..Summ.." from account: "..Sender.." to account: "..Receiver.." id: "..id)
                            LogTXT.write(" Commission: "..(1-Short.commission)..", Final transfer: "..(Summ*Short.commission).."\n")
                            LogTXT.close()
                                
                            print("Transfering is completed!")
                            return true
                        else
                            printError("Not enough money!")
                            return "not_enough_money"
                        end
                    else
                        printError("Not enough money!")
                        return "not_enough_money"
                    end
                else
                    printError("Password incorrect!")
                    return "password_incorrect"
                end
            else
                printError("Second account doesn't exists!")
                return "second_account_doesnt_exists"
            end
        else
            printError("Second account doesn't exists!")
            return "second_account_doesnt_exists"
        end
    else
        printError("First account doesn't exists!")
        return "first_account_doesnt_exists"
    end
end

function Short.BankOFF(SecretPass, id)
    local SecretPassPATH = "BankData/SecretPass.txt"

    local secret_pass = Short.Read(SecretPassPATH)

    if secret_pass == SecretPass then
        return true
    end
end

return Short
