local Short = dofile("APIS/ShortCuts.lua")

local Network = {}

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.open)
end

function Network.send(SendId, Message, Protocol, id)
    if SendId == "1" then
        rednet.send(id, "RangerBank: 1", Protocol)
        rednet.send(id, Message, Protocol)

        print("Message send!")

    elseif SendId == "2" then
        rednet.send(id, "RangerBank: 2", Protocol)
        rednet.send(id, Message, Protocol)
        
        print("Message send!")

    elseif SendId == "3" then
        if Short.GetMoney(Message) ~= nil then
            rednet.send(id, "RangerBank: 3", Protocol)
            rednet.send(id, Short.GetMoney(Message), Protocol)
        else
            rednet.send(id, "RangerBank: 2", Protocol)
            rednet.send(id, "Account doesn't exists!", Protocol)
        end
        
        print("Message send!")
    end
end

function Network.MessageHandler()
    print("Waiting for a message...")
    local session_id, send_id = rednet.receive("RangerBank")

    if send_id == "ping" then
        rednet.send(session_id, "pong")
    elseif send_id == "RangerBank:get_money" then
        print("getting money...")
        local password, account = 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif account == 1 then
                        account = message

                        local BankAccPath = "BankAccounts/"..account
                        local BankPassPath = "BankAccounts/"..account.."/password.txt"

                        if fs.exists(BankAccPath) then

                            local server_password = Short.Read(BankPassPath)
                            if server_password == password then
                                Network.send("3", account, "RangerBank", id)
                                break
                            else
                                Network.send("2", "Wrong password!", "RangerBank", id)
                                printError("Wrong password!")
                                break
                            end
                        else
                            Network.send("2", "Account doesn't exist!", "RangerBank", id)
                            printError("Account doesn't exist!")
                            break
                        end
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:login" then
            
        print("login...")
        local password, account = 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif account == 1 then
                        account = message

                        local BankAccPath = "BankAccounts/"..account
                        local BankPassPath = "BankAccounts/"..account.."/password.txt"

                        if fs.exists(BankAccPath) then

                            local server_password = Short.Read(BankPassPath)
                            if server_password == password then

                                Network.send("1", "Succesfuly logined!", "RangerBank", id)
                                print("Succesfuly logined!")
                                print("")
                                break
                            else
                                Network.send("2", "Wrong password!", "RangerBank", id)
                                printError("Wrong password!")
                                break
                            end
                        else
                            Network.send("2", "Account doesn't exist!", "RangerBank", id)
                            printError("Account doesn't exist!")
                            break
                        end
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:register" then
        print("register...")
        local password, account = 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif account == 1 then
                        account = message

                        print("Creating account...")
                        local result = Short.AddAccount(account, password, id)
                        if result == true then
                            Network.send("1", "Account created!", "RangerBank", id)
                        elseif result == "account_already_exists" then
                            Network.send("2", "Account already exists!", "RangerBank", id)
                        elseif result == "too_many_characters" then
                            Network.send("2", "Too many characters!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:delete_account" then
        print("deleting account...")
        local password, account = 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif account == 1 then
                        account = message

                        local result = Short.DeleteAccount(account, password, id)
                        if result == true then
                            Network.send("1", "Account Deleted!", "RangerBank", id)
                        elseif result == "password_incorrect" then
                            Network.send("2", "Password incorrect!", "RangerBank", id)
                        elseif result == "account_doesnt_exists" then
                            Network.send("2", "Account doesn't exists!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:change_password" then
        print("change password...")
        local password_old, password_new, account = 1, 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password_old == 1 then
                        password_old = message
                    elseif password_new == 1 then
                        password_new = message
                    elseif account == 1 then
                        account = message

                        local LogsPATH = "BankAccounts/"..account.."/logs.txt"

                        local result = Short.ChangePassword(account, password_old, password_new, id)
                        if result == true then
                            Network.send("1", "Password changed!", "RangerBank", id)
                            Short.AddInLog(LogsPATH, Short.GenerateLog("Change pass", {session_id}))
                        elseif result == "password_incorrect" then
                            Network.send("2", "Password incorrect!", "RangerBank", id)
                        elseif result == "account_doesnt_exists" then
                            Network.send("2", "Account doesn't exists!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:add_money" then
        print("adding money...")
        local secret_pass, money, account = 1, 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if secret_pass == 1 then
                        secret_pass = message
                    elseif money == 1 then
                        money = message
                    elseif account == 1 then
                        account = message

                        local result = Short.AddMoney(account, money, secret_pass, id)
                        if result == true then
                            Network.send("1", "Complete!", "RangerBank", id)
                        elseif result == "secretpass_incorrect" then
                            Network.send("2", "SecretPass incorrect!", "RangerBank", id)
                        elseif result == "account_doesnt_exists" then
                            Network.send("2", "Account doesn't exists!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end 
    elseif send_id == "RangerBank:minus_money" then
        print("minusing money...")
        local secret_pass, money, account = 1, 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if secret_pass == 1 then
                        secret_pass = message
                    elseif money == 1 then
                        money = message
                    elseif account == 1 then
                        account = message

                        local result = Short.MinusMoney(account, money, secret_pass, id)
                        if result == true then
                            Network.send("1", "Complete!", "RangerBank", id)
                        elseif result == "not_enough_money" then
                            Network.send("2", "Not enough money!", "RangerBank", id)
                        elseif result == "secretpass_incorrect" then
                            Network.send("2", "SecretPass incorrect!", "RangerBank", id)
                        elseif result == "account_doesnt_exists" then
                            Network.send("2", "Account doesn't exists!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:transfer_money" then
        print("transfering money...")
        local password, money, receiver, sender = 1, 1, 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif money == 1 then
                        money = message
                    elseif receiver == 1 then
                        receiver = message
                    elseif sender == 1 then
                        sender = message

                        local LogsSPATH = "BankAccounts/"..sender.."/logs.txt"
                        local LogsRPATH = "BankAccounts/"..receiver.."/logs.txt"

                        local result = Short.TransferMoney(sender, receiver, password, tonumber(money), id)
                        if result == true then
                            Short.AddInLog(LogsSPATH, Short.GenerateLog("Transfer", {receiver, money, session_id}))
                            Short.AddInLog(LogsRPATH, Short.GenerateLog("Receive", {sender, money, session_id}))
                            Network.send("1", "Transfering is completed!", "RangerBank", id)
                        elseif result == "not_enough_money" then
                            Network.send("2", "Not enough money!", "RangerBank", id)
                        elseif result == "password_incorrect" then
                            Network.send("2", "Password incorrect!", "RangerBank", id)
                        elseif result == "second_account_doesnt_exists" then
                            Network.send("2", "Receiver doesn't exists!", "RangerBank", id)
                        elseif result == "first_account_doesnt_exists" then
                            Network.send("2", "Sender doesn't exists!", "RangerBank", id)
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:first_login_log" then
        print("Log login...")
        local login = 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if login == 1 then
                        login = message
                        
                        local logPATH = "BankAccounts/"..login.."/logs.txt"
                    
                        Short.AddInLog(logPATH, Short.GenerateLog("Login", {session_id}))
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:get_log" then
        print("Get log...")
        local login, password = 1, 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if password == 1 then
                        password = message
                    elseif login == 1 then
                        login = message
                        
                        local AccountPATH = "BankAccounts/"..login
                        local PassPATH = "BankAccounts/"..login.."/password.txt"
                        local logPATH = "BankAccounts/"..login.."/logs.txt"

                        if fs.exists(AccountPATH) then
                            local pass = Short.Read(PassPATH)
                            if pass == password then
                                local log = Short.Read(logPATH)
                                Network.send("1", log, "RangerBank", id)
                                break
                            else
                                Network.send("2", "Wrong password!", "RangerBank", id)
                                break
                            end
                        else
                            Network.send("2", "Account doesnt exists!", "RangerBank", id)
                            break
                        end
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    elseif send_id == "RangerBank:OFF" then
        print("OFF?...")
        local secret_pass = 1
        while true do
            local id, message = rednet.receive("RangerBank", 1)

            if message ~= nil then
                print("Message is not nil...")
                if session_id == id then
                    print("id and session_id match...")
                    if secret_pass == 1 then
                        secret_pass = message
                    
                        local result = Short.BankOFF(secret_pass, id)
                        if result == true then
                            local OffPATH = "BankData/Off.txt"
                            Network.send("1", "OFF", "RangerBank", id)
                            Network.close()
                            Short.Write("1", OffPATH)
                            print("Off...")
                            os.sleep(1)
                            os.reboot()
                        else
                            Network.send("2", "Error!", "RangerBank", id)
                        end
                        break
                    else
                        Network.send("2", "Error!", "RangerBank", id)
                        break
                    end
                else
                    Network.send("2", "Wrong Id!", "RangerBank", id)
                    printError("Wrong Id!")
                end
            else
                break
            end
        end
    end
end

return Network
