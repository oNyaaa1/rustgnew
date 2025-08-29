DeriveGamemode("base")
GM.Name = "gRust | Rust in Garry's Mod"
GM.Author = ""
GM.Email = ""
GM.Website = ""
gRust = gRust or {}
LANG = LANG or {}
local IncludeCL = CLIENT and include or AddCSLuaFile
local IncludeSV = SERVER and include or function() end
local IncludeSH = CLIENT and include or function(f)
    AddCSLuaFile(f)
    return include(f)
end

IncludeSH("config.lua")
gRust.IncludeSV = SERVER and include or function() end
gRust.IncludeCL = SERVER and AddCSLuaFile or include
gRust.IncludeSH = function(dir)
    if SERVER then
        AddCSLuaFile(dir)
        return include(dir)
    else
        return include(dir)
    end
end

local smart_include = function(f)
    if string.find(f, "sv_") then
        return IncludeSV(f)
    elseif string.find(f, "cl_") then
        return IncludeCL(f)
    elseif string.find(f, "sh_") then
        return IncludeSH(f)
    end
end

gRust.IncludeDir = function(dir)
    local fol = dir .. '/'
    local files, folders = file.Find(fol .. '*', "LUA")
    for _, f in ipairs(files) do
        print("[gRust]" .. fol .. f)
        smart_include(fol .. f)
    end

    for _, f in ipairs(folders) do
        print("[gRust]" .. dir .. '/' .. f)
        gRust.IncludeDir(dir .. '/' .. f)
    end
end

gRust.IncludeDir("rustgnew/gamemode/main")