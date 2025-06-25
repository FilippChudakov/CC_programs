local Short = dofile("APIS/ShortCuts.lua")

off = Short.Read("BankData/Off.txt")

if off == "0" then
    os.run({}, "BanID.lua")
    os.run({}, "BankServer.lua")
elseif off == "1" then
    Short.Write("0", "BankData/Off.txt")
    print("Quit")
end
