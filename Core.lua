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

local loadSilent = true
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", loadSilent)
if not HandyNotes then return end

local format, tostring, strlen, strtrim, string_gsub = string.format, tostring, strlen, strtrim, string.gsub
local tContains, tInsert, tAppendAll = tContains, table.insert, tAppendAll

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
local ORANGE = function(txt) return ORANGE_FONT_COLOR:WrapTextInColorCode(txt) end
local BLUE = function(txt) return BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(txt) end  -- PURE_BLUE_COLOR, LIGHTBLUE_FONT_COLOR 

local function StringIsEmpty(str)
	return str == nil or strlen(str) == 0
end

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
L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY = "Hold %s to see details"
L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY_HOVER = "Hold %s and hover icon to see details"

L.QUESTLINE_NAME_FORMAT = "|TInterface\\Icons\\INV_Misc_Book_07:16:16:0:-1|t %s"
L.QUESTLINE_CHAPTER_NAME_FORMAT = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a %s"
-- L.QUESTLINE_PROGRESS_FORMAT = MAJOR_FACTION_RENOWN_CURRENT_PROGRESS
L.QUESTLINE_PROGRESS_FORMAT = string_gsub(QUEST_LOG_COUNT_TEMPLATE, "%%s", "|cffffffff")

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

-- GENERIC_FRACTION_STRING = "%d/%d";
-- MAJOR_FACTION_RENOWN_CURRENT_PROGRESS = "Aktueller Fortschritt: |cffffffff%d/%d|r";
-- QUEST_LOG_COUNT_TEMPLATE = "Quests: %s%d|r|cffffffff/%d|r";

-- Custom strings
L.SLASHCMD_USAGE = "Usage:"

-- "achievementcompare-GreenCheckmark"
-- "achievementcompare-YellowCheckmark"

-- local LibDD = LibStub:GetLibrary('LibUIDropDownMenu-4.0')

local CHECKMARK_ICON_STRING = "|A:achievementcompare-YellowCheckmark:0:0|a"

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

local CampaignUtils =       { debug = false, debug_prefix = "CP:" }
-- local DBUtil =              { debug = false, debug_prefix = GREEN("DB:") }
local LocalQuestCache =     { debug = false, debug_prefix = ORANGE("Quest-CACHE:") }
local LocalQuestUtils =     { debug = false, debug_prefix = ORANGE("QuestUtils:") }
local LocalQuestLineUtils = { debug = false, debug_prefix = "QL:" }
local ZoneStoryUtils =      { debug = false, debug_prefix = "ZS:" }
local QuestFilterUtils =    { debug = false, debug_prefix = "QFilter:" }
local LocalUtils = {}

--> TODO: CampaignCache, QuestCache

-- In debug mode show additional infos in a quest icon's tooltip, eg. questIDs,
-- achievementIDs, etc.
function debug:AddDebugLineToTooltip(tooltip, debugInfo)
    local text = debugInfo and debugInfo.text
    local addBlankLine = debugInfo and debugInfo.addBlankLine
    if DEV_MODE then
        if text then GameTooltip_AddDisabledLine(tooltip, text, false) end
        if addBlankLine then GameTooltip_AddBlankLineToTooltip(tooltip) end
    end
end

-- In debug mode show additional quest data.
function debug:AddDebugQuestInfoLineToTooltip(tooltip, pin)
    GameTooltip_AddBlankLineToTooltip(tooltip)
    pin.questInfo.pinMapID = GRAY(tostring(pin.mapID))
    local leftHandColor, rightHandColor
    for k, v in pairs(pin.questInfo) do
        leftHandColor = (v == true) and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
        rightHandColor = (v == true) and GREEN_FONT_COLOR or NORMAL_FONT_COLOR
        GameTooltip_AddColoredDoubleLine(tooltip, k, tostring(v), leftHandColor, rightHandColor)
    end
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

    QuestFilterUtils:Init()

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

-- function DBUtil:CheckInitCategory(categoryName)
--     if not ns.data[categoryName] then
--         ns.data[categoryName] = {}
--         debug:print(self, "Initialized DB:", categoryName)
--     end
-- end

-- -- Save each questline with its questIDs and mapIDs.
-- --> { [questLineID] = {mapIDs={mapID1, mapID2, ...}, quests={questID1, questID2, ...}}, ... }
-- ---@param questLineInfo QuestLineInfo
-- ---@param mapID number
-- ---@param questIDs number[]?
-- --
-- function DBUtil:SaveSingleQuestLine(questLineInfo, mapID, questIDs)
--     if not ns.data.questLines[questLineInfo.questLineID] then
--         ns.data.questLines[questLineInfo.questLineID] = {
--             -- questID = questLineInfo.questID,
--             mapIDs = {mapID},
--             quests = questIDs,
--         }
--         debug:print(self, format("%d Saved QL: %s", questLineInfo.questLineID, questLineInfo.questLineName))
--         return
--     end
--     if not tContains(ns.data.questLines[questLineInfo.questLineID].mapIDs, mapID) then
--         tInsert(ns.data.questLines[questLineInfo.questLineID].mapIDs, mapID)
--         debug:print(self, format("%d Updated QL with map %d", questLineInfo.questLineID, mapID))
--     end
-- end

-- function DBUtil:GetSavedQuestLineQuests(questLineID)
--     return ns.data.questLines[questLineID] and ns.data.questLines[questLineID].quests
-- end

----- Tooltip Data Handler ----------


local function GetCollapseTypeModifier(isComplete, varName)
    local types = {
        auto = (not isComplete) or IsShiftKeyDown(),
        hide = IsShiftKeyDown(),
        -- hide = false,
        show = true,
    }
    return types[ns.settings[varName]]
end

----- Zone Story ----------

ZoneStoryUtils.storiesOnMap = {}  --> { [mapID] = {storyAchievementID, storyMapInfo}, ... }
ZoneStoryUtils.achievements = {}  --> { [achievementID] = achievementInfo, ... }

function ZoneStoryUtils:GetZoneStoryInfo(mapID, prepareCache)
    if not self.storiesOnMap[mapID] then
        local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID)
        if not storyAchievementID then return end

        local mapInfo = LocalUtils:GetMapInfo(storyMapID or mapID)
        self.storiesOnMap[mapID] = {storyAchievementID, mapInfo}
        debug:print(self, "Added zone story:", storyAchievementID, storyMapID, mapInfo.name)
    end
    if not prepareCache then
        return SafeUnpack(self.storiesOnMap[mapID])
    end
end

function ZoneStoryUtils:HasZoneStoryInfo(mapID)
    return self.storiesOnMap[mapID] ~= nil
end

function ZoneStoryUtils:GetAchievementInfo(achievementID)
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

        -- Fix achievementInfo.completed - In some areas eg. Azshara it shows completed although it's not.
        achievementInfo.completed = (achievementInfo.numCompleted == achievementInfo.numCriteria)

        self.achievements[achievementID] = achievementInfo
        debug:print(self, "> Added achievementInfo:", achievementID, achievementInfo.name)
    end

    return self.achievements[achievementID]
end

function ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    debug:print(self, format(YELLOW("Scanning zone (%s) for stories..."), pin.mapID or "n/a"))

    local storyAchievementID, storyMapInfo = self:GetZoneStoryInfo(pin.mapID)
    if not storyAchievementID then
        debug:print(self, "> Nothing found.")
        return false
    end

    local achievementInfo = self:GetAchievementInfo(storyAchievementID)

    -- Category name
    if ns.settings.showCategoryNames then
        GameTooltip_AddColoredDoubleLine(tooltip, " ", ZONE, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)
    end

    -- Zone story name
    local storyNameTemplate = achievementInfo.completed and L.STORY_NAME_FORMAT_COMPLETE or L.STORY_NAME_FORMAT_INCOMPLETE
    local storyName = storyMapInfo and storyMapInfo.name or achievementInfo.name
    GameTooltip_AddColoredLine(tooltip, storyNameTemplate:format(achievementInfo.icon, storyName), ZONE_STORY_HEADER_COLOR)

    -- Chapter status
    GameTooltip_AddHighlightLine(tooltip, QUEST_STORY_STATUS:format(achievementInfo.numCompleted, achievementInfo.numCriteria))
    debug:AddDebugLineToTooltip(tooltip, {text=format("> A:%d \"%s\"", storyAchievementID, achievementInfo.name)})

    -- Chapter list
    if GetCollapseTypeModifier(achievementInfo.completed, "collapseType_zonestory") then
        local wrapLine = false
        local criteriaName
        for i, criteriaInfo in ipairs(achievementInfo.criteriaList) do
            criteriaName = criteriaInfo.criteriaString
            if debug.showChapterIDsInTooltip then
                if (not criteriaInfo.assetID) or (criteriaInfo.assetID == 0) then
                    criteriaName = format("|cffcc1919%03d %05d|r %s", criteriaInfo.criteriaType, criteriaInfo.criteriaID, criteriaInfo.criteriaString)
                else
                    criteriaName = format("|cff808080%03d %05d|r %s", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaString)
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

    debug:print(self, format("Found story with %d |4chapter:chapters;.", achievementInfo.numCriteria))
    return true
end

--------------------------------------------------------------------------------
----- Quest Filter Handler -----------------------------------------------------
--------------------------------------------------------------------------------

function QuestFilterUtils:Init()
    for i, weeklyQuestLineID in ipairs(self.weeklyQuestLines) do
        local weeklyQuestIDs = LocalQuestCache:GetQuestLineQuests(weeklyQuestLineID)
        tAppendAll(self.weeklyQuests, weeklyQuestIDs)
    end
    for i, dailyQuestLineID in ipairs(self.dailyQuestLines) do
        local dailyQuestIDs = LocalQuestCache:GetQuestLineQuests(dailyQuestLineID)
        tAppendAll(self.dailyQuests, dailyQuestIDs)
    end
    debug:print(self, "Filter data have been prepared")
end

-- All quests in this table are weekly quests of different questlines.
QuestFilterUtils.weeklyQuests = {
    70750, 72068, 72373, 72374, 72375, 75259, 75859, 75860, 75861, 77254,  -- Dragonflight, "Aiding the Accord" quests
    66042,  -- Shadowlands, Zereth Mortis, "Patterns Within Patterns"
    63949,  -- Shadowlands, Korthia, "Shaping Fate"
    61332, 62861, 62862, 62863, -- Shadowlands, Covenant Sanctum (Kyrian), "Return Lost Souls" quests
    61982, -- Shadowlands (Kyrian), "Replenish the Reservoir"
    57301, -- Shadowlands, Maldraxxus, "Callous Concoctions"
}

-- All quests of these questlines are weekly quests.
QuestFilterUtils.weeklyQuestLines = {
    1416,  -- Dragonflight, "Bonus Event Holiday Quests"
}

-- All quests in this table are daily quests of different questlines.
QuestFilterUtils.dailyQuests = {
    59826, 59827, 59828, -- Shadowlands, Maldraxxus, "Bet On Yourself"
}

-- All quests of these questlines are daily quests or daily single quest questlines.
QuestFilterUtils.dailyQuestLines = {
    971,  -- Battle for Azeroth, Mechagon, "Visit from Archivist Bitbyte"
    974,  -- Battle for Azeroth, Mechagon, "Visit from Tortollans"
}

-- All quests in this table have been marked obsolete by Blizzard and cannot be
-- obtained or completed.
QuestFilterUtils.obsoleteQuests = {
    62699, -- Shadowlands, Covenant Sanctum (Kyrian)
}

----- Player Race ----------

-- local playerRaceName, raceFileName, playerRaceID = UnitRace("player")
local playerRaceID = select(3, UnitRace("player"))

-- All quests in this table are bound to a specific player race.
-- REF.: <https://wowpedia.fandom.com/wiki/RaceId>
local raceQuests = {
    ["8325"] = {10},  -- Eastern Kingdoms, Sunstrider Isle, "Reclaiming Sunstrider Isle" (Horde)
    ["8326"] = {10},  -- Eastern Kingdoms, Sunstrider Isle, "Unfortunate Measures" (Horde)
    ["8334"] = {10},  -- Eastern Kingdoms, Sunstrider Isle, "Aggression" (Horde)
    ["8335"] = {10},  -- Eastern Kingdoms, Sunstrider Isle, "Felendren the Banished" (Horde)
    ["8347"] = {10},  -- Eastern Kingdoms, Sunstrider Isle, "Aiding the Outrunners" (Horde)
    ["9327"] = {10},  -- Eastern Kingdoms, Ghostlands, "The Forsaken"
    ["28202"] = {3, 29, 34},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Alliance)
    ["28204"] = {7, 9},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Alliance)
    ["28205"] = {4},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Alliance)
    ["28428"] = {2, 5, 36},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Horde)
    ["28429"] = {6, 24, 25, 26, 28},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Horde)
    ["28430"] = {9, 35},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Horde)
    ["28431"] = {8, 10, 27},  -- Eastern Kingdoms, Burning Steppes, "A Perfect Costume" (Horde)
}

-- Quests which are not bound to a specific player race are considered playable.
function QuestFilterUtils:ShouldShowRaceQuest(questID)
    local questIDstring = tostring(questID)
    if not raceQuests[questIDstring] then return true end

    return tContains(raceQuests[questIDstring], playerRaceID)
end

----- Player Class ----------

-- local playerClassName, classFilename, playerClassID = UnitClass("player")
local playerClassID = select(3, UnitClass("player"))

-- All quests in this table are specific to aka player class.
-- REF.: <https://wowpedia.fandom.com/wiki/ClassId>
local classQuests = {
    ["54058"] = {5},  -- Battle for Azeroth, Crucible of Storms, "Unintended Consequences" (Neutral)
    ["54118"] = {5},  -- Battle for Azeroth, Crucible of Storms, "Every Little Death Helps" (Horde)
    ["54433"] = {5},  -- Battle for Azeroth, Crucible of Storms, "Orders from Azshara" (Horde)
}

-- Quests which are not bound to a specific player class are considered playable.
function QuestFilterUtils:ShouldShowClassQuest(questID)
    local questIDstring = tostring(questID)
    if not classQuests[questIDstring] then return true end

    return tContains(classQuests[questIDstring], playerClassID)
end

----- Faction Groups ----------

local playerFactionGroup = UnitFactionGroup("player")

-- Quest faction groups: {Alliance=1, Horde=2, Neutral=3}
local QuestFactionGroupID = EnumUtil.MakeEnum(PLAYER_FACTION_GROUP[1], PLAYER_FACTION_GROUP[0], "Neutral")

-----

-- Quests are either for a specific faction group, quest type, phase, etc. Try to match those.
---@param questInfo table
---@return boolean
--
function QuestFilterUtils:PlayerMatchesQuestRequirements(questInfo)
    if questInfo.isObsolete then
        debug:print(self, "Skipping OBSOLETE quest:", questInfo.questID)
        return false
    end
    if not self:ShouldShowRaceQuest(questInfo.questID) then
        debug:print(self, "Skipping RACE quest:", questInfo.questID)
        return false
    end
    if not self:ShouldShowClassQuest(questInfo.questID) then
        debug:print(self, "Skipping CLASS quest:", questInfo.questID)
        return false
    end

    -- Filter quest by faction group (1 == Alliance, 2 == Horde, [3 == Neutral])
    local isFactionGroupMatch = tContains({QuestFactionGroupID[playerFactionGroup], QuestFactionGroupID.Neutral}, questInfo.questFactionGroup)
    return isFactionGroupMatch
end

--> TODO - Add more filter types
    -- eg. quests which are optional (?), different class, phase (?), weekly, daily, etc.
--> TODO - Check quest giver quests
--> TODO - Check quest types: warfront (?), WorldQuests (!, QL-940) 
    -- [quest=53955]  -- "Warfront: The Battle for Darkshore" (???)
--> TODO - Add filter for wrong factionGroup quests
    -- [quest=54114]  -- Battle for Azeroth, Crucible of Storms, "Every Little Death Helps" (Alliance, not Neutral)

----- Faction Group Labels ----------

local QuestNameFactionGroupFormat = {
    [QuestFactionGroupID.Alliance] = L.QUEST_NAME_FORMAT_ALLIANCE,
    [QuestFactionGroupID.Horde] = L.QUEST_NAME_FORMAT_HORDE,
    [QuestFactionGroupID.Neutral] = L.QUEST_NAME_FORMAT_NEUTRAL,
}

-- DAILY = "Täglich";
-- WEEKLY = "Wöchentlich";
-- PARENS_TEMPLATE = "(%s)";
-- NORMAL_QUEST_DISPLAY = "|cff000000%s|r";
-- IGNORED_QUEST_DISPLAY = "|cff000000%s (ignoriert)|r";
-- TRIVIAL_QUEST_DISPLAY = "|cff000000%s (niedrigstufig)|r";
-- OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = "(Optional) %s";

local function FormatQuestName(questInfo)
    local questTitle = QuestNameFactionGroupFormat[questInfo.questFactionGroup]:format(questInfo.questName)

    if not StringIsEmpty(questInfo.questName) then
        if questInfo.isDaily then
            questTitle = BLUE(PARENS_TEMPLATE:format(DAILY))..ITEM_NAME_DESCRIPTION_DELIMITER..questTitle
        end
        if questInfo.isWeekly then
            questTitle = BLUE(PARENS_TEMPLATE:format(WEEKLY))..ITEM_NAME_DESCRIPTION_DELIMITER..questTitle
        end
        if debug.showChapterIDsInTooltip then
            local colorCodeString = questInfo.questType == 0 and GRAY_FONT_COLOR_CODE or LIGHTBLUE_FONT_COLOR_CODE
            questTitle = format(colorCodeString.."%02d %05d|r %s", questInfo.questType, questInfo.questID, questTitle)
        end
    else
        debug:print("Empty:", questInfo.questID, tostring(questTitle), tostring(questInfo.questName))
        questTitle = RETRIEVING_DATA
        if debug.isActive then
            questTitle = format("> isDisabled: %s, questFactionGroup: %s, questExpansionID: %d", tostring(questInfo.isDisabledForSession), tostring(questInfo.questFactionGroup), questInfo.questExpansionID)
        end
        if debug.showChapterIDsInTooltip then
            local colorCodeString = questInfo.questType == 0 and GRAY_FONT_COLOR_CODE or LIGHTBLUE_FONT_COLOR_CODE
            questTitle = format(colorCodeString.."%02d %05d|r %s", questInfo.questType, questInfo.questID, questTitle)
        end
    end

    return questTitle
end

----- Quest Handler ----------

LocalQuestUtils.cache = {}

LocalQuestUtils.GetQuestName = function(self, questID)
    -- REF.: <https://www.townlong-yak.com/framexml/live/QuestUtils.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
	if not HaveQuestData(questID) then
		C_QuestLog.RequestLoadQuestByID(questID)
	end

    return QuestUtils_GetQuestName(questID)   -- QuestCache:Get(questID).title
end

function LocalQuestUtils:IsDaily(questID)
    local questInfo = QuestCache:Get(questID)
    if (questInfo and questInfo.frequency) then
        return questInfo.frequency == Enum.QuestFrequency.Daily
    end

    return tContains(QuestFilterUtils.dailyQuests, questID)
end

function LocalQuestUtils:IsWeekly(questID)
    local gameQuestInfo = QuestCache:Get(questID)
    if (gameQuestInfo and gameQuestInfo.frequency) then
        return gameQuestInfo.frequency == Enum.QuestFrequency.Weekly
    end

    return tContains(QuestFilterUtils.weeklyQuests, questID)
end

-- Some quests which are still in the game have been marked obsolete by Blizzard
-- and cannot be obtained or completed.
-- **Note:** This is not a foolproof solution, but seems to work so far.
function LocalQuestUtils:IsObsolete(questID)
    if tContains(QuestFilterUtils.obsoleteQuests, questID) then
        -- Prioritize manually verified questIDs
        return true
    end
    if (GetQuestExpansion(questID) < 0) then
        return true
    end
    -- if not HaveQuestData(questID) and (QuestCache.objects[questID] == nil or StringIsEmpty(QuestCache.objects[questID].title)) then
    if not HaveQuestData(questID) and (QuestCache.objects[questID] == nil) then
        return true
    end

    return false
end

-- Some quest are specified as Neutral, but are Alliance or Horde quests instead.
function LocalQuestUtils:GetQuestFactionGroup(questID)
    local questFactionGroup = GetQuestFactionGroup(questID) or QuestFactionGroupID.Neutral
    return questFactionGroup
end

-- Retrieve different quest details.
--
function LocalQuestUtils:GetQuestInfo(questID, targetType, pinMapID)
    local questName = self:GetQuestName(questID)
    if (targetType == "questline") then
        -- local nilCount = 0
        -- if StringIsEmpty(questName) then
        --     questName, nilCount = self:CheckNilQuest(questID)
        -- end
        -- if self.cache[questID] then
        --     return self.cache[questID]
        -- end
        local questInfo = {
            isAccountQuest = C_QuestLog.IsAccountQuest(questID),
            isBounty = C_QuestLog.IsQuestBounty(questID),
            isBreadcrumbQuest = IsBreadcrumbQuest(questID),
            isCalling = C_QuestLog.IsQuestCalling(questID),
            isCampaign = C_CampaignInfo.IsCampaignQuest(questID),
            isComplete = C_QuestLog.IsComplete(questID),
            isDaily = self:IsDaily(questID),
            isDisabledForSession = C_QuestLog.IsQuestDisabledForSession(questID),
            isFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID),
            isInvasion = C_QuestLog.IsQuestInvasion(questID),
            isLegendary = C_QuestLog.IsLegendaryQuest(questID),
            isObsolete = self:IsObsolete(questID),
            isRepeatable = C_QuestLog.IsRepeatableQuest(questID),
            isReplayable = C_QuestLog.IsQuestReplayable(questID),
            isSequenced = IsQuestSequenced(questID),
            isStory = IsStoryQuest(questID),
            isThreat = C_QuestLog.IsThreatQuest(questID),
            isTrivial = C_QuestLog.IsQuestTrivial(questID),
            isWeekly = self:IsWeekly(questID),
            questDifficulty = C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID),  --> Enum.RelativeContentDifficulty
            questExpansionID = GetQuestExpansion(questID),
            questFactionGroup = self:GetQuestFactionGroup(questID),
            questID = questID,
            questMapID = GetQuestUiMapID(questID),
            questName = questName,
            questType = C_QuestLog.GetQuestType(questID),
        }
        -- if not (StringIsEmpty(questName) and self.cache[questID]) then
        --     -- Should not be cached w/o a name
        --     self.cache[questID] = questInfo
        -- end

        return questInfo
    end

    if (targetType == "pin") then
        local questInfo = {
            hasPOIInfo = QuestHasPOIInfo(questID),  -- QuestPOIGetIconInfo(questID)
            isAccountQuest = C_QuestLog.IsAccountQuest(questID),
            isBounty = C_QuestLog.IsQuestBounty(questID),
            isBreadcrumbQuest = IsBreadcrumbQuest(questID),
            isCalling = C_QuestLog.IsQuestCalling(questID),
            isCampaign = C_CampaignInfo.IsCampaignQuest(questID),
            isComplete = C_QuestLog.IsComplete(questID),
            isDaily = self:IsDaily(questID),
            isDisabledForSession = C_QuestLog.IsQuestDisabledForSession(questID),
            isFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID),
            isInvasion = C_QuestLog.IsQuestInvasion(questID),
            isLegendary = C_QuestLog.IsLegendaryQuest(questID),
            -- isObsolete = self:IsObsolete(questID),
            isReadyForTurnIn = C_QuestLog.ReadyForTurnIn(questID),
            isRepeatable = C_QuestLog.IsRepeatableQuest(questID),
            isReplayable = C_QuestLog.IsQuestReplayable(questID),
            isReplayedRecently = C_QuestLog.IsQuestReplayedRecently(questID),
            isSequenced = IsQuestSequenced(questID),
            isStory = IsStoryQuest(questID),
            isTask = C_QuestLog.IsQuestTask(questID),
            isThreat = C_QuestLog.IsThreatQuest(questID),
            isTrivial = C_QuestLog.IsQuestTrivial(questID),
            isWeekly = self:IsWeekly(questID),
            isWorldQuest = C_QuestLog.IsWorldQuest(questID),
            questDifficulty = C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID),  --> Enum.RelativeContentDifficulty
            questExpansionID = GetQuestExpansion(questID),
            questFactionGroup = self:GetQuestFactionGroup(questID),
            questID = questID,
            questMapID = GetQuestUiMapID(questID),
            questName = questName,
            questType = C_QuestLog.GetQuestType(questID),
            -- Test
            questTagInfo = C_QuestLog.GetQuestTagInfo(questID),
            questWatchType = C_QuestLog.GetQuestWatchType(questID),
            isFailed = C_QuestLog.IsFailed(questID),
            isOnQuest = C_QuestLog.IsOnQuest(questID),
            canHaveWarBonus = C_QuestLog.QuestCanHaveWarModeBonus(questID),
            hasWarBonus = C_QuestLog.QuestHasWarModeBonus(questID),
            -- C_QuestLog.IsOnMap(questID) : onMap, hasLocalPOI
        }

        questInfo.activeMapID = ns.activeZoneMapInfo.mapID  --> The ID of the map the user is currently looking at
        questInfo.isActiveMap = (questInfo.activeMapID == pinMapID)
        questInfo.isQuestMap = (questInfo.questMapID == pinMapID)
        local zoneStoryMapID = questInfo.questMapID > 0 and questInfo.questMapID or pinMapID
        questInfo.hasZoneStoryInfo = ZoneStoryUtils:HasZoneStoryInfo(zoneStoryMapID)
        questInfo.hasQuestLineInfo = LocalQuestLineUtils:HasQuestLineInfo(questID, questInfo.activeMapID)

        return questInfo
    end
end

-- -- Retrieve different (mostly cached) quest details.
-- --
-- LocalQuestUtils.GetQuestInfo = function(self, questID, targetType)
--     ---@class QuestInfo
--     local questInfo = QuestCache:Get(questID)
--     if (targetType == "questline") then
--         local questName = self:GetQuestName(questID)
--         local nilCount = 0
--         if StringIsEmpty(questName) then
--             questName, nilCount = LocalQuestUtils:CheckNilQuest(questID)
--         end

--         return questInfo
--     end
-- end

-- function Test_QuestInfo(questID)
--     local questInfo = LocalQuestUtils:GetQuestInfo(questID, "questline")
--     local info = {}
--     for k, v in pairs(questInfo) do
--         if v then info[k] = v end
--     end
--     return info
-- end

-- function Test_QuestCache(questID)
--     local questInfo = QuestCache:Get(questID)
--     local info = {}
--     for k, v in pairs(questInfo) do
--         if v then info[k] = v end
--     end
--     return info
--     -- for k, v in pairs(QuestCache.objects[74869]) do
--     --     -- if v then info[k] = v end
--     --     print(k, "-->", type(v) == "function" and v() or v)
--     -- end
-- end

-- -- Some quests have been removed from the game but still appear as part of 
-- -- questlines. Save this quests and count how many times is hasn't been found.
-- -- Sometimes the quest data takes some time to be retrieved. If we get data,
-- -- remove quest from this list.
-- ---@param questID number
-- ---@return string questName
-- ---@return number? nilCount
-- --
-- function LocalQuestUtils:CheckNilQuest(questID)
--     DBUtil:CheckInitCategory("nilQuests")
--     if not ns.data.nilQuests[questID] then
--         ns.data.nilQuests[questID] = 0
--         debug:print(self, "nilQuest:", questID, "Added to DB")
--     end

--     local nilCount = ns.data.nilQuests[questID]
--     if (nilCount == -1) then
--         -- Quest will be removed from the game.
--         --> This has been verified manually by checking online databases.
--         debug:print(self, "nilQuest:", questID, "Removed from game")
--         return '', -1
--     end

--     local questName = self:GetQuestName(questID)
--     if not StringIsEmpty(questName) then
--         -- Got data, can be removed
--         ns.data.nilQuests[questID] = nil
--         debug:print(self, "nilQuest:", questID, questName, "Removed from DB")
--         return questName
--     else
--         ns.data.nilQuests[questID] = nilCount + 1
--         nilCount = ns.data.nilQuests[questID]
--         debug:print(self, "nilQuest:", questID, nilCount, "Updated counter")
--     end

--     return questName, nilCount
-- end


LocalQuestCache.questLineQuests = {}  --> { [questLineID] = {questID1, questID2, ...}, ... }

function LocalQuestCache:GetQuestLineQuests(questLineID, prepareCache)
    local questIDs = self.questLineQuests[questLineID]
    if not questIDs then
        -- questIDs = DBUtil:GetSavedQuestLineQuests(questLineID) or C_QuestLine.GetQuestLineQuests(questLineID)
        questIDs = C_QuestLine.GetQuestLineQuests(questLineID)

        if (#questIDs == 0) then return end

        self.questLineQuests[questLineID] = questIDs
        debug:print(self, format("%d Added %d |4quest:quests; for QL", questLineID, #questIDs))
    end

    if not prepareCache then
        return questIDs
    end
end

----- Questline Handler ----------
--
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua>

LocalQuestLineUtils.questLineInfos = {}  --> { [questLineID] = {questLineInfo={questLineInfo1, questLineInfo2, ...}, mapIDs={mapID1, mapID2, ...} ...}, ... }
LocalQuestLineUtils.questLineQuestsOnMap = {}  --> { [questID] = {questLineID=questLineID, mapIDs={mapID1, mapID2, ...}} , ... }

-- Retrieve available questlines for given map.
---@param mapID number  The uiMapID
---@param prepareCache boolean?  If true, just updates the data without returning it.
---@return QuestLineInfo[]? questLineInfos
--
function LocalQuestLineUtils:GetAvailableQuestLines(mapID, prepareCache)
    if prepareCache then debug:print(self, "Looking for QuestLines in", mapID) end

    -- DBUtil:CheckInitCategory("questLines")

    local questLineInfos = self:GetCachedQuestLines(mapID)
    local isProcessedZone = questLineInfos ~= nil

    if not questLineInfos then
        questLineInfos = C_QuestLine.GetAvailableQuestLines(mapID)
        if TableIsEmpty(questLineInfos) then return end  --> still no infos

        debug:print(self, format("> Found %d questline |4info:infos; for map %d", #questLineInfos, mapID))
    end

    if not isProcessedZone then
        -- Once a zone has been opened/changed on the world map, update data
        for i, questLineInfo in ipairs(questLineInfos) do
            debug:print(self, ORANGE("%d - Processing QL %d"):format(i, questLineInfo.questLineID))
            self:AddQuestLineQuestToMap(mapID, questLineInfo.questLineID, questLineInfo.questID)
            self:AddSingleQuestLine(questLineInfo, mapID)
            --> TODO - Add quests meta infos ???
        end
        debug:print(self, format(YELLOW("Cached or updated %d questline |4info:infos; for map %d"), #questLineInfos, mapID))
    end

    if not prepareCache then
        -- local questLineInfos = self.questLineInfos[mapID]
        debug:print(self, format("> Returning %d questline |4info:infos; for map %d", #questLineInfos, mapID))
        return questLineInfos
    end
end

function LocalQuestLineUtils:GetCachedQuestLines(mapID)
    local questLineInfos = {}
    for cachedQuestLineID, cachedQuestLineData in pairs(self.questLineInfos) do
        if tContains(cachedQuestLineData.mapIDs, mapID) then
            tInsert(questLineInfos, cachedQuestLineData.questLineInfo)
        end
    end
    if TableHasAnyEntries(questLineInfos) then
        return questLineInfos
    end
end

function LocalQuestLineUtils:AddSingleQuestLine(questLineInfo, mapID)
    if not self.questLineInfos[questLineInfo.questLineID] then
        self.questLineInfos[questLineInfo.questLineID] = {
            questLineInfo = questLineInfo,
            mapIDs = { mapID },
        }
        debug:print(self, format("%d Added QL and map %d", questLineInfo.questLineID, mapID))
        -- Also save QL in database or update mapIDs
        local quests = LocalQuestCache:GetQuestLineQuests(questLineInfo.questLineID)
        -- DBUtil:SaveSingleQuestLine(questLineInfo, mapID, quests)
        return
    end
    if not tContains(self.questLineInfos[questLineInfo.questLineID].mapIDs, mapID) then
        tInsert(self.questLineInfos[questLineInfo.questLineID].mapIDs, mapID)
        debug:print(self, format("%d Updated QL with map %d", questLineInfo.questLineID, mapID))
        -- Also update database mapIDs
        -- DBUtil:SaveSingleQuestLine(questLineInfo, mapID)
    end
end

function LocalQuestLineUtils:AddQuestLineQuestToMap(mapID, questLineID, questID)
    if not self.questLineQuestsOnMap[questID] then
        self.questLineQuestsOnMap[questID] = {
            questLineID = questLineID,
            mapIDs = { mapID },
        }
        debug:print(self, format("%d Added QL-quest %d to map %d", questLineID, questID, mapID))
        return
    end
    if not tContains(self.questLineQuestsOnMap[questID].mapIDs, mapID) then
        tInsert(self.questLineQuestsOnMap[questID].mapIDs, mapID)
        debug:print(self, format("%d Updated QL-quest %d with map %d", questLineID, questID, mapID))
    end
end

function LocalQuestLineUtils:FilterQuestLineQuests(questLineInfo)
    local filteredQuestInfos = {}
    filteredQuestInfos.quests = {}
    filteredQuestInfos.unfilteredQuests = LocalQuestCache:GetQuestLineQuests(questLineInfo.questLineID)
    filteredQuestInfos.numTotalUnfiltered = #filteredQuestInfos.unfilteredQuests
    filteredQuestInfos.numTotal = 0
    filteredQuestInfos.numCompleted = 0
    for i, questID in ipairs(filteredQuestInfos.unfilteredQuests) do
        local questInfo = LocalQuestUtils:GetQuestInfo(questID, "questline")
        if QuestFilterUtils:PlayerMatchesQuestRequirements(questInfo) then
            -- if DEV_MODE and questInfo.questName == '' then                      --> FIXME - Why sometimes no quest names?
            --     print("questName:", questID, HaveQuestData(questID))
            --     for k, v in pairs(questInfo) do
            --         if v then print("  ", k, "-->", v) end
            --     end
            -- end
            if not (questInfo.isDaily or questInfo.isWeekly) then
                if questInfo.isFlaggedCompleted then
                    filteredQuestInfos.numCompleted = filteredQuestInfos.numCompleted + 1
                end
                filteredQuestInfos.numTotal = filteredQuestInfos.numTotal + 1
            end
            tInsert(filteredQuestInfos.quests, questInfo)
        end
    end
    filteredQuestInfos.isComplete = filteredQuestInfos.numCompleted == filteredQuestInfos.numTotal

    return filteredQuestInfos
end

function LocalQuestLineUtils:HasQuestLineInfo(questID, mapID)
    return self.questLineQuestsOnMap[questID] or C_QuestLine.GetQuestLineInfo(questID, mapID)
end

function LocalQuestLineUtils:GetCachedQuestLineInfo(questID, mapID)
    if self.questLineQuestsOnMap[questID] then
        local questLineID = self.questLineQuestsOnMap[questID].questLineID
        local questLineInfo = self.questLineInfos[questLineID].questLineInfo
        -- **Note:**
        -- Only the first questline info per questline is cached, which also
        -- means that the info values are not specific to the given quest,
        -- but these are currently not relevant.
        questLineInfo.questID = questID
        return questLineInfo
    else
        -- Might have slipped through caching (???); try API function
        debug:print(self, RED("Not cached quest %d, using API call for map %d"):format(questID, mapID))
        return C_QuestLine.GetQuestLineInfo(questID, mapID)
    end
end

LocalQuestLineUtils.GetQuestLineInfoByPin = function(self, pin)
    debug:print(self, "Searching QL for pin", pin.questID, pin.mapID)
    local questLineInfo = self:GetCachedQuestLineInfo(pin.questID, pin.mapID)
    if questLineInfo then
        debug:print(self, format("%d Found QL %d", pin.questID, pin.questLineID or questLineInfo.questLineID))
        return questLineInfo
    end
    debug:print(self, RED("Nothing found for pin"), pin.questID, pin.mapID)
end

LocalQuestLineUtils.AddQuestLineDetailsToTooltip = function(self, tooltip, pin, campaignChapterID)
    local questLineInfo = self:GetQuestLineInfoByPin(pin)
    if campaignChapterID then
        local chapterInfo = C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID)
        local chapterName = chapterInfo and chapterInfo.name or RED(RETRIEVING_DATA)
        questLineInfo = {
            questLineID = campaignChapterID,
            questLineName = chapterName,
        }
    end
    if not questLineInfo then return false end

    pin.questInfo.currentQuestLineID = questLineInfo.questLineID
    -- Note: This is later needed for the currentChapterID in quest campaigns.
    -- The actual `C_CampaignInfo.GetCurrentChapterID(campaignID)` refers only
    -- to active quest campaigns.

    local filteredQuestInfos = LocalQuestLineUtils:FilterQuestLineQuests(questLineInfo)
    if (filteredQuestInfos.numTotalUnfiltered > 1 and filteredQuestInfos.numTotal <= 1) then
        debug:print("Rebuilding tooltip")                                       --> TODO - Find a better way 
        return self:AddQuestLineDetailsToTooltip(tooltip, pin, campaignChapterID)
    end

    -- Category name
    if ns.settings.showCategoryNames then
        GameTooltip_AddColoredDoubleLine(tooltip, " ", L.CATEGORY_NAME_QUESTLINE, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)
    end

    -- Questline header name + progress
    local questLineNameTemplate = pin.questInfo.isCampaign and L.QUESTLINE_CHAPTER_NAME_FORMAT or L.QUESTLINE_NAME_FORMAT
    questLineNameTemplate = filteredQuestInfos.isComplete and questLineNameTemplate.."  "..CHECKMARK_ICON_STRING or questLineNameTemplate
    GameTooltip_AddColoredLine(tooltip, questLineNameTemplate:format(questLineInfo.questLineName), QUESTLINE_HEADER_COLOR)
    GameTooltip_AddNormalLine(tooltip, L.QUESTLINE_PROGRESS_FORMAT:format(filteredQuestInfos.numCompleted, filteredQuestInfos.numTotal))
    debug:AddDebugLineToTooltip(tooltip, {text=format("> L:%d \"%s\" #%d Quests", questLineInfo.questLineID, questLineInfo.questLineName, filteredQuestInfos.numTotalUnfiltered)})

    -- Questline quests
    if GetCollapseTypeModifier(filteredQuestInfos.isComplete, "collapseType_questline") then
        local wrapLine = false
        local lineLimit = 48                                                    --> TODO - Determine tooltip height
        for i, questInfo in ipairs(filteredQuestInfos.quests) do
            -- Add a line limit
            if (filteredQuestInfos.numTotal > lineLimit) then
                debug:print(QuestFilterUtils, "filteredQuestInfos.numTotal:", filteredQuestInfos.numTotal)
                if (questInfo.isCampaign or questInfo.hasZoneStoryInfo) then lineLimit = 32 end
                if (questInfo.isCampaign and questInfo.hasZoneStoryInfo) then lineLimit = 24 end
                if (i == lineLimit) then
                    local numRemaining = filteredQuestInfos.numTotal - i
                    GameTooltip_AddNormalLine(tooltip, format("(+ %d more)", numRemaining))
                    debug:print(QuestFilterUtils, "lineLimit:", lineLimit)
                    return
                end
            end
            local isActiveQuest = (questInfo.questID == pin.questInfo.questID) or questInfo.isComplete
            local questTitle = FormatQuestName(questInfo)
            if not StringIsEmpty(questInfo.questName) then
                if questInfo.isFlaggedCompleted then
                    GameTooltip_AddColoredLine(tooltip, L.CHAPTER_NAME_FORMAT_COMPLETED:format(questTitle), GREEN_FONT_COLOR, wrapLine)
                elseif isActiveQuest then
                    GameTooltip_AddNormalLine(tooltip, L.CHAPTER_NAME_FORMAT_CURRENT:format(questTitle), wrapLine)
                else
                    GameTooltip_AddHighlightLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(questTitle), wrapLine)
                end
            else
                GameTooltip_AddErrorLine(tooltip, L.CHAPTER_NAME_FORMAT_NOT_COMPLETED:format(questTitle), wrapLine)
            end
        end
    else
        local textTemplate = (pin.pinTemplate == LocalUtils.QuestPinTemplate) and L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY or L.STORY_HINT_FORMAT_SEE_CHAPTERS_KEY_HOVER
        GameTooltip_AddInstructionLine(tooltip, textTemplate:format(GREEN(SHIFT_KEY)))
    end

    return true
end

----- Common Utilities ----------

LocalUtils.QuestPinTemplate = "QuestPinTemplate"
LocalUtils.StorylineQuestPinTemplate = "StorylineQuestPinTemplate"
LocalUtils.mapInfoCache = {}  --> { [mapID] = mapInfo, ...}

function LocalUtils:GetMapInfo(mapID)
    if not LocalUtils.mapInfoCache[mapID] then
        LocalUtils.mapInfoCache[mapID] = C_Map.GetMapInfo(mapID)
        debug:print("Added mapID", mapID, "to map cache")
    end
    return LocalUtils.mapInfoCache[mapID]
end

----- Campaign Handler ----------
--
-- REF.: <https://www.townlong-yak.com/framexml/live/ObjectAPI/CampaignChapter.lua>

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
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
    end

    -- Category name
    if ns.settings.showCategoryNames then
        GameTooltip_AddColoredDoubleLine(tooltip, " ", TRACKER_HEADER_CAMPAIGN_QUESTS, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR)
    end

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

--> TODO - Continue campaign tests
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
    return ns.settings.showPluginName and (pin.questInfo.isReadyForTurnIn
        or pin.questType or IsShiftKeyDown()
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
        pin.questInfo = LocalQuestUtils:GetQuestInfo(pin.questID, "pin", pin.mapID)
    end

    local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
    -- Addon name
    if ShouldShowPluginName(pin) then
        local questTypeText = DEV_MODE and tostring(pin.questType) or " "
        GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR, nil, nil)
    end
    debug:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})

    if (pin.questType and ns.settings.showQuestType) then                       --> TODO - Enhance, eg. isBounty, etc.
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
        -- if not tContains({"Normal", "Legendary", "Trivial"}, pin.questType) then GameTooltip_AddBlankLineToTooltip(tooltip) end
    end

    -- debug:print("pin:", pin.mapID, pin:GetMap():GetMapID(), GetQuestUiMapID(pin.questID), YELLOW(pin.questType or "no-type"))
    if (debug.isActive and IsShiftKeyDown() and IsControlKeyDown()) then
        debug:AddDebugQuestInfoLineToTooltip(tooltip, pin)
        GameTooltip:Show()
        return
    end
    if (pin.questInfo.hasZoneStoryInfo and ns.settings.showZoneStory) then
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
        ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.hasQuestLineInfo and ns.settings.showQuestLine) then
        --> TODO - Optimize info retrieval to load only once (!)
        -- if pin.questInfo.hasZoneStoryInfo then GameTooltip_AddBlankLineToTooltip(tooltip) end
        LocalQuestLineUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.isCampaign and ns.settings.showCampaign) then
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
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
        pin.questInfo = LocalQuestUtils:GetQuestInfo(pin.questID, "pin", pin.mapID)
    end

    local tooltip = GameTooltip
    -- Addon name
    if ShouldShowPluginName(pin) then
        local questTypeText = DEV_MODE and tostring(pin.questType) or " "
        GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, CATEGORY_NAME_COLOR, CATEGORY_NAME_COLOR, nil, nil)
    end
    debug:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})

    if (pin.questType and ns.settings.showQuestType) then                       --> TODO - Enhance, eg. isBounty, etc.
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
    end
    if (pin.questInfo.isReadyForTurnIn and ns.settings.showQuestTurnIn) then
        tooltip:AddLine(QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN)
    end
    if (debug.isActive and IsShiftKeyDown() and IsControlKeyDown()) then
        debug:AddDebugQuestInfoLineToTooltip(tooltip, pin)
        GameTooltip:Show()
        return
    end
    if (pin.questInfo.hasZoneStoryInfo and ns.settings.showZoneStory) then
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
        ZoneStoryUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.hasQuestLineInfo and ns.settings.showQuestLine) then
        -- if pin.questInfo.hasZoneStoryInfo then GameTooltip_AddBlankLineToTooltip(tooltip) end
        LocalQuestLineUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    end
    if (pin.questInfo.isCampaign and ns.settings.showCampaign) then             --> TODO - Optimize info retrieval to load only once (!)
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
        CampaignUtils:AddCampaignDetailsTooltip(tooltip, pin)
    end

    GameTooltip:Show()
end

local function Hook_OnClick(pin, mouseButton)                                   --> TODO - Needed ???
    if IsAltKeyDown() then
        debug:print("Alt-Clicked:", pin.questID, pin.pinTemplate, mouseButton)    --> works, but only with "LeftButton" (!)
    end
end

----- Ace3 Profile Handler ----------

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
        debug:print(event, ...)
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
    local parent_state = HandyNotes:IsEnabled()
    if (parent_state ~= self:IsEnabled()) then
        -- Toggle this plugin
        if parent_state then self:OnEnable() else self:OnDisable() end
        self:SetEnabledState(parent_state)
    end
end

function HandyNotesPlugin:RegisterHooks()
    debug:print(debug.hooks, "Hooking active quests...")
    hooksecurefunc(QuestPinMixin, "OnMouseEnter", Hook_ActiveQuestPin_OnEnter)
    hooksecurefunc(QuestPinMixin, "OnClick", Hook_OnClick)

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
    -- debug:print(GRAY("GetNodes2"), "> uiMapID:", uiMapID, "minimap:", minimap)
    if minimap then return PointsDataIterator end  -- minimap is currently not used

    if WorldMapFrame then
        local isWorldMapShown = WorldMapFrame:IsShown()
        local mapID = uiMapID or WorldMapFrame:GetMapID()
        local mapInfo = LocalUtils:GetMapInfo(mapID)
        debug:print(GRAY("GetNodes2"), "> uiMapID:", uiMapID, "mapID:", mapID)

        if (isWorldMapShown and mapInfo.mapType == Enum.UIMapType.Zone) then
            ns.activeZoneMapInfo = mapInfo
            debug:print(LocalQuestLineUtils, GRAY("Entering zone:"), mapID, mapInfo.name)
            -- Update data cache for current zone
            local prepareCache = true
            ZoneStoryUtils:GetZoneStoryInfo(mapID, prepareCache)
            LocalQuestLineUtils:GetAvailableQuestLines(mapID, prepareCache)
        end
        if (isWorldMapShown and mapInfo.mapType == Enum.UIMapType.Continent) then
            ns.activeContinentMapInfo = mapInfo
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

-- QUEST_LOG_COVENANT_CALLINGS_HEADER = "|cffffffffBerufungen:|r |cffffd200%d/%d abgeschlossen|r";

C_Minimap.IsTrackingHiddenQuests()

-- local function tCount(tbl)
-- 	local n = #tbl or 0
-- 	if (n == 0) then
-- 		for _ in pairs(tbl) do
-- 			n = n + 1
-- 		end
-- 	end
-- 	return n
-- end

]]
--@end-do-not-package@