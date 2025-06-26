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

function Short.CreateLog(filepath, log)
    local Full_log = {}
    local serialized_log = Short.serialize(log)
    table.insert(Full_log, serialized_log)

    local serialized_Full_log = Short.serialize(Full_log)
    Short.Write(serialized_Full_log, filepath)
end

function Short.GenerateLog(typed, data)
    local log = {}
    local date = os.date("%Y-%m-%d")

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

function Short.AddAccount(AccName, Password, id)
    print("Adding account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == false then
        print("Account doesn't exists...")
        if #AccName <= 10 then
            if not Short.BanSymbols(AccName) then
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
                printError("Illegal characters!")
                return "illegal_characters"
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
    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local pass = Short.Read(PassPATH)
        
        if pass == Password then
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
    if fs.exists(BankAccPATH) == true then
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local pass = Short.Read(PassPATH)
        
        if OldPassword == pass then
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
    print("Adding money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local Secret = Short.Read(SecretPATH)
        
        if SecretPass == Secret then
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
            printError("SecretPass incorrect!")
            return "secretpass_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.MinusMoney(AccName, Summ, SecretPass, id)
    print("Minusing money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local Secret = Short.Read(SecretPATH)
        
        if SecretPass == Secret then
            print("SecretPass correct...")
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
            
            local money = Short.Read(MoneyPATH)

            if tonumber(money) > tonumber(Summ) then
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
            printError("SecretPass incorrect!")
            return "secretpass_incorrect"
        end
    else
        printError("Account doesn't exists!")
        return "account_doesnt_exists"
    end
end

function Short.TransferMoney(Sender, Receiver, Password, Summ, id)
    print("Transferring money from account: "..Sender.." to account: "..Receiver.."...")
    local BankFirstAccPATH = "BankAccounts/"..Sender
    if fs.exists(BankFirstAccPATH) == true then
    
        print("First account exists...")
        local BankSecondAccPATH = "BankAccounts/"..Receiver
        if fs.exists(BankSecondAccPATH) == true then

            print("Second account exists...")
            if Sender ~= Receiver then

                local PassPATH = "BankAccounts/"..Sender.."/password.txt"
                local password = Short.Read(PassPATH)
                
                if Password == password then
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
                            LogTXT.write("\nTransferring "..Summ.." from account: "..Sender.." to account: "..Receiver.." id: "..id)
                            LogTXT.write(" Commission: "..(Summ - Short.commission)..", Final transfer: "..(Summ*Short.commission))
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
