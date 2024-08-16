--------------------------------------------------------------------------------
--[[ Quest Information - Utility and Wrapper functions for handling quest data. ]]--
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
-- REF.: <https://warcraft.wiki.gg/wiki/World_of_Warcraft_API>
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
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestInfoSharedDocumentation.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestTaskInfoDocumentation.lua>
-- REF.: <https://warcraft.wiki.gg/wiki/API_C_QuestLog.GetQuestTagInfo>
-- (see also the function comments section for more reference)
--
--------------------------------------------------------------------------------

local AddonID, ns = ...;

-- Upvalues
local C_QuestLog = C_QuestLog;
local C_QuestInfoSystem = C_QuestInfoSystem;
local C_CampaignInfo = C_CampaignInfo;

local QuestFactionGroupID = ns.QuestFactionGroupID  --> <Data.lua>

--------------------------------------------------------------------------------

local LocalQuestInfo = {};
ns.QuestInfo = LocalQuestInfo;

-- Return the factionGroupID for the given quest.
function LocalQuestInfo:GetQuestFactionGroup(questID)
    local questFactionGroup = GetQuestFactionGroup(questID);

    return questFactionGroup or QuestFactionGroupID.Neutral;
end

-- Check if given quest is part of a questline.
function LocalQuestInfo:HasQuestLineInfo(questID, uiMapID)                      --> TODO - Refine
    if not uiMapID then
        uiMapID = ns.activeZoneMapInfo and ns.activeZoneMapInfo.mapID or WorldMapFrame:GetMapID();
    end
    return (C_QuestLine.GetQuestLineInfo(questID, uiMapID)) ~= nil
end


local function AddMoreQuestInfo(questInfo)
    local classificationID = questInfo.questClassification or LocalQuestInfo:GetQuestClassificationID(questInfo.questID);
    local tagInfo = C_QuestLog.GetQuestTagInfo(questInfo.questID);
    questInfo.isDaily = questInfo.frequency and questInfo.frequency == Enum.QuestFrequency.Daily;
    questInfo.isWeekly = questInfo.frequency and questInfo.frequency == Enum.QuestFrequency.Weekly;
    questInfo.isFailed = C_QuestLog.IsFailed(questInfo.questID);
    questInfo.isAccountQuest = tagInfo and tagInfo.tagID == Enum.QuestTag.Account or C_QuestLog.IsAccountQuest(questInfo.questID);
    questInfo.isActive = C_TaskQuest.IsActive(questInfo.questID);
    questInfo.isBonusObjective = classificationID and classificationID == Enum.QuestClassification.BonusObjective or QuestUtils_IsQuestBonusObjective(questInfo.questID);
    questInfo.isCampaign = (questInfo.campaignID ~= nil) or (classificationID and classificationID == Enum.QuestClassification.Campaign) or C_CampaignInfo.IsCampaignQuest(questInfo.questID);
    questInfo.isImportant = classificationID and classificationID == Enum.QuestClassification.Important or C_QuestLog.IsImportantQuest(questInfo.questID);
    questInfo.isLegendary = classificationID and classificationID == Enum.QuestClassification.Legendary or C_QuestLog.IsLegendaryQuest(questInfo.questID);
    questInfo.isOnQuest = C_QuestLog.IsOnQuest(questInfo.questID);
    questInfo.isQuestlineQuest = classificationID and classificationID == Enum.QuestClassification.Questline or LocalQuestInfo:HasQuestLineInfo(questInfo.questID);
    questInfo.isReadyForTurnIn = C_QuestLog.ReadyForTurnIn(questInfo.questID);
    questInfo.isThreat = classificationID and classificationID == Enum.QuestClassification.Threat or (tagInfo and tagInfo.tagID == Enum.QuestTagType.Threat);
    questInfo.isTrivial = C_QuestLog.IsQuestTrivial(questInfo.questID);
    questInfo.isWorldQuest = questInfo.isTask or (classificationID and classificationID == Enum.QuestClassification.WorldQuest) or (tagInfo and tagInfo.worldQuestType ~= nil) or QuestUtils_IsQuestWorldQuest(questInfo.questID);
    questInfo.questFactionGroup = LocalQuestInfo:GetQuestFactionGroup(questInfo.questID);
    questInfo.questTagInfo = C_QuestLog.GetQuestTagInfo(questInfo.questID);
    -- Test
    questInfo.isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questInfo.questID);
    questInfo.isCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount(questInfo.questID);
    questInfo.wasEarnedByMe = questInfo.isCompleted and not questInfo.isCompletedOnAccount;
    --> TODO: fix the following
    -- print("questInfo.isStory:", questInfo.isStory)
    -- print("questInfo.isDaily:", questInfo.isDaily)
    -- print("questInfo.isWeekly:", questInfo.isWeekly)
    -- isMeta
end

-- Retrieve native quest info for given quest.
---@param questID number
---@return QuestInfo?
-- 
-- `QuestInfo` structure (name/type): <br>
-- * `campaignID` --> `number?`  <br>
-- * `difficultyLevel` --> `number` <br>
-- * `frequency` --> `QuestFrequency?`  <br>
-- * `hasLocalPOI` --> `boolean` <br>
-- * `headerSortKey` --> `number?`  <br>
-- * `isAbandonOnDisable` --> `boolean` <br>
-- * `isAutoComplete` --> `boolean` <br>
-- * `isBounty` --> `boolean` <br>
-- * `isCollapsed` --> `boolean` <br>
-- * `isHeader` --> `boolean` <br>
-- * `isHidden` --> `boolean` <br>
-- * `isInternalOnly` --> `boolean` <br>
-- * `isOnMap` --> `boolean` <br>
-- * `isScaling` --> `boolean` <br>
-- * `isStory` --> `boolean` <br>
-- * `isTask` --> `boolean` <br>
-- * `level` --> `number` <br>
-- * `overridesSortOrder` --> `boolean` <br>
-- * `questClassification` --> `QuestClassification` <br>
-- * `questID` --> `number` <br>
-- * `questLogIndex` --> `luaIndex` <br>
-- * `readyForTranslation` --> `boolean` <br>
-- * `sortAsNormalQuest` --> `boolean` <br>
-- * `startEvent` --> `boolean` <br>
-- * `suggestedGroup` --> `number` <br>
-- * `title` --> `string` <br>
-- * `useMinimalHeader` --> `boolean` <br>
--
-- REF.: [QuestLogDocumentation.lua](https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua) <br>
-- REF.: [QuestMixin](https://www.townlong-yak.com/framexml/live/Blizzard_ObjectAPI/Quest.lua)
-- 
function LocalQuestInfo:GetQuestInfo(questID)
    local questInfo = QuestCache:Get(questID);  --> QuestMixin
    if not questInfo then
        questInfo = C_QuestLog.GetInfo(questID);
    end
    if not questInfo then return; end

    AddMoreQuestInfo(questInfo);

    return questInfo;
end

-- Wrapper functions for quest classificationIDs.
---@param questID number
---@return (Enum.QuestClassification)? classificationID
-- 
-- Supported Enum.QuestClassification types (value/name): <br>
-- *  0 "Important" <br>
-- *  1 "Legendary" <br>
-- *  2 "Campaign" <br>
-- *  3 "Calling" <br>
-- *  4 "Meta" <br>
-- *  5 "Recurring" <br>
-- *  6 "Questline" <br>
-- *  7 "Normal" <br>
-- *  8 "BonusObjective" <br>
-- *  9 "Threat" <br>
-- * 10 "WorldQuest" <br>
--
-- REF.: [QuestInfoSharedDocumentation.lua](https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestInfoSharedDocumentation.lua) <br>
-- REF.: [QuestInfoSystemDocumentation.lua](https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestInfoSystemDocumentation.lua) <br>
-- REF.: [QuestUtils.lua](https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLUtil/QuestUtils.lua) <br>
--
function LocalQuestInfo:GetQuestClassificationID(questID)
    local classificationID = C_QuestInfoSystem.GetQuestClassification(questID);
    return classificationID;
end

function LocalQuestInfo:GetQuestClassificationDetails(questID, skipFormatting)
    return QuestUtil.GetQuestClassificationDetails(questID, skipFormatting or true);
end

-- returns { text=..., atlas=..., size=...}
function LocalQuestInfo:GetQuestClassificationInfo(classificationID)
    local info = QuestUtil.GetQuestClassificationInfo(classificationID);
    -- Add text + atlas for 'BonusObjective'. Leave 'Threat' and 'WorldQuest', since their type is dynamic and handled separately.
    local classificationInfoTableMore = {
        [Enum.QuestClassification.BonusObjective] =	{ text = MAP_LEGEND_BONUSOBJECTIVE, atlas = "questbonusobjective", size = 16 },
    };
    return info or classificationInfoTableMore[classificationID];
end

--@do-not-package@
--------------------------------------------------------------------------------
--> TODO
--[[

QuestUtils_IsQuestDungeonQuest(questID)
QuestUtils_GetQuestName(questID)  --> (needed ??)
QuestUtils_GetCurrentQuestLineQuest(questLineID)
QuestUtils_IsQuestWatched(questID)

C_QuestLog.GetActiveThreatMaps()  --> uiMapID list
C_QuestLog.HasActiveThreats()  --> boolean
C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID)  --> boolean
C_QuestLog.GetBountiesForMapID(uiMapID)  --> BountyInfo list
C_QuestLog.GetMapForQuestPOIs()  --> uiMapID list
C_QuestLog.GetQuestsOnMap(questID)  --> QuestOnMapInfo list (Structure --> <QuestLogDocumentation.lua>)
C_QuestLog.GetAllCompletedQuestIDs()  --> questID list              (needed ??)
C_QuestLog.GetQuestDifficultyLevel(questID)  --> level number

C_QuestLog.GetQuestType(questID)  --> questType number
C_QuestLog.GetZoneStoryInfo(uiMapID)  --> achievementID, storyMapID
C_QuestLog.IsComplete(questID)  --> boolean
C_QuestLog.IsMetaQuest(questID)  --> boolean
C_QuestLog.IsOnMap(questID)  --> boolean                            (needed ??)
C_QuestLog.IsOnQuest(questID)  --> boolean
C_QuestLog.IsPushableQuest(questID)  --> boolean - Returns true if the quest can be shared with other players.
C_QuestLog.IsQuestFromContentPush(questID)  --> boolean
C_QuestLog.IsQuestBounty(questID)  --> boolean
C_QuestLog.IsQuestCalling(questID)  --> boolean
C_QuestLog.IsQuestDisabledForSession(questID)  --> boolean - Meaning??
C_QuestLog.QuestIgnoresAccountCompletedFiltering(questID)  --> boolean
C_QuestLog.IsQuestInvasion(questID)  --> boolean
C_QuestLog.IsQuestRepeatableType(questID)  --> boolean
C_QuestLog.IsRepeatableQuest(questID)  --> boolean - Returns true if the specified quest is a repeatable quest.
C_QuestLog.IsQuestReplayable(questID)  --> boolean - Identifies if a quest is eligible for replay with party members who have not yet completed it.
C_QuestLog.IsQuestReplayedRecently(questID)  --> boolean
C_QuestLog.IsQuestTask(questID)  --> boolean
C_QuestLog.IsThreatQuest(questID)  --> boolean
C_QuestLog.IsUnitOnQuest(unit, questID)  --> boolean

C_TaskQuest.DoesMapShowTaskQuestObjectives(uiMapID)  --> boolean
C_TaskQuest.GetQuestInfoByQuestID(questID)  -->  {questTitle, factionID?, capped?, displayAsObjective?}
C_TaskQuest.GetQuestLocation(questID, uiMapID)  --> {locationX, locationY}
C_TaskQuest.GetQuestZoneID(questID)  --> uiMapID number
C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)  --> TaskPOIData list (Structure --> <QuestTaskInfoDocumentation.lua> or below)
C_TaskQuest.GetThreatQuests()  --> questID list

--> <https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentationGenerated/QuestLineInfoDocumentation.lua>
C_QuestLine.GetAvailableQuestLines(uiMapID)  --> QuestLineInfo list
C_QuestLine.GetQuestLineInfo(questID, uiMapID, displayableOnly)  --> QuestLineInfo (Structure --> <QuestLineInfoDocumentation.lua> or below)
C_QuestLine.GetQuestLineQuests(questLineID)  --> questID list
C_QuestLine.IsComplete(questLineID)  --> boolean
C_QuestLine.QuestLineIgnoresAccountCompletedFiltering(uiMapID, questLineID)  --> boolean
C_QuestLine.RequestQuestLinesForMap(uiMapID)  --> nil

------------------------
----- Future ideas -----
------------------------

C_QuestLog.DoesQuestAwardReputationWithFaction(questID, targetFactionID)  --> boolean
C_QuestLog.GetQuestDetailsTheme(questID)  --> QuestTheme (Structure --> <QuestLogDocumentation.lua>)
C_TaskQuest.GetQuestIconUIWidgetSet(questID)  --> widgetSet number
C_TaskQuest.GetQuestTooltipUIWidgetSet(questID)  --> widgetSet number

QuestUtil.GetQuestIconOfferForQuestID(questID, isLegendary, frequency, isRepeatable, isImportant, isMeta)
QuestUtil.GetQuestIconActiveForQuestID(questID, isComplete, isLegendary, frequency, isRepeatable, isImportant, isMeta)
QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID)
QuestUtil.IsQuestActiveButNotComplete(questID)
QuestUtil.GetThreatPOIIcon(questID)  --> used in <data\questtypetags.lua>
--> <https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLUtil/QuestUtils.lua>

---------------------------
----- Quick Reference -----
---------------------------

Name = "QuestFrequency",
Type = "Enumeration",
NumValues = 4,
MinValue = 0,
MaxValue = 3,
Fields =
{
    { Name = "Default", Type = "QuestFrequency", EnumValue = 0 },
    { Name = "Daily", Type = "QuestFrequency", EnumValue = 1 },
    { Name = "Weekly", Type = "QuestFrequency", EnumValue = 2 },
    { Name = "ResetByScheduler", Type = "QuestFrequency", EnumValue = 3 },
},

Name = "QuestTag",
Type = "Enumeration",
NumValues = 12,
MinValue = 1,
MaxValue = 288,
Fields =
{
    { Name = "Group", Type = "QuestTag", EnumValue = 1 },
    { Name = "PvP", Type = "QuestTag", EnumValue = 41 },
    { Name = "Raid", Type = "QuestTag", EnumValue = 62 },
    { Name = "Dungeon", Type = "QuestTag", EnumValue = 81 },
    { Name = "Legendary", Type = "QuestTag", EnumValue = 83 },
    { Name = "Heroic", Type = "QuestTag", EnumValue = 85 },
    { Name = "Raid10", Type = "QuestTag", EnumValue = 88 },
    { Name = "Raid25", Type = "QuestTag", EnumValue = 89 },
    { Name = "Scenario", Type = "QuestTag", EnumValue = 98 },
    { Name = "Account", Type = "QuestTag", EnumValue = 102 },
    { Name = "CombatAlly", Type = "QuestTag", EnumValue = 266 },
    { Name = "Delve", Type = "QuestTag", EnumValue = 288 },
},

Name = "WorldQuestQuality",
Type = "Enumeration",
NumValues = 3,
MinValue = 0,
MaxValue = 2,
Fields =
{
    { Name = "Common", Type = "WorldQuestQuality", EnumValue = 0 },
    { Name = "Rare", Type = "WorldQuestQuality", EnumValue = 1 },
    { Name = "Epic", Type = "WorldQuestQuality", EnumValue = 2 },
},

Name = "QuestTagInfo",
Type = "Structure",
Fields =
{
    { Name = "tagName", Type = "cstring", Nilable = false },
    { Name = "tagID", Type = "number", Nilable = false },
    { Name = "worldQuestType", Type = "number", Nilable = true },
    { Name = "quality", Type = "WorldQuestQuality", Nilable = true },
    { Name = "tradeskillLineID", Type = "number", Nilable = true },
    { Name = "isElite", Type = "bool", Nilable = true },
    { Name = "displayExpiration", Type = "bool", Nilable = true },
},

Name = "TaskPOIData",
Type = "Structure",
Fields =
{
    { Name = "questId", Type = "number", Nilable = false },
    { Name = "x", Type = "number", Nilable = false },
    { Name = "y", Type = "number", Nilable = false },
    { Name = "inProgress", Type = "bool", Nilable = false },
    { Name = "numObjectives", Type = "number", Nilable = false },
    { Name = "mapID", Type = "number", Nilable = false },
    { Name = "isQuestStart", Type = "bool", Nilable = false },
    { Name = "isDaily", Type = "bool", Nilable = false },
    { Name = "isCombatAllyQuest", Type = "bool", Nilable = false },
    { Name = "isMeta", Type = "bool", Nilable = false },
    { Name = "childDepth", Type = "number", Nilable = true },
},

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
    { Name = "isLocalStory", Type = "bool", Nilable = false },
    { Name = "isDaily", Type = "bool", Nilable = false },
    { Name = "isCampaign", Type = "bool", Nilable = false },
    { Name = "isImportant", Type = "bool", Nilable = false },
    { Name = "isAccountCompleted", Type = "bool", Nilable = false },
    { Name = "isCombatAllyQuest", Type = "bool", Nilable = false },
    { Name = "isMeta", Type = "bool", Nilable = false },
    { Name = "inProgress", Type = "bool", Nilable = false },
    { Name = "isQuestStart", Type = "bool", Nilable = false },
    { Name = "floorLocation", Type = "QuestLineFloorLocation", Nilable = false },
},

]]
--------------------------------------------------------------------------------
--@end-do-not-package@