--------------------------------------------------------------------------------
--[[ HandyNotes: Loremaster ]]--
--
-- by erglo <erglo.coder+HNLM@gmail.com>
--
-- Copyright (C) 2023  Erwin D. Glockner (aka erglo)
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses.
--
--
-- Files used for reference:
-- REF.: <https://www.wowace.com/projects/ace3/pages/getting-started>
-- REF.: <https://wowpedia.fandom.com/wiki/API_C_AddOns.GetAddOnMetadata>
-- REF.: <World of Warcraft\_retail_\Interface\AddOns\HandyNotes\HandyNotes.lua>
-- (see also the function comments section for more reference)
--
--------------------------------------------------------------------------------

local AddonID, ns = ...

local currentLocale = GetLocale()
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local HandyNotes = _G.HandyNotes

local HandyNotesPlugin = LibStub("AceAddon-3.0"):NewAddon("HNLM", "AceConsole-3.0")
-- local HandyNotesPlugin = LibStub("AceAddon-3.0"):NewAddon(AddonID, "AceConsole-3.0")

-- This is optional, but convenient
HandyNotesPlugin.title = GetAddOnMetadata(AddonID, "Title")
HandyNotesPlugin.icon = GetAddOnMetadata(AddonID, "IconTexture") or GetAddOnMetadata(AddonID, "IconAtlas")
HandyNotesPlugin.version = GetAddOnMetadata(AddonID, "Version")
HandyNotesPlugin.description = GetAddOnMetadata(AddonID, "Notes-"..currentLocale) or GetAddOnMetadata(AddonID, "Notes")

-- Prepare options
local _, optionsTitle = strsplit(":", HandyNotesPlugin.title)

local options = {
    handler = HandyNotesPlugin,
    name = strtrim(optionsTitle),
    desc = HandyNotesPlugin.description,
    type = 'group',
    args = {
        msg = {
            type = 'input',
            name = 'My Message',
            desc = 'The message for my addon',
            -- set = 'SetMyMessage',
            -- get = 'GetMyMessage',
        },
    },
}

------ Main --------------------------------------------------------------------

function HandyNotesPlugin:OnInitialize()
    -- Using AceConsole for slash commands
    self:RegisterChatCommand("hnlm", "ProcessSlashCommands")
end

function HandyNotesPlugin:OnEnable()
    -- Register this plugin to HandyNotes
    -- REF.: HandyNotes:RegisterPluginDB(pluginName, pluginHandler, optionsTable)
    HandyNotes:RegisterPluginDB(self.title, self, options)
    self:Print(YELLOW_FONT_COLOR:WrapTextInColorCode(self.title), "is enabled")
end

-- function HandyNotesPlugin:OnDisable()
--     -- Called when the addon is disabled
-- end

-----|--------------------------------------------------------------------------
-- Required functions for HandyNotes


-- points[<mapfile>] = { [<coordinates>] = { <quest ID>, <item name>, <notes> } }


-- An iterator function that will loop over and return 5 values
--      (coord, uiMapID, iconpath, scale, alpha)
--      for every node in the requested zone. If the uiMapID return value is nil, we assume it is the
--      same uiMapID as the argument passed in. Mainly used for continent uiMapID where the map passed
--      in is a continent, and the return values are coords of subzone maps.
local function DataIterator(...)
    -- for k,v in pairs(ns) do
    --     print(k, "-->", v)
    -- end
    HandyNotesPlugin:Print("args -->", ...)
-- local function DataIterator(t, prev)
    -- if not t then return end
    -- if not completedQuests[38356] or not completedQuests[37961] then return end
    -- local coord, v = next(t, prev)
    -- while coord do
    --     if v and (db.completed or not completedQuests[v[1]]) then
    --         return coord, nil, "interface\\icons\\inv_misc_punchcards_yellow", db.icon_scale, db.icon_alpha
    --     end

    --     coord, v = next(t, coord)
    -- end
end

-- REF.: iter, state, value = pluginHandler:GetNodes2(uiMapID, minimap)
-- Parameters
--  - uiMapID: The zone we want data for
--  - minimap: Boolean argument indicating that we want to get nodes to display for the minimap
-- Returns:
--  - iter: An iterator function that will loop over and return 5 values
--      (coord, uiMapID, iconpath, scale, alpha)
--      for every node in the requested zone. If the uiMapID return value is nil, we assume it is the
--      same uiMapID as the argument passed in. Mainly used for continent uiMapID where the map passed
--      in is a continent, and the return values are coords of subzone maps.
--  - state, value: First 2 args to pass into iter() on the initial iteration
function HandyNotesPlugin:GetNodes2(uiMapID, minimap)
    return DataIterator, 1, 2
end

--------------------------------------------------------------------------------
----- Slash Commands (requires: AceConsole) ------------------------------------
--------------------------------------------------------------------------------

function HandyNotesPlugin:ProcessSlashCommands(input)
    -- Process the slash command ('input' contains whatever follows the slash command)
    -- Registered in :OnEnable()
    if (input == "version") then
        self:Print(YELLOW_FONT_COLOR:WrapTextInColorCode(self.title), self.version)
    end
    if (input == "config") then
        Settings.OpenToCategory(HandyNotes.name)
    end
end
