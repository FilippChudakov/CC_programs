local files = {
    {   -- /
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/startup.lua",
        path = "startup.lua"
    },
    { 
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/Coder.lua",
        path = "Coder.lua"
    },
    {   -- /APIS/
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/APIS/Network.lua",
        path = "APIS/Network.lua"
    },
    {   
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/APIS/ShortCuts.lua",
        path = "APIS/ShortCuts.lua"
    },
    {   
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/APIS/UI.lua",
        path = "APIS/UI.lua"
    },
    {   -- /RangerBankData/
        url = "https://raw.githubusercontent.com/FilippChudakov/CC_programs/refs/heads/main/RangerBank/RangerBankTerminals/Bankomat/RangerBankData/SecretPass.txt",
        path = "RangerBankData/SecretPass.txt"
    }
}


local overwriteMode = nil

print("Starting download...")

for i, file in ipairs(files) do
    local exists = fs.exists(file.path)
    local shouldDownload = true

    if exists then
        if overwriteMode == "all" then
            shouldDownload = true
        elseif overwriteMode == "none" then
            shouldDownload = false
        else
            print("\nFile alredy exists: " .. file.path)
            write("Replace? [y]es, [n]o, [r]eplase all, [s]kip all: ")
            local input = string.lower(read())
            if input == "r" then
                overwriteMode = "all"
                shouldDownload = true
            elseif input == "s" then
                overwriteMode = "none"
                shouldDownload = false
            elseif input == "y" then
                shouldDownload = true
            else
                shouldDownload = false
            end
            print()
        end
    end

    if not shouldDownload then
        print("SKIPPED (" .. file.path .. ")")
    else
        write("DOWNLOADING (" .. file.path .. ")... ")
        
        local response, err = http.get(file.url)
        
        if response then
            local content = response.readAll()
            response.close()
            
            -- FIX: Remove trailing whitespaces and newlines
            -- This ensures that files with single digits don't have an extra empty line
            if content then
                content = content:gsub("%s+$", "")
            end
            
            local dir = fs.getDir(file.path)
            if dir ~= ".." and not fs.exists(dir) then
                fs.makeDir(dir)
            end
            
            local f = fs.open(file.path, "w")
            if f then
                f.write(content)
                f.close()
                print("\nDone!")
            else
                print("\nFILE ERROR: Can not access to your files.\n")
            end
        else
            print("\nHTTP ERROR: " .. tostring(err) .. "\n")
        end
    end
end

print("\nDownload complete! \n\nDon't forget encrypt SecretPass!")