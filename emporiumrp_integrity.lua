--[[
script Integrity Scanner
Copyright (c) 2025 Meth Monsignor, Emporium Server Owner
Licensed under the MIT License.
Free to use, modify, and distribute with attribution.
]]

-- Only run on server
if not SERVER then return end

-- One time execution guard
if _G.__INTEGRITY_SCAN_RAN then return end
_G.__INTEGRITY_SCAN_RAN = true

print("[EmporiumRP] Integrity Scanner script loaded.")

-- BASIC CONFIG TO ENABLE SCANNER
local ENABLE_INTEGRITY_SCAN = true
if not ENABLE_INTEGRITY_SCAN then return end

-- CONFIGURATION
local addonFolders = {
    "Folder names", "Folder names", "Folder names"
}

local config = {
    enableSoundScan = true,
    enableLuaSyntaxCheck = true,
    enableStructureAudit = true,
    enableGlobalAudit = true
}

local scanSummary = { ok = 0, warning = 0, error = 0 }

-- LOGGING
local function logToFile(text)
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
    file.Append("emporiumrp_integrity_log.txt", timestamp .. text .. "\n")
end

if not file.Exists("emporiumrp_integrity_log.txt", "DATA") then
    file.Write("emporiumrp_integrity_log.txt", "[EmporiumRP] Integrity Log Initialized\n")
end

-- UTILITY
local function endsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

local function safeRead(path)
    local ok, content = pcall(function()
        return file.Read(path, "GAME")
    end)
    return ok and content or nil
end

-- SCANNER FUNCTION
local function runIntegrityScan(addonName)
    local addonPath = "addons/" .. addonName
    print("\n[Addon Integrity Scanner] Running diagnostics for: " .. addonName)
    logToFile("[Addon: " .. addonName .. "] Starting diagnostics")

    local function checkSoundFiles(path)
        if not config.enableSoundScan then return end
        print("[Audit] Scanning sound files...")
        logToFile("[Audit] Scanning sound files...")
        local foldersToScan = { path .. "/sound" }

        while #foldersToScan > 0 do
            local current = table.remove(foldersToScan)
            local files, folders = file.Find(current .. "/*", "GAME")

            if not files then
                print("[Error] Could not access: " .. current)
                logToFile("[Error] Could not access: " .. current)
                scanSummary.error = scanSummary.error + 1
            else
                for _, fileName in ipairs(files) do
                    local ext = fileName:match("^.+(%..+)$")
                    if ext == ".wav" or ext == ".mp3" or ext == ".ogg" then
                        local virtualPath = current .. "/" .. fileName
                        if file.Exists(virtualPath, "GAME") then
                            print("[OK] Indexed sound: " .. virtualPath)
                            logToFile("[OK] Indexed sound: " .. virtualPath)
                            scanSummary.ok = scanSummary.ok + 1
                        else
                            print("[Missing] File not indexed: " .. virtualPath)
                            logToFile("[Missing] File not indexed: " .. virtualPath)
                            scanSummary.warning = scanSummary.warning + 1
                        end
                    end
                end

                for _, folderName in ipairs(folders) do
                    table.insert(foldersToScan, current .. "/" .. folderName)
                end
            end
        end
    end

    local function checkLuaSyntax(path)
        if not config.enableLuaSyntaxCheck then return end
        print("[Audit] Validating Lua syntax...")
        logToFile("[Audit] Validating Lua syntax...")
        local foldersToScan = { path .. "/lua" }

        while #foldersToScan > 0 do
            local current = table.remove(foldersToScan)
            local files, folders = file.Find(current .. "/*", "GAME")

            for _, fileName in ipairs(files) do
                if endsWith(fileName, ".lua") then
                    local fullPath = current .. "/" .. fileName
                    local code = safeRead(fullPath)
                    if code then
                        local ok, err = pcall(function()
                            CompileString(code, fullPath, true)
                        end)
                        if ok then
                            print("[OK] Lua compiles: " .. fullPath)
                            logToFile("[OK] Lua compiles: " .. fullPath)
                            scanSummary.ok = scanSummary.ok + 1
                        else
                            print("[Error] Syntax issue in " .. fullPath .. " -> " .. err)
                            logToFile("[Error] Syntax issue in " .. fullPath .. " -> " .. err)
                            scanSummary.error = scanSummary.error + 1
                        end
                    else
                        print("[Error] Could not read Lua file: " .. fullPath)
                        logToFile("[Error] Could not read Lua file: " .. fullPath)
                        scanSummary.error = scanSummary.error + 1
                    end
                end
            end

            for _, folderName in ipairs(folders) do
                table.insert(foldersToScan, current .. "/" .. folderName)
            end
        end
    end

    local function checkFolderStructure(path)
        if not config.enableStructureAudit then return end
        print("[Audit] Validating addon folder layout...")
        logToFile("[Audit] Validating addon folder layout...")
        local jsonPath = path .. "/addon.json"
        local nestedGModPath = path .. "/garrysmod"

        if file.Exists(jsonPath, "GAME") then
            print("[OK] addon.json present.")
            logToFile("[OK] addon.json present.")
            scanSummary.ok = scanSummary.ok + 1
        else
            print("[Warning] addon.json missing in " .. path)
            logToFile("[Warning] addon.json missing in " .. path)
            scanSummary.warning = scanSummary.warning + 1
        end

        if file.Exists(nestedGModPath, "GAME") then
            print("[Error] Nested garrysmod folder detected: " .. nestedGModPath)
            logToFile("[Error] Nested garrysmod folder detected: " .. nestedGModPath)
            scanSummary.error = scanSummary.error + 1
        else
            print("[OK] No nested garrysmod folder.")
            logToFile("[OK] No nested garrysmod folder.")
            scanSummary.ok = scanSummary.ok + 1
        end
    end

    local function checkRogueGlobals()
        if not config.enableGlobalAudit then return end
        print("[Audit] Scanning for rogue global scripts...")
        logToFile("[Audit] Scanning for rogue global scripts...")
        local roguePaths = {
            "lua/entities/",
            "lua/weapons/",
            "lua/autorun/",
            "lua/effects/"
        }

        for _, path in ipairs(roguePaths) do
            local files, _ = file.Find(path .. "*.lua", "GAME")
            for _, fileName in ipairs(files) do
                local fullPath = path .. fileName
                if not string.find(fullPath, addonName, 1, true) then
                    print("[Warning] Global script outside addon scope: " .. fullPath)
                    logToFile("[Warning] Global script outside addon scope: " .. fullPath)
                    scanSummary.warning = scanSummary.warning + 1
                else
                    scanSummary.ok = scanSummary.ok + 1
                end
            end
        end
    end

    checkSoundFiles(addonPath)
    checkLuaSyntax(addonPath)
    checkFolderStructure(addonPath)
    checkRogueGlobals()

    print("[Scan Complete] All checks concluded for: " .. addonName)
    logToFile("[Scan Complete] All checks concluded for: " .. addonName)
end

-- MANUAL TRIGGER CONSOLE
concommand.Add("run_integrity_scan", function()
    print("[EmporiumRP] Manual scan triggered via console.")
    logToFile("[EmporiumRP] Manual scan triggered via console.")
    for _, addonName in ipairs(addonFolders) do
        runIntegrityScan(addonName)
    end
    end)

    print("\n[EmporiumRP Audit Summary]")
    print("OK: " .. scanSummary.ok)
    print("Warnings: " .. scanSummary.warning)
    print("Errors: " .. scanSummary.error)
    print("[Audit Finished] All addons scanned.\n")

    logToFile("OK: " .. scanSummary.ok)
    logToFile("Warnings: " .. scanSummary.warning)
    logToFile("Errors: " .. scanSummary.error)

    logToFile("[Audit Finished] All addons scanned.\n")

