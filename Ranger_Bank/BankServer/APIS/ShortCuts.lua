local Network = require("APIS/Network")
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

-- BankFunctions
function Short.GetMoney(AccName)
    print("Getting money from Account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) then
        print("Account exists...")
        local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
        
        money = Short.Read(MoneyPATH)
        
        print("Complete!")
        print("")
        return money
    else
        printError("Account doesn't exists!")
        print("")
        return nil
    end
end

function Short.AddAccount(AccName, Password, id)
    print("Adding account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == false then
        print("Account doesn't exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
        
        Short.Write(Password, PassPATH)
        print("Password.txt created...")
        
        Short.Write("0", PassPATH)
        print("Money.txt created...")
        
        print("Account created!")
        Network.send("1", "Account created!", "RangerBank", id)
    else
        printError("Account already exists!")
        Network.send("2", "Account already exists!", "RangerBank", id)
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
            Network.send("1", "Account Deleted!", "RangerBank", id)
        else
            printError("Password incorrect!")
            Network.send("2", "Password incorrect!", "RangerBank", id)
        end
    else
        printError("Account doesn't exists!")
        Network.send("2", "Account doesn't exists!", "RangerBank", id)
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
            Network.send("1","Password changed!", "RangerBank", id)
        else
            printError("Password incorrect!")
            Network.send("2", "Password incorrect!", "RangerBank", id)
        end
    else
        printError("Account doesn't exists!")
        Network.send("2", "Account doesn't exists!", "RangerBank", id)
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
            Network.send("1", "Complete!", "RangerBank", id)
        else
            printError("SecretPass incorrect!")
            Network.send("2", "SecretPass incorrect!", "RangerBank", id)
        end
    else
        printError("Account doesn't exists!")
        Network.send("2", "Account doesn't exists!", "RangerBank", id)
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
                Network.send("1", "Complete!", "RangerBank", id)
            else
                printError("Not enough money!")
                Network.send("2", "Not enough money!", "RangerBank", id)
            end
        else
            printError("SecretPass incorrect!")
            Network.send("2", "SecretPass incorrect!", "RangerBank", id)
        end
    else
        printError("Account doesn't exists!")
        Network.send("2", "Account doesn't exists!", "RangerBank", id)
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
            local PassPATH = "BankAccounts/"..Sender.."/password.txt"
            
            local password = Short.Read(PassPATH)
            
            if Password == password then
                print("Password correct...")
                local MoneyPATH1 = "BankAccounts/"..Sender.."/money.txt"
        
                local money = Short.Read(MoneyPATH1)

                if tonumber(money) > Summ then
                    local MoneyPATH2 = "BankAccounts/"..Receiver.."/money.txt"
                    local BankMoneyPATH = "BankData/money.txt"

                    local money1 = Short.Read(MoneyPATH1)
                    local money2 = Short.Read(MoneyPATH2)
                    local bank_money = Short.Read(BankMoneyPATH)

                    local new_money1 = tonumber(money1) - Summ
                    local mew_money2 = tonumber(money2) + (Summ*Short.commission)
                    local new_bank_money = tonumber(bank_money) + Summ - (Summ*Short.commission)

                    Short.Write(new_money1, MoneyPATH)
                    Short.Write(new_money2, MoneyPATH2)
                    Short.Write(new_bank_money, BankMoneyPATH)

                    local LogTXT = fs.open("BankData/TransferLogs.txt", "a")
                    LogTXT.write("\nTransferring "..Summ.." from account: "..Sender.." to account: "..Receiver.." id: "..id)
                    LogTXT.write("Commission: "..(Summ - Short.commission)..", Final transfer: "..(Summ*Short.commission))
                    LogTXT.close()
                                
                    print("Transfering is completed!")
                    SendMessage("Transfering is completed!", "1", nil, id)
                else
                    printError("Not enough money!")
                    SendMessage("Not enough money!", "2", nil, id)
                end
            else
                printError("Password incorrect!")
                SendMessage("Password incorrect!", "2", nil, id)
            end
        else
            printError("Second account doesn't exists!")
            SendMessage("Second account doesn't exists!", "2", nil, id)
        end
    else
        printError("First account doesn't exists!")
        SendMessage("First account doesn't exists!", "2", nil, id)
    end
end

function Network.BankOFF(SecretPass, id)
    local SecretPassPATH = "BankData/SecretPass.txt"
    local OffPATH = "BankData/Off.txt"

    local secret_pass = Short.Read(SecretPassPATH)

    if secret_pass == SecretPass then
        Network.send("1", "OFF", "RangerBank", id)
        Network.close()
        Short.Write("1", OffPATH)
        print("Off...")
        os.sleep(1)
        os.reboot()
    end
end

return Short