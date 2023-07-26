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

-- ACHIEVEMENT_COLOR, ACHIEVEMENT_COMPLETE_COLOR, ACHIEVEMENT_INCOMPLETE_COLOR, CAMPAIGN_COMPLETE_COLOR
-- QUEST_OBJECTIVE_FONT_COLOR, QUEST_OBJECTIVE_DISABLED_FONT_COLOR
-- QUEST_OBJECTIVE_HIGHLIGHT_FONT_COLOR, QUEST_OBJECTIVE_DISABLED_HIGHLIGHT_FONT_COLOR
-- local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
-- local C_QuestLog_GetZoneStoryInfo = C_QuestLog.GetZoneStoryInfo
local C_QuestLine_GetQuestLineQuests = C_QuestLine.GetQuestLineQuests
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
-- local GRAY = function(txt) return DISABLED_FONT_COLOR:WrapTextInColorCode(txt) end

----- Debugging -----

local DEV_MODE = false

local debug = {}
debug.isActive = DEV_MODE
debug.showChapterIDsInTooltip = DEV_MODE
debug.print = function(self, ...)
    if self.isActive then
        print(YELLOW("LM-DBG:"), ...)
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
    self:Printf(L.OPTION_STATUS_FORMAT, YELLOW(ns.pluginInfo.title), L.OPTION_STATUS_ENABLED)

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
    -- local numCriteriaTotal, numCriteriaCompleted = utils.achieve.GetWrappedAchievementNumCriteria(achievementInfo.achievementID, includeCompleted)
    -- self:Print(achievementInfo.achievementID, achievementInfo.name, format("%d/%d", numCriteriaCompleted, numCriteriaTotal))
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

-- local QuestLineCache = {}
-- QuestLineCache.includeNumCompletedCriteria = true
-- QuestLineCache.data = {}
-- QuestLineCache.Add = function(self, questLineID)
--     local info = {}
-- end


local function GetCompleteAchievementInfo(achievementID)
    local info = utils.achieve.GetWrappedAchievementInfo(achievementID)
    info.numCriteria = utils.achieve.GetWrappedAchievementNumCriteria(achievementID)
    info.numCompleted = 0
    info.criteriaList = {}
    do
        for criteriaIndex=1, info.numCriteria do
            local criteriaInfo = utils.achieve.GetWrappedAchievementCriteriaInfo(achievementID, criteriaIndex)
            if criteriaInfo then
                if criteriaInfo.completed then
                    info.numCompleted = info.numCompleted + 1
                end
                tInsert(info.criteriaList, criteriaInfo)
            end
        end
    end
    return info
end

local LocalUtils = {}
LocalUtils.processedStoryQuests = {}
LocalUtils.processedQuestLineQuests = {}
-- LocalUtils.cachedQuestLineInfos = {}

function LocalUtils:GetQuestLineInfoByPin(pin)
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua>
    local mapID = pin.mapID or pin:GetMap():GetMapID()
	-- local mapInfo = C_Map.GetMapInfo(mapID)
    debug:print("Retrieving quest line data...")
    local questLineInfo = C_QuestLine.GetQuestLineInfo(pin.questID, mapID)
    debug:print(">", questLineInfo and questLineInfo.questLineID and questLineInfo.questLineName)
    return questLineInfo
end

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
function LocalUtils:AddBlankLineToTooltip(tooltip, text, addBlankLine)
    if DEV_MODE then
        GameTooltip_AddDisabledLine(tooltip, text, false)
        if addBlankLine then GameTooltip_AddBlankLineToTooltip(tooltip) end
    else
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end
end

function LocalUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    local mapID = pin.mapID or pin:GetMap():GetMapID()
    debug:print(format("Checking zone (%s) for stories...", mapID or "n/a"))
    local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID)
    if storyAchievementID then
        local achievementInfo = GetCompleteAchievementInfo(storyAchievementID)
        -- Add zone story name
        local mapInfo = C_Map.GetMapInfo(storyMapID)
        local StoryNameTemplate = achievementInfo.completed and L.STORY_NAME_COMPLETE_FORMAT or L.STORY_NAME_INCOMPLETE_FORMAT
        GameTooltip_AddColoredLine(tooltip, StoryNameTemplate:format(achievementInfo.icon, mapInfo.name), ACHIEVEMENT_COLOR)  -- SCENARIO_STAGE_COLOR)
        -- Add chapter status
        GameTooltip_AddHighlightLine(tooltip, L.STORY_STATUS_FORMAT:format(achievementInfo.numCompleted, achievementInfo.numCriteria))
        self:AddBlankLineToTooltip(tooltip, format("> A:%d \"%s\"", storyAchievementID, achievementInfo.name), not IsShiftKeyDown())
        -- Add chapter list
        if (not achievementInfo.completed or IsShiftKeyDown()) then
            local wrapLine = false
            for i, criteriaInfo in ipairs(achievementInfo.criteriaList) do
                tInsert(self.processedStoryQuests, criteriaInfo.assetID)
                -- criteriaInfo.criteriaString = format("%d %d %s", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaString)
                -- debug:print("criteria:", criteriaInfo.criteriaType, criteriaInfo.assetID, criteriaInfo.criteriaID)
                if debug.showChapterIDsInTooltip then criteriaInfo.criteriaString = format("|cff808080%05d|r %s", criteriaInfo.assetID, criteriaInfo.criteriaString) end
                if criteriaInfo.completed then
                    GameTooltip_AddColoredLine(tooltip, L.STORY_CHAPTER_COMPLETED_FORMAT:format(criteriaInfo.criteriaString), GREEN_FONT_COLOR, wrapLine)
                else
                    GameTooltip_AddHighlightLine(tooltip, L.STORY_CHAPTER_NOT_COMPLETED_FORMAT:format(criteriaInfo.criteriaString), wrapLine)
                end
            end
        else
            -- GameTooltip_AddBlankLineToTooltip(tooltip)
            GameTooltip_AddInstructionLine(tooltip, format("Note: Hold %s to see chapters", ACTIONBAR_HOTKEY_FONT_COLOR:WrapTextInColorCode(SHIFT_KEY)))
        end
    else
        debug:print("> No stories found. :(")
    end
end

-- local function GetNumQuestLineQuests(questLineID)
--     local questList = C_QuestLine_GetQuestLineQuests(questLineID)
--     return #questList
-- end

function LocalUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
    local questLineInfo = self:GetQuestLineInfoByPin(pin)
    if not questLineInfo then return end
    -- Add quest line header
    GameTooltip_AddBlankLineToTooltip(tooltip)
    GameTooltip_AddColoredLine(tooltip, L.QUEST_LINE_NAME_FORMAT:format(questLineInfo.questLineName), SCENARIO_STAGE_COLOR)
    -- Add chapters
    local wrapLine = false
    local questIDs = C_QuestLine_GetQuestLineQuests(questLineInfo.questLineID)
    if TableIsEmpty(questIDs) then return end
    self:AddBlankLineToTooltip(tooltip, format("> L:%d \"%s\"", questLineInfo.questLineID, questLineInfo.questLineName))
    for i, questID in ipairs(questIDs) do
        if tContains(self.processedQuestLineQuests, questID) then break end
        local questFactionGroup = GetQuestFactionGroup(questID) or 3
        if PlayerMatchesQuestFactionGroup(questFactionGroup) then
            tInsert(self.processedQuestLineQuests, questID)
            -- local questName = QuestUtils_GetQuestName(questID)
            local questName = self:GetQuestName(questID)
            if questName == '' then                                         --> FIXME - Why sometimes no quest names?
                print("questName:", questID, HaveQuestData(questID))
            end
            local questTitle = QuestNameFactionGroupFormat[questFactionGroup]:format(questName)
            local questCompleted = C_QuestLog.IsComplete(questID) or C_QuestLog.IsQuestFlaggedCompleted(questID)
            if tContains(self.processedStoryQuests, questID) then questTitle = "> "..questTitle end
            -- print("quest:", questID, questLineInfo.questID, questID == questLineInfo.questID, questCompleted, isOnQuest)
            -- debug:print("quest faction:", i, questID, questFactionGroup)
            if debug.showChapterIDsInTooltip then questTitle = format("|cff808080%05d|r %s", questID, questTitle) end
            -- if tContains({QuestFactionGroupID[playerFactionGroup], QuestFactionGroupID.Neutral}, questFactionGroup) then
            if questCompleted then
                GameTooltip_AddColoredLine(tooltip, L.QUEST_LINE_CHAPTER_COMPLETED_FORMAT:format(questTitle), GREEN_FONT_COLOR, wrapLine)
            elseif (questID == questLineInfo.questID) then
                GameTooltip_AddNormalLine(tooltip, L.QUEST_LINE_CHAPTER_CURRENT_FORMAT:format(questTitle), wrapLine)
            else
                GameTooltip_AddHighlightLine(tooltip, L.QUEST_LINE_CHAPTER_NOT_COMPLETED_FORMAT:format(questTitle), wrapLine)
            end
        end
    end
    if DEV_MODE and questLineInfo.isCampaign then
        self:AddBlankLineToTooltip(tooltip, format("> > isCampaign: %s %s", tostring(questLineInfo.isCampaign), tostring(C_CampaignInfo.IsCampaignQuest(pin.questID))))
    end
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

--[[
{
    Name = "QuestLineInfo",
    Type = "Structure",
    Fields =
    {
        { Name = "questLineName", Type = "cstring", Nilable = false },
        { Name = "questName", Type = "cstring", Nilable = false },
        { Name = "questLineID", Type = "number", Nilable = false },
        { Name = "questID", Type = "number", Nilable = false },
        { Name = "x", Type = "number", Nilable = false },
        { Name = "y", Type = "number", Nilable = false },
        { Name = "isHidden", Type = "bool", Nilable = false },
        { Name = "isLegendary", Type = "bool", Nilable = false },
        { Name = "isDaily", Type = "bool", Nilable = false },
        { Name = "isCampaign", Type = "bool", Nilable = false },
        { Name = "isImportant", Type = "bool", Nilable = false },
        { Name = "floorLocation", Type = "QuestLineFloorLocation", Nilable = false },
    },
},
]]

local function Hook_OnEnter(pin)
    -- REF.: <https://www.townlong-yak.com/framexml/live/SharedTooltipTemplates.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/GameTooltip.lua>
    -- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedMapDataProviders/StorylineQuestDataProvider.lua>
    if not pin.questID then return end
    if not ShouldHookQuestPin(pin) then return end

    local tooltip = GameTooltip                                                 --> TODO - Add to options: addon name, questID, etc.
    GameTooltip_AddColoredDoubleLine(tooltip, " ", HandyNotesPlugin.name, NORMAL_FONT_COLOR, GRAY_FONT_COLOR, nil, nil)
    -- if not pin.mapID then pin.mapID = pin:GetMap():GetMapID() end  -- Needed for QuestPinTemplate
    if (pin.pinTemplate ~= LocalUtils.QuestPinTemplate) then
        -- Ignore QuestPinTemplate aka. active quests since they do show the quest type by default
        QuestUtils_AddQuestTypeToTooltip(tooltip, pin.questID, NORMAL_FONT_COLOR)
    end
    LocalUtils:AddBlankLineToTooltip(tooltip, format("> Q:%d - %s", pin.questID, pin.pinTemplate), true)
    debug:print("pin:", pin.mapID, pin:GetMap():GetMapID(), GetQuestUiMapID(pin.questID), YELLOW(pin.questType or "no-type"))
    LocalUtils:AddZoneStoryDetailsToTooltip(tooltip, pin)
    LocalUtils:AddQuestLineDetailsToTooltip(tooltip, pin)
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
    debug:print(YELLOW("Hooking active quests..."))
    hooksecurefunc(QuestPinMixin, "OnMouseEnter", Hook_OnEnter)
    hooksecurefunc(QuestPinMixin, "OnClick", Hook_OnClick)
    -- Storyline Quests
    debug:print(YELLOW("Hooking storyline quests..."))
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
    debug:print("HN args -->", state, value)
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
    if WorldMapFrame then
        local isWorldMapShown = WorldMapFrame:IsShown()
        local mapID = WorldMapFrame:GetMapID()
        local mapInfo = C_Map.GetMapInfo(mapID)
        -- Tests
        -- if (mapInfo.mapType == Enum.UIMapType.Zone) then
        --     debug:print("Requesting QL >", mapID, YELLOW(mapInfo.name))
        --     C_QuestLine.RequestQuestLinesForMap(mapID)
        -- end
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
IsBreadcrumbQuest(questID)
IsQuestSequenced(questID)
IsStoryQuest(questID)
C_QuestLog.GetQuestDifficultyLevel(questID)  --> 60
C_QuestLog.GetQuestTagInfo(questID)  --> QuestTagInfo table
C_QuestLog.GetQuestType(questID)  --> Enum.QuestTag

-- local tagInfo = C_QuestLog.GetQuestTagInfo(self.questID);
-- local quality = tagInfo and tagInfo.quality or Enum.WorldQuestQuality.Common;

-- local percent = math.floor((numFulfilled/numRequired) * 100);                --> TODO - Add progress percentage ???
-- GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));

REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/WarCampaignDocumentation.lua>
C_CampaignInfo.IsCampaignQuest(questID)
C_CampaignInfo.GetCampaignID(questID)
C_CampaignInfo.GetAvailableCampaigns()  --> list of campaignIDs

C_QuestLog.GetNextWaypoint(questID)  --> mapID, x, y
C_QuestLog.GetNextWaypointForMap(questID, uiMapID)  --> x, y
C_QuestLog.GetNextWaypointText(questID)  --> waypointText

C_QuestLine.GetAvailableQuestLines(uiMapID)  --> questLines

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

]]
--@end-do-not-package@