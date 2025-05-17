local Short = require("APIS/ShortCuts")

off = Short.Read("BankData/Off.txt")

if Off == "0" then
    os.run({}, "BankServer.lua")
elseif Off == "1" then
    Short.Write("0", "BankData/Off.txt")
    print("Quit")
end
