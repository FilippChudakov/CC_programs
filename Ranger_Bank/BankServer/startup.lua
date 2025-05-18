local OffTXT = fs.open("BankData/Off.txt", "r")
local OffSTR = OffTXT.readAll()
OffTXT.close()

if OffSTR == "0" then
    os.run({}, "BankServer.lua")
elseif OffSTR == "1" then
    local OffTXT = fs.open("BankData/Off.txt", "w")
    OffTXT.write("0")
    OffTXT.close()
    print("Quit")
end
