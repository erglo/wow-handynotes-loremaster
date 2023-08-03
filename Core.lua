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
local db

local format, tostring = string.format, tostring
local tContains, tInsert = tContains, table.insert

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

    CAMPAIGN_QUEST_FORMAT = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a This quest is part of the %s campaign.",
    CAMPAIGN_QUEST_LINE_FORMAT = "|A:Campaign-QuestLog-LoreBook-Back:16:16:0:0|a This quest line is part of the %s campaign.",

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
            print(YELLOW(prefix.." "..t.debug_prefix), select(2, ...))
        end
    elseif self.isActive then
        print(YELLOW(prefix..":"), ...)
    end
end
debug.hooks = {}
debug.hooks.debug = true
debug.hooks.debug_prefix = "HOOKS:"

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
    -- ns.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    --> Available AceDB subtables: char, realm, class, race, faction, factionrealm, profile, and global
    db = ns.db.profile

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

-- local BaseCache = {}
-- setmetatable(BaseCache, {
--     __index = function (self, key)
--         local keyString = tostring(key)
--         return self[keyString]
--     end,
--     __newindex = function(self, key, value)
--         local keyString = tostring(key)
--         self[keyString] = value
--     end}
-- )


local DBUtil = {}
DBUtil.debug = false
DBUtil.debug_prefix = GREEN("DB:")

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

local QuestCache = {}
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

local QuestLineCache = {}
QuestLineCache.debug = false
QuestLineCache.debug_prefix = "QL-CACHE:"
QuestLineCache.questLineInfos = {}  --> Structure: { ["mapID"] = {questLineInfo1, questLineInfo2, ...}, ... }
-- setmetatable(QuestLineCache.questLineInfos, BaseCache)

QuestLineCache.GetAvailableQuestLines = function(self, mapID, prepareCache)
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
        if not TableHasAnyEntries(questLineInfos) then return end  --> Still no infos
        self.questLineInfos[mapID] = questLineInfos
        debug:print(self, format("> Adding %d |4QuestLine:QuestLines; to %d", #questLineInfos, mapID))
        if prepareCache then
            for i, questLineInfo in ipairs(questLineInfos) do
                local quests = QuestCache:GetQuestLineQuests(questLineInfo.questLineID, false)
                -- Also save IDs in the database
                DBUtil:SaveSingleQuestLine(questLineInfo, mapID, quests)
            end
        end
    end

    if not prepareCache then
        local questLineInfos = self.questLineInfos[mapID]
        debug:print(self, format("Returning %d |4QuestLine:QuestLines; for %d", #questLineInfos, mapID))
        return questLineInfos
    end
end
QuestLineCache.AddSingleQuestLine = function(self, mapID, questLineInfo)
    if not self.questLineInfos[mapID] then
        self.questLineInfos[mapID] = {}
    end
    debug:print(self, format("Adding %d to %d", questLineInfo.questLineID, mapID))
    tInsert(self.questLineInfos[mapID], questLineInfo)
    -- Also save IDs in the database
    DBUtil:SaveSingleQuestLine(questLineInfo, mapID)
end
QuestLineCache.GetQuestLineInfoByPin = function(self, pin)
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
QuestLineCache.GetQuestLineInfo = function(self, questID, mapID)
    return C_QuestLine.GetQuestLineInfo(questID, mapID)
end

----- Database utilities ----------

function DBUtil:CheckInitCategory(categoryName)
    if not db[categoryName] then
        -- Save { [questLineID] = {questID=questID, mapIDs={mapID1, mapID2, ...}, quests={questID1, questID2, ...}}, ... }
        db[categoryName] = {}
        setmetatable(db[categoryName], BaseCache)
        debug:print(self, "Initialized DB:", categoryName)
    end
end

function DBUtil:SaveSingleQuestLine(questLineInfo, mapID, quests)
    local questIDs = quests or QuestCache:GetQuestLineQuests(questLineInfo.questLineID)
    -- Structure: { [questLineID] = {questID=questID, mapIDs={mapID1, mapID2, ...}, quests={questID1, questID2, ...}}, ... }
    if not db.questLines[questLineInfo.questLineID] then
        db.questLines[questLineInfo.questLineID] = {
            questID = questLineInfo.questID,
            mapIDs = {mapID},
            quests = questIDs,
        }
        debug:print(self, "Saved QL:", questLineInfo.questLineID, questLineInfo.questLineName)

    elseif not tContains(db.questLines[questLineInfo.questLineID].mapIDs, mapID) then
        tInsert(db.questLines[questLineInfo.questLineID].mapIDs, mapID)
        debug:print(self, "Added mapID to QL:", mapID, questLineInfo.questLineID)
    end
end
function DBUtil:GetSavedQuestLinesForMap(mapID)
    local infos = {}
    for questLineID, questLineData in pairs(db.questLines) do
        if tContains(questLineData.mapIDs, mapID) then
            tInsert(infos, questLineData.questID)
        end
    end
    if TableHasAnyEntries(infos) then debug:print(DBUtil, format("Loaded %d |4QuestLine:QuestLines; for %d", #infos, mapID)) end

    return infos
end
function DBUtil:GetSavedQuestLineMapForQuest(questID)
    for questLineID, questLineData in pairs(db.questLines) do
        if tContains(questLineData.quests, questID) then
            local mapID = questLineData.mapIDs[1]
            debug:print(self, "Found map for quest:", mapID)

            return mapID
        end
    end
end

----- Common utilities ----------

local LocalUtils = {}

function LocalUtils:GetQuestName(questID)
    -- REF.: <https://www.townlong-yak.com/framexml/live/QuestUtils.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
	if not HaveQuestData(questID) then
		C_QuestLog.RequestLoadQuestByID(questID);
	end
	return QuestUtils_GetQuestName(questID);
end

-- Determine different quest details
function LocalUtils:AddQuestInfoToPin(pin)
    local questID = pin.questID
    local questInfo = {
        questID = questID,
        questName = self:GetQuestName(questID),
        questMapID = GetQuestUiMapID(questID),
        questDifficulty = C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID),  --> Enum.RelativeContentDifficulty
        questExpansionID = GetQuestExpansion(questID),
        questFactionGroup = GetQuestFactionGroup(questID),
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
        -- Test
        questTagInfo = C_QuestLog.GetQuestTagInfo(questID),
        questType = C_QuestLog.GetQuestType(questID),
        questWatchType = C_QuestLog.GetQuestWatchType(questID),
        -- C_QuestLog.IsComplete(questID) : isComplete
        -- C_QuestLog.IsFailed(questID) : isFailed
        -- C_QuestLog.IsOnMap(questID) : onMap, hasLocalPOI
        -- C_QuestLog.IsOnQuest(questID) : isOnQuest
        -- C_QuestLog.IsPushableQuest(questID) : isPushable - True if the quest can be shared with other players.
        -- C_QuestLog.QuestCanHaveWarModeBonus(questID) : hasBonus
        -- C_QuestLog.QuestHasWarModeBonus(questID) : hasBonus
    }

    local activeMapID = ns.uiMapID  --> The ID of the map the user is currently looking at
    questInfo.activeMapID = activeMapID
    questInfo.pinMapID = pin.mapID
    questInfo.isActiveMap = (activeMapID == questInfo.pinMapID)
    questInfo.isQuestMap = (questInfo.questMapID == questInfo.pinMapID)
    questInfo.hasZoneStoryInfo = (C_QuestLog.GetZoneStoryInfo(activeMapID) ~= nil)
    questInfo.hasQuestLineInfo = (C_QuestLine.GetQuestLineInfo(questID, questInfo.questMapID) ~= nil)

    pin.questInfo = questInfo
end

-- In debug mode show additional quest data.
function LocalUtils:AddDebugQuestInfoLineToTooltip(tooltip, pin)
    GameTooltip_AddBlankLineToTooltip(tooltip)
    local leftHandColor, rightHandColor
    for k, v in pairs(pin.questInfo) do
        leftHandColor = (v == true) and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
        rightHandColor = (v == true) and GREEN_FONT_COLOR or NORMAL_FONT_COLOR
        GameTooltip_AddColoredDoubleLine(tooltip, k, tostring(v), leftHandColor, rightHandColor)
    end
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
    self:AddDebugLineToTooltip(tooltip, {text=format("> A:%d \"%s\"", storyAchievementID, achievementInfo.name)})
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
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
    else
        GameTooltip_AddInstructionLine(tooltip, L.STORY_SEE_CHAPTERS_KEY_FORMAT:format(GREEN(SHIFT_KEY)))
        -- GameTooltip_AddBlankLineToTooltip(tooltip)
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
            local leftOffset = 0
            if isQuestCompleted then
                GameTooltip_AddColoredLine(tooltip, L.QUEST_LINE_CHAPTER_COMPLETED_FORMAT:format(questTitle), GREEN_FONT_COLOR, wrapLine, leftOffset)
            elseif (questID == questLineInfo.questID) then
                GameTooltip_AddNormalLine(tooltip, L.QUEST_LINE_CHAPTER_CURRENT_FORMAT:format(questTitle), wrapLine, leftOffset)
            elseif isActiveQuest then
                GameTooltip_AddNormalLine(tooltip, L.QUEST_LINE_CHAPTER_CURRENT_FORMAT:format(questTitle), wrapLine, leftOffset)
            else
                GameTooltip_AddHighlightLine(tooltip, L.QUEST_LINE_CHAPTER_NOT_COMPLETED_FORMAT:format(questTitle), wrapLine, leftOffset)
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

local function ShouldHookQuestPin(pin)
    return tContains({LocalUtils.StorylineQuestPinTemplate, LocalUtils.QuestPinTemplate}, pin.pinTemplate)
end

-- local function ShouldHookWorldQuestPin(pin)
--     return pin.pinTemplate ~= WorldMap_WorldQuestDataProviderMixin:GetPinTemplate()
--     -- "BonusObjectivePinTemplate", "ThreatObjectivePinTemplate"
-- end

local function ShouldShowPluginName(pin)
    return (pin.questInfo.isReadyForTurnIn or pin.questType or IsShiftKeyDown() or pin.questInfo.isCampaign or DEV_MODE)
end

-- REF.: <https://www.townlong-yak.com/framexml/live/SharedTooltipTemplates.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/GameTooltip.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/StorylineQuestDataProvider.lua>
--
local function Hook_StorylineQuestPin_OnEnter(pin)
    if not pin.questID then return end
    if (pin.pinTemplate ~= LocalUtils.StorylineQuestPinTemplate) then return end

    local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
    local questTypeText = DEV_MODE and tostring(pin.questType) or " "
    GameTooltip_AddBlankLineToTooltip(tooltip)
    GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, GRAY_FONT_COLOR, GRAY_FONT_COLOR, nil, nil)
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
            local textFormat = hasQuestLine and L.CAMPAIGN_QUEST_LINE_FORMAT or L.CAMPAIGN_QUEST_FORMAT
            GameTooltip_AddNormalLine(tooltip, format(textFormat, SCENARIO_STAGE_COLOR:WrapTextInColorCode(campaignInfo.name)))
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

local function Hook_ActiveQuestPin_OnEnter(pin)
    if not pin.questID then return end
    if (pin.pinTemplate ~= LocalUtils.QuestPinTemplate) then return end

    -- Extend quest meta data
    pin.mapID = pin.mapID or pin:GetMap():GetMapID()
    -- pin.mapID = pin:GetMap():GetMapID()  -- always get currently active map
    if not (pin.questInfo and pin.questInfo.questID == pin.questID) then
        -- Only update (once) when hovering a different quest pin
        LocalUtils:AddQuestInfoToPin(pin)
    end

    local tooltip = GameTooltip
    -- Addon name
    if ShouldShowPluginName(pin) then
        local questTypeText = DEV_MODE and tostring(pin.questType) or " "
        GameTooltip_AddColoredDoubleLine(tooltip, questTypeText, HandyNotesPlugin.name, GRAY_FONT_COLOR, GRAY_FONT_COLOR, nil, nil)
    end
    LocalUtils:AddDebugLineToTooltip(tooltip, {text=format("> Q:%d - %s", pin.questID, pin.pinTemplate)})

    if pin.questType then                                                       --> TODO - Enhance, eg. isBounty, etc.
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
    end
    if pin.questInfo.isReadyForTurnIn then
        if tContains({"Normal", "Legendary", "Trivial"}, pin.questType) then GameTooltip_AddBlankLineToTooltip(tooltip) end
        tooltip:AddLine(QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN)
    end
    if DEV_MODE and IsShiftKeyDown() then
        LocalUtils:AddDebugQuestInfoLineToTooltip(tooltip, pin)
        GameTooltip:Show()
        return
    end
    if pin.questInfo.hasZoneStoryInfo then
        --> TODO - Optimize info retrieval to load only once (!)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        LocalUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    end
    if pin.questInfo.hasQuestLineInfo then
        --> TODO - Optimize info retrieval to load only once (!)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        LocalUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    end
    -- if pin.questInfo.isCampaign then
    --     GameTooltip_AddBlankLineToTooltip(tooltip)
    --     LocalUtils:AddCampaignDetailsTooltip(tooltip, pin)  -- , hasStory, hasQuestLine)
    -- end

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

function HandyNotesPlugin:RegisterHooks()
    -- Active Quests                                                            --> TODO - Keep ???
    debug:print(debug.hooks, YELLOW("Hooking active quests..."))
    hooksecurefunc(QuestPinMixin, "OnMouseEnter", Hook_ActiveQuestPin_OnEnter)
    -- EventRegistry:RegisterCallback("MapCanvas.QuestPin.OnEnter", HookIntoQuestTooltip, PTR_IssueReporter)
    hooksecurefunc(QuestPinMixin, "OnClick", Hook_OnClick)
    -- Storyline Quests
    debug:print(debug.hooks, YELLOW("Hooking storyline quests..."))
    hooksecurefunc(StorylineQuestPinMixin, "OnMouseEnter", Hook_StorylineQuestPin_OnEnter)
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