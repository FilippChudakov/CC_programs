--- Functions ---
peripheral.find("modem", rednet.open)

function SendMessage(Message, SendId, Length, id)
    if SendId == "1" then
        rednet.send(id, "BankSendId: 1")
        rednet.send(id, Message)
        
        print("Message send!")
    elseif SendId == "2" then
        rednet.send(id, "BankSendId: 2")
        rednet.send(id, Message)
        
        print("Message send!")
    elseif SendId == "3" then
        if GetMoney(Message) ~= nil then
            rednet.send(id, "BankSendId: 3")
            rednet.send(id, GetMoney(Message))
        else
            rednet.send(id, "BankSendId: 2")
            rednet.send(id, "Account doesn't exists!")
        end
        
        print("Message send!")
    elseif SendId == "4" then
        rednet.send(id, "BankSendId: 4")
        rednet.send(id, Length)
        
        for L = 1, Length do
            rednet.send(id, Message)
            print("Sending...")
            rednet.broadcast(Message)
        end
        
        print("Message send!")
    end
    print("")
end

function GetMoney(AccName)
    print("Getting money from Account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
        print("Account exists...")
        local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
        
        local MoneyTXT = fs.open(MoneyPATH, "r")
        local money = MoneyTXT.readAll()
        MoneyTXT.close()
        
        print("Complete!")
        print("")
        return money
    else
        print("Account doesn't exists!")
        print("")
        return nil
    end
end

function AddAccount(AccName, PassWord, id)
    print("Adding account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == false then
    
        print("Account doesn't exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
        
        local PassTXT = fs.open(PassPATH, "w")
        PassTXT.write(PassWord)
        PassTXT.close()
        print("Password.txt created...")
        
        local MoneyTXT = fs.open(MoneyPATH, "w")
        MoneyTXT.write("0")
        MoneyTXT.close()
        print("Money.txt created...")
        
        print("Account created!")
        SendMessage("Account created!", "1", nil, id)
    else
        printError("Account already exists!")
        SendMessage("Account already exists!", "2", nil, id)
    end
end

function DeleteAccount(AccName, PassWord, id)
    print("Deleting Account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local PassTXT = fs.open(PassPATH, "r")
        local pass = PassTXT.readAll()
        PassTXT.close()
        
        if pass == PassWord then
            print("Password correct...")
            local BankAccPATH = "BankAccounts/"..AccName
            local OffBankAccMoneyPATH = "BankAccounts/OffBankAcc/money.txt"
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
            
            local Money1TXT = fs.open(MoneyPATH, "r")
            local Money1STR = Money1TXT.readAll()
            Money1TXT.close()

            local Money1INT = tonumber(Money1STR)
            
            local Money2TXT = fs.open(OffBankAccMoneyPATH, "r")
            local Money2STR = Money2TXT.readAll()
            Money2TXT.close()

            local Money2INT = tonumber(Money2STR)

            local NewMoney = Money2INT + Money1INT
            
            local Money2TXT = fs.open(OffBankAccMoneyPATH, "w")
            Money2TXT.write(NewMoney)
            Money2TXT.close()
        
            fs.delete(BankAccPATH)
        
            print("Account Deleted!")
            SendMessage("Account Deleted!", "1", nil, id)
        else
            printError("Password incorrect!")
            SendMessage("Password incorrect!", "2", nil, id)
        end
    else
        printError("Account doesn't exists!")
        SendMessage("Account doesn't exists!", "2", nil, id)
    end
end

function ChangePassword(AccName, OldPassWord, NewPassWord, id)
    print("Change password for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
        
        print("Account exists...")
        local PassPATH = "BankAccounts/"..AccName.."/password.txt"
        
        local PassTXT = fs.open(PassPATH, "r")
        local pass = PassTXT.readAll()
        PassTXT.close()
        
        if OldPassWord == pass then
        
            print("Password correct...")
            local PassPATH = "BankAccounts/"..AccName.."/password.txt"
            
            local PassTXT = fs.open(PassPATH, "w")
            PassTXT.write(NewPassWord)
            PassTXT.close()
            
            print("Password changed!")
            SendMessage("Password changed!", "1", nil, id)
        else
            printError("Password incorrect!")
            SendMessage("Password incorrect!", "2", nil, id)
        end
    else
        printError("Account doesn't exists!")
        SendMessage("Account doesn't exists!", "2", nil, id)
    end
end

function AddMoney(AccName, Summ, SecretPass, id)
    print("Adding money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local SecretTXT = fs.open(SecretPATH, "r")
        local Secret = SecretTXT.readAll()
        SecretTXT.close()
        
        if SecretPass == Secret then
            print("SecretPass correct...")
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
    
            local MoneyTXT = fs.open(MoneyPATH, "r")
            local MoneySTR = MoneyTXT.readAll()
            MoneyTXT.close()

            local MoneyINT = tonumber(MoneySTR)

            local NewMoney = MoneyINT + Summ

            local MoneyTXT = fs.open(MoneyPATH, "w")
            MoneyTXT.write(NewMoney)
            MoneyTXT.close()
            print("Complete!")
            SendMessage("Complete!", "1", nil, id)
        else
            printError("SecretPass incorrect!")
            SendMessage("SecretPass incorrect!", "2", nil, id)
        end
    else
        printError("Account doesn't exists!")
        SendMessage("Account doesn't exists!", "2", nil, id)
    end
end

function MinusMoney(AccName, Summ, SecretPass, id)
    print("Minusing money for account: "..AccName.."...")
    local BankAccPATH = "BankAccounts/"..AccName
    if fs.exists(BankAccPATH) == true then
    
        print("Account exists...")
        local SecretPATH = "BankData/SecretPass.txt"
        
        local SecretTXT = fs.open(SecretPATH, "r")
        local Secret = SecretTXT.readAll()
        SecretTXT.close()
        
        if SecretPass == Secret then
            print("SecretPass correct...")
            local MoneyPATH = "BankAccounts/"..AccName.."/money.txt"
    
            local MoneyTXT = fs.open(MoneyPATH, "r")
            local MoneySTR = MoneyTXT.readAll()
            MoneyTXT.close()

            local MoneyINT = tonumber(MoneySTR)
            local SummINT = tonumber(Summ)

            if MoneyINT > SummINT then
                local MoneyTXT = fs.open(MoneyPATH, "r")
                local MoneySTR = MoneyTXT.readAll()
                MoneyTXT.close()
                
                local MoneyINT = tonumber(MoneySTR)

                local NewMoney = MoneyINT - Summ
                            
                local MoneyTXT = fs.open(MoneyPATH, "w")
                MoneyTXT.write(NewMoney)
                MoneyTXT.close()
                            
                print("Complete!")
                SendMessage("Complete!", "1", nil, id)
            else
                printError("Not enough money!")
                SendMessage("Not enough money!", "2", nil, id)
            end
        else
            printError("SecretPass incorrect!")
            SendMessage("SecretPass incorrect!", "2", nil, id)
        end
    else
        printError("Account doesn't exists!")
        SendMessage("Account doesn't exists!", "2", nil, id)
    end
end

function TransferMoney(FirstAccName, SecondAccName, PassWord, Summ, id)
    print("Transferring money from account: "..FirstAccName.." to account: "..SecondAccName.."...")
    local BankFirstAccPATH = "BankAccounts/"..FirstAccName
    if fs.exists(BankFirstAccPATH) == true then
    
        print("First account exists...")
        local BankSecondAccPATH = "BankAccounts/"..SecondAccName
        if fs.exists(BankSecondAccPATH) == true then

            print("Second account exists...")
            local PassPATH = "BankAccounts/"..FirstAccName.."/password.txt"
            
            local PassTXT = fs.open(PassPATH, "r")
            local pass = PassTXT.readAll()
            PassTXT.close()
            
            if PassWord == pass then
                print("Password correct...")
                local MoneyPATH = "BankAccounts/"..FirstAccName.."/money.txt"
        
                local MoneyTXT = fs.open(MoneyPATH, "r")
                local MoneySTR = MoneyTXT.readAll()
                MoneyTXT.close()

                local MoneyINT = tonumber(MoneySTR)

                if MoneyINT > Summ then
                    local MoneyPATH1 = "BankAccounts/"..FirstAccName.."/money.txt"
                    local MoneyPATH2 = "BankAccounts/"..SecondAccName.."/money.txt"

                    local Money1TXT = fs.open(MoneyPATH1, "r")
                    local Money1STR = Money1TXT.readAll()
                    Money1TXT.close()
                        
                    local Money1INT = tonumber(Money1STR)

                    local NewMoney1 = Money1INT - Summ
                            
                    local Money1TXT = fs.open(MoneyPATH1, "w")
                    Money1TXT.write(NewMoney1)
                    Money1TXT.close()

                    local Money2TXT = fs.open(MoneyPATH2, "r")
                    local Money2STR = Money2TXT.readAll()
                    Money2TXT.close()

                    local Money2INT = tonumber(Money2STR)

                    local NewMoney2 = Money2INT + (Summ*0.95)
                                
                    local Money2TXT = fs.open(MoneyPATH2, "w")
                    Money2TXT.write(NewMoney2)
                    Money2TXT.close()
                                
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

--- Network Functions ---
function ResetSavings()
    SaveMsgAcc = nil
    SaveMsgPass = nil
    SaveMsgSPass = nil
    SaveMsgSumm = nil
    TermAccSTR = nil
    TermAcc = false
end


function MessageHandler()
    print("Waiting for a message...")
    local id, msg = rednet.receive()
    sessionId = id
    print("Message received...")
    print("Handling message...")
    if msg == "BankomatSendId: 1" then
        print("BankomatSendId: 1...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    local BankAccPATH = "BankAccounts/"..saveMsg

                    if fs.exists(BankAccPATH) == true then
                        print("Account exists!")
                        SendMessage("Account exists!", "1", nil, saveId)
                        break
                    else
                        printError("Account doesn't exists!")
                        SendMessage("Account doesn't exists!", "2", nil, saveId)
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "BankomatSendId: 2" then
        print("BankomatSendId: 2...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    if SaveMsgAcc == nil then
                        print("Saving MsgAcc...")
                        SaveMsgAcc = saveMsg
                    elseif SaveMsgSumm == nil then
                        print("Saving MsgSumm...")
                        SaveMsgSumm = saveMsg
                    elseif SaveMsgSPass == nil then
                        print("Saving MsgSPass...")
                        SaveMsgSPass = saveMsg
                        AddMoney(SaveMsgAcc, SaveMsgSumm, SaveMsgSPass, saveId)
                        ResetSavings()
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "BankomatSendId: 3" then
        print("BankomatSendId: 3...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    if SaveMsgAcc == nil then
                        print("Saving MsgAcc...")
                        SaveMsgAcc = saveMsg
                    elseif SaveMsgSumm == nil then
                        print("Saving MsgSumm...")
                        SaveMsgSumm = saveMsg
                    elseif SaveMsgSPass == nil then
                        print("Saving MsgSPass...")
                        SaveMsgSPass = saveMsg
                        MinusMoney(SaveMsgAcc, SaveMsgSumm, SaveMsgSPass, saveId)
                        ResetSavings()
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "TerminalSendId: 1" then
        print("TerminalSendId: 1...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    local BankAccPATH = "BankAccounts/"..saveMsg
    
                    if fs.exists(BankAccPATH) == true then
                        print("Account exists!")
                        SendMessage("Account exists!", "1", nil, saveId)
                        break
                    else
                        printError("Account doesn't exists!")
                        SendMessage("Account doesn't exists!", "2", nil, saveId)
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "TerminalSendId: 2" then
        print("TerminalSendId: 2...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    
                    if TermAcc == false then
                        print("TermAcc Exists?")
                        local BankAccPATH = "BankAccounts/"..saveMsg

                        if fs.exists(BankAccPATH) == true then
                            print("Account exists!")
                            TermAcc = true
                            TermAccSTR = saveMsg
                        else
                            printError("Account doesn't exists!")
                            SendMessage("Account doesn't exists!", "2", nil, saveId)
                            ResetSavings()
                            break
                        end
                    elseif SaveMsgAcc == nil then
                        print("Saving MsgAcc...")
                        SaveMsgAcc = saveMsg
                    elseif SaveMsgPass == nil then
                        print("Saving MsgPass...")
                        SaveMsgPass = saveMsg
                    elseif SaveMsgSumm == nil then
                        print("Saving MsgSumm...")
                        SaveMsgSumm = saveMsg


                        local BankPassPATH = "BankAccounts/"..SaveMsgAcc.."/password.txt"

                        local PassTXT = fs.open(BankPassPATH, "r")
                        local pass = PassTXT.readAll()
                        PassTXT.close()

                        if SaveMsgPass == pass then
                            print("Password correct...")
                            local BankMoneyPATH = "BankAccounts/"..SaveMsgAcc.."/money.txt"

                            local MoneyTXT = fs.open(BankMoneyPATH, "r")
                            local money = MoneyTXT.readAll()
                            MoneyTXT.close()

                            local moneyINT = tonumber(money)

                            local SaveMsgSummINT = tonumber(SaveMsgSumm)

                            if moneyINT > SaveMsgSummINT then
                                print("Money enough...")

                                local SaveMsgSummINT = tonumber(SaveMsgSumm)

                                TransferMoney(SaveMsgAcc, TermAccSTR, SaveMsgPass, SaveMsgSummINT, saveId)

                                print("Complete!")
                                SendMessage("Complete!", "1", nil, saveId)
                                ResetSavings()
                                break
                            else
                                printError("ServerError 2!")
                                SendMessage("ServerError 2", "2", nil , saveId)
                                ResetSavings()
                                break
                            end
                        else
                            printError("Password incorrect!")
                            print()
                            print(saveId)
                            SendMessage("Password incorrect!", "2", nil, saveId)
                            ResetSavings()
                            break
                        end
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "RBankSendId: 1" then
        print("RBankSendId: 1...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")
                    local BankAccPATH = "BankAccounts/"..saveMsg
    
                    if fs.exists(BankAccPATH) == true then
                        print("Account exists!")
                        SendMessage("Account exists!", "1", nil, saveId)
                        ResetSavings()
                        break
                    else
                        printError("Account doesn't exists!")
                        SendMessage("Account doesn't exists!", "2", nil, saveId)
                        ResetSavings()
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "RBankSendId: 2" then
        print("RBankSendId: 2...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")

                    if SaveMsgAcc == nil then
                        print("Saving MsgAcc...")
                        SaveMsgAcc = saveMsg
                    elseif SaveMsgPass == nil then
                        print("Saving MsgPass...")
                        SaveMsgPass = saveMsg

                        if SaveMsgPass ~= nil then
                            print("MsgPass not nil...")
                            local BankPassPATH = "BankAccounts/"..SaveMsgAcc.."/password.txt"

                            local PassTXT = fs.open(BankPassPATH, "r")
                            local pass = PassTXT.readAll()
                            PassTXT.close()

                            if SaveMsgPass == pass then
                                print("Password correct!")
                                SendMessage("Password correct!", "1", nil, saveId)
                                ResetSavings()
                                break
                            else
                                printError("Password incorrect!")
                                SendMessage("Password incorrect!", "2", nil, saveId)
                                ResetSavings()
                                break
                            end
                        else
                            printError("ServerError 2!")
                            SendMessage("ServerError 2", "2", nil , saveId)
                            ResetSavings()
                            break
                        end
                    else
                        printError("ServerError 2!")
                        SendMessage("ServerError 2", "2", nil , saveId)
                        ResetSavings()
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "RBankSendId: 3" then
        print("RBankSendId: 3...")
        while true do
            print("receiving...")
            local id, msg = rednet.receive(nil, 1)
            saveId = id
            saveMsg = msg
            if msg ~= nil then
                print("Msg not nil")
                if saveId == sessionId  then
                    print("SaveId and sessionId is match...")

                    if SaveMsgAcc == nil then
                        print("Saving MsgAcc...")
                        SaveMsgAcc = saveMsg
                    elseif SaveMsgPass == nil then
                        print("Saving MsgPass...")
                        SaveMsgPass = saveMsg

                        if SaveMsgPass ~= nil then
                            print("MsgPass not nil...")
                            local BankAccPATH = "BankAccounts/"..SaveMsgAcc

                            AddAccount(SaveMsgAcc, SaveMsgPass, saveId)
                            ResetSavings()
                            break
                        else
                            printError("ServerError 2!")
                            SendMessage("ServerError 2", "2", nil , saveId)
                            ResetSavings()
                            break
                        end
                    else
                        printError("ServerError 2!")
                        SendMessage("ServerError 2", "2", nil , saveId)
                        ResetSavings()
                        break
                    end
                else
                    printError("Message with a wrong id...")
                    SendMessage("ServerError 2", "2", nil , saveId)
                end
            else
                printError("Message is too late!")
                SendMessage("Message is too late!", "2", nil, sessionId)
                ResetSavings()
                break
            end
        end
    elseif msg == "BANKSENDID: OFF" then
        print("OFF...")
        sleep(2)
        local OffTXT = fs.open("BankData/Off.txt", "w")
        OffTXT.write("1")
        OffTXT.close()
        peripheral.find("modem", rednet.close)
        os.reboot()
    else
        printError("Wrong BankSystem Id!")
        SendMessage("Wrong BankSystem Id!", "2", nil, id)
    end
end

--- Main while true ---


while true do
    ResetSavings()
    --MessageHandler()
    local try = pcall(MessageHandler)
    if try == false then
        ResetSavings()
        print("")
        printError("Unknown Error")
        print("")
    end
end
