--------------------------------------------------------------------------------
--[[ HandyNotes: Loremaster (Dragonflight) ]]--
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

local HandyNotes = _G.HandyNotes
local utils = ns.utils

-- local ExpansionInfo = {
--     ["ID"] = LE_EXPANSION_DRAGONFLIGHT,  -- 9
--     ["name"] = EXPANSION_NAME9,
--     ["continents"] = {1978},  --> Dragon Isles
--     ["zoneMapIDs"] = HandyNotes:GetContinentZoneList(1978)
-- }

local HandyNotesPlugin = LibStub("AceAddon-3.0"):NewAddon("HNLM-DF", "AceConsole-3.0")

function HandyNotesPlugin:OnInitialize()
    ns.db = LibStub("AceDB-3.0"):New("HN_LM09_DB")
    -- ns.var = HN_LM09_DB

    ns.options = ns.pluginInfo.options(self)

    -- Using AceConsole for slash commands                                      --> TODO - Keep slash commands ???
    self:RegisterChatCommand("hnlm", "ProcessSlashCommands")
end

function HandyNotesPlugin:OnEnable()
    -- Register this plugin to HandyNotes
    -- REF.: HandyNotes:RegisterPluginDB(pluginName, pluginHandler, optionsTable)
    HandyNotes:RegisterPluginDB(AddonID, self, ns.options)
    self:Print(YELLOW_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title), "is enabled")

    -- Test utils
    -- local achievementInfo = utils.achieve.GetWrappedAchievementInfo(16398)
    -- -- if not ns.db.continents then
    -- --     ns.db.continents = {}
    -- -- end
    -- -- if not ns.db.continents[DRAGON_ISLES_MAP_ID] then
    -- --     ns.db.continents[DRAGON_ISLES_MAP_ID] = {}
    -- -- end
    -- ns.var.achievements = {}
    -- ns.var.achievements[achievementInfo.achievementID] = utils.achieve.GetAchievementCriteriaInfoList(achievementInfo.achievementID)
    -- -- local includeCompleted = true
    -- local numCriteriaTotal, numCriteriaCompleted = utils.achieve.GetWrappedAchievementNumCriteria(achievementInfo.id, includeCompleted)
    -- self:Print(achievementInfo.id, achievementInfo.name, format("%d/%d", numCriteriaCompleted, numCriteriaTotal))
end

function HandyNotesPlugin:OnDisable()
    self:Print(YELLOW_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title), "is disabled")
end

--------------------------------------------------------------------------------
----- Required functions for HandyNotes ----------------------------------------
--------------------------------------------------------------------------------


-- points[<mapfile>] = { [<coordinates>] = { <quest ID>, <item name>, <notes> } }


-- An iterator function that will loop over and return 5 values
-- (coord, uiMapID, iconpath, scale, alpha)
-- for every node in the requested zone. If the uiMapID return value is nil, we assume it is the
-- same uiMapID as the argument passed in. Mainly used for continent uiMapID where the map passed
-- in is a continent, and the return values are coords of subzone maps.
--
local function PointsDataIterator(state, value)
    if not state then return end
    HandyNotesPlugin:Print("args -->", state, value)
    -- local coord, v = next(t, prev)
    -- while coord do
    --     if v and (db.completed or not completedQuests[v[1]]) then
    --         return coord, nil, "interface\\icons\\inv_misc_punchcards_yellow", db.icon_scale, db.icon_alpha
    --     end

    --     coord, v = next(t, coord)
    -- end
end

-- Required standard function for HandyNotes to get a location node.
---@param uiMapID number  The zone we want data for
---@param minimap boolean  Boolean argument indicating that we want to get nodes to display for the minimap
---@return function iter  An iterator function that will loop over and return 5 values (coord, uiMapID, iconpath, scale, alpha)
---@return any state  Arg 1 to pass into iter() on the initial iteration
---@return any value  Arg 2 to pass into iter() on the initial iteration
--
--> REF.: <World of Warcraft\_retail_\Interface\AddOns\HandyNotes\HandyNotes.lua>
--
function HandyNotesPlugin:GetNodes2(uiMapID, minimap)
    local isWorldMapShown = WorldMapFrame and WorldMapFrame:IsShown()
    return PointsDataIterator, isWorldMapShown, WorldMapFrame and WorldMapFrame:GetMapID()
end

-- Standard functions you can provide optionally:
-- pluginHandler:OnEnter(uiMapID/mapFile, coord)
--     Function we will call when the mouse enters a HandyNote, you will generally produce a tooltip here.
-- pluginHandler:OnLeave(uiMapID/mapFile, coord)
--     Function we will call when the mouse leaves a HandyNote, you will generally hide the tooltip here.
-- pluginHandler:OnClick(button, down, uiMapID/mapFile, coord)
--     Function we will call when the user clicks on a HandyNote, you will generally produce a menu here on right-click.

--------------------------------------------------------------------------------
----- Slash Commands (requires: AceConsole) ------------------------------------
--------------------------------------------------------------------------------

function HandyNotesPlugin:ProcessSlashCommands(input)
    -- Process the slash command ('input' contains whatever follows the slash command)
    -- Registered in :OnEnable()
    if (input == "version") then
        self:Print(YELLOW_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title), ns.pluginInfo.version)
    end
    if (input == "config") then
        Settings.OpenToCategory(HandyNotes.name)
    end
end
