--  ------------------------------------------------------------
ModInfo = Ext.GetModInfo("b66d56c6-12f9-4abc-844f-0c30b89d32e4")
IDENTIFIER = "S7_UI_Components_Library"
--  ------------------------------------------------------------

--  ===========
--  DIRECTORIES
--  ===========

Dir = {
    ["GameGUI"] = "Public/Game/GUI/",   --  GameUI Directory
    ["GameMasterGUI"] = "Public/Game/GUI/GM/",  --  GameMasterUI Directory
    ["ModGUI"] = "Public/S7_UI_Components_Library_b66d56c6-12f9-4abc-844f-0c30b89d32e4/GUI/"    -- UCLibrary Directory
}

--  =============
--  REMATERIALIZE
--  =============

--- Completely clone an element
---@param element any Element to copy
---@param config table
---@param clones table
---@return any clone Rematerialized element
function Rematerialize(element, config, clones)
    config = config or {}
    clones = clones or {}
    local clone = {}

    if type(element) == "table" then
        if clones[element] then clone = clones[element]
        else
            clone = {}
            clones[element] = clone
            for key, value in next, element do clone[Rematerialize(key, clones)] = Rematerialize(value, clones) end
            if config.metatables then setmetatable(clone, Rematerialize(getmetatable(element), clones)) end   --  Copy metatables
        end
    elseif type(element) == "function" or type(element) == "userdata" or type(element) == "thread" then if config.nonstringifiable then clone = element end
    else clone = element end    --  if element is anything other than a table, return as is

    return clone
end

--  =========
--  INTEGRATE
--  =========

--- Merge source and target. Existing source elements have priority.
---@param source table
---@param target table
---@return table source
function Integrate(source, target)
    local source = source or {}
    for key, value in pairs(target) do
        if type(value) == "table" then
            if not source[key] then source[key] = {} end
            source[key] = Integrate(source[key], value)
        end
        source[key] = source[key] or value
    end
    return source
end

--  ===========
--  DEBUG PRINT
--  ===========

function S7DebugPrint(...)
    local args = {...}
    local logMsg = args[1] or ""    -- The message to display
    local logSource = args[2] or "" -- The Source/Origin of the message
    local logType = args[3] or "Log"    -- The type of message (Log, Warning, Error)
    local ignoreDevMode = args[4] or false  -- Print message regardless of DeveloperMode
    local highlight = args[5] or false  -- Highlights the display message
    local highlightChar = args[6] or "="    -- Highlighting character

    if Ext.IsDeveloperMode() or ignoreDevMode then
        local context = ""
        if Ext.IsClient() then context = "C"
        elseif Ext.IsServer() then context = "S" end

        local logFunctions = {["Log"] = Ext.Print, ["Warning"] = Ext.PrintWarning, ["Error"] = Ext.PrintError}
        local printFunction = logFunctions[logType]

        local displayString = "[" .. IDENTIFIER .. ":Lua(" .. context .. "):" .. logSource .. "] --- " .. logMsg

        if highlight then printFunction(string.rep(highlightChar, string.len(displayString))) end
        printFunction(displayString)
        if highlight then printFunction(string.rep(highlightChar, string.len(displayString))) end
    end
end

--  =========================
--  VALIDATE NON-EMPTY STRING
--  =========================

--- Check if string is not nil and is not empty
---@param str any Element to check validity of
function ValidString(str)
    if type(str) == "string" and str ~= nil and str ~= "" and str ~= "{}" and str ~= "[]" then return true
    else return false end
end

--  ===============
--  MOD INFORMATION
--  ===============

local modInfoTable = {
    ["Author"] = ModInfo.Author,
    ["Name"] = ModInfo.Name,
    ["UUID"] = ModInfo.UUID,
    ["Version"] = ModInfo.Version,
    ["PublishedVersion"] = ModInfo.PublishVersion,
    ["ModVersion"] = "0.0.0.0",
}

CENTRAL = {}    --  Holds Global Settings and Information
local file = Ext.LoadFile("S7Central.json") or "{}"
if ValidString(file) then CENTRAL = Ext.JsonParse(file) end
if CENTRAL[IDENTIFIER] == nil then CENTRAL[IDENTIFIER] = Rematerialize(modInfoTable) end

--  =====  MOD VERSIONING  =====
Ext.Require("ModVersioning.lua")
--  ============================

--- Initialize CENTRAL
---@param ref table Reference table
---@param tar table Target table
local function initCENTRAL(ref, tar)
    for field, value in pairs(ref) do
        if ModInfo[field] then tar[field] = Rematerialize(ModInfo[field])
        else if not tar[field] then tar[field] = Rematerialize(value) end end
        if type(value) == 'table' then initCENTRAL(value, tar[field]) end
    end
end

initCENTRAL(modInfoTable, CENTRAL[IDENTIFIER])
CENTRAL[IDENTIFIER]["ModVersion"] = ParseVersion(ModInfo.Version, "string")
Ext.SaveFile("S7Central.json", Ext.JsonStringify(CENTRAL))

--  =======================
--  REGISTER DEBUG LISTENER
--  =======================

---@param UI UIObject
function RegisterDebugHooks(UI)
    if Ext.IsDeveloperMode() then
        Ext.RegisterUICall(UI, "S7_DebugHook", function(ui, call, ...)
            local args = {...}
            S7DebugPrint(tostring(args[1]) .. ":" .. tostring(args[2]), "Auxiliary", "Log", nil, true)
            local i = 3
            while i <= #args do
                if args[i+1] ~= nil then
                    S7DebugPrint(tostring(args[i]) .. ":" .. tostring(args[i+1]), "Auxiliary")
                    i = i + 2
                else
                    S7DebugPrint(tostring(args[i]), "Auxiliary")
                    i = i + 1
                end
            end
        end)
    end
end

--  =======================
--  TRAILING ZEROES COUNTER
--  =======================

---@param n number
---@return number count Number of trailing zeroes
function GetTrailingZeroes(n)
    local i, count = 10, 0
    while n % i == 0 do
        count = count + 1
        i = i * 10
    end
    return count
end

--  ============================
--  DECLARATION OF GLOBAL TABLES
--  ============================

SpecsHandler = {}
BuildSpecifications = {}
UILibrary = {
    ["msgBox"] = {},
    ["GMJournal"] = {},
    ["Pyramid"] = {}
}