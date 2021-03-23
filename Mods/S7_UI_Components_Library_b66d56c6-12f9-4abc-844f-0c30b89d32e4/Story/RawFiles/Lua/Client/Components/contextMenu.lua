--  ============
--  CONTEXT MENU
--  ============

---@class ContextEntry @ContextEntries for ContextMenu
---@field ID number|ResolverFunction AFAIK only affects positon in FlashArray. (Optional) Auto-generated based on length of array
---@field actionID number|ResolverFunction This number is thrown on button-press and subsequently broadcasted on S7UCL::ContextMenu net-channel
---@field clickSound boolean|ResolverFunction Probably controls whether mouseClick produces a sound
---@field isDisabled boolean|ResolverFunction If true, the button is greyed out and cannot be pressed
---@field isUnavailable boolean|ResolverFunction If true, the button will not show up at all. Useful for exceptions
---@field isLegal boolean|ResolverFunction If false, button is red and indicates an act of crime
---@field text string|ResolverFunction ContextMenu label text
---@field restrictUI nil|table|ResolverFunction If not nil, then ctxEntries will not show up for UITypes in this array. (-1 for game-world)
ContextEntry = {
    ID = function(r) return r.Root.windowsMenu_mc.list.length end,
    clickSound = true,
    isDisabled = false,
    isUnavailable = false,
    isLegal = true,
    text = "null",
    --actionID = 0,
    --restrictUI = {},
}

---Create new ContextEntry
---@param object ContextEntry
---@return ContextEntry
function ContextEntry:New(object)
    local object = object or {}
    if not ValidInputTable(object, {'actionID'}) then Debug:FError('Invalid ActionID') end
    object = Integrate(self, object)
    object.New = nil -- Remove constructor from the object.
    return object
end

---@alias activator string `ActivatorType::ActivatorValue`. e.g. StatsId::LOOT_Paper_Sheet_A

---@class ContextMenu @ContextMenu UI Component
---@field TypeID number UI TypeID. 11 or 10. Most listeners work for 11
---@field Activator activator ActivatorType::ActivatorValue. Ties activation and ContextEntries together
---@field Target EclItem|EclCharacter Item that was right-clicked (can also be a game-world character)
---@field Character EclCharacter Character that right-clicked (i.e. the player character)
---@field Origin number Origin of the CtxMenu. UI TypeID.
---@field MouseTarget string DisplayName of the mouse-target
---@field TargetType string Character or Item
---@field Intercept boolean Should intercept ContextMenu
---@field Component table Holds information about WindowElement
---@field ContextEntries table<activator, ContextEntry[]> Array of constituting ContextEntries
---@field UI UIObject UIObject
---@field Root table UIObject root
UILibrary.contextMenu = {
    TypeID = 11, -- or 10
    Activator = "",
    Intercept = false,
    Component = {},
    ContextEntries = {},
    Origin = -1,
    MouseTarget = "",
    TargetType = "Item",
    UI = {},
    Root = {},
    Character = {},
    Target = {},
}

--- Initialize new ContextMenu object
---@param object nil|ContextMenu Object to instantiate
---@return ContextMenu object ContextMenu object
function UILibrary.contextMenu:New(object)
    local object = object or {}
    object = Integrate(self, object)
    return object
end

---Get UI details
---@param ui UIObject UIObject from one of the listeners
function UILibrary.contextMenu:GetUI(ui)
    self.UI = ui or Ext.GetUIByType(self.TypeID) or Ext.GetBuiltinUI(Dir.GameGUI .. 'contextMenu.swf')
    self.Root = self.UI:GetRoot()
end

--- Get Existing ContextEntries for given activator
---@param activator activator
---@return table<activator, ContextEntry[]>|nil ContextEntries
function UILibrary.contextMenu:Get(activator)
    if self.ContextEntries[activator] then
        return self.ContextEntries[activator]
    end
end

---Adds CtxEntries to CtxMenu
---@param ctxMenu ContextEntry[]
---@param ctxEntries ContextEntry[]
function UILibrary.contextMenu:Add(ctxMenu, ctxEntries)
    if type(ctxEntries) ~= 'table' then return end
    ForEach(ctxEntries, function (_, entry)
        if type(entry) ~= 'table' then return end
        if IsValid(Pinpoint(entry.actionID, ctxMenu)) then return end
        table.insert(ctxMenu, ContextEntry:New(entry))
    end)
end

---Register new activator entry for the ContextMenu
---@param e table<activator, ContextEntry[]> ContextEntries
function UILibrary.contextMenu:Update(e)
    ForEach(e, function (activator, ctxEntries)
        if type(ctxEntries) ~= 'table' then return end
        if not self.ContextEntries[activator] then self.ContextEntries[activator] = {} end
        self:Add(self.ContextEntries[activator], ctxEntries)
    end)
end

---Quick register options. Skips straight to registration
---@param e table<activator, ContextEntry[]> ContextEntries
function UILibrary.contextMenu:Register(e)
    ForEach(e, function (activator, ctxEntries)
        if type(ctxEntries) ~= 'table' then return end
        local ctxMenu = self:Get(activator) or {}
        self:Add(ctxMenu, ctxEntries)
        self:Update({[activator] = ctxMenu})
    end)
end

--  =====================================
ContextMenu = UILibrary.contextMenu:New()
--  =====================================

--  ======================
--  INTERCEPT CONTEXT MENU
--  ======================

--  DETERMINE ACTIVATOR
--  ===================

--  TODO: Refactor this ugly mess into something more maintainable.
---Determine activator
---@param statsActivator activator
---@param templateActivator activator
local function determineActivator(targetType, statsActivator, templateActivator)
    local targetType = targetType or "Item"
    local anyActivator = 'Any::' .. targetType
    ContextMenu.Activator = anyActivator

    -- Check if statsActivator ContextEntries have been registered already
    if ContextMenu.ContextEntries[statsActivator] then
        -- If anyActivators have also been registered then inherit ContextEntries. statsActivator has higher specificity than anyActivator
        if ContextMenu.ContextEntries[anyActivator] then
            ContextMenu:Add(ContextMenu.ContextEntries[statsActivator], ContextMenu.ContextEntries[anyActivator])
        end
        ContextMenu.Activator = statsActivator  --  Set Activator
    end

    -- Check if templateActivator ContextEntries have been registered already
    if ContextMenu.ContextEntries[templateActivator] then
        -- If anyActivators have also been registered then inherit ContextEntries. statsActivator has higher specificity than anyActivator
        if ContextMenu.ContextEntries[anyActivator] then
            ContextMenu:Add(ContextMenu.ContextEntries[templateActivator], ContextMenu.ContextEntries[anyActivator])
        end
        -- If statsActivator was also registered then inherit ContextEntries. RootTemplate has higher specificity than statsActivator
        if ContextMenu.ContextEntries[statsActivator] then
            ContextMenu:Add(ContextMenu.ContextEntries[templateActivator], ContextMenu.ContextEntries[statsActivator])
        end
        ContextMenu.Activator = templateActivator   --  Set Activator
    end
end

--  PREPARE INTERCEPT
--  =================

---Pre-Intercept Setup
---@param ui UIObject
---@param call string External Interface Call
---@param itemDouble number
---@param x number
---@param y number
---@param origin UIObject Origin UI
local function preInterceptSetup(ui, call, itemDouble, x, y, origin)
    ContextMenu.Origin = origin:GetTypeId() or ContextMenu.Origin   -- TypeID of the Origin UI element

    ContextMenu.Target = Ext.GetItem(Ext.DoubleToHandle(itemDouble))  --  Set Item
    if not ContextMenu.Target then return end
    ContextMenu.TargetType = 'Item'

    local statsActivator = 'StatsId::' .. ContextMenu.Target.StatsId  ---@type activator
    local templateActivator = 'RootTemplate::' .. ContextMenu.Target.RootTemplate.Id  ---@type activator

    determineActivator(ContextMenu.TargetType, statsActivator, templateActivator)   --  Set Activator

    ContextMenu.Character = Ext.GetCharacter(ui:GetPlayerHandle())  --  Set Character
    ContextMenu.Intercept = IsValid(ContextMenu.Activator)          --  Go for Intercept if Activator IsValid
end

--  REGISTER LISTENERS
--  ==================

---Registers ContextMenu Listeners
local function RegisterContextMenuListeners()
    Debug:Print("Registering ContextMenu Listeners")

    --  Setup Party Inventory UI
    local partyInventoryUI = Ext.GetBuiltinUI(Dir.GameGUI .. 'partyInventory.swf')
    Ext.RegisterUICall(partyInventoryUI, 'openContextMenu', function(ui, call, id, itemDouble, x, y)
        preInterceptSetup(ui, call, itemDouble, x, y, partyInventoryUI)
    end)

    --  Setup Container Inventory UI
    local containerInventoryUI = Ext.GetUIByType(9) or Ext.GetBuiltinUI(Dir.GameGUI .. 'containerInventory.swf')
    Ext.RegisterUICall(containerInventoryUI, 'openContextMenu', function(ui, call, itemDouble, x, y)
        preInterceptSetup(ui, call, itemDouble, x, y, containerInventoryUI)
    end)

    --  Setup Character Sheet UI
    local characterSheetUI = Ext.GetBuiltinUI(Dir.GameGUI .. 'characterSheet.swf')
    Ext.RegisterUICall(characterSheetUI, 'openContextMenu', function(ui, call, itemDouble, x, y)
        preInterceptSetup(ui, call, itemDouble, x, y, characterSheetUI)
    end)

    --  Setup Crafting UI
    local uiCraftUI = Ext.GetBuiltinUI(Dir.GameGUI .. 'uiCraft.swf')
    Ext.RegisterUICall(uiCraftUI, 'openContextMenu', function(ui, call, itemDouble, x, y)
        preInterceptSetup(ui, call, itemDouble, x, y, uiCraftUI)
    end)

    --  Setup Game World
    --  ----------------

    ---Requests information about MouseTarget from the server
    ---@param text string DisplayName from enemyHealthBar.swf or tooltip.swf
    ---@param type string Character|Item
    local function requestInfoAboutMouseTarget(text, type)
        ContextMenu.MouseTarget, ContextMenu.TargetType, ContextMenu.Origin = text, type, -1
        if not IsValid(text) then return end

        local character = UserInformation.CurrentCharacter or Ext.GetBuiltinUI(Dir.GameGUI .. 'characterSheet.swf'):GetPlayerHandle()
        ContextMenu.Character = Ext.GetCharacter(character)
        if not ContextMenu.Character then return end

        local payload = {
            ['CharacterGUID'] = ContextMenu.Character.MyGuid,
            ['Target'] = ContextMenu.MouseTarget,
            ['TargetType'] = ContextMenu.TargetType,
            ['Position'] = ContextMenu.Character.WorldPos,
            ['SearchRadius'] = 20
        }
        Ext.PostMessageToServer(Channel.GameWorldTarget, Ext.JsonStringify(payload))
    end

    Ext.RegisterUITypeInvokeListener(EnemyHealthBar.TypeID, 'setText', function (ui, call, text, ...)
        requestInfoAboutMouseTarget(text, 'Character')
    end, 'Before')

    Ext.RegisterUITypeInvokeListener(Tooltip.TypeID, 'addTooltip', function(ui, call, text, ...)
        requestInfoAboutMouseTarget(text, 'Item')
    end, 'Before')

    Ext.RegisterNetListener(Channel.GameWorldTarget, function (channel, payload)
        local payload = Ext.JsonParse(payload) or {}
        if not IsValid(payload) then return end

        ContextMenu.TargetType = payload.Type
        ContextMenu.Target = ContextMenu.TargetType == 'Character' and Ext.GetCharacter(payload.GUID) or Ext.GetItem(payload.GUID) --  Game-world target (item or character)

        local statsActivator = 'StatsId::' .. payload.StatsId  ---@type activator
        local templateActivator = 'RootTemplate::' .. payload.RootTemplate ---@type activator

        determineActivator(ContextMenu.TargetType, statsActivator, templateActivator)   --  Set Activator

        ContextMenu.Intercept = IsValid(ContextMenu.Activator)    -- Go for Intercept if Activator IsValid
    end)

    --  REGISTER CONTEXT MENU HOOKS ON INTERCEPT
    --  ========================================

    Ext.RegisterUITypeInvokeListener(ContextMenu.TypeID, 'open', function(ui, call, ...)
        if not ContextMenu.Intercept then return end    --  If Intercept was denied then return

        local ctxEntries = ContextMenu.ContextEntries[ContextMenu.Activator]    --  Get ContextEntries
        if not ctxEntries then return end

        Debug:Print("Intercepted ContextMenu. Registering Hooks")
        ContextMenu:GetUI(ui)   --  Fetch UI details

        --  These will be passed into Resolver functions below
        local resolverArguments = {
            ['Target'] = ContextMenu.Target,
            ['Character'] = ContextMenu.Character,
            ['Activator'] = ContextMenu.Activator,
            ['MouseTarget'] = ContextMenu.MouseTarget,
            ['TargetType'] = ContextMenu.TargetType,
            ['UI'] = ContextMenu.UI,
            ['Root'] = ContextMenu.Root,
            ['TypeID'] = ContextMenu.TypeID,
            ['SubComponent'] = ctxEntries
        }

        --  Adding ctxEntries
        ForEach(ctxEntries, function (_, entry)
            if type(entry) ~= 'table' then return end

            --  Resolve ctxEntry
            local resolved = Map(entry, function (key, value)
                if key == 'New' then return key, nil end
                return key, Resolve(value, resolverArguments)
            end)

            if resolved.isUnavailable then return end -- if isUnavailable is true then return
            if resolved.restrictUI ~= nil and IsValid(Pinpoint(ContextMenu.Origin, resolved.restrictUI)) then return end -- If UI TypeID is in restrictUI array then return.

            --  Create buttons
            ContextMenu.Root.addButton(resolved.ID, resolved.actionID, resolved.clickSound, "", resolved.text, resolved.isDisabled, resolved.isLegal)
            ContextMenu.Root.addButtonsDone()
        end)

        ContextMenu.Intercept = false   --  Done intercepting
    end, "Before")

    --  BUTTON PRESS
    --  ============

    ContextMenu:GetUI()
    Ext.RegisterUICall(ContextMenu.UI, 'buttonPressed', function(ui, call, id, actionID, handle)
        Debug:Print("ContextMenu Action: " .. tostring(actionID))

        local itemNetID
        local actionID = tonumber(actionID)
        if ContextMenu.Target then itemNetID = ContextMenu.Target.NetID end

        local payload = {
            ['CharacterGUID'] = ContextMenu.Character.MyGuid,
            ['Activator'] = ContextMenu.Activator,
            ['actionID'] = actionID,
            ['MouseTarget'] = ContextMenu.MouseTarget,
            ['TargetType'] = ContextMenu.TargetType,
            ['ItemNetID'] = itemNetID
        }
        Ext.PostMessageToServer(Channel.ContextMenu, Ext.JsonStringify(payload))   --  Post ContextAction Payload to Server. Bounces back to Client
    end)

    --  MENU CLOSE
    --  ==========

    Ext.RegisterUITypeCall(ContextMenu.TypeID, 'menuClosed', function()
        ContextMenu.Activator = nil
        ContextMenu.MouseTarget = nil
        ContextMenu.Target = nil
    end)

    Debug:Print("ContextMenu Listener Registration Completed")
end

--  ===============================================================
Ext.RegisterListener('SessionLoaded', RegisterContextMenuListeners)
--  ===============================================================

--  ===============
--  GAME ACTION IDs
--  ===============

--[[
    ["Use"] = 2,
    ["Equip"] = 2,
    ["Launch"] = 2,
    ["Cast Skill"] = 2,
    ["Consume"] = 2,
    ["Open"] = 3,
    ["Unequip"] = 17,
    ["Examine"] = 22,
    ["Drop Item"] = 20,
    ["Combine With"] = 28,
    ["Add To Wares"] = 50,
    ["Remove From Wares"] = 51,
    ["Pickup And Add To Wares"] = 60,
    ["Add To Hotbar"] = 63,
]]

--  =====================
--  SNAPSHOT CONTEXT MENU
--  =====================

---Print a snapshot of ContextMenu's current state to the debug-console and (optionally) save it in Osiris Data/S7Debug
---@param fileName string|nil if specified, will save the results in a .yaml file in `Osiris Data/S7Debug/`
local function SnapshotContextMenu(fileName)
    local ctxInfo = Rematerialize(ContextMenu) -- Drops non-stringifiable elements
    ctxInfo['ContextEntries'] = nil  --  Too big to be useful in the debug-console

    --  Pretty print snapshot
    Write:SetHeader('ContextMenu:')
    Write:Tabulate(ctxInfo)
    ctxInfo['ContextEntry'] = Yamlify(ContextMenu.ContextEntries[ContextMenu.Activator])
    Write:NewLine('ContextEntry:\n')
    Write:NewLine(ctxInfo['ContextEntry'])
    Debug:Print(Write:Display())

    ctxInfo['ContextEntries'] = ContextMenu.ContextEntries    --  Re-add ContextEntries for printing

    --  Save to external yaml file if fileName was specified
    if IsValid(fileName) then
        SaveFile('S7Debug/' .. fileName .. '.yaml', Yamlify(ctxInfo))
    end
end

if Ext.IsDeveloperMode() then
    ConsoleCommander:Register({

        --  ---------------------------------------------
        --  !S7_UI_Components_Library SnapshotContextMenu
        --  ---------------------------------------------

        Name = 'SnapshotContextMenu',
        Description = 'Prints the current state of the ContextMenu object',
        Context = 'Client',
        Params = {[1] = 'fileName: string|nil - Will save results in Osiris Data/S7Debug/[fileName].yaml if specified'},
        Action = SnapshotContextMenu
    })
end