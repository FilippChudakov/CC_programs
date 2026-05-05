local Short = dofile("APIS/ShortCuts.lua")
local crypto = dofile("APIS/Crypto.lua")

local pub, priv = crypto.generateKeyPair()
local sessions = {}

local Network = {}

function Network.version()
    return {"RangerBankServer 3.0", "Fixed some bugs and add encryption"}
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
    elseif version == "3.0" then
        return "Fixed some bugs and add encryption"
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

function Network.send(SendId, Message, Protocol, id, needEncrypt)
    if SendId == "1" then
        if not needEncrypt then
            Message = crypto.encrypt(Short.serialize(Message), sessions[id])
        end
        rednet.send(id, {"RangerBank: 1", Message}, Protocol)

        print("Message send!")
    elseif SendId == "2" then
        if not needEncrypt then
            Message = crypto.encrypt(Short.serialize(Message), sessions[id])
        end
        rednet.send(id, {"RangerBank: 2", Message}, Protocol)

        print("Message send!")
    elseif SendId == "3" then
        local money = Short.GetMoney(Message)
        if money ~= nil then
            money = crypto.encrypt(money, sessions[id])
            rednet.send(id, {"RangerBank: 3", money}, Protocol)
        else
            data = crypto.encrypt(Short.serialize({"Account doesn't exists!"}), sessions[id])
            rednet.send(id, data, Protocol)
        end
        
        print("Message send!")
    end
end


function Network.send_error(result, id, needEncrypt)
    if result == true then
        return false
    elseif result == "unsecured_connection" then
        Network.send("2", "This server does not support unsecured connections!", "RangerBank", id, needEncrypt)
    elseif result == "account_already_exists" then
        Network.send("2", "Account already exists!", "RangerBank", id, needEncrypt)
    elseif result == "too_many_characters" then
        Network.send("2", "Too many characters!", "RangerBank", id, needEncrypt)
    elseif result == "illegal_characters" then
        Network.send("2", "Illegal characters!", "RangerBank", id, needEncrypt)
    elseif result == "password_incorrect" then
        Network.send("2", "Password incorrect!", "RangerBank", id, needEncrypt)
    elseif result == "account_doesnt_exists" then
        Network.send("2", "Account doesn't exists!", "RangerBank", id, needEncrypt)
    elseif result == "secretpass_incorrect" then
        Network.send("2", "SecretPass incorrect!", "RangerBank", id, needEncrypt)
    elseif result == "not_enough_money" then
        Network.send("2", "Not enough money!", "RangerBank", id, needEncrypt)
    elseif result == "second_account_doesnt_exists" then
        Network.send("2", "Receiver doesn't exists!", "RangerBank", id, needEncrypt)
    elseif result == "first_account_doesnt_exists" then
        Network.send("2", "Sender doesn't exists!", "RangerBank", id, needEncrypt)
    elseif result == "nil_password" then
        Network.send("2", "Password is nil!", "RangerBank", id, needEncrypt)
    else
        Network.send("2", "Error!", "RangerBank", id, needEncrypt)
    end
end

local printing = true

function Network.MessageHandler()
    if printing then
        print("\nWaiting for a message...\n")
    end

    printing = true
    
    local session_id, message = rednet.receive("RangerBank")
    
    if message == "key_request" then
        rednet.send(session_id, pub, "RangerBank")
        printing = false
        return
    elseif message[1] == "key" then
        sessions[session_id] = crypto.getSharedSecret(message[2], priv)
        printing = false
        return
    elseif message == "ping" then
        print("id: "..session_id.." ping")
        rednet.send(session_id, "pong")
        return
    elseif type(message) ~= "string" then
        print("This server does not support unsecured connections.")
        Network.send_error("unsecured_connection", session_id, true)
        return
    else
        message = Short.deserialize(crypto.decrypt(message, sessions[session_id]))
    end

    if session_id ~= nil and message ~= nil then

        if message[1] == "ping" then
            print("id: "..session_id.." ping")
            rednet.send(session_id, "pong")

        elseif message[1] == "RangerBank:get_money" then
            print("getting money...")

            message["account"] = message["account"]:lower()

            local result = Short.GetMoney_Net(message["account"], message["password"], session_id)

            if result == true then
                Network.send("3", message["account"], "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:login" then
            print("login...")

            message["account"] = message["account"]:lower()

            local BankAccPath = "BankAccounts/"..message["account"]
            local BankPassPath = "BankAccounts/"..message["account"].."/password.txt"

            if Short.BanSymbols(message["account"]) then
                Network.send("2", "Illegal characters!", "RangerBank", session_id)
                printError("Illegal characters!")
            end

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

            message["account"] = message["account"]:lower()

            local result = Short.AddAccount(message["account"], message["password"], session_id)
            if result == true then
                Network.send("1", "Account created!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:delete_account" then
            print("deleting account...")

            local result = Short.DeleteAccount(message["account"]:lower(), message["password"], session_id)
            if result == true then
                Network.send("1", "Account Deleted!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:change_password" then
            print("change password...")

            message["account"] = message["account"]:lower()

            local LogsPATH = "BankAccounts/"..message["account"].."/logs.txt"

            local result = Short.ChangePassword(message["account"], message["password"], message["new_pass"], session_id)
            if result == true then
                Short.AddInLog(LogsPATH, Short.GenerateLog("Change pass", {session_id}))
                Network.send("1", "Password changed!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:add_money" then
            print("adding money...")
            
            message["account"] = message["account"]:lower()

            local LogsPATH = "BankAccounts/"..message["account"].."/logs.txt"

            local result = Short.AddMoney(message["account"], message["summ"], message["secret_pass"], session_id)
            if result == true then
                Short.AddInLog(LogsPATH, Short.GenerateLog("Add money", {message["summ"]}))
                Network.send("1", "Complete!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:minus_money" then
            print("minusing money...")

            message["account"] = message["account"]:lower()

            local LogsPATH = "BankAccounts/"..message["account"].."/logs.txt"

            local result = Short.MinusMoney(message["account"], message["summ"], message["secret_pass"], session_id)
            if result == true then
                Short.AddInLog(LogsPATH, Short.GenerateLog("Minus money", {message["summ"]}))
                Network.send("1", "Complete!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:transfer_money" then
            print("transfering money...")
            message["account"] = message["account"]:lower()
            message["receiver"] = message["receiver"]:lower()

            local LogsSPATH = "BankAccounts/"..message["account"].."/logs.txt"
            local LogsRPATH = "BankAccounts/"..message["receiver"].."/logs.txt"

            local result = Short.TransferMoney(message["account"], message["receiver"], message["password"], tonumber(message["summ"]), session_id)
            if result == true then
                Short.AddInLog(LogsSPATH, Short.GenerateLog("Transfer", {message["receiver"], message["summ"], session_id}))
                Short.AddInLog(LogsRPATH, Short.GenerateLog("Receive", {message["account"], message["summ"], session_id}))
                Network.send("1", "Transfering is completed!", "RangerBank", session_id)
            else
                Network.send_error(result, session_id)
            end

        elseif message[1] == "RangerBank:first_login_log" then
            print("Log login...")

            local AccountPATH = "BankAccounts/"..message["account"]
            local PassPATH = "BankAccounts/"..message["account"].."/password.txt"
            local logPATH = "BankAccounts/"..message["account"].."/logs.txt"

            if Short.BanSymbols(message["account"]) then
                Network.send("2", "Illegal characters!", "RangerBank", session_id)
                printError("Illegal characters!")
            end

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

            if Short.BanSymbols(message["account"]) then
                Network.send("2", "Illegal characters!", "RangerBank", session_id)
                printError("Illegal characters!")
            end

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

            if Short.BanSymbols(message["account"]) then
                Network.send("2", "Illegal characters!", "RangerBank", session_id)
                printError("Illegal characters!")
            end

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
        else
            printing = false
        end
    else
        printing = false
    end
end

return Network
