local Short = require("APIS/ShortCuts")
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

function Network.MessageHandler()
    local session_id, send_id = rednet.receive("RangerBank")

    if send_id == "RangerBank:get_money" then
        print("getting money...")
        local password, account = 1
        while true do
        local id, message = rednet.receive("RangerBank", 1)

        if message ~= nil then
            print("Message is not nil...")
            if session_id == id then
                print("id and session_id match...")
                if password == 1 then
                    password == message
                elseif account == 1 then
                    account == message

                    local BankAccPath = "BankAccounts/"..account
                    local BankPassPath = "BankAccounts/"..account.."/password.txt"

                    if fs.exists(BankAccPath) then

                        local server_password = Read(BankPassPath)
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
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:login" then
            
        print("login...")
        local password, account = 1
        while true do
        local id, message = rednet.receive("RangerBank", 1)

        if message ~= nil then
            print("Message is not nil...")
            if session_id == id then
                print("id and session_id match...")
                if password == 1 then
                    password = message
                elseif account == 1 then
                    account == message

                    local BankAccPath = "BankAccounts/"..account
                    local BankPassPath = "BankAccounts/"..account.."/password.txt"

                    if fs.exists(BankAccPath) then

                        local server_password = Read(BankPassPath)
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
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:register" then
        print("register...")
        local password, account = 1
        while true do
        local id, message = rednet.receive("RangerBank", 1)

        if message ~= nil then
            print("Message is not nil...")
            if session_id == id then
                print("id and session_id match...")
                if password == 1 then
                    password = message
                elseif account == 1 then
                    account == message

                    Short.AddAccount(account, password, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:delete_account" then
        print("deleting account...")
        local password, account = 1
        while true do
        local id, message = rednet.receive("RangerBank", 1)

        if message ~= nil then
            print("Message is not nil...")
            if session_id == id then
                print("id and session_id match...")
                if password == 1 then
                    password = message
                elseif account == 1 then
                    account == message

                    Short.DeleteAccount(account, password, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:change_password" then
        print("change password...")
        local password_old, password_new, account = 1
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
                    account == message

                    Short.ChangePassword(account, password_old, password_new, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:add_money" then
        print("adding money...")
        local secret_pass, money, account = 1
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
                    account == message

                    Short.AddMoney(account, money, secret_pass, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
    elseif send_id == "RangerBank:minus_money" then
        print("minusing money...")
        local secret_pass, money, account = 1
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
                    account == message

                    Short.MinusMoney(account, money, secret_pass, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
        end
        elseif send_id == "RangerBank:tranfer_money" then
        print("transfering money...")
        local password, money, account, receiver, sender = 1
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
                    receiver == message
                elseif sender == 1 then
                    sender == message

                    Short.TransferMoney(sender, receiver, password, money, id)
                    break

                    end
                else
                    break
                end
            else
                Network.send("2", "Wrong Id!", "RangerBank", id)
                printError("Wrong Id!")
            end
        else
            break
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
                    
                    Short.BankOFF(secret_pass, id)
                    break

                else
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

return Network
