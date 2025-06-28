local Short = dofile("APIS/ShortCuts.lua")

local Network = {}

function Network.version()
    return {"RangerBankServer 2.6", "Fixed some bugs"}
end

function Network.changelog(version)
    if version == "2.0" then
        return "Reworked graphics and add protocol"
    elseif version == "2.1" then
        return "Fixed some bugs"
    elseif version == "2.5" then
        return "Reworked rednet use"
    elseif version == "2.6" then
        return "Fixed some bugs"
    else
        return "not a version"
    end
end

function Network.open()
    peripheral.find("modem", rednet.open)
end

function Network.close()
    peripheral.find("modem", rednet.close)
end

function Network.send(SendId, Message, Protocol, id)
    if SendId == "1" then
        rednet.send(id, {"RangerBank: 1", Message}, Protocol)

        print("Message send!")
    elseif SendId == "2" then
        rednet.send(id, {"RangerBank: 2", Message}, Protocol)

        print("Message send!")
    elseif SendId == "3" then
        local money = Short.GetMoney(Message)
        if money ~= nil then
            rednet.send(id, {"RangerBank: 3", money}, Protocol)
        else
            rednet.send(id, {"RangerBank: 2", "Account doesn't exists!"}, Protocol)
        end
        
        print("Message send!")
    end
end

function Network.MessageHandler()
    print("\nWaiting for a message...\n")
    local session_id, message = rednet.receive("RangerBank")

    if session_id ~= nil and message ~= nil then

        if message[1] == "ping" then
            print("id: "..session_id.." ping")
            rednet.send(session_id, "pong")

        elseif message[1] == "RangerBank:get_money" then
            print("getting money...")
            local BankAccPath = "BankAccounts/"..message["account"]
            local BankPassPath = "BankAccounts/"..message["account"].."/password.txt"

            if fs.exists(BankAccPath) then
                local server_password = Short.Read(BankPassPath)
                if server_password == message["password"] then
                    Network.send("3", message["account"], "RangerBank", session_id)
                else
                    Network.send("2", "Wrong password!", "RangerBank", session_id)
                    printError("Wrong password!")
                end
            else
                Network.send("2", "Account doesn't exist!", "RangerBank", session_id)
                printError("Account doesn't exist!")
            end

        elseif message[1] == "RangerBank:login" then
            print("login...")
            local BankAccPath = "BankAccounts/"..message["account"]
            local BankPassPath = "BankAccounts/"..message["account"].."/password.txt"

            if fs.exists(BankAccPath) then
                local server_password = Short.Read(BankPassPath)
                if server_password == message["password"] then
                    Network.send("1", "Succesfuly logined!", "RangerBank", session_id)
                    print("Succesfuly logined!")
                else
                    Network.send("2", "Wrong password!", "RangerBank", session_id)
                    printError("Wrong password!")
                end
            else
                Network.send("2", "Account doesn't exist!", "RangerBank", session_id)
                printError("Account doesn't exist!")
            end

        elseif message[1] == "RangerBank:register" then
            print("register...")

            local result = Short.AddAccount(message["account"], message["password"], session_id)
            if result == true then
                Network.send("1", "Account created!", "RangerBank", session_id)
            elseif result == "account_already_exists" then
                Network.send("2", "Account already exists!", "RangerBank", session_id)
            elseif result == "too_many_characters" then
                Network.send("2", "Too many characters!", "RangerBank", session_id)
            elseif result == "illegal_characters" then
                Network.send("2", "Illegal characters!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:delete_account" then
            print("deleting account...")

            local result = Short.DeleteAccount(message["account"], message["password"], session_id)
            if result == true then
                Network.send("1", "Account Deleted!", "RangerBank", session_id)
            elseif result == "password_incorrect" then
                Network.send("2", "Password incorrect!", "RangerBank", session_id)
            elseif result == "account_doesnt_exists" then
                Network.send("2", "Account doesn't exists!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:change_password" then
            print("change password...")

            local LogsPATH = "BankAccounts/"..message["account"].."/logs.txt"

            local result = Short.ChangePassword(message["account"], message["password"], message["new_pass"], session_id)
            if result == true then
                Network.send("1", "Password changed!", "RangerBank", session_id)
                Short.AddInLog(LogsPATH, Short.GenerateLog("Change pass", {session_id}))
            elseif result == "password_incorrect" then
                Network.send("2", "Password incorrect!", "RangerBank", session_id)
            elseif result == "account_doesnt_exists" then
                Network.send("2", "Account doesn't exists!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:add_money" then
            print("adding money...")

            local result = Short.AddMoney(message["account"], message["summ"], message["secret_pass"], session_id)
            if result == true then
                Network.send("1", "Complete!", "RangerBank", session_id)
            elseif result == "secretpass_incorrect" then
                Network.send("2", "SecretPass incorrect!", "RangerBank", session_id)
            elseif result == "account_doesnt_exists" then
                Network.send("2", "Account doesn't exists!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:minus_money" then
            print("minusing money...")

            local result = Short.MinusMoney(message["account"], message["summ"], message["secret_pass"], session_id)
            if result == true then
                Network.send("1", "Complete!", "RangerBank", session_id)
            elseif result == "not_enough_money" then
                Network.send("2", "Not enough money!", "RangerBank", session_id)
            elseif result == "secretpass_incorrect" then
                Network.send("2", "SecretPass incorrect!", "RangerBank", session_id)
            elseif result == "account_doesnt_exists" then
                Network.send("2", "Account doesn't exists!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:transfer_money" then
            print("transfering money...")

            local LogsSPATH = "BankAccounts/"..message["account"].."/logs.txt"
            local LogsRPATH = "BankAccounts/"..message["receiver"].."/logs.txt"

            local result = Short.TransferMoney(message["account"], message["receiver"], message["password"], tonumber(message["summ"]), session_id)
            if result == true then
                Short.AddInLog(LogsSPATH, Short.GenerateLog("Transfer", {message["receiver"], message["summ"], session_id}))
                Short.AddInLog(LogsRPATH, Short.GenerateLog("Receive", {message["account"], message["summ"], session_id}))
                Network.send("1", "Transfering is completed!", "RangerBank", session_id)
            elseif result == "not_enough_money" then
                Network.send("2", "Not enough money!", "RangerBank", session_id)
            elseif result == "password_incorrect" then
                Network.send("2", "Password incorrect!", "RangerBank", session_id)
            elseif result == "second_account_doesnt_exists" then
                Network.send("2", "Receiver doesn't exists!", "RangerBank", session_id)
            elseif result == "first_account_doesnt_exists" then
                Network.send("2", "Sender doesn't exists!", "RangerBank", session_id)
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:first_login_log" then
            print("Log login...")

            local AccountPATH = "BankAccounts/"..message["account"]
            local PassPATH = "BankAccounts/"..message["account"].."/password.txt"
            local logPATH = "BankAccounts/"..message["account"].."/logs.txt"

            if fs.exists(AccountPATH) then
                if Short.Read(PassPATH) == message["password"] then
                    Short.AddInLog(logPATH, Short.GenerateLog("Login", {session_id}))
                else
                    Network.send("2", "Wrong password!", "RangerBank", session_id)
                end
            else
                Network.send("2", "Account doesnt exists!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:get_log" then
            print("Get log...")

            local AccountPATH = "BankAccounts/"..message["account"]
            local PassPATH = "BankAccounts/"..message["account"].."/password.txt"
            local logPATH = "BankAccounts/"..message["account"].."/logs.txt"

            if fs.exists(AccountPATH) then
                local pass = Short.Read(PassPATH)
                if pass == message["password"] then
                    local log = Short.Read(logPATH)
                    Network.send("1", log, "RangerBank", session_id)
                else
                    Network.send("2", "Wrong password!", "RangerBank", session_id)
                end
            else
                Network.send("2", "Account doesnt exists!", "RangerBank", session_id)
            end
        
        elseif message[1] == "RangerBank:delete_login_logs" then
            print("deleting logs...")

            local AccountPATH = "BankAccounts/"..message["account"]
            local PassPATH = "BankAccounts/"..message["account"].."/password.txt"
            local logPATH = "BankAccounts/"..message["account"].."/logs.txt"

            if fs.exists(AccountPATH) then
                if Short.Read(PassPATH) == message["password"] then
                    local status = Short.DeleteFullLog(logPATH, "Login")
                    if status then
                        Short.AddInLog(logPATH, Short.GenerateLog("DLL", {session_id}))
                    end
                    local log = Short.Read(logPATH)
                    Network.send("1", log, "RangerBank", session_id)
                else
                    Network.send("2", "Wrong password!", "RangerBank", session_id)
                end
            else
                Network.send("2", "Account doesnt exists!", "RangerBank", session_id)
            end

        elseif message[1] == "RangerBank:OFF" then
            print("OFF?...")

            local result = Short.BankOFF(message["secret_pass"], session_id)
            if result == true then
                local OffPATH = "BankData/Off.txt"
                Network.send("1", "OFF", "RangerBank", session_id)
                Network.close()
                Short.Write("1", OffPATH)
                print("Off...")
                os.sleep(1)
                os.reboot()
            else
                Network.send("2", "Error!", "RangerBank", session_id)
            end
        end
    end
end

return Network
