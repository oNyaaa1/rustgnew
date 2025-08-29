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

local meta = FindMetaTable("Player")
function meta:GetHunger()
    return self:GetNWInt("Hunger", 0)
end

function meta:GetThirst()
    return self:GetNWInt("Thirst", 0)
end

local meta = FindMetaTable("Player")
function meta:SetHunger(amy)
    self:SetNWInt("Hunger", amy)
end

function meta:SetThirst(amy)
    self:SetNWInt("Thirst", amy)
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

function Logger(msg)
    MsgC(Color(63, 163, 191), "[", Color(31, 119, 163), "GRust", Color(63, 163, 191), "] ", Color(200, 200, 200), msg .. "\n")
end

gRust.IncludeDir = function(dir)
    local fol = dir .. '/'
    local files, folders = file.Find(fol .. '*', "LUA")
    for _, f in ipairs(files) do
        Logger("[gRust]" .. fol .. f)
        smart_include(fol .. f)
    end

    for _, f in ipairs(folders) do
        Logger("[gRust]" .. dir .. '/' .. f)
        gRust.IncludeDir(dir .. '/' .. f)
    end
end

gRust.IncludeDir("rustgnew/gamemode/main")