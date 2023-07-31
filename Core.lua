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
-- REF.: <https://wowpedia.fandom.com/wiki/API_C_AddOns.GetAddOnMetadata>
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

local format = string.format
local tostring = tostring
local tContains = tContains
-- local tDeleteItem = tDeleteItem
local tInsert = table.insert
-- local strjoin = strjoin

-- local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
-- local C_QuestLog_GetZoneStoryInfo = C_QuestLog.GetZoneStoryInfo
-- local C_QuestLine_GetQuestLineQuests = C_QuestLine.GetQuestLineQuests
local QuestUtils_GetQuestName = QuestUtils_GetQuestName
local QuestUtils_AddQuestTypeToTooltip = QuestUtils_AddQuestTypeToTooltip
local GetQuestFactionGroup = GetQuestFactionGroup

----- Load addons ----------

-- REF.: AceAddon:GetAddon(name, silent)
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
local HandyNotesPlugin = LibStub("AceAddon-3.0"):NewAddon("Loremaster", "AceConsole-3.0")
-- local L = LibStub('AceLocale-3.0'):GetLocale(ADDON_NAME)
local L = {
    -- WoW global strings
    OPTION_STATUS_DISABLED = VIDEO_OPTIONS_DISABLED,
    OPTION_STATUS_ENABLED = VIDEO_OPTIONS_ENABLED,
    OPTION_STATUS_FORMAT = SLASH_TEXTTOSPEECH_HELP_FORMATSTRING,
    OPTION_STATUS_READY_FORMAT = LFG_READY_CHECK_PLAYER_IS_READY,  -- "%s is ready.";,
    -- BLIZZARD_STORE_PRODUCT_IS_READY = "Your %s is Ready!";

    QUEST_LINE_NAME_FORMAT = "|TInterface\\Icons\\INV_Misc_Book_07:16:16:0:-1|t %s",
    QUEST_LINE_CHAPTER_COMPLETED_FORMAT = "|TInterface\\Scenarios\\ScenarioIcon-Check:16:16:0:-1|t %s",
    QUEST_LINE_CHAPTER_NOT_COMPLETED_FORMAT = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s",
    QUEST_LINE_CHAPTER_CURRENT_FORMAT = "|A:common-icon-forwardarrow:16:16:2:-1|a %s",

    QUEST_NAME_ALLIANCE_FORMAT = "%s |A:questlog-questtypeicon-alliance:16:16:0:-1|a",
    QUEST_NAME_HORDE_FORMAT = "%s |A:questlog-questtypeicon-horde:16:16:0:-1|a",
    QUEST_NAME_NEUTRAL_FORMAT = "%s",
    -- QUEST_TYPE_TRIVIAL_NAME_FORMAT = TRIVIAL_QUEST_DISPLAY,  -- "|cff000000%s (niedrigstufig)|r";

    STORY_NAME_COMPLETE_FORMAT = "|T%d:16:16:0:0|t %s  |A:achievementcompare-YellowCheckmark:0:0|a",
    STORY_NAME_INCOMPLETE_FORMAT = "|T%d:16:16:0:0|t %s",
    STORY_CHAPTER_COMPLETED_FORMAT = "|TInterface\\Scenarios\\ScenarioIcon-Check:16:16:0:-1|t %s",
    STORY_CHAPTER_NOT_COMPLETED_FORMAT = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s",
    STORY_STATUS_FORMAT = QUEST_STORY_STATUS,
    STORY_SEE_CHAPTERS_KEY_FORMAT = "Hold %s to see chapters",

    QUEST_IS_CAMPAIGN_QUEST_FORMAT = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a This quest is part of the %s campaign.",

    -- ACHIEVEMENT_NAME_FORMAT = "|T%d:16:16:0:0|t %s",
    ACHIEVEMENT_COLON_FORMAT = CONTENT_TRACKING_ACHIEVEMENT_FORMAT,  -- "Erfolg: \"%s\"";
    ACHIEVEMENT_UNLOCKED_FORMAT = ACHIEVEMENT_UNLOCKED_CHAT_MSG,  -- "Erfolg errungen: %s";
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
    OBJECTIVE_FORMAT = CONTENT_TRACKING_OBJECTIVE_FORMAT,  --> "- %s"
    -- ERR_ACHIEVEMENT_WATCH_COMPLETED = "Dieser Erfolg wurde bereits abgeschlossen.";
    -- GUILD_NEWS_VIEW_ACHIEVEMENT = "Erfolg anzeigen";
    -- CONTINENT = "Kontinent";
    -- ACHIEVEMENT_NOT_COMPLETED = ACHIEVEMENT_COMPARISON_NOT_COMPLETED,  -- "Erfolg nicht abgeschlossen";

    -- Custom strings
    HIDE_WITH_2KEY_COMBO = "<Click %s+%s to hide>",
    SLASHCMD_USAGE = "Usage:",
}
-- "achievementcompare-GreenCheckmark"
-- "achievementcompare-YellowCheckmark"

-- local LibDD = LibStub:GetLibrary('LibUIDropDownMenu-4.0')

----- Utilities ----------------------------------------------------------------

----- Colors -----

local YELLOW = function(txt) return YELLOW_FONT_COLOR:WrapTextInColorCode(txt) end
local GRAY = function(txt) return GRAY_FONT_COLOR:WrapTextInColorCode(txt) end
-- local LGRAY = function(txt) return LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(txt) end
local GREEN = function(txt) return FACTION_GREEN_COLOR:WrapTextInColorCode(txt) end  -- ACTIONBAR_HOTKEY_FONT_COLOR

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
            print(YELLOW(prefix.."_"..t.debug_prefix), select(2, ...))
        end
    elseif self.isActive then
        print(YELLOW(prefix..":"), ...)
    end
end

----- Faction Groups ----------

local playerFactionGroup = UnitFactionGroup("player")

-- Quest faction groups: {Alliance=1, Horde=2, Neutral=3}
local QuestFactionGroupID = EnumUtil.MakeEnum(PLAYER_FACTION_GROUP[1], PLAYER_FACTION_GROUP[0], "Neutral")

local QuestNameFactionGroupFormat = {
    [QuestFactionGroupID.Alliance] = L.QUEST_NAME_ALLIANCE_FORMAT,
    [QuestFactionGroupID.Horde] = L.QUEST_NAME_HORDE_FORMAT,
    [QuestFactionGroupID.Neutral] = "%s",
}

-- Filter given quest by faction group (1 == Alliance, 2 == Horde, [3 == Neutral])
local function PlayerMatchesQuestFactionGroup(questFactionGroup)
    return tContains({QuestFactionGroupID[playerFactionGroup], QuestFactionGroupID.Neutral}, questFactionGroup)
end

----- Main ---------------------------------------------------------------------

function HandyNotesPlugin:OnInitialize()
    -- Load options database and settings
    ns.options = ns.pluginInfo.options(self)
    ns.db = LibStub("AceDB-3.0"):New("LoremasterDB")                            --> TODO - Add default options

    self:RegisterHooks()
end

function HandyNotesPlugin:OnEnable()
    -- Using AceConsole for slash commands                                      --> TODO - Keep slash commands ???
    self.slash_commands = {"lm", "loremaster"}
    for i, command in ipairs(self.slash_commands) do
        self:RegisterChatCommand(command, "ProcessSlashCommands")
    end

    -- Register this addon to HandyNotes as plugin
    -- REF.: HandyNotes:RegisterPluginDB(pluginName, pluginHandler, optionsTable)
    HandyNotes:RegisterPluginDB(AddonID, self, ns.options)
    self:Printf(L.OPTION_STATUS_READY_FORMAT, YELLOW(ns.pluginInfo.title))
end

function HandyNotesPlugin:OnDisable()
    -- Using AceConsole for slash commands                                      --> TODO - Keep slash commands ???
    for i, command in ipairs(self.slash_commands) do
        self:UnregisterChatCommand(command)
    end

    self:Printf(L.OPTION_STATUS_FORMAT, YELLOW(ns.pluginInfo.title), L.OPTION_STATUS_DISABLED)
end

-- Standard functions you can provide optionally:
-- pluginHandler:OnEnter(uiMapID/mapFile, coord)
--     Function we will call when the mouse enters a HandyNote, you will generally produce a tooltip here.
-- pluginHandler:OnLeave(uiMapID/mapFile, coord)
--     Function we will call when the mouse leaves a HandyNote, you will generally hide the tooltip here.
-- pluginHandler:OnClick(button, down, uiMapID/mapFile, coord)
--     Function we will call when the user clicks on a HandyNote, you will generally produce a menu here on right-click.


----- Tooltip Utilities ----------

local ZoneStoryCache = {}
ZoneStoryCache.debug = false
ZoneStoryCache.debug_prefix = "ZS-CACHE:"
ZoneStoryCache.meta = {}  --> {[mapID] = {storyAchievementID, storyMapInfo}, ...}
ZoneStoryCache.achievements = {}  --> achievementInfo + .criteriaList
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

local QuestCache = {}
QuestCache.debug = false
QuestCache.debug_prefix = "Quest-CACHE:"
-- Structure: { [questLineID] = {questID1, questID2, ...}, ... }
QuestCache.GetQuestLineQuests = function(self, questLineID, prepareCache)
    -- print(">",  questLineID, prepareCache)
    if not ns.db.questLineQuests then
        ns.db.questLineQuests = {}
        debug:print(self, "Initialized 'questLineQuests' DB")
    end
    if not ns.db.questLineQuests[questLineID] then
        local questIDs = C_QuestLine.GetQuestLineQuests(questLineID)
        if (not questIDs or #questIDs == 0) then return end
        ns.db.questLineQuests[questLineID] = questIDs
        debug:print(self, format("> Adding %d QL |4quest:quests; to %d", #questIDs, questLineID))
        -- return questIDs
    end
    if not prepareCache then
        local questIDs = ns.db.questLineQuests[questLineID]
        debug:print(format("> Returning %d QL |4quest:quests; for %d", #questIDs, questLineID))
        return questIDs
    end
end

local QuestLineCache = {}
QuestLineCache.debug = false
QuestLineCache.debug_prefix = "QL-CACHE:"
-- Structure: { [mapID] = {questLineInfo1, questLineInfo2, ...}, ... }
QuestLineCache.GetAvailableQuestLines = function(self, mapID, prepareCache)
    if not ns.db.questLineInfos then
        ns.db.questLineInfos = {}
        debug:print(self, "Initialized 'questLineInfos' DB")
    end
    if not ns.db.questLineInfos[mapID] then
        local questLines = C_QuestLine.GetAvailableQuestLines(mapID)
        if (not questLines or #questLines == 0) then return end
        ns.db.questLineInfos[mapID] = questLines
        debug:print(self, format("> Adding %d |4QuestLine:QuestLines; to %d", #questLines, mapID))
        if prepareCache then
            for i, questLineInfo in ipairs(questLines) do
                QuestCache:GetQuestLineQuests(questLineInfo.questLineID, prepareCache)
            end
        end
    end
    if not prepareCache then
        local questLines = ns.db.questLineInfos[mapID]
        debug:print(self, format("Returning %d |4QuestLine:QuestLines; for %d", #questLines, mapID))
        return questLines
    end
end
QuestLineCache.AddSingleQuestLine = function(self, mapID, questLineInfo)
    if not ns.db.questLineInfos[mapID] then
        ns.db.questLineInfos[mapID] = {}
    end
    debug:print(self, format("Adding %d to %d", questLineInfo.questLineID, mapID))
    tInsert(ns.db.questLineInfos[mapID], questLineInfo)
end
QuestLineCache.GetQuestLineInfoByPin = function(self, pin)
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua>
    -- debug:print(YELLOW("Fetching single quest line info..."))
    local mapID = pin.mapID or pin:GetMap():GetMapID()
    local questLines = self:GetAvailableQuestLines(mapID)
    if questLines then
        -- Try cache look-up first
        for i, questLineInfo in ipairs(questLines) do
            if (questLineInfo.questID == pin.questID) then
                debug:print(self, "> Found cached QL:", questLineInfo.questLineID, questLineInfo.questLineName)
                return questLineInfo
            end
        end
        -- Try get new info
        local questLineInfo = C_QuestLine.GetQuestLineInfo(pin.questID, mapID)
        if questLineInfo then
            debug:print("> Got new QL:", questLineInfo.questLineID and questLineInfo.questLineName)
            self:AddSingleQuestLine(mapID, questLineInfo)
            return questLineInfo
        end
    end
end


local LocalUtils = {}

function LocalUtils:GetQuestName(questID)
    -- REF.: <https://www.townlong-yak.com/framexml/live/QuestUtils.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
	if not HaveQuestData(questID) then
		C_QuestLog.RequestLoadQuestByID(questID);
	end
	return QuestUtils_GetQuestName(questID);
end

-- In debug mode show additional infos ie. questIDs, achievementIDs, etc. or
-- show a blank line instead in normal mode.
function LocalUtils:AddDebugLineToTooltip(tooltip, debugInfo)
    local text = debugInfo and debugInfo.text
    local addBlankLine = debugInfo and debugInfo.addBlankLine
    -- local devModeOnly = debugInfo and debugInfo.devModeOnly
    if DEV_MODE then
        GameTooltip_AddDisabledLine(tooltip, text, false)
        if addBlankLine then GameTooltip_AddBlankLineToTooltip(tooltip) end
    end
end

function LocalUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    local mapID = pin.mapID or pin:GetMap():GetMapID()
    -- debug:print(format("Checking zone (%s) for stories...", mapID or "n/a"))
    local storyAchievementID, storyMapInfo = ZoneStoryCache:GetZoneStoryInfo(mapID)

    if not storyAchievementID then return false; end

    local achievementInfo = ZoneStoryCache:GetAchievementInfo(storyAchievementID)
    -- Add zone story name
    local StoryNameTemplate = achievementInfo.completed and L.STORY_NAME_COMPLETE_FORMAT or L.STORY_NAME_INCOMPLETE_FORMAT
    GameTooltip_AddColoredLine(tooltip, StoryNameTemplate:format(achievementInfo.icon, storyMapInfo.name), ACHIEVEMENT_COLOR)  -- SCENARIO_STAGE_COLOR)
    -- Add chapter status
    GameTooltip_AddHighlightLine(tooltip, L.STORY_STATUS_FORMAT:format(achievementInfo.numCompleted, achievementInfo.numCriteria))
    self:AddDebugLineToTooltip(tooltip, {text=format("> A:%d \"%s\"", storyAchievementID, achievementInfo.name)}) --, addBlankLine=false})  --  not IsShiftKeyDown())
    -- Add chapter list
    if IsShiftKeyDown() then
    -- if (not achievementInfo.completed or IsShiftKeyDown()) then
        local wrapLine = false
        for i, criteriaInfo in ipairs(achievementInfo.criteriaList) do
            -- tInsert(self.processedStoryQuests, criteriaInfo.assetID or criteriaInfo.criteriaID)
            -- criteriaInfo.criteriaString = format("%d %d %s", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaString)
            -- debug:print("criteria:", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaID)
            if debug.showChapterIDsInTooltip then criteriaInfo.criteriaString = format("|cff808080%05d|r %s", criteriaInfo.assetID, criteriaInfo.criteriaString) end
            if criteriaInfo.completed then
                GameTooltip_AddColoredLine(tooltip, L.STORY_CHAPTER_COMPLETED_FORMAT:format(criteriaInfo.criteriaString), GREEN_FONT_COLOR, wrapLine)
            else
                GameTooltip_AddHighlightLine(tooltip, L.STORY_CHAPTER_NOT_COMPLETED_FORMAT:format(criteriaInfo.criteriaString), wrapLine)
            end
        end
        GameTooltip_AddBlankLineToTooltip(tooltip)
    else
        GameTooltip_AddInstructionLine(tooltip, L.STORY_SEE_CHAPTERS_KEY_FORMAT:format(GREEN(SHIFT_KEY)))
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end

    return true
end

-- local function GetNumQuestLineQuests(questLineID)
--     local questList = C_QuestLine_GetQuestLineQuests(questLineID)
--     return #questList
-- end

function LocalUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    local questLineInfo = QuestLineCache:GetQuestLineInfoByPin(pin)
    if not questLineInfo then return false end
    -- Quest line header
    GameTooltip_AddColoredLine(tooltip, L.QUEST_LINE_NAME_FORMAT:format(questLineInfo.questLineName), SCENARIO_STAGE_COLOR)
    -- Chapters
    local wrapLine = false
    local questIDs = QuestCache:GetQuestLineQuests(questLineInfo.questLineID)
    local numQuestIDs = #questIDs
    self:AddDebugLineToTooltip(tooltip, {text=format("> L:%d \"%s\" #%d Quests", questLineInfo.questLineID, questLineInfo.questLineName, numQuestIDs)})
    local previousQuestName = ''
    for i, questID in ipairs(questIDs) do
        -- Add line limit
        if (i == 50) then
            local numRemaining = numQuestIDs - i
            GameTooltip_AddNormalLine(tooltip, format("(+ %d more)", numRemaining), wrapLine)
            return
        end
        local questFactionGroup = GetQuestFactionGroup(questID) or 3
        if PlayerMatchesQuestFactionGroup(questFactionGroup) then
            -- local questName = QuestUtils_GetQuestName(questID)
            local questName = self:GetQuestName(questID)
            if DEV_MODE and questName == '' then                                             --> FIXME - Why sometimes no quest names?
                print("questName:", questID, HaveQuestData(questID))
            end
            -- if (questName ~= '' and previousQuestName ~= '') and (questName == previousQuestName) then break end     --> FIXME - Double Names, other class/start ???
            -- previousQuestName = questName
            local questTitle = QuestNameFactionGroupFormat[questFactionGroup]:format(questName)
            -- local isQuestCompleted = C_QuestLog.IsComplete(questID) or C_QuestLog.IsQuestFlaggedCompleted(questID)
            local isActiveQuest = C_QuestLog.IsComplete(questID)
            local isQuestCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)

            -- print("quest:", questID, questLineInfo.questID, questID == questLineInfo.questID, isQuestCompleted, isOnQuest)
            -- debug:print("quest faction:", i, questID, questFactionGroup)
            if debug.showChapterIDsInTooltip then questTitle = format("|cff808080%05d|r %s", questID, questTitle) end
            -- if tContains({QuestFactionGroupID[playerFactionGroup], QuestFactionGroupID.Neutral}, questFactionGroup) then
            if isQuestCompleted then
                GameTooltip_AddColoredLine(tooltip, L.QUEST_LINE_CHAPTER_COMPLETED_FORMAT:format(questTitle), GREEN_FONT_COLOR, wrapLine)
            elseif (questID == questLineInfo.questID) then
                GameTooltip_AddNormalLine(tooltip, L.QUEST_LINE_CHAPTER_CURRENT_FORMAT:format(questTitle), wrapLine)
            elseif isActiveQuest then
                GameTooltip_AddNormalLine(tooltip, L.QUEST_LINE_CHAPTER_CURRENT_FORMAT:format(questTitle), wrapLine)
            else
                GameTooltip_AddHighlightLine(tooltip, L.QUEST_LINE_CHAPTER_NOT_COMPLETED_FORMAT:format(questTitle), wrapLine)
            end
        end
    end
    -- if DEV_MODE and questLineInfo.isCampaign then
    --     self:AddDebugLineToTooltip(tooltip, format("> > isCampaign: %s %s", tostring(questLineInfo.isCampaign), tostring(C_CampaignInfo.IsCampaignQuest(pin.questID))))
    -- end
    return true
end

----- Hooks ----------

LocalUtils.QuestPinTemplate = "QuestPinTemplate"
LocalUtils.StorylineQuestPinTemplate = "StorylineQuestPinTemplate"

function ShouldHookQuestPin(pin)
    return tContains({LocalUtils.StorylineQuestPinTemplate, LocalUtils.QuestPinTemplate}, pin.pinTemplate)
end

-- local function ShouldHookWorldQuestPin(pin)
--     return pin.pinTemplate ~= WorldMap_WorldQuestDataProviderMixin:GetPinTemplate()
--     -- "BonusObjectivePinTemplate", "ThreatObjectivePinTemplate"
-- end

local function Hook_OnEnter(pin)
    -- REF.: <https://www.townlong-yak.com/framexml/live/SharedTooltipTemplates.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/GameTooltip.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/StorylineQuestDataProvider.lua>
    if not pin.questID then return end
    if not ShouldHookQuestPin(pin) then return end

    local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
    local questTypeText = DEV_MODE and GRAY(pin.questType or "?") or " "
    GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, NORMAL_FONT_COLOR, GRAY_FONT_COLOR, nil, nil)
    if (pin.pinTemplate ~= LocalUtils.QuestPinTemplate) then
        -- Ignore QuestPinTemplate aka. active quests since they do show the quest type by default
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
        -- print("Displaying quest type", pin.questType)
        if not tContains({"Normal", "Legendary", "Trivial"}, pin.questType) then GameTooltip_AddBlankLineToTooltip(tooltip) end
    else
        pin.pinTemplate = pin.pinTemplate or "Active"
    end
    LocalUtils:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})
    debug:print("pin:", pin.mapID, pin:GetMap():GetMapID(), GetQuestUiMapID(pin.questID), YELLOW(pin.questType or "no-type"))
    local hasStory = LocalUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    local hasQuestLine = LocalUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    local isCampaign = C_CampaignInfo.IsCampaignQuest(pin.questID)
    if isCampaign then
        local campaignID = C_CampaignInfo.GetCampaignID(pin.questID)
        local campaignInfo = C_CampaignInfo.GetCampaignInfo(campaignID)
        if campaignInfo then
            if (hasStory or hasQuestLine) then GameTooltip_AddBlankLineToTooltip(tooltip); end
            LocalUtils:AddDebugLineToTooltip(tooltip, {text=format("> > isCampaign: %d %s", campaignInfo.isWarCampaign, campaignInfo.description)}) --, devModeOnly=true})
            GameTooltip_AddNormalLine(tooltip, L.QUEST_IS_CAMPAIGN_QUEST_FORMAT:format(SCENARIO_STAGE_COLOR:WrapTextInColorCode(campaignInfo.name)))
        end
    end
    GameTooltip:Show()
end

-- local function HNQH_TaskPOI_OnEnter(pin, skipSetOwner)
--     -- REF.: <https://www.townlong-yak.com/framexml/live/WorldMapFrame.lua>
--     -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/BonusObjectiveDataProvider.lua>
--     if not pin.questID then return end
--     if not ShouldHookWorldQuestPin(pin) then return end

--     local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
--     -- GameTooltip_AddBlankLineToTooltip(tooltip)
--     GameTooltip_AddColoredDoubleLine(tooltip, " ", HandyNotesPlugin.name, NORMAL_FONT_COLOR, GRAY_FONT_COLOR, nil, nil)
--     if IsShiftKeyDown() then
--         GameTooltip_AddQuest(tooltip, pin.questID)
--     else
--         QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
--         GameTooltip_AddInstructionLine(tooltip, format(L.HIDE_WITH_2KEY_COMBO, ALT_KEY_TEXT, KEY_BUTTON1))  -- SHIFT_KEY_TEXT
--         GameTooltip_AddDisabledLine(tooltip, format("#%d - %s", pin.questID, pin.pinTemplate))
--     end
--     GameTooltip:Show()
-- end

local function Hook_OnClick(pin, mouseButton)
    if IsAltKeyDown() then
        debug:print("Alt-Clicked:", pin.questID, pin.pinTemplate, mouseButton)    --> works, but only with "LeftButton" (!)
    end
end

function HandyNotesPlugin:RegisterHooks()
    -- Active Quests                                                            --> TODO - Keep ???
    -- debug:print(YELLOW("Hooking active quests..."))
    hooksecurefunc(QuestPinMixin, "OnMouseEnter", Hook_OnEnter)
    hooksecurefunc(QuestPinMixin, "OnClick", Hook_OnClick)
    -- Storyline Quests
    -- debug:print(YELLOW("Hooking storyline quests..."))
    hooksecurefunc(StorylineQuestPinMixin, "OnMouseEnter", Hook_OnEnter)
    hooksecurefunc(StorylineQuestPinMixin, "OnClick", Hook_OnClick)
    -- Bonus Objectives
    -- -- if _G.TaskPOI_OnEnter then
    -- if _G["TaskPOI_OnEnter"] then
    --     -- hooksecurefunc("TaskPOI_OnEnter", HNQH_TaskPOI_OnEnter)
    --     if not self:IsHooked(nil, "TaskPOI_OnEnter") then
    --         self:SecureHook(nil, "TaskPOI_OnEnter", HNQH_TaskPOI_OnEnter)
    --     end
    -- end
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
    if minimap then return PointsDataIterator end  -- minimap lis currently not used
    debug:print(GRAY("GetNodes2"), "> uiMapID:", uiMapID or nil, "minimap:", minimap or nil)

    if WorldMapFrame then
        local isWorldMapShown = WorldMapFrame:IsShown()
        local mapID = uiMapID or WorldMapFrame:GetMapID()
        local mapInfo = C_Map.GetMapInfo(mapID)
        -- Tests
        if (isWorldMapShown and mapInfo.mapType == Enum.UIMapType.Zone) then
            -- Update data cache for current zone
            ZoneStoryCache:GetZoneStoryInfo(mapID, true)
            QuestLineCache:GetAvailableQuestLines(mapID, true)
        end
        -- local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
        -- -- local doesMapShowTaskObjectives = C_TaskQuest.DoesMapShowTaskQuestObjectives(mapID)
        -- -- print("doesMapShowTaskObjectives:", doesMapShowTaskObjectives, "questsOnMap:", #questsOnMap)
        -- print("questsOnMap:", #questsOnMap)
        return PointsDataIterator, isWorldMapShown, mapID
    end
    return PointsDataIterator
end

--------------------------------------------------------------------------------
----- Slash Commands (requires: AceConsole) ------------------------------------
--------------------------------------------------------------------------------

local arg_list = {
    version = "Display addon version",
    config = "Display settings",
}

function HandyNotesPlugin:ProcessSlashCommands(input)
    -- Process the slash command ('input' contains whatever follows the slash command)
    -- Registered in :OnEnable()
    if (input == '') then
        -- Print usage message to chat
        self:Print(L.SLASHCMD_USAGE, format(" '/%s <%s>'", self.slash_commands[1], YELLOW("arg")), "|",
                                     format(" '/%s <%s>'", self.slash_commands[2], YELLOW("arg")))
        -- for i, command in ipairs(self.slash_commands) do
        --     print(format(" '/%s <%s>'", command, YELLOW("arg")))
        -- end
        for arg_name, arg_description in pairs(arg_list) do
            self:Print(" ", L.OBJECTIVE_FORMAT:format(YELLOW(arg_name..":")), arg_description)
        end
    end
    if (input == "version") then
        self:Print(ns.pluginInfo.version)
    end
    if (input == "config") then
        Settings.OpenToCategory(HandyNotes.name)
    end
end

--@do-not-package@
--------------------------------------------------------------------------------
--[[ Tests
--------------------------------------------------------------------------------

GetQuestExpansion(questID)
GetQuestLink(questID)
GetQuestUiMapID(questID)
C_QuestLog.GetQuestDifficultyLevel(questID)  --> 60
C_QuestLog.GetQuestTagInfo(questID)  --> QuestTagInfo table
C_QuestLog.GetQuestType(questID)  --> Enum.QuestTag

-- local percent = math.floor((numFulfilled/numRequired) * 100);                --> TODO - Add progress percentage ???
-- GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));


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

REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/WarCampaignDocumentation.lua>
C_CampaignInfo.GetAvailableCampaigns() : campaignIDs
C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID) : campaignChapterInfo
C_CampaignInfo.GetCampaignID(questID) : campaignID
C_CampaignInfo.GetCampaignInfo(campaignID) : campaignInfo
C_CampaignInfo.GetChapterIDs(campaignID) : chapterIDs
C_CampaignInfo.GetCurrentChapterID(campaignID) : currentChapterID
C_CampaignInfo.GetFailureReason(campaignID) : failureReason
C_CampaignInfo.GetState(campaignID) : state
C_CampaignInfo.IsCampaignQuest(questID) : isCampaignQuest
C_CampaignInfo.UsesNormalQuestIcons(campaignID) : useNormalQuestIcons
C_LoreText.RequestLoreTextForCampaignID(campaignID)

CAMPAIGN_AVAILABLE_QUESTLINE = "Setzt die Kampagne fort, indem Ihr die Quest \"%s\" in %s annehmt.";
CAMPAIGN_LORE_BUTTON_HELPTIP = "Klickt auf das Geschichtsbuch, um die bisherige Geschichte zu lesen...";
CAMPAIGN_PROGRESS_CHAPTERS = "Kampagne: |cffffd200%1$d/%2$d Kapitel|r";
CAMPAIGN_PROGRESS_CHAPTERS_TOOLTIP = "|cffffd200Kampagnenfortschritt|n|cffffffff%1$d/%2$d Kapiteln|r|n|n";
STORY_CHAPTERS = "%d/%d Kapitel";

]]
--@end-do-not-package@