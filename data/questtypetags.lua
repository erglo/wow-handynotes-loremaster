--------------------------------------------------------------------------------
--[[ Quest Type Tags - Constants and data handler. ]]--
--
-- by erglo <erglo.coder+HNLM@gmail.com>
--
-- Copyright (C) 2024  Erwin D. Glockner (aka erglo, ergloCoder)
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
-- World of Warcraft API reference:
-- REF.: <https://www.townlong-yak.com/framexml/live/Helix/GlobalStrings.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedXMLBase/TableUtil.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_UIPanels_Game/QuestMapFrame.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/MapConstantsDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestConstantsDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLBase/Constants.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_SharedXML/SharedConstants.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestInfoSystemDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua>
-- REF.: <https://warcraft.wiki.gg/wiki/API_C_QuestLog.GetQuestTagInfo>
-- (see also the function comments section for more reference)
--
--------------------------------------------------------------------------------

local AddonID, ns = ...

local LocalQuestTagUtil = {}
ns.QuestTagUtil = LocalQuestTagUtil

local QuestFactionGroupID = ns.QuestFactionGroupID  --> <Data.lua>

----- Constants ----------------------------------------------------------------

--> TODO - Outsource table `L`
local L = {}
L.CATEGORY_NAME_QUESTLINE = QUEST_CLASSIFICATION_QUESTLINE
L.QUEST_TYPE_NAME_FORMAT_TRIVIAL = string.gsub(TRIVIAL_QUEST_DISPLAY, "|cff000000", '')
L.TEXT_DELIMITER = ITEM_NAME_DESCRIPTION_DELIMITER

-- Upvalues + Wrapper
local QUEST_TAG_ATLAS = QUEST_TAG_ATLAS
LocalQuestTagUtil.GetQuestTagInfo = function(self, questID) return C_QuestLog.GetQuestTagInfo(questID); end

-- Quest tag IDs, additional to `Enum.QuestTag` and `Enum.QuestTagType`
--> REF.: [Enum.QuestTag](https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua)
--> REF.: [Enum.QuestTagType](https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestConstantsDocumentation.lua)
--
local LocalQuestTag = {}
LocalQuestTag.Class = 21
LocalQuestTag.Escort = 84
LocalQuestTag.Artifact = 107
LocalQuestTag.WorldQuest = 109
LocalQuestTag.BurningLegionWorldQuest = 145
LocalQuestTag.BurningLegionInvasionWorldQuest = 146
LocalQuestTag.Profession = 267
-- LocalQuestTag.Threat = 268
LocalQuestTag.WarModePvP = 255
LocalQuestTag.Important = 282


-- Expand the default quest tag atlas map
-- **Note:** Before adding more tag icons, check if they're not already part of `QUEST_TAG_ATLAS`!
--
LocalQuestTagUtil.QUEST_TAG_ATLAS = {}
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Artifact] = "ArtifactQuest"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.BurningLegionWorldQuest] = "worldquest-icon-burninglegion"  --> Legion Invasion World Quest Wrapper (~= Enum.QuestTagType.Invasion)
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.BurningLegionInvasionWorldQuest] = "legioninvasion-map-icon-portal"  --> Legion Invasion World Quest Wrapper (~= Enum.QuestTagType.Invasion)
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Class] = "questlog-questtypeicon-class"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Escort] = "nameplates-InterruptShield"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Profession] = "Profession"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.WorldQuest] = "worldquest-tracker-questmarker"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Threat] = "worldquest-icon-nzoth"   -- "Ping_Map_Threat"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.WarModePvP] = "questlog-questtypeicon-pvp"
LocalQuestTagUtil.QUEST_TAG_ATLAS["CAMPAIGN"] = "Quest-Campaign-Available"
LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_CAMPAIGN"] = "Quest-Campaign-TurnIn"
LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_DAILY_CAMPAIGN"] = "Quest-DailyCampaign-TurnIn"
LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_IMPORTANT"] = "questlog-questtypeicon-importantturnin"  -- "quest-important-turnin"
LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_REPEATABLE"] = "QuestRepeatableTurnin"
LocalQuestTagUtil.QUEST_TAG_ATLAS["DAILY_CAMPAIGN"] = "Quest-DailyCampaign-Available"
LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT"] = "questlog-questtypeicon-important"  -- "quest-important-available"
LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Important] = "questlog-questtypeicon-important"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_CAMPAIGN"] = "Quest-Campaign-Available-Trivial"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_IMPORTANT"] = "quest-important-available-trivial"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_LEGENDARY"] = "quest-legendary-available-trivial"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL"] = "TrivialQuests"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["MONTHLY"] = "questlog-questtypeicon-monthly"

-- local QuestTagNames = {
--     ["CAMPAIGN"] = TRACKER_HEADER_CAMPAIGN_QUESTS,
--     ["COMPLETED"] = COMPLETE,
--     ["IMPORTANT"] = ENCOUNTER_JOURNAL_SECTION_FLAG5,
--     ["LEGENDARY"] = MAP_LEGEND_LEGENDARY,  -- ITEM_QUALITY5_DESC,
--     ["STORY"] = LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT,
--     ["TRIVIAL_CAMPAIGN"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(TRACKER_HEADER_CAMPAIGN_QUESTS),
--     ["TRIVIAL_IMPORTANT"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(ENCOUNTER_JOURNAL_SECTION_FLAG5),
--     ["TRIVIAL_LEGENDARY"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(ITEM_QUALITY5_DESC),
--     ["TRIVIAL"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS),
-- }

--------------------------------------------------------------------------------

-- Return all available quest tags for given quest.
---@param questInfo table  The quest details as returned by `LocalQuestUtils:GetQuestInfo()`.
---@param iconWidth integer  The width of the icon.
---@param iconHeight integer|nil  The height of the icon. Defaults to the size of `iconWidth`.
---@return table|nil tagData  --> `{tagName: string = tagAtlasMarkup: string, ...}` or `nil`.
--
-- REF.: [Constants.lua](https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLBase/Constants.lua),
--       [QuestUtils.lua](https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLUtil/QuestUtils.lua)
--
function LocalQuestTagUtil:GetAllQuestTags(questInfo, iconWidth, iconHeight)
    local width, height = iconWidth, iconHeight or iconWidth
    local tagData = {}
    local classificationID, classificationText, classificationAtlas, clSize = QuestUtil.GetQuestClassificationDetails(questInfo.questID)
    if classificationID then  --> Enum.QuestClassification
        questInfo.classificationID = classificationID
        -- Note: Blizzard seems to currently prioritize the classification details over tag infos.
        local atlasMarkup = CreateAtlasMarkup(classificationAtlas, width, height)
        tagData[classificationText] = atlasMarkup
    end
    if questInfo.questTagInfo then
        if (questInfo.questTagInfo.worldQuestType ~= nil) then
            local atlasName, atlasWidth, atlasHeight = QuestUtil.GetWorldQuestAtlasInfo(questInfo.questID, questInfo.questTagInfo, questInfo.isActive)
            local atlasMarkup = CreateAtlasMarkup(atlasName, width, height)
            tagData[questInfo.questTagInfo.tagName] = atlasMarkup
        end
        -- Check WORLD_QUEST_TYPE_ATLAS and QUEST_TAG_ATLAS for a matching icon.
        -- Note: works only with `Enum.QuestTag` and partially with `Enum.QuestTagType`. (see `Constants.lua`)
        local atlasName = QuestUtils_GetQuestTagAtlas(questInfo.questTagInfo.tagID, questInfo.questTagInfo.worldQuestType)
        if atlasName then
            local atlasMarkup = CreateAtlasMarkup(atlasName, width, height)
            tagData[questInfo.questTagInfo.tagName] = atlasMarkup
        -- else
        --     print("NOT found:", questInfo.questTagInfo.tagID, questInfo.questTagInfo.tagName)
        end
        if (questInfo.questTagInfo.tagID == Enum.QuestTag.Account and questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
            local factionString = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and FACTION_HORDE or FACTION_ALLIANCE
            local tagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE"
            local tagName = questInfo.questTagInfo.tagName..L.TEXT_DELIMITER..PARENS_TEMPLATE:format(factionString)
            local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagID], width, height)
            tagData[tagName] = atlasMarkup
        end
        if (questInfo.questTagInfo.tagID == Enum.QuestTagType.Threat or questInfo.isThreat) then
            local atlas = QuestUtil.GetThreatPOIIcon(questInfo.questID)
            local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
            tagData[questInfo.questTagInfo.tagName] = atlasMarkup
        end
    end
    -- Tags unsupported through `questTagInfo`, but still in `QUEST_TAG_ATLAS`
    -- if questInfo.isReadyForTurnIn then
    --     local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS.COMPLETED, width, height)
    --     tagData[GOAL_COMPLETED] = atlasMarkup
    -- end
    if questInfo.isDaily then
        local atlas = questInfo.isReadyForTurnIn and "QuestRepeatableTurnin" or QUEST_TAG_ATLAS.DAILY
        local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
        tagData[DAILY] = atlasMarkup
    end
    if questInfo.isWeekly then
        local atlas = questInfo.isReadyForTurnIn and "QuestRepeatableTurnin" or QUEST_TAG_ATLAS.WEEKLY
        local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
        tagData[WEEKLY] = atlasMarkup
    end
    if questInfo.isFailed then
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS.FAILED, width, height)
        tagData[FAILED] = atlasMarkup
    end
    if (not questInfo.questTagInfo or questInfo.questTagInfo.tagID ~= Enum.QuestTag.Account) and (questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
        -- Add faction group icon only when no questTagInfo provided or not an account-wide quest
        local tagName = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and ITEM_REQ_HORDE or ITEM_REQ_ALLIANCE
        local tagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE"
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagID], width, height)
        tagData[tagName] = atlasMarkup
    end
	if (QuestUtils_ShouldDisplayExpirationWarning(questInfo.questID) and QuestUtils_IsQuestWithinLowTimeThreshold(questInfo.questID)) then
        -- local tagID = QuestUtils_IsQuestWithinCriticalTimeThreshold(questInfo.questID) and "EXPIRING_SOON" or "EXPIRING"
        -- local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagID], width, height)
        local atlas = QuestUtils_IsQuestWithinCriticalTimeThreshold(questInfo.questID) and "questlog-questtypeicon-clockorange" or "questlog-questtypeicon-clockyellow"
        local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
        tagData[PROFESSIONS_COLUMN_HEADER_EXPIRATION] = atlasMarkup
    end
    if questInfo.isStory then
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS.STORY, width, height)
        tagData[STORY_PROGRESS] = atlasMarkup
    end
    -- Tags removed from `QUEST_TAG_ATLAS`
    if questInfo.isAccountQuest then
        local tagName = Enum.QuestTag.Account
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagName] or "questlog-questtypeicon-account", width, height)
        tagData[ACCOUNT_QUEST_LABEL] = atlasMarkup
    end
    if questInfo.isLegendary then
        local tagName = questInfo.isReadyForTurnIn and "COMPLETED_LEGENDARY" or Enum.QuestTag.Legendary
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagName] or "questlog-questtypeicon-legendary", width, height)
        tagData[MAP_LEGEND_LEGENDARY] = atlasMarkup
    end
    -- Custom tags
    if questInfo.hasQuestLineInfo then
        local atlasMarkup = CreateAtlasMarkup("questlog-storylineicon", width, height)
        tagData[L.CATEGORY_NAME_QUESTLINE] = atlasMarkup
    end
    if questInfo.isTrivial then
        local atlasMarkup = CreateAtlasMarkup("TrivialQuests", width, height)
        local tagName = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS)
        tagData[tagName] = atlasMarkup
    end
    if questInfo.isBonusObjective then
        local atlasMarkup = CreateAtlasMarkup("questbonusobjective", width, height)
        tagData[MAP_LEGEND_BONUSOBJECTIVE] = atlasMarkup
    end
    -- if questInfo.isDaily then
    --     local atlas, tagName;
    --     if questInfo.isCampaign then
    --         atlas = questInfo.isReadyForTurnIn and "Quest-DailyCampaign-TurnIn" or "Quest-DailyCampaign-Available"
    --         tagName = MAP_LEGEND_CAMPAIGN..L.TEXT_DELIMITER..PARENS_TEMPLATE:format(DAILY)
    --     else
    --         atlas = questInfo.isReadyForTurnIn and "QuestRepeatableTurnin" or "QuestDaily"
    --         tagName = DAILY  -- ERR_QUEST_OBJECTIVE_COMPLETE_S:format(DAILY)
    --     end
    --     if atlas then
    --         local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
    --         tagData[tagName] = atlasMarkup
    --     end
    -- end

    if tagData ~= {} then
        -- table.sort(tagData, function(a, b)
        --     return a[0] < b[0];  --> 0-9
        -- end)
        return tagData
    end
end

--@do-not-package@
--------------------------------------------------------------------------------

-- "Interface/QuestFrame/QuestFrameQuestIcons" (turn-in icons)
-- 
-->  only 16 pt
-- "Interface/GossipFrame/CampaignGossipIcons" (available + Callings + turn-in)
-- "Interface/GossipFrame/ImportantGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/InProgressGossipIcons" (all types)
-- "Interface/GossipFrame/LegendaryGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/RepeatableGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/WrapperGossipIcons" (meta?) (available + turn-in)
--[[
    --> 32 ("Interface/Minimap/ObjectIconsAtlas")
    "TrivialQuests"
    ok --> "QuestRepeatableTurnin" or "QuestDaily"
    "QuestTurnin" or "QuestNormal"
    "QuestLegendaryTurnin" or "QuestLegendary"
    "QuestArtifactTurnin" / "QuestArtifact"
    "Quest-Campaign-TurnIn" or "Quest-Campaign-Available"
    ok --> "Quest-DailyCampaign-TurnIn" or "Quest-DailyCampaign-Available"
    "quest-legendary-turnin" or ("quest-legendary-available-trivial" or "quest-legendary-available")
    "quest-important-turnin" or ("quest-important-available-trivial" or "quest-important-available")
    "quest-recurring-turnin" or ("quest-recurring-trivial" or "quest-recurring-available")
    "quest-wrapper-turnin" or ("quest-wrapper-trivial" or "quest-wrapper-available")

    "Callings-Turnin" or "Callings-Available"  --> 26, 33
]]
--[[
    "questlog-questtypeicon-account"  --> 18 pt
    "questlog-questtypeicon-alliance"  --> 18 pt
    "questlog-questtypeicon-class"  --> 18 pt
    "questlog-questtypeicon-daily"  --> 18 pt
    "questlog-questtypeicon-dungeon"  --> 18 pt
    "questlog-questtypeicon-group"  --> 18 pt
    "questlog-questtypeicon-heroic"  --> 18 pt
    "questlog-questtypeicon-horde"  --> 18 pt
    "questlog-questtypeicon-legendary"  --> 18 pt
    "questlog-questtypeicon-legendaryturnin"  --> 18 pt
    "questlog-questtypeicon-lock"  --> 18 pt
    "questlog-questtypeicon-monthly"  --> 18 pt
    "questlog-questtypeicon-pvp"  --> 18 pt
    "questlog-questtypeicon-quest"  --> 18 pt
    "questlog-questtypeicon-questfailed"  --> 18 pt
    "questlog-questtypeicon-raid"  --> 18 pt
    "questlog-questtypeicon-scenario"  --> 18 pt
    "questlog-questtypeicon-story"  --> 18 pt
    "questlog-questtypeicon-weekly"  --> 18 pt
    "questlog-questtypeicon-clockorange"  --> 22 pt
    "questlog-questtypeicon-clockyellow"  --> 22 pt
    "questlog-questtypeicon-important"  --> 18 pt
    "questlog-questtypeicon-importantturnin"  --> 18 pt
    "questlog-questtypeicon-Recurring"  --> 18 pt
    "questlog-questtypeicon-Recurringturnin"  --> 18 pt
    "questlog-questtypeicon-Wrapper"  --> 18 pt
    "questlog-questtypeicon-Wrapperturnin"  --> 18 pt
    "questlog-storylineicon"  --> 22 pt
    "questlog-questtypeicon-Delves"  --> 18 pt
]]
--------------------------------------------------------------------------------
--@end-do-not-package@
