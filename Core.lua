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
-- Ace3 API reference:
-- REF.: <https://www.wowace.com/projects/ace3/pages/getting-started>
--
-- HandyNotes API reference:
-- REF.: <https://www.curseforge.com/wow/addons/handynotes>
-- REF.: <https://github.com/Nevcairiel/HandyNotes/blob/master/HandyNotes.lua>
--
-- World of Warcraft API reference:
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/UITimerDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/GlobalStrings.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/TableUtil.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/QuestMapFrame.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/MapConstantsDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestConstantsDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Constants.lua>
-- (see also the function comments section for more reference)
--
--------------------------------------------------------------------------------

local AddonID, ns = ...
local utils = ns.utils

local QuestCache = {}

local silent = true
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", silent)
if not HandyNotes then return end

local format, tostring, strlen, strtrim, string_gsub = string.format, tostring, strlen, strtrim, string.gsub
local tContains, tInsert = tContains, table.insert

local C_QuestLog, C_QuestLine, C_CampaignInfo = C_QuestLog, C_QuestLine, C_CampaignInfo
local QuestUtils_GetQuestName = QuestUtils_GetQuestName
local QuestUtils_AddQuestTypeToTooltip = QuestUtils_AddQuestTypeToTooltip
local GetQuestFactionGroup, GetQuestUiMapID, QuestHasPOIInfo = GetQuestFactionGroup, GetQuestUiMapID, QuestHasPOIInfo
local IsBreadcrumbQuest, IsQuestSequenced, IsStoryQuest = IsBreadcrumbQuest, IsQuestSequenced, IsStoryQuest
local GetQuestExpansion, UnitFactionGroup = GetQuestExpansion, UnitFactionGroup
local C_Map = C_Map  -- C_TaskQuest

local GREEN_FONT_COLOR, NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR = GREEN_FONT_COLOR, NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR

local CATEGORY_NAME_COLOR = GRAY_FONT_COLOR
local ZONE_STORY_HEADER_COLOR = ACHIEVEMENT_COLOR
local QUESTLINE_HEADER_COLOR = SCENARIO_STAGE_COLOR
local CAMPAIGN_HEADER_COLOR = CAMPAIGN_COMPLETE_COLOR

local YELLOW = function(txt) return YELLOW_FONT_COLOR:WrapTextInColorCode(txt) end
local GRAY = function(txt) return GRAY_FONT_COLOR:WrapTextInColorCode(txt) end
local GREEN = function(txt) return FACTION_GREEN_COLOR:WrapTextInColorCode(txt) end
local RED = function(txt) return RED_FONT_COLOR:WrapTextInColorCode(txt) end

local function StringIsEmpty(str)
	return str == nil or strlen(str) == 0
end

-- local function tCount(tbl)
-- 	local n = #tbl or 0
-- 	if (n == 0) then
-- 		for _ in pairs(tbl) do
-- 			n = n + 1
-- 		end
-- 	end
-- 	return n
-- end

-- local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME)
-- local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes", true)
local L = {}
-- WoW global strings
L.OPTION_STATUS_DISABLED = VIDEO_OPTIONS_DISABLED
L.OPTION_STATUS_ENABLED = VIDEO_OPTIONS_ENABLED
L.OPTION_STATUS_FORMAT = SLASH_TEXTTOSPEECH_HELP_FORMATSTRING
L.OPTION_STATUS_FORMAT_READY = LFG_READY_CHECK_PLAYER_IS_READY  -- "%s is ready."

L.CATEGORY_NAME_QUESTLINE = "Questline"  -- Questreihe

L.QUEST_NAME_FORMAT_ALLIANCE = "%s |A:questlog-questtypeicon-alliance:16:16:0:-1|a"
L.QUEST_NAME_FORMAT_HORDE = "%s |A:questlog-questtypeicon-horde:16:16:0:-1|a"
L.QUEST_NAME_FORMAT_NEUTRAL = "%s"
-- QUEST_TYPE_NAME_FORMAT_TRIVIAL = TRIVIAL_QUEST_DISPLAY,  -- "|cff000000%s (niedrigstufig)|r"

L.STORY_NAME_FORMAT_COMPLETE = "|T%d:16:16:0:0|t %s  |A:achievementcompare-YellowCheckmark:0:0|a"
L.STORY_NAME_FORMAT_INCOMPLETE = "|T%d:16:16:0:0|t %s"
L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY = "Hold %s to see chapters"
L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY_HOVER = "Hold %s and hover icon to see chapters"

L.QUESTLINE_NAME_FORMAT = "|TInterface\\Icons\\INV_Misc_Book_07:16:16:0:-1|t %s"
L.QUESTLINE_PROGRESS_FORMAT = "|"..string_gsub(strtrim(CAMPAIGN_PROGRESS_CHAPTERS_TOOLTIP, "|n"), "[|]n[|]c", HEADER_COLON.." |c", 1)

L.CAMPAIGN_NAME_FORMAT_COMPLETE = "|A:Campaign-QuestLog-LoreBook:16:16:0:0|a %s  |A:achievementcompare-YellowCheckmark:0:0|a"
L.CAMPAIGN_NAME_FORMAT_INCOMPLETE = "|A:Campaign-QuestLog-LoreBook:16:16:0:0|a %s"
L.CAMPAIGN_PROGRESS_FORMAT = "|"..string_gsub(strtrim(CAMPAIGN_PROGRESS_CHAPTERS_TOOLTIP, "|n"), "[|]n[|]c", HEADER_COLON.." |c", 1)
L.CAMPAIGN_TYPE_FORMAT_QUEST = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a This quest is part of the %s campaign."
L.CAMPAIGN_TYPE_FORMAT_QUESTLINE = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a This quest line is part of the %s campaign."

L.CHAPTER_NAME_FORMAT_COMPLETED = "|TInterface\\Scenarios\\ScenarioIcon-Check:16:16:0:-1|t %s"
L.CHAPTER_NAME_FORMAT_NOT_COMPLETED = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s"
L.CHAPTER_NAME_FORMAT_CURRENT = "|A:common-icon-forwardarrow:16:16:2:-1|a %s"

-- ACHIEVEMENT_NAME_FORMAT = "|T%d:16:16:0:0|t %s",
-- ACHIEVEMENT_COLON_FORMAT = CONTENT_TRACKING_ACHIEVEMENT_FORMAT,  -- "Erfolg: \"%s\"";
-- ACHIEVEMENT_UNLOCKED_FORMAT = ACHIEVEMENT_UNLOCKED_CHAT_MSG,  -- "Erfolg errungen: %s";
-- "questlog-questtypeicon-story"
-- "CampaignAvailableQuestIcon"
-- "Campaign-QuestLog-LoreBook", "Campaign-QuestLog-LoreBook-Back"

-- REQ_ACHIEVEMENT = ITEM_REQ_PURCHASE_ACHIEVEMENT,
-- ITEM_REQ_REPUTATION = "Requires %s - %s";
-- ITEM_REQ_SKILL = "Requires %s";
-- ITEM_REQ_SPECIALIZATION = "Requires: %s";
-- ITEM_REQ_ALLIANCE = "Alliance Only";
-- ITEM_REQ_HORDE = "Horde Only";
-- ACHIEVEMENT_STATUS_COMPLETED = ACHIEVEMENTFRAME_FILTER_COMPLETED,  -- "Errungen";
-- ACHIEVEMENT_STATUS_INCOMPLETE = ACHIEVEMENTFRAME_FILTER_INCOMPLETE, -- "Unvollständig";
-- ACHIEVEMENT_UNLOCKED = "Erfolg errungen";
-- ACHIEVEMENT_CATEGORY_PROGRESS = "Fortschrittsüberblick";
-- ACHIEVEMENT_COMPARISON_NO_PROGRESS = "Noch kein Fortschritt für diesen Erfolg";
-- ACHIEVEMENT_META_COMPLETED_DATE = "%s abgeschlossen.";
-- ARTIFACT_HIDDEN_ACHIEVEMENT_PROGRESS_FORMAT = "%s (%d / %d)";
-- CONTENT_TRACKING_CHECKMARK_TOOLTIP_TITLE = "Zurzeit verfolgt";
L.OBJECTIVE_FORMAT = CONTENT_TRACKING_OBJECTIVE_FORMAT  -- "- %s"
-- ERR_ACHIEVEMENT_WATCH_COMPLETED = "Dieser Erfolg wurde bereits abgeschlossen.";
-- GUILD_NEWS_VIEW_ACHIEVEMENT = "Erfolg anzeigen";
-- CONTINENT = "Kontinent";
-- ACHIEVEMENT_NOT_COMPLETED = ACHIEVEMENT_COMPARISON_NOT_COMPLETED,  -- "Erfolg nicht abgeschlossen";
-- QUEST_LOG_COVENANT_CALLINGS_HEADER = "|cffffffffBerufungen:|r |cffffd200%d/%d abgeschlossen|r";

-- Custom strings
L.SLASHCMD_USAGE = "Usage:"

-- "achievementcompare-GreenCheckmark"
-- "achievementcompare-YellowCheckmark"

-- local LibDD = LibStub:GetLibrary('LibUIDropDownMenu-4.0')

----- Debugging -----

local DEV_MODE = false

local debug = {}
debug.isActive = DEV_MODE
debug.showChapterIDsInTooltip = DEV_MODE
debug.print = function(self, ...)
    local prefix = "LM-DBG"
    if type(...) == "table" then
        local t = ...
        if t.debug then
            print(YELLOW(prefix.." "..t.debug_prefix), select(2, ...))
        end
    elseif self.isActive then
        print(YELLOW(prefix..":"), ...)
    end
end
debug.hooks = {}
debug.hooks.debug = false
debug.hooks.debug_prefix = "HOOKS:"

-- In debug mode show additional infos in a quest icon's tooltip, eg. questIDs,
-- achievementIDs, etc.
debug.AddDebugLineToTooltip = function(self, tooltip, debugInfo)
    local text = debugInfo and debugInfo.text
    local addBlankLine = debugInfo and debugInfo.addBlankLine
    if DEV_MODE then
        if text then GameTooltip_AddDisabledLine(tooltip, text, false) end
        if addBlankLine then GameTooltip_AddBlankLineToTooltip(tooltip) end
    end
end

----- Faction Groups ----------

local playerFactionGroup = UnitFactionGroup("player")

-- Quest faction groups: {Alliance=1, Horde=2, Neutral=3}
local QuestFactionGroupID = EnumUtil.MakeEnum(PLAYER_FACTION_GROUP[1], PLAYER_FACTION_GROUP[0], "Neutral")

local QuestNameFactionGroupFormat = {
    [QuestFactionGroupID.Alliance] = L.QUEST_NAME_FORMAT_ALLIANCE,
    [QuestFactionGroupID.Horde] = L.QUEST_NAME_FORMAT_HORDE,
    [QuestFactionGroupID.Neutral] = L.QUEST_NAME_FORMAT_NEUTRAL,
}

-- Filter given quest by faction group (1 == Alliance, 2 == Horde, [3 == Neutral])
local function PlayerMatchesQuestFactionGroup(questFactionGroup)
    return tContains({QuestFactionGroupID[playerFactionGroup], QuestFactionGroupID.Neutral}, questFactionGroup)
end

----- Main ---------------------------------------------------------------------

local HandyNotesPlugin = LibStub("AceAddon-3.0"):NewAddon("Loremaster", "AceConsole-3.0")
--> AceConsole is used for chat frame related functions, eg. printing or slash commands 

function HandyNotesPlugin:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("LoremasterDB", ns.pluginInfo.defaultOptions)
    --> Available AceDB sub-tables: char, realm, class, race, faction, factionrealm, factionrealmregion, profile, and global

    ns.settings = self.db.profile  --> All characters using the same profile share this database.
    ns.data = self.db.global  --> All characters on the same account share this database.

    self.options = ns.pluginInfo.options()

    -- Register options to Ace3 for a standalone config window
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddonID, self.options)

    -- Register this addon + options to HandyNotes as a plugin
    HandyNotes:RegisterPluginDB(AddonID, self, self.options)

    ns.cprint = function(s, ...) self:Print(...) end
    ns.cprintf = function(s, ...) self:Printf(...) end

    self.slash_commands = {"lm", "loremaster"}                                  --> TODO - Keep slash commands ???
    self.hasRegisteredSlashCommands = false

    self:RegisterHooks()    --> TODO - Switch to AceHook for unhooking
end

function HandyNotesPlugin:OnEnable()
    -- Register slash commands via AceConsole
    for i, command in ipairs(self.slash_commands) do
        self:RegisterChatCommand(command, "ProcessSlashCommands")
    end
    self.hasRegisteredSlashCommands = true

    self:Printf(L.OPTION_STATUS_FORMAT_READY, YELLOW(ns.pluginInfo.title))
end

function HandyNotesPlugin:OnDisable()
    -- Unregister slash commands from via AceConsole
    if self.hasRegisteredSlashCommands then
        for i, command in ipairs(self.slash_commands) do
            self:UnregisterChatCommand(command)
        end
    end
    self.hasRegisteredSlashCommands = false

    --> TODO - Add unhooking

    self:Printf(L.OPTION_STATUS_FORMAT, YELLOW(ns.pluginInfo.title), L.OPTION_STATUS_DISABLED)
end

----- Slash Commands ----------

function HandyNotesPlugin:ProcessSlashCommands(msg)
    -- Process the slash command ('input' contains whatever follows the slash command)
    -- Registered in :OnEnable()
    local input = strtrim(msg)

    if (input == "help") then
        -- Print usage message to chat
        self:Print(L.SLASHCMD_USAGE, format(" '/%s <%s>'", self.slash_commands[1], YELLOW("arg")), "|",
        format(" '/%s <%s>'", self.slash_commands[2], YELLOW("arg")))

        -- local arg_list = {
        --     version = "Display addon version",
        --     config = "Display settings",
        -- }
        -- for arg_name, arg_description in pairs(arg_list) do
        --     self:Print(" ", L.OBJECTIVE_FORMAT:format(YELLOW(arg_name..":")), arg_description)
        -- end

    elseif (input == "version") then
        self:Print(ns.pluginInfo.version)

    elseif (input == "config") then
        Settings.OpenToCategory(HandyNotes.name)
        -- LibStub("AceConfigDialog-3.0"):Open("HandyNotes")

    else
        LibStub("AceConfigDialog-3.0"):Open(AddonID)

    end
end

-- Standard functions you can provide optionally:
-- pluginHandler:OnEnter(uiMapID/mapFile, coord)
--     Function we will call when the mouse enters a HandyNote, you will generally produce a tooltip here.
-- pluginHandler:OnLeave(uiMapID/mapFile, coord)
--     Function we will call when the mouse leaves a HandyNote, you will generally hide the tooltip here.
-- pluginHandler:OnClick(button, down, uiMapID/mapFile, coord)
--     Function we will call when the user clicks on a HandyNote, you will generally produce a menu here on right-click.

----- Database utilities ----------

local DBUtil = {}
DBUtil.debug = DEV_MODE
DBUtil.debug_prefix = GREEN("DB:")

function DBUtil:CheckInitCategory(categoryName)
    if not ns.data[categoryName] then
        -- Save { [questLineID] = {questID=questID, mapIDs={mapID1, mapID2, ...}, quests={questID1, questID2, ...}}, ... }
        ns.data[categoryName] = {}
        debug:print(self, "Initialized DB:", categoryName)
    end
end

function DBUtil:SaveSingleQuestLine(questLineInfo, mapID, quests)
    local questIDs = quests or QuestCache:GetQuestLineQuests(questLineInfo.questLineID)
    -- Structure: { [questLineID] = {questID=questID, mapIDs={mapID1, mapID2, ...}, quests={questID1, questID2, ...}}, ... }
    if not ns.data.questLines[questLineInfo.questLineID] then
        ns.data.questLines[questLineInfo.questLineID] = {
            questID = questLineInfo.questID,
            mapIDs = {mapID},
            quests = questIDs,
        }
        debug:print(self, "Saved QL:", questLineInfo.questLineID, questLineInfo.questLineName)

    elseif not tContains(ns.data.questLines[questLineInfo.questLineID].mapIDs, mapID) then
        tInsert(ns.data.questLines[questLineInfo.questLineID].mapIDs, mapID)
        debug:print(self, "Added mapID to QL:", mapID, questLineInfo.questLineID)
    end
end
function DBUtil:GetSavedQuestLinesForMap(mapID)
    local infos = {}
    for questLineID, questLineData in pairs(ns.data.questLines) do
        if tContains(questLineData.mapIDs, mapID) then
            tInsert(infos, questLineData.questID)
        end
    end
    if TableHasAnyEntries(infos) then debug:print(DBUtil, format("Loaded %d |4QuestLine:QuestLines; for %d", #infos, mapID)) end

    return infos
end
function DBUtil:GetSavedQuestLineMapForQuest(questID)
    for questLineID, questLineData in pairs(ns.data.questLines) do
        if tContains(questLineData.quests, questID) then
            local mapID = questLineData.mapIDs[1]
            debug:print(self, "Found map for quest:", mapID)

            return mapID
        end
    end
end

----- Tooltip Data Handler ----------

local ZoneStoryUtils = {}
ZoneStoryUtils.debug = false
ZoneStoryUtils.debug_prefix = "ZS:"

local ZoneStoryCache = {}
ZoneStoryCache.debug = false
ZoneStoryCache.debug_prefix = "ZS-CACHE:"
ZoneStoryCache.meta = {}  --> {[mapID] = {storyAchievementID, storyMapInfo}, ...}
ZoneStoryCache.achievements = {}  --> achievementInfo + .criteriaList
-- setmetatable(ZoneStoryCache.meta, BaseCache)
-- setmetatable(ZoneStoryCache.achievements, BaseCache)
ZoneStoryCache.GetZoneStoryInfo = function(self, mapID, prepareCache)
    if not self.meta[mapID] then
        local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID)
        if not storyAchievementID then return end
        local mapInfo = C_Map.GetMapInfo(storyMapID or mapID)
        self.meta[mapID] = {storyAchievementID, mapInfo}
        debug:print(self, "Added zone story:", storyAchievementID, storyMapID, mapInfo.name)
    end
    if not prepareCache then
        debug:print(self, "Returning zone story for", mapID)
        return SafeUnpack(self.meta[mapID])
    end
end
ZoneStoryCache.GetAchievementInfo = function(self, achievementID)
    if not self.achievements[achievementID] then
        local achievementInfo = utils.achieve.GetWrappedAchievementInfo(achievementID)
        achievementInfo.numCriteria = utils.achieve.GetWrappedAchievementNumCriteria(achievementID)
        achievementInfo.numCompleted = 0
        achievementInfo.criteriaList = {}
        for criteriaIndex=1, achievementInfo.numCriteria do
            local criteriaInfo = utils.achieve.GetWrappedAchievementCriteriaInfo(achievementID, criteriaIndex)
            if criteriaInfo then
                if criteriaInfo.completed then
                    achievementInfo.numCompleted = achievementInfo.numCompleted + 1
                end
                tInsert(achievementInfo.criteriaList, criteriaInfo)
            end
        end
        self.achievements[achievementID] = achievementInfo
        debug:print(self, "Added achievementInfo:", achievementID, achievementInfo.name)
    end
    debug:print(self, "Returning achievementInfo for", achievementID)
    return self.achievements[achievementID]
end

local LocalQuestUtils = {}

LocalQuestUtils.GetQuestName = function(self, questID)
    -- REF.: <https://www.townlong-yak.com/framexml/live/QuestUtils.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
	if not HaveQuestData(questID) then
		C_QuestLog.RequestLoadQuestByID(questID)
	end

	return QuestUtils_GetQuestName(questID)
end

-- Retrieve different quest details.
LocalQuestUtils.GetQuestInfo = function(self, questID, targetType)
    -- C_TaskQuest.GetQuestInfoByQuestID(questID) 
    if (targetType == "questline") then
        local questName = self:GetQuestName(questID)
        local nilCount = 0
        if StringIsEmpty(questName) then
            questName, nilCount = LocalQuestUtils:CheckNilQuest(questID)
        end
        local isOnMap, hasLocalPOI = C_QuestLog.IsOnMap(questID)
        return {
            questID = questID,
            questName = questName,
            nilCount = nilCount,
            isOnMap = isOnMap,
            hasLocalPOI = hasLocalPOI,
            questMapID = GetQuestUiMapID(questID),
            questExpansionID = GetQuestExpansion(questID),
            questFactionGroup = GetQuestFactionGroup(questID) or QuestFactionGroupID.Neutral,
            isAccountQuest = C_QuestLog.IsAccountQuest(questID),
            isBounty = C_QuestLog.IsQuestBounty(questID),
            isBreadcrumbQuest = IsBreadcrumbQuest(questID),
            isCalling = C_QuestLog.IsQuestCalling(questID),
            isCampaign = C_CampaignInfo.IsCampaignQuest(questID),
            isComplete = C_QuestLog.IsComplete(questID),
            isDisabledForSession = C_QuestLog.IsQuestDisabledForSession(questID),
            isFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID),
            isInvasion = C_QuestLog.IsQuestInvasion(questID),
            isLegendaryQuest = C_QuestLog.IsLegendaryQuest(questID),
            isRepeatable = C_QuestLog.IsRepeatableQuest(questID),
            isReplayable = C_QuestLog.IsQuestReplayable(questID),
            isReplayedRecently = C_QuestLog.IsQuestReplayedRecently(questID),
            isSequenced = IsQuestSequenced(questID),
            isStoryQuest = IsStoryQuest(questID),
            isTask = C_QuestLog.IsQuestTask(questID),
            isThreat = C_QuestLog.IsThreatQuest(questID),
            isTrivial = C_QuestLog.IsQuestTrivial(questID),
            questTagInfo = C_QuestLog.GetQuestTagInfo(questID),
            questType = C_QuestLog.GetQuestType(questID),
            questWatchType = C_QuestLog.GetQuestWatchType(questID),
        }
    end
end

-- LocalQuestUtils.weeklyQuests = {                                                --> TODO - Check quest giver quests
--     "61982", -- Kyrian, "Replenish the Reservoir"
--     "61332", -- Kyrian, "Return Lost Souls"
--     "62861", -- Kyrian, "Return Lost Souls"
--     "62862", -- Kyrian, "Return Lost Souls"
--     "62863", -- Kyrian, "Return Lost Souls"
-- }

-- function Test_QuestInfo(questID)
--     local questInfo = LocalQuestUtils:GetQuestInfo(questID, "questline")
--     local info = {}
--     for k, v in pairs(questInfo) do
--         if v then info[k] = v end
--     end
--     return info
-- end

-- Some quests have been removed from the game but still appear as part of 
-- questlines. Save this quests and count how many times is hasn't been found.
-- Sometimes the quest data takes some time to be retrieved. If we get data,
-- remove quest from this list.
LocalQuestUtils.CheckNilQuest = function(self, questID)
    DBUtil:CheckInitCategory("nilQuests")
    local questIDstring = tostring(questID)
    if not ns.data.nilQuests[questIDstring] then
        ns.data.nilQuests[questIDstring] = 0
        debug:print("nilQuest:", questIDstring, "Added to DB")
    end

    local nilCount = ns.data.nilQuests[questIDstring]
    if (nilCount == -1) then
        -- Quest has been removed from the game
        --> This has been verified manually by checking online databases.
        debug:print("nilQuest:", questIDstring, "Removed from game")
        return '', -1
    end

    local questName = self:GetQuestName(questID)
    if not StringIsEmpty(questName) then
        -- Got data, can be removed
        ns.data.nilQuests[questIDstring] = nil
        debug:print("nilQuest:", questIDstring, questName, "Removed from DB")
        return questName
    else
        ns.data.nilQuests[questIDstring] = nilCount + 1
        nilCount = ns.data.nilQuests[questIDstring]
        debug:print("nilQuest:", questIDstring, nilCount, "Updated counter")
    end

    return questName, nilCount
end


QuestCache.debug = false
QuestCache.debug_prefix = "Quest-CACHE:"
QuestCache.questLineQuests = {}  --> Structure: { [questLineID] = {questID1, questID2, ...}, ... }
-- setmetatable(QuestCache.questLineQuests, BaseCache)
QuestCache.GetQuestLineQuests = function(self, questLineID, prepareCache)
    -- print(">",  questLineID, prepareCache)
    if not self.questLineQuests then
        self.questLineQuests = {}
        debug:print(self, "Initialized 'questLineQuests' DB")
    end
    if not self.questLineQuests[questLineID] then
        local questIDs = C_QuestLine.GetQuestLineQuests(questLineID)
        if (not questIDs or #questIDs == 0) then return end
        self.questLineQuests[questLineID] = questIDs
        debug:print(self, format("> Adding %d QL |4quest:quests; to %d", #questIDs, questLineID))
        -- return questIDs
    end
    if not prepareCache then
        local questIDs = self.questLineQuests[questLineID]
        debug:print(self, format("> Returning %d QL |4quest:quests; for %d", #questIDs, questLineID))
        return questIDs
    end
end

----- QuestLine ----------

local LocalQuestLineUtils = {}
LocalQuestLineUtils.debug = true
LocalQuestLineUtils.debug_prefix = "QL-CACHE:"
LocalQuestLineUtils.questLineInfos = {}  --> { ["mapID"] = {questLineInfo1, questLineInfo2, ...}, ... }

-- Retrieve available questlines for given map.
---@param mapID number  The uiMapID
---@param updateData boolean If true, just updates the data without returning it.
---@return QuestLineInfo[]? questLineInfos
--
LocalQuestLineUtils.GetAvailableQuestLines = function(self, mapID, updateData)
    DBUtil:CheckInitCategory("questLines")
    if not self.questLineInfos[mapID] then
        local questLineInfos = C_QuestLine.GetAvailableQuestLines(mapID)
        if not TableHasAnyEntries(questLineInfos) then
            -- Also check database
            local questLineDataQuestIDs = DBUtil:GetSavedQuestLinesForMap(mapID)
            for i, questID in ipairs(questLineDataQuestIDs) do
                local questLineInfo = self:GetQuestLineInfo(questID, mapID)
                tInsert(questLineInfos, questLineInfo)
            end
        end
        if not TableHasAnyEntries(questLineInfos) then return end  --> still no infos

        self.questLineInfos[mapID] = questLineInfos
        debug:print(self, format("> Adding %d |4QuestLine:QuestLines; to %d", #questLineInfos, mapID))

        if updateData then
            for i, questLineInfo in ipairs(questLineInfos) do
                local quests = QuestCache:GetQuestLineQuests(questLineInfo.questLineID, false)
                -- Also save IDs in the database
                DBUtil:SaveSingleQuestLine(questLineInfo, mapID, quests)
            end
        end
    end

    if not updateData then
        local questLineInfos = self.questLineInfos[mapID]
        debug:print(self, format("Returning %d |4QuestLine:QuestLines; for %d", #questLineInfos, mapID))
        return questLineInfos
    end
end

LocalQuestLineUtils.AddSingleQuestLine = function(self, mapID, questLineInfo)
    if not self.questLineInfos[mapID] then
        self.questLineInfos[mapID] = {}
    end
    debug:print(self, format("Adding %d to %d", questLineInfo.questLineID, mapID))
    tInsert(self.questLineInfos[mapID], questLineInfo)
    -- Also save IDs in the database
    DBUtil:SaveSingleQuestLine(questLineInfo, mapID)
end

LocalQuestLineUtils.GetQuestLineInfoByPin = function(self, pin)
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua>
    local mapID = pin.mapID or pin:GetMap():GetMapID()
    local questLineInfos = self:GetAvailableQuestLines(mapID)
    if questLineInfos then
        -- Try cache look-up first
        for i, questLineInfo in ipairs(questLineInfos) do
            if (questLineInfo.questID == pin.questID) then
                debug:print(self, "> Found cached QL:", questLineInfo.questLineID, questLineInfo.questLineName)
                return questLineInfo
            end
        end
    end
    -- Try get new info
    local questLineInfo = self:GetQuestLineInfo(pin.questID, mapID)
    if not questLineInfo then
        -- Try database look-up
        local questLineMapID = DBUtil:GetSavedQuestLineMapForQuest(pin.questID)
        if not questLineMapID then return end
        questLineInfo = self:GetQuestLineInfo(pin.questID, questLineMapID)
    end
    if questLineInfo then
        debug:print(self, "> Got new QL:", questLineInfo.questLineID and questLineInfo.questLineName)
        self:AddSingleQuestLine(mapID, questLineInfo)
        return questLineInfo
    end
end

LocalQuestLineUtils.GetQuestLineInfo = function(self, questID, mapID)
    return C_QuestLine.GetQuestLineInfo(questID, mapID)
end

LocalQuestLineUtils.AddQuestLineDetailsToTooltip = function(self, tooltip, pin, campaignChapterID)
    local questLineInfo = self:GetQuestLineInfoByPin(pin)
    if campaignChapterID then
        local chapterInfo = C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID)
        local chapterName = chapterInfo and chapterInfo.name or RED(RETRIEVING_DATA)
        questLineInfo = {
            questLineID = campaignChapterID,
            questLineName = chapterName
        }
    end

    if not questLineInfo then return false end

    pin.questInfo.currentQuestLineID = questLineInfo.questLineID
    -- Note: This is later needed for the currentChapterID in quest campaigns. The
    -- actual `C_CampaignInfo.GetCurrentChapterID(campaignID)` refers only to active quest campaigns.

    -- Category name
    GameTooltip_AddColoredDoubleLine(tooltip, " ", L.CATEGORY_NAME_QUESTLINE, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)

    -- Quest line header
    GameTooltip_AddColoredLine(tooltip, L.QUESTLINE_NAME_FORMAT:format(questLineInfo.questLineName), QUESTLINE_HEADER_COLOR)
    -- Chapters
    local wrapLine = false
    local questIDs = QuestCache:GetQuestLineQuests(questLineInfo.questLineID)
    local numQuestIDs = #questIDs
    debug:AddDebugLineToTooltip(tooltip, {text=format("> L:%d \"%s\" #%d Quests", questLineInfo.questLineID, questLineInfo.questLineName, numQuestIDs)})
    for i, questID in ipairs(questIDs) do
        -- Add a line limit
        if (i == 50) then
            local numRemaining = numQuestIDs - i
            GameTooltip_AddNormalLine(tooltip, format("(+ %d more)", numRemaining), wrapLine)
            return
        end
        local questInfo = LocalQuestUtils:GetQuestInfo(questID, "questline")
        if PlayerMatchesQuestFactionGroup(questInfo.questFactionGroup) then
            -- local questName = LocalQuestUtils:GetQuestName(questID)
            if DEV_MODE and questInfo.questName == '' then                      --> FIXME - Why sometimes no quest names?
                print("questName:", questID, HaveQuestData(questID))
                for k, v in pairs(questInfo) do
                    if v then print("  ", k, "-->", v) end
                end
            end
            local questTitle = QuestNameFactionGroupFormat[pin.questInfo.questFactionGroup]:format(questInfo.questName)
            -- local isActiveQuest = C_QuestLog.IsComplete(questID)
            local isActiveQuest = questInfo.isComplete
            -- local isQuestCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
            local isQuestCompleted = questInfo.isFlaggedCompleted
            if debug.showChapterIDsInTooltip then questTitle = format("|cff808080%02d %d|r %s", questInfo.questType, questID, questTitle) end
            local leftOffset = 0
            if not StringIsEmpty(questInfo.questName) then
                if isQuestCompleted then
                    GameTooltip_AddColoredLine(tooltip, L.CHAPTER_NAME_FORMAT_COMPLETED:format(questTitle), GREEN_FONT_COLOR, wrapLine, leftOffset)
                elseif (questID == questLineInfo.questID) then
                    GameTooltip_AddNormalLine(tooltip, L.CHAPTER_NAME_FORMAT_CURRENT:format(questTitle), wrapLine, leftOffset)
                elseif isActiveQuest then
                    GameTooltip_AddNormalLine(tooltip, L.CHAPTER_NAME_FORMAT_CURRENT:format(questTitle), wrapLine, leftOffset)
                else
                    GameTooltip_AddHighlightLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(questTitle), wrapLine, leftOffset)
                end
            else
                if debug.showChapterIDsInTooltip then questTitle = format("|cff808080%02d %d|r %s", questInfo.questType, questID, RETRIEVING_DATA) end
                GameTooltip_AddErrorLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(questTitle), wrapLine, leftOffset)
            end
        end
    end

    return true
end

----- Common utilities ----------

local LocalUtils = {}

LocalUtils.QuestPinTemplate = "QuestPinTemplate"
LocalUtils.StorylineQuestPinTemplate = "StorylineQuestPinTemplate"

-- Determine different quest details
function LocalUtils:AddQuestInfoToPin(pin)
    local questID = pin.questID
    local questInfo = {
        questID = questID,
        questName = LocalQuestUtils:GetQuestName(questID),
        questMapID = GetQuestUiMapID(questID),
        -- questDifficulty = C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID),  --> Enum.RelativeContentDifficulty
        questExpansionID = GetQuestExpansion(questID),
        questFactionGroup = GetQuestFactionGroup(questID) or QuestFactionGroupID.Neutral,
        hasPOIInfo = QuestHasPOIInfo(questID),  -- QuestPOIGetIconInfo(questID)
        isAccountQuest = C_QuestLog.IsAccountQuest(questID),
        isBounty = C_QuestLog.IsQuestBounty(questID),
        isBreadcrumbQuest = IsBreadcrumbQuest(questID),
        isCalling = C_QuestLog.IsQuestCalling(questID),
        isCampaign = C_CampaignInfo.IsCampaignQuest(questID),
        isDisabledForSession = C_QuestLog.IsQuestDisabledForSession(questID),
        isFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID),
        isInvasion = C_QuestLog.IsQuestInvasion(questID),
        isLegendaryQuest = C_QuestLog.IsLegendaryQuest(questID),
        isReadyForTurnIn = C_QuestLog.ReadyForTurnIn(questID),
        isRepeatable = C_QuestLog.IsRepeatableQuest(questID),
        isReplayable = C_QuestLog.IsQuestReplayable(questID),
        isReplayedRecently = C_QuestLog.IsQuestReplayedRecently(questID),
        isSequenced = IsQuestSequenced(questID),
        isStoryQuest = IsStoryQuest(questID),
        isTask = C_QuestLog.IsQuestTask(questID),
        isThreat = C_QuestLog.IsThreatQuest(questID),
        isTrivial = C_QuestLog.IsQuestTrivial(questID),
        isWorldQuest = C_QuestLog.IsWorldQuest(questID),
        isComplete = C_QuestLog.IsComplete(questID),
        -- Test
        questTagInfo = C_QuestLog.GetQuestTagInfo(questID),
        questType = C_QuestLog.GetQuestType(questID),
        questWatchType = C_QuestLog.GetQuestWatchType(questID),
        isFailed = C_QuestLog.IsFailed(questID),
        isOnQuest = C_QuestLog.IsOnQuest(questID),
        -- C_QuestLog.IsOnMap(questID) : onMap, hasLocalPOI
        -- C_QuestLog.IsPushableQuest(questID) : isPushable - True if the quest can be shared with other players.
        canHaveWarBonus = C_QuestLog.QuestCanHaveWarModeBonus(questID),
        hasWarBonus = C_QuestLog.QuestHasWarModeBonus(questID),
    }

    local activeMapID = ns.uiMapID  --> The ID of the map the user is currently looking at
    questInfo.activeMapID = activeMapID
    questInfo.isActiveMap = (activeMapID == pin.mapID)
    questInfo.isQuestMap = (questInfo.questMapID == pin.mapID)
    questInfo.hasZoneStoryInfo = (C_QuestLog.GetZoneStoryInfo(activeMapID) ~= nil)
    questInfo.hasQuestLineInfo = (LocalQuestLineUtils:GetQuestLineInfo(questID, activeMapID) ~= nil)

    pin.questInfo = questInfo
end

-- In debug mode show additional quest data.
function LocalUtils:AddDebugQuestInfoLineToTooltip(tooltip, pin)
    GameTooltip_AddBlankLineToTooltip(tooltip)
    pin.questInfo.pinMapID = GRAY(tostring(pin.mapID))
    local leftHandColor, rightHandColor
    for k, v in pairs(pin.questInfo) do
        leftHandColor = (v == true) and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
        rightHandColor = (v == true) and GREEN_FONT_COLOR or NORMAL_FONT_COLOR
        GameTooltip_AddColoredDoubleLine(tooltip, k, tostring(v), leftHandColor, rightHandColor)
    end
end

function ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    debug:print(self, format("Checking zone (%s) for stories...", pin.mapID or "n/a"))

    local storyAchievementID, storyMapInfo = ZoneStoryCache:GetZoneStoryInfo(pin.mapID)
    if not storyAchievementID then
        debug:print(self, "> Nothing found.")
        return false
    end

    -- Category name
    GameTooltip_AddColoredDoubleLine(tooltip, " ", ZONE, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)

    local achievementInfo = ZoneStoryCache:GetAchievementInfo(storyAchievementID)
    -- Zone story name
    local storyNameTemplate = achievementInfo.completed and L.STORY_NAME_FORMAT_COMPLETE or L.STORY_NAME_FORMAT_INCOMPLETE
    local storyName = storyMapInfo and storyMapInfo.name or achievementInfo.name
    GameTooltip_AddColoredLine(tooltip, storyNameTemplate:format(achievementInfo.icon, storyName), ZONE_STORY_HEADER_COLOR)
    -- Chapter status
    GameTooltip_AddHighlightLine(tooltip, QUEST_STORY_STATUS:format(achievementInfo.numCompleted, achievementInfo.numCriteria))
    debug:AddDebugLineToTooltip(tooltip, {text=format("> A:%d \"%s\"", storyAchievementID, achievementInfo.name)})
    -- Chapter list
    if IsShiftKeyDown() then
        local wrapLine = false
        local criteriaName
        for i, criteriaInfo in ipairs(achievementInfo.criteriaList) do
            criteriaName = criteriaInfo.criteriaString
            -- debug:print("criteria:", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaID)
            if debug.showChapterIDsInTooltip then
                if (not criteriaInfo.assetID) or (criteriaInfo.assetID == 0) then
                    criteriaName = format("|cffcc1919%03d %d|r %s", criteriaInfo.criteriaType, criteriaInfo.criteriaID, criteriaInfo.criteriaString)
                else
                    criteriaName = format("|cff808080%03d %d|r %s", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaString)
                end
            end
            if criteriaInfo.completed then
                GameTooltip_AddColoredLine(tooltip, L.CHAPTER_NAME_FORMAT_COMPLETED:format(criteriaName), GREEN_FONT_COLOR, wrapLine)
            else
                GameTooltip_AddHighlightLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(criteriaName), wrapLine)
            end
        end
    else
        local textTemplate = (pin.pinTemplate == LocalUtils.QuestPinTemplate) and L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY or L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY_HOVER
        GameTooltip_AddInstructionLine(tooltip, textTemplate:format(GREEN(SHIFT_KEY)))
    end

    debug:print(self, format("> Found story with %d |4chapter:chapters;.", achievementInfo.numCriteria))
    return true
end

-- local function GetNumQuestLineQuests(questLineID)
--     local questList = C_QuestLine_GetQuestLineQuests(questLineID)
--     return #questList
-- end

----- Campaign ----------
--
-- REF.: <https://www.townlong-yak.com/framexml/live/ObjectAPI/CampaignChapter.lua>

local CampaignUtils = {}
CampaignUtils.debug = false
CampaignUtils.debug_prefix = "CP:"
CampaignUtils.wrap_chapterName = false
CampaignUtils.leftOffset_description = 16
CampaignUtils.GetCampaignInfo = function(self, campaignID)  -- Extend default results from `C_CampaignInfo.GetCampaignInfo`
    local campaignInfo = C_CampaignInfo.GetCampaignInfo(campaignID)
    if not campaignInfo then return end

    campaignInfo.campaignState = C_CampaignInfo.GetState(campaignID)  --> Enum.CampaignState
    campaignInfo.isComplete = campaignInfo.campaignState == Enum.CampaignState.Complete
    campaignInfo.chapterIDs = C_CampaignInfo.GetChapterIDs(campaignID)
    campaignInfo.currentChapterID = C_CampaignInfo.GetCurrentChapterID(campaignID)  --> This refers to the currently active quest campaign only (!)
    campaignInfo.numChaptersTotal = #campaignInfo.chapterIDs
    campaignInfo.numChaptersCompleted = 0
    for i, chapterID in ipairs(campaignInfo.chapterIDs) do
        local chapterIsComplete = C_QuestLine.IsComplete(chapterID)
        if chapterIsComplete then
            campaignInfo.numChaptersCompleted = campaignInfo.numChaptersCompleted + 1
        end
    end

    return campaignInfo
end

function CampaignUtils:AddCampaignDetailsTooltip(tooltip, pin, showHintOnly)
    local campaignID = C_CampaignInfo.GetCampaignID(pin.questID)
    local campaignInfo = self:GetCampaignInfo(campaignID)

    if not campaignInfo then return end

    -- Show quest line of current chapter
    if not pin.questInfo.hasQuestLineInfo and (campaignInfo.numChaptersTotal > 0) then
        LocalQuestLineUtils:AddQuestLineDetailsToTooltip(tooltip, pin, campaignInfo.currentChapterID)
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end

    -- Category name
    GameTooltip_AddColoredDoubleLine(tooltip, " ", TRACKER_HEADER_CAMPAIGN_QUESTS, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)

    -- -- Show hint that quest (line) is part of this campaign
    -- if DEV_MODE or showHintOnly then
    --     local hintTextFormat = pin.questInfo.hasQuestLineInfo and L.CAMPAIGN_TYPE_FORMAT_QUESTLINE or L.CAMPAIGN_TYPE_FORMAT_QUEST
    --     GameTooltip_AddNormalLine(tooltip, format(hintTextFormat, SCENARIO_STAGE_COLOR:WrapTextInColorCode(campaignInfo.name)))
    --     debug:AddDebugLineToTooltip(tooltip, {addBlankLine=debug.isActive})

    --     -- return
    -- end

    -- Campaign header - name + progress
    local campaignNameTemplate = campaignInfo.isComplete and L.CAMPAIGN_NAME_FORMAT_COMPLETE or L.CAMPAIGN_NAME_FORMAT_INCOMPLETE
    GameTooltip_AddColoredLine(tooltip,campaignNameTemplate:format(campaignInfo.name), CAMPAIGN_HEADER_COLOR)
    GameTooltip_AddNormalLine(tooltip, L.CAMPAIGN_PROGRESS_FORMAT:format(campaignInfo.numChaptersCompleted, campaignInfo.numChaptersTotal))
    debug:AddDebugLineToTooltip(tooltip, {text=format("> C:%d, state: %d, isWarCampaign: %d|n> > currentChapterID: %d", campaignID, campaignInfo.campaignState, campaignInfo.isWarCampaign, campaignInfo.currentChapterID)})
    -- Campaign chapters
    for i, chapterID in ipairs(campaignInfo.chapterIDs) do
        local chapterInfo = C_CampaignInfo.GetCampaignChapterInfo(chapterID)
        local chapterName = chapterInfo and chapterInfo.name or RED(RETRIEVING_DATA)
        local currentChapterID = pin.questInfo.hasQuestLineInfo and pin.questInfo.currentQuestLineID or campaignInfo.currentChapterID
        if debug.showChapterIDsInTooltip then chapterName = format("|cff808080%d|r %s", chapterID, chapterName) end
        if chapterInfo then
            local chapterIsComplete = C_QuestLine.IsComplete(chapterID)
            if chapterIsComplete then
                GameTooltip_AddColoredLine(tooltip, L.CHAPTER_NAME_FORMAT_COMPLETED:format(chapterName), GREEN_FONT_COLOR, self.wrap_chapterName)
            elseif (chapterID == currentChapterID) then
                GameTooltip_AddNormalLine(tooltip, L.CHAPTER_NAME_FORMAT_CURRENT:format(chapterName), self.wrap_chapterName)
            else
                GameTooltip_AddHighlightLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(chapterName), self.wrap_chapterName)
            end
            if DEV_MODE and not StringIsEmpty(chapterInfo.description) then     --> TODO - Needed ???
                GameTooltip_AddDisabledLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(chapterInfo.description), false, 16)
            end
        end
    end

    if DEV_MODE and not StringIsEmpty(campaignInfo.description) then
        -- Campaign description
        GameTooltip_AddDisabledLine(tooltip, QUEST_DESCRIPTION, false)
        GameTooltip_AddDisabledLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(campaignInfo.description), true)
        if campaignInfo.isWarCampaign then
            GameTooltip_AddDisabledLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(WAR_CAMPAIGN), false)
        end
    end
end

-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/WarCampaignDocumentation.lua>
-- C_CampaignInfo.GetAvailableCampaigns() : campaignIDs
-- C_CampaignInfo.UsesNormalQuestIcons(campaignID) : useNormalQuestIcons
-- C_CampaignInfo.GetFailureReason(campaignID) : failureReason

--------------------------------------------------------------------------------
----- Hooking Functions --------------------------------------------------------
--------------------------------------------------------------------------------

-- local function ShouldHookQuestPin(pin)
--     return tContains({LocalUtils.StorylineQuestPinTemplate, LocalUtils.QuestPinTemplate}, pin.pinTemplate)
-- end

-- local function ShouldHookWorldQuestPin(pin)
--     return pin.pinTemplate ~= WorldMap_WorldQuestDataProviderMixin:GetPinTemplate()
--     -- "BonusObjectivePinTemplate", "ThreatObjectivePinTemplate"
-- end

local function ShouldShowPluginName(pin)
    return (pin.questInfo.isReadyForTurnIn or pin.questType or IsShiftKeyDown()
            or pin.questInfo.hasQuestLineInfo or pin.questInfo.isCampaign
            or DEV_MODE)
end

-- REF.: <https://www.townlong-yak.com/framexml/live/SharedTooltipTemplates.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/GameTooltip.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/StorylineQuestDataProvider.lua>
--
local function Hook_StorylineQuestPin_OnEnter(pin)
    if not pin.questID then return end
    if (pin.pinTemplate ~= LocalUtils.StorylineQuestPinTemplate) then return end

    -- Extend quest meta data
    pin.mapID = pin.mapID or pin:GetMap():GetMapID()
    pin.isPreviousPin = pin.questInfo and pin.questInfo.questID == pin.questID
    if not pin.isPreviousPin then
        -- Only update (once) when hovering a different quest pin
        LocalUtils:AddQuestInfoToPin(pin)
    end

    local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
    -- Addon name
    if ShouldShowPluginName(pin) then
        local questTypeText = DEV_MODE and tostring(pin.questType) or " "
        GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR, nil, nil)
    end
    debug:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})

    if (pin.questType and ns.settings.showQuesType) then                        --> TODO - Enhance, eg. isBounty, etc.
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
        -- if not tContains({"Normal", "Legendary", "Trivial"}, pin.questType) then GameTooltip_AddBlankLineToTooltip(tooltip) end
    end

    -- debug:print("pin:", pin.mapID, pin:GetMap():GetMapID(), GetQuestUiMapID(pin.questID), YELLOW(pin.questType or "no-type"))
    if (DEV_MODE and IsShiftKeyDown() and IsControlKeyDown()) then
        LocalUtils:AddDebugQuestInfoLineToTooltip(tooltip, pin)
        GameTooltip:Show()
        return
    end
    if (pin.questInfo.hasZoneStoryInfo and ns.settings.showZoneStory) then      --> TODO - Optimize info retrieval to load only once (!)
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
        ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.hasQuestLineInfo and ns.settings.showQuestLine) then
        --> TODO - Optimize info retrieval to load only once (!)
        if pin.questInfo.hasZoneStoryInfo then GameTooltip_AddBlankLineToTooltip(tooltip) end
        LocalQuestLineUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.isCampaign and ns.settings.showCampaign) then
        GameTooltip_AddBlankLineToTooltip(tooltip)
        CampaignUtils:AddCampaignDetailsTooltip(tooltip, pin)
    end

    GameTooltip:Show()
end

-- local function HNQH_TaskPOI_OnEnter(pin, skipSetOwner)
--     -- REF.: <https://www.townlong-yak.com/framexml/live/WorldMapFrame.lua>
--     -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/BonusObjectiveDataProvider.lua>
--     if not pin.questID then return end
--     if not ShouldHookWorldQuestPin(pin) then return end

--     local tooltip = GameTooltip
--     -- GameTooltip_AddBlankLineToTooltip(tooltip)
--     GameTooltip_AddColoredDoubleLine(tooltip, " ", HandyNotesPlugin.name, NORMAL_FONT_COLOR, CATEGORY_NAME_COLOR, nil, nil)
--     if IsShiftKeyDown() then
--         GameTooltip_AddQuest(tooltip, pin.questID)
--     else
--         QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
--         GameTooltip_AddDisabledLine(tooltip, format("#%d - %s", pin.questID, pin.pinTemplate))
--     end
--     GameTooltip:Show()
-- end

local function Hook_ActiveQuestPin_OnEnter(pin)
    if not pin.questID then return end
    if (pin.pinTemplate ~= LocalUtils.QuestPinTemplate) then return end

    -- Extend quest meta data
    pin.mapID = pin.mapID or pin:GetMap():GetMapID()
    pin.isPreviousPin = pin.questInfo and pin.questInfo.questID == pin.questID
    debug:print(debug.hooks, "isPreviousPin:", pin.isPreviousPin, pin.questInfo and pin.questInfo.questID or "nil", pin.questID)
    if not pin.isPreviousPin then
        -- Only update (once) when hovering a different quest pin
        LocalUtils:AddQuestInfoToPin(pin)
    end

    local tooltip = GameTooltip
    -- Addon name
    if ShouldShowPluginName(pin) then
        local questTypeText = DEV_MODE and tostring(pin.questType) or " "
        GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR, nil, nil)
    end
    debug:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})

    if (pin.questType and ns.settings.showQuesType) then                        --> TODO - Enhance, eg. isBounty, etc.
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
    end
    if pin.questInfo.isReadyForTurnIn then
        -- if tContains({"Normal", "Legendary", "Trivial"}, pin.questType) then GameTooltip_AddBlankLineToTooltip(tooltip) end
        tooltip:AddLine(QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN)
    end
    if (DEV_MODE and IsShiftKeyDown() and IsControlKeyDown()) then
        LocalUtils:AddDebugQuestInfoLineToTooltip(tooltip, pin)
        GameTooltip:Show()
        return
    end
    if (pin.questInfo.hasZoneStoryInfo and ns.settings.showZoneStory) then      --> TODO - Optimize info retrieval to load only once (!)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.hasQuestLineInfo and ns.settings.showQuestLine) then
        if pin.questInfo.hasZoneStoryInfo then GameTooltip_AddBlankLineToTooltip(tooltip) end
        LocalQuestLineUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.isCampaign and ns.settings.showCampaign) then             --> TODO - Optimize info retrieval to load only once (!)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        CampaignUtils:AddCampaignDetailsTooltip(tooltip, pin)
    end

    GameTooltip:Show()
end

local function Hook_OnClick(pin, mouseButton)
    if IsAltKeyDown() then
        debug:print("Alt-Clicked:", pin.questID, pin.pinTemplate, mouseButton)    --> works, but only with "LeftButton" (!)
    end
end

-- -- REF.: <https://www.townlong-yak.com/framexml/live/CallbackRegistry.lua><br>
-- -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_PTRFeedback/Blizzard_PTRFeedback_Tooltips.lua>
-- --
-- local function HookIntoQuestTooltip(sender, self, questID, isGroup)
--     local title = C_QuestLog.GetTitleForQuestID(questID)
--     if (isGroup ~= null and not isGroup) then
--         --If isGroup is null, that means the event always shows tooltip
--         --If isGroup is a bool, it only shows a tooltip if true, so when false we must provide our own
--         GameTooltip:ClearAllPoints()
--         GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
--         GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
--         PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title, true)
--         GameTooltip:Show()
--     else
--         PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title)
--     end
-- end

function HandyNotesPlugin:OnProfileChanged(event, ...)
    -- REF.: <https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0>
    debug:print(debug.hooks, event, ...)

    if (event == "OnProfileReset") then
        -- local database = ...
        local noChildren, noCallbacks = nil, true
        self.db:ResetProfile(noChildren, noCallbacks)
    end

    if (event == "OnProfileDeleted") then
        -- local database = ...
        -- local noChildren, noCallbacks = nil, true
        -- self.db:ResetProfile(noChildren, noCallbacks)
        print(event, ...)
    end

    -- Note: The database given to the event handler is the one that changed,
    -- ie. HandyNotes.db (do NOT use!)
    if (event == "OnProfileCopied") then
        local database, newProfileKey = ...
        local silent = true
        self.db:CopyProfile(newProfileKey, silent)
    end
    if (event == "OnProfileChanged") then
        local database, newProfileKey = ...
        self.db:SetProfile(newProfileKey)
    end
    ns.settings = self.db.profile
    self:Print(HandyNotes.name, "profile change adapted.")

    --> TODO - L10n
    -- REF.: <https://www.wowace.com/projects/ace3/localization>
end

function HandyNotesPlugin:OnHandyNotesStateChanged()
    -- print("state:", HandyNotes:IsEnabled(), self:IsEnabled(), HandyNotesPlugin:IsEnabled())
    local parent_state = HandyNotes:IsEnabled()
    if (parent_state ~= self:IsEnabled()) then
        -- Toogle this plugin
        if parent_state then self:OnEnable() else self:OnDisable() end
        self:SetEnabledState(parent_state)
    end
    -- print("state:", HandyNotes:IsEnabled(), self:IsEnabled(), HandyNotesPlugin:IsEnabled())
end

function HandyNotesPlugin:RegisterHooks()
    -- Active Quests
    debug:print(debug.hooks, "Hooking active quests...")
    hooksecurefunc(QuestPinMixin, "OnMouseEnter", Hook_ActiveQuestPin_OnEnter)
    hooksecurefunc(QuestPinMixin, "OnClick", Hook_OnClick)

    -- Storyline Quests
    debug:print(debug.hooks, "Hooking storyline quests...")
    hooksecurefunc(StorylineQuestPinMixin, "OnMouseEnter", Hook_StorylineQuestPin_OnEnter)
    hooksecurefunc(StorylineQuestPinMixin, "OnClick", Hook_OnClick)

    -- Bonus Objectives
    -- if _G["TaskPOI_OnEnter"] then
    --     -- hooksecurefunc("TaskPOI_OnEnter", HNQH_TaskPOI_OnEnter)
    --     if not self:IsHooked(nil, "TaskPOI_OnEnter") then
    --         self:SecureHook(nil, "TaskPOI_OnEnter", HNQH_TaskPOI_OnEnter)
    --     end
    -- end

    -- HandyNotes Hooks
    --> Callback types: <https://www.wowace.com/projects/ace3/pages/ace-db-3-0-tutorial#title-5>
    HandyNotes.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    HandyNotes.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    HandyNotes.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    HandyNotes.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
    hooksecurefunc(HandyNotes, "OnEnable", self.OnHandyNotesStateChanged)
    hooksecurefunc(HandyNotes, "OnDisable", self.OnHandyNotesStateChanged)
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
    -- debug:print("HN args -->", state, value)
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
-- REF.: <World of Warcraft\_retail_\Interface\AddOns\HandyNotes\HandyNotes.lua><br>
-- REF.: <FrameXML/Blizzard_SharedMapDataProviders/QuestDataProvider.lua>
--
function HandyNotesPlugin:GetNodes2(uiMapID, minimap)
    ns.uiMapID = uiMapID
    if minimap then return PointsDataIterator end  -- minimap lis currently not used
    debug:print(GRAY("GetNodes2"), "> uiMapID:", uiMapID, "minimap:", minimap)

    if WorldMapFrame then
        -- print(GRAY("GetNodes2"), "> uiMapID:", uiMapID, "minimap:", minimap)
        local isWorldMapShown = WorldMapFrame:IsShown()
        local mapID = uiMapID or WorldMapFrame:GetMapID()
        local mapInfo = C_Map.GetMapInfo(mapID)
        -- Tests
        if (isWorldMapShown and mapInfo.mapType == Enum.UIMapType.Zone) then
            -- Update data cache for current zone
            ZoneStoryCache:GetZoneStoryInfo(mapID, true)
            LocalQuestLineUtils:GetAvailableQuestLines(mapID, true)
        end
        -- local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
        -- -- local doesMapShowTaskObjectives = C_TaskQuest.DoesMapShowTaskQuestObjectives(mapID)
        -- -- print("doesMapShowTaskObjectives:", doesMapShowTaskObjectives, "questsOnMap:", #questsOnMap)
        -- print("questsOnMap:", #questsOnMap)
        return PointsDataIterator, isWorldMapShown, mapID
    end
    return PointsDataIterator
end

--@do-not-package@
--------------------------------------------------------------------------------
--[[ Tests
--------------------------------------------------------------------------------

GetQuestLink(questID)

C_QuestLog.GetQuestDifficultyLevel(questID)  --> 60
C_QuestLog.GetQuestTagInfo(questID)  --> QuestTagInfo table
C_QuestLog.GetQuestType(questID)  --> Enum.QuestTag

-- local percent = math.floor((numFulfilled/numRequired) * 100);                --> TODO - Add progress percentage ???
-- GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));

C_QuestLog.GetQuestsOnMap(uiMapID) : quests

C_QuestLog.GetNextWaypoint(questID)  --> mapID, x, y
C_QuestLog.GetNextWaypointForMap(questID, uiMapID)  --> x, y
C_QuestLog.GetNextWaypointText(questID)  --> waypointText

-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_DebugTools/Blizzard_DebugTools.lua>
function FrameStackTooltip_OnDisplaySizeChanged(self)
	local height = GetScreenHeight();
	if (height > 768) then
		self:SetScale(768/height);
	else
		self:SetScale(1);
	end
end

C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)

local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID);

STORY_CHAPTERS = "%d/%d Kapitel";

]]
--@end-do-not-package@