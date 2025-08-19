# Gmod-server-Integrity-Scanner
A modular GMod tool that scans Lua, sound files, folder structure, and global directories for early detection of errors, rogue assets, and addon integrity issues.



*Important*

Place .lua file in garrysmod/lua/autorun/server
Don't forget to add your folder names in 

local addonFolders = {
    "Folder names", "Folder names", "Folder names"
}


After names are in there, open your console in your game panel and copy and paste run_integrity_scan
It doesn't show up in the in game console.
