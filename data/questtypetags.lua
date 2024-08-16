--------------------------------------------------------------------------------
--[[ Quest Type Tags - Utility and wrapper functions for handling quest tags. ]]--
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
local LocalQuestInfo = ns.QuestInfo  --> <data\questinfo.lua>

----- Constants ----------------------------------------------------------------

--> TODO - L10n, outsource table `L`
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
local shallowCopy = true;
LocalQuestTagUtil.QUEST_TAG_ATLAS = CopyTable(QUEST_TAG_ATLAS, shallowCopy);
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
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_IMPORTANT"] = "questlog-questtypeicon-importantturnin"  -- "quest-important-turnin"
LocalQuestTagUtil.QUEST_TAG_ATLAS["COMPLETED_REPEATABLE"] = "QuestRepeatableTurnin"
LocalQuestTagUtil.QUEST_TAG_ATLAS["DAILY_CAMPAIGN"] = "Quest-DailyCampaign-Available"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT"] = "questlog-questtypeicon-important"  -- "quest-important-available"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Important] = "questlog-questtypeicon-important"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_CAMPAIGN"] = "Quest-Campaign-Available-Trivial"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_IMPORTANT"] = "quest-important-available-trivial"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL_LEGENDARY"] = "quest-legendary-available-trivial"
LocalQuestTagUtil.QUEST_TAG_ATLAS["TRIVIAL"] = "TrivialQuests"
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["MONTHLY"] = "questlog-questtypeicon-monthly"

--------------------------------------------------------------------------------

-- These types are handled separately or have fallback handler.
local classificationIgnoreTable = {
	-- Enum.QuestClassification.Important,
	-- Enum.QuestClassification.Legendary,
	Enum.QuestClassification.Campaign,
	-- Enum.QuestClassification.Calling,
	-- Enum.QuestClassification.Meta,
	-- Enum.QuestClassification.Recurring,
	-- Enum.QuestClassification.Questline,
	Enum.QuestClassification.Normal,
    -- Enum.QuestClassification.BonusObjective,
    -- Enum.QuestClassification.Threat,
    -- Enum.QuestClassification.WorldQuest,
}

local function FormatTagName(tagName, questInfo)
    if questInfo.isTrivial then
        questInfo.hasTrivialTag = true;
        return L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(tagName) or tagName;
    end

    return tagName;
end

LocalQuestTagUtil.defaultIconWidth = 20;
LocalQuestTagUtil.defaultIconHeight = 20;

function LocalQuestTagUtil:GetQuestTagInfoList(questID)
    local questInfo = LocalQuestInfo:GetQuestInfo(questID);
    -- local classificationInfo = LocalQuestInfo:GetQuestClassificationInfo(questInfo.questClassification);
    local width = self.defaultIconWidth;
    local height = self.defaultIconHeight;
    local tagInfoList = {};  --> {{atlasMarkup=..., tagName=..., tagID=...}, ...}

    -- Note: Blizzard seems to currently prioritize the classification details over tag infos. We do so as well.
    local classificationID, classificationText, classificationAtlas, clSize = LocalQuestInfo:GetQuestClassificationDetails(questID);
    if (classificationID and not tContains(classificationIgnoreTable, classificationID)) then
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(classificationAtlas, width, height),
            ["tagName"] = classificationText,
            ["tagID"] = classificationID,
            ["ranking"] = 1,  -- manually ranking the quest type
        });
        -- print("new classification:", classificationID, classificationText)
    end
    -- Quest (type) tags
    if questInfo.questTagInfo then
        local info = {};
        info["tagID"] = questInfo.questTagInfo.tagID;
        info["tagName"] = FormatTagName(questInfo.questTagInfo.tagName, questInfo);
        info["ranking"] = 2;

        if (questInfo.questTagInfo.worldQuestType ~= nil) then
            local atlasName, atlasWidth, atlasHeight = QuestUtil.GetWorldQuestAtlasInfo(questInfo.questID, questInfo.questTagInfo, questInfo.isActive)
            info["atlasMarkup"] = CreateAtlasMarkup(atlasName, width, height);
        else
            -- Check WORLD_QUEST_TYPE_ATLAS and QUEST_TAG_ATLAS for a matching icon, alternatively try our local copy of QUEST_TAG_ATLAS.
            -- Note: works only with `Enum.QuestTag` and partially with `Enum.QuestTagType`. (see `Constants.lua`)
            local atlasName = QuestUtils_GetQuestTagAtlas(questInfo.questTagInfo.tagID, questInfo.questTagInfo.worldQuestType) or self.QUEST_TAG_ATLAS[questInfo.questTagInfo.tagID];
            if atlasName then
                info["atlasMarkup"] = CreateAtlasMarkup(atlasName, width, height);
            end
        end
        if questInfo.isThreat then
            local atlas = QuestUtil.GetThreatPOIIcon(questInfo.questID);
            info["atlasMarkup"] = CreateAtlasMarkup(atlas, width, height);
        end
        if (questInfo.questTagInfo.tagID == Enum.QuestTag.Account and questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
            local factionString = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and FACTION_HORDE or FACTION_ALLIANCE;
            local factionTagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE";
            local tagName = questInfo.questTagInfo.tagName..L.TEXT_DELIMITER..PARENS_TEMPLATE:format(factionString);
            info["atlasMarkup"] = CreateAtlasMarkup(self.QUEST_TAG_ATLAS[factionTagID], width, height);
            info["tagName"] = FormatTagName(tagName, questInfo);
        end
        tinsert(tagInfoList, info);
    end
    -- Neglected or unsupported tags prior to Dragonflight (tags unsupported through `questTagInfo`, but still in `QUEST_TAG_ATLAS`)
    if questInfo.isDaily then
        local atlas = questInfo.isReadyForTurnIn and "QuestRepeatableTurnin" or self.QUEST_TAG_ATLAS.DAILY
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(atlas, width, height),
            ["tagName"] = DAILY,
            ["tagID"] = "D",
            ["ranking"] = 3,
        });
    end
    if questInfo.isWeekly then
        local atlas = questInfo.isReadyForTurnIn and "QuestRepeatableTurnin" or self.QUEST_TAG_ATLAS.WEEKLY
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(atlas, width, height),
            ["tagName"] = WEEKLY,
            ["tagID"] = "W",
            ["ranking"] = 3,
        });
    end
    if questInfo.isFailed then
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(self.QUEST_TAG_ATLAS.FAILED, width, height),
            ["tagName"] = FAILED,
            ["tagID"] = "F",
            ["ranking"] = 3,
        });
    end
    -- if questInfo.isStory then
    --     tinsert(tagInfoList, {
    --         ["atlasMarkup"] = CreateAtlasMarkup(self.QUEST_TAG_ATLAS.STORY, width, height),
    --         ["tagName"] = STORY_PROGRESS,
    --         ["tagID"] = "S",
    --         ["ranking"] = 3,
    --     });
    -- end
    -- Unsupported by QuestClassification                                       --> TODO- Check frequently, currently: 11.0.2
    if questInfo.isBonusObjective then
        local bonusClassificationID = Enum.QuestClassification.BonusObjective;
        local bonusClassificationInfo = LocalQuestInfo:GetQuestClassificationInfo(bonusClassificationID);
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(bonusClassificationInfo.atlas, width, height),
            ["tagName"] = bonusClassificationInfo.text,
            ["tagID"] = bonusClassificationID,
            ["ranking"] = 3,
        });
    end
    if questInfo.isCampaign then
        -- Is supported by classification, but icon is awful. We are going to replace it.
        local atlas = questInfo.isReadyForTurnIn and "Quest-Campaign-TurnIn" or "Quest-Campaign-Available"
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(atlas, width, height),
            ["tagName"] = FormatTagName(QUEST_CLASSIFICATION_CAMPAIGN, questInfo),
            ["tagID"] = "C",
            ["ranking"] = 3,
        });
    end
    if (questInfo.isQuestlineQuest or questInfo.hasQuestLineInfo) then
        local questlineClassificationID = Enum.QuestClassification.Questline;
        local questlineClassificationInfo = LocalQuestInfo:GetQuestClassificationInfo(questlineClassificationID);
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(questlineClassificationInfo.atlas, width, height),
            ["tagName"] = questlineClassificationInfo.text,
            ["tagID"] = questlineClassificationID,
            ["ranking"] = 3,
        });
    end
    -- Legacy Tags (removed by Blizzard from `QUEST_TAG_ATLAS`)
    if questInfo.isAccountQuest then
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup("questlog-questtypeicon-account", width, height),
            ["tagName"] = ACCOUNT_QUEST_LABEL,
            ["tagID"] = Enum.QuestTag.Account,
            ["ranking"] = 3,
        });
    end
    -- Custom tags
    if questInfo.isCompletedOnAccount then
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup("questlog-questtypeicon-account", width, height),
            ["tagName"] = ACCOUNT_COMPLETED_QUEST_LABEL,
            ["tagID"] = -1,
            ["ranking"] = 4,
        });
    end
    if questInfo.isCompleted then
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup("questlog-questtypeicon-account", width, height),
            ["tagName"] = GOAL_COMPLETED,
            ["tagID"] = -1,
            ["ranking"] = 4,
        });
    end
    if questInfo.wasEarnedByMe then
        local TEXT_DELIMITER = ITEM_NAME_DESCRIPTION_DELIMITER;
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup("questlog-questtypeicon-account", width, height),
            ["tagName"] = QUEST_COMPLETE..HEADER_COLON..TEXT_DELIMITER..UnitName("player"),
            ["tagID"] = -1,
            ["ranking"] = 4,
        });
    end

    self:AddTrivialQuestTagInfo(questInfo, tagInfoList);

    if (not questInfo.questTagInfo or questInfo.questTagInfo.tagID ~= Enum.QuestTag.Account) and (questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
        -- Add *faction group icon only* when no questTagInfo provided or not an account-wide quest
        local tagName = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and ITEM_REQ_HORDE or ITEM_REQ_ALLIANCE;
        local factionTagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE";
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup(self.QUEST_TAG_ATLAS[factionTagID], width, height),
            ["tagName"] = tagName,
            ["tagID"] = factionTagID,
            ["ranking"] = 5,
        });
    end

    return tagInfoList, questInfo;
end


-- Return all available quest tags for given quest.
---@param questID number
---@param iconWidth number
---@param iconHeight number|nil  Defaults to the size of `iconWidth`.
---@return table|nil tagData  --> `{tagName: string = tagAtlasMarkup: string, ...}` or `nil`.
--
-- REF.: [Constants.lua](https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLBase/Constants.lua),
--       [QuestUtils.lua](https://www.townlong-yak.com/framexml/live/Blizzard_FrameXMLUtil/QuestUtils.lua)
--
function LocalQuestTagUtil:GetAllQuestTags(questID, iconWidth, iconHeight)
    local questInfo = LocalQuestInfo:GetQuestInfo(questID)
    local width, height = iconWidth, iconHeight or iconWidth
    local tagData = {}
    -- Neglected tags (tags unsupported through `questTagInfo`, but still in `QUEST_TAG_ATLAS`)
    -- if questInfo.isReadyForTurnIn then                                       --> TODO - Keep ???
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
    if questInfo.isCompletedOnAccount then
        local atlasMarkup = CreateAtlasMarkup("questlog-questtypeicon-account", width, height)
        tagData[ACCOUNT_COMPLETED_QUEST_LABEL ] = atlasMarkup
    end
    -- Prefer classification over tag IDs
    if (questInfo.questClassification and not tContains(classificationIgnoreTable, questInfo.questClassification)) then  --> Enum.QuestClassification
        local classificationID, classificationText, classificationAtlas, clSize = QuestUtil.GetQuestClassificationDetails(questInfo.questID)
        -- print("questInfo.questClassification:", questInfo.questClassification, classificationText)
        -- Note: Blizzard seems to currently prioritize the classification details over tag infos.
        local atlasMarkup = CreateAtlasMarkup(classificationAtlas, width, height)
        tagData[classificationText] = atlasMarkup
    end
    -- Quest (type) tags
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
        if (questInfo.questTagInfo.tagID == Enum.QuestTagType.Threat or questInfo.isThreat) then
            local atlas = QuestUtil.GetThreatPOIIcon(questInfo.questID)
            local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
            tagData[questInfo.questTagInfo.tagName] = atlasMarkup
        end
        if (questInfo.questTagInfo.tagID == Enum.QuestTag.Account and questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
            local factionString = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and FACTION_HORDE or FACTION_ALLIANCE
            local tagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE"
            local tagName = questInfo.questTagInfo.tagName..L.TEXT_DELIMITER..PARENS_TEMPLATE:format(factionString)
            local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagID], width, height)
            tagData[tagName] = atlasMarkup
        end
    end
    if (not questInfo.questTagInfo or questInfo.questTagInfo.tagID ~= Enum.QuestTag.Account) and (questInfo.questFactionGroup ~= QuestFactionGroupID.Neutral) then
        -- Add faction group icon only when no questTagInfo provided or not an account-wide quest
        local tagName = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and ITEM_REQ_HORDE or ITEM_REQ_ALLIANCE
        local tagID = questInfo.questFactionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE"
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS[tagID], width, height)
        tagData[tagName] = atlasMarkup
    end
	if (QuestUtils_ShouldDisplayExpirationWarning(questInfo.questID) and QuestUtils_IsQuestWithinLowTimeThreshold(questInfo.questID)) then
        local atlas = QuestUtils_IsQuestWithinCriticalTimeThreshold(questInfo.questID) and "questlog-questtypeicon-clockorange" or "questlog-questtypeicon-clockyellow"
        local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
        tagData[PROFESSIONS_COLUMN_HEADER_EXPIRATION] = atlasMarkup
    end
    if questInfo.isStory then
        local atlasMarkup = CreateAtlasMarkup(QUEST_TAG_ATLAS.STORY, width, height)
        tagData[STORY_PROGRESS] = atlasMarkup
    end
    -- Legacy Tags (removed by Blizzard from `QUEST_TAG_ATLAS`)
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
    if (questInfo.isQuestlineQuest or questInfo.hasQuestLineInfo) then
        local atlasMarkup = CreateAtlasMarkup("questlog-storylineicon", width, height)
        tagData[L.CATEGORY_NAME_QUESTLINE] = atlasMarkup
    end
    if questInfo.isTrivial then
        local atlasMarkup = CreateAtlasMarkup("TrivialQuests", width, height)
        local tagName = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS)
        tagData[tagName] = atlasMarkup
    end
    if questInfo.isCampaign then -- and not questInfo.isDaily and not questInfo.isWeekly) then
        local atlas = questInfo.isReadyForTurnIn and "Quest-Campaign-TurnIn" or "Quest-Campaign-Available"
        local atlasMarkup = CreateAtlasMarkup(atlas, width, height)
        tagData[MAP_LEGEND_CAMPAIGN] = atlasMarkup
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

----- Tag: Important -----

--> TODO - L10n
-- local QUEST_TYPE_NAME_IMPORTANT = QUEST_CLASSIFICATION_IMPORTANT;

-- LocalQuestInfo.TagName = {};
-- LocalQuestInfo.TagName["IMPORTANT"] = QUEST_TYPE_NAME_IMPORTANT;
-- LocalQuestInfo.TagName["IMPORTANT_TRIVIAL"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(QUEST_TYPE_NAME_IMPORTANT);

-- LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT"] = "importantavailablequesticon";  -- "quest-important-available";
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT_ACTIVE"] = "importantactivequesticon";
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT_TURNIN"] = "quest-important-turnin";  -- "importantincompletequesticon";
-- LocalQuestTagUtil.QUEST_TAG_ATLAS["IMPORTANT_TRIVIAL"] = "quest-important-available-trivial";
-- -- LocalQuestTagUtil.QUEST_TAG_ATLAS[LocalQuestTag.Important] = "questlog-questtypeicon-important"

-- function LocalQuestTagUtil:GetImportantTagInfo(questInfo, classificationInfo)
--     -- Default values
--     local tagName = classificationInfo and classificationInfo.text or self.TagName["IMPORTANT"];
--     local atlas = classificationInfo and classificationInfo.atlas or self.QUEST_TAG_ATLAS["IMPORTANT"];
--     local info = {tagName=tagName, atlas=atlas};

--     if questInfo.isTrivial then
--         info["tagName"] = self.TagName["IMPORTANT_TRIVIAL"];
--         info["atlas"] = self.QUEST_TAG_ATLAS["IMPORTANT_TRIVIAL"];
--     end
--     if questInfo.isReadyForTurnIn then
--         info["atlas"] = self.QUEST_TAG_ATLAS["IMPORTANT_TURNIN"];
--     end
--     if info.isActive then
--         info["atlas"] = self.QUEST_TAG_ATLAS["IMPORTANT_ACTIVE"];
--     end

--     return info;
-- end

function LocalQuestTagUtil:AddTrivialQuestTagInfo(questInfo, tagInfoList)
    -- local isShallowCopy = true;
    -- local tagInfoListCopy = CopyTable(tagInfoList, isShallowCopy);
    -- -- local questTypeAlpha = QuestUtil.GetAvailableQuestIconAlpha(questInfo.questID);
    -- -- Replace primary and secondary quest type (ranking 1+2) with "trivial" details
    -- for index, tagInfo in ipairs(tagInfoListCopy) do
    --     if questInfo.isTrivial then
    --         if tContains({1, 2}, tagInfo.ranking) then
    --             tagInfoList[index] = {
    --                 ["atlasMarkup"] = tagInfo.atlasMarkup,
    --                 ["tagName"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(tagInfo.tagName),
    --                 ["tagID"] = tagInfo.tagID,
    --                 ["ranking"] = tagInfo.ranking,
    --                 ["alpha"] = 0.5,
    --             };
    --         end
    --         -- if not questInfo.hasTrivialTag then
    --         if (tagInfo.tagID ~= "T") then
    --             -- Add a standalone "trivial" tag
    --             tinsert(tagInfoList, {
    --                 ["atlasMarkup"] = CreateAtlasMarkup("TrivialQuests", 20, 20),
    --                 ["tagName"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS.."-1"),
    --                 ["tagID"] = "T",
    --                 ["ranking"] = 0,
    --                 ["alpha"] = 0.5,
    --             });
    --         end
    --         -- questInfo.hasTrivialTag = true;
    --     end
    -- end
    -- if (#tagInfoListCopy == 0 and questInfo.isTrivial and not questInfo.hasTrivialTag) then
    if (#tagInfoList <= 1 and questInfo.isTrivial and not questInfo.hasTrivialTag) then
        -- Add a standalone "trivial" tag
        tinsert(tagInfoList, {
            ["atlasMarkup"] = CreateAtlasMarkup("TrivialQuests", 20, 20),
            ["tagName"] = L.QUEST_TYPE_NAME_FORMAT_TRIVIAL:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS),
            ["tagID"] = "T",
            ["ranking"] = 0,
            ["alpha"] = 0.5,
        });
        -- questInfo.hasTrivialTag = true;
    end
end

--@do-not-package@
--------------------------------------------------------------------------------

--> TODO - New in Patch 11.0.0.:
--[[
QuestLineInfo
  + isLocalStory
  + isAccountCompleted
  + isCombatAllyQuest
  + isMeta
  + inProgress
  + isQuestStart

Enum.QuestTag
  + Delve

Enum.QuestTagType
  + Capstone
  + WorldBoss

-----

-- "Interface/QuestFrame/QuestFrameQuestIcons" (turn-in icons)
-- 
-->  only 16 pt
-- "Interface/GossipFrame/CampaignGossipIcons" (available + Callings + turn-in)
-- "Interface/GossipFrame/ImportantGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/InProgressGossipIcons" (all types)
-- "Interface/GossipFrame/LegendaryGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/RepeatableGossipIcons" (available + turn-in)
-- "Interface/GossipFrame/WrapperGossipIcons" (meta?) (available + turn-in)

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

    Name = "QuestRepeatability",
    Type = "Enumeration",
    NumValues = 5,
    MinValue = 0,
    MaxValue = 4,
    Fields =
    {
        { Name = "None", Type = "QuestRepeatability", EnumValue = 0 },
        { Name = "Daily", Type = "QuestRepeatability", EnumValue = 1 },
        { Name = "Weekly", Type = "QuestRepeatability", EnumValue = 2 },
        { Name = "Turnin", Type = "QuestRepeatability", EnumValue = 3 },
        { Name = "World", Type = "QuestRepeatability", EnumValue = 4 },
    },

    Name = "QuestTagType",
    Type = "Enumeration",
    NumValues = 19,
    MinValue = 0,
    MaxValue = 18,
    Fields =
    {
        { Name = "Tag", Type = "QuestTagType", EnumValue = 0 },
        { Name = "Profession", Type = "QuestTagType", EnumValue = 1 },
        { Name = "Normal", Type = "QuestTagType", EnumValue = 2 },
        { Name = "PvP", Type = "QuestTagType", EnumValue = 3 },
        { Name = "PetBattle", Type = "QuestTagType", EnumValue = 4 },
        { Name = "Bounty", Type = "QuestTagType", EnumValue = 5 },
        { Name = "Dungeon", Type = "QuestTagType", EnumValue = 6 },
        { Name = "Invasion", Type = "QuestTagType", EnumValue = 7 },
        { Name = "Raid", Type = "QuestTagType", EnumValue = 8 },
        { Name = "Contribution", Type = "QuestTagType", EnumValue = 9 },
        { Name = "RatedReward", Type = "QuestTagType", EnumValue = 10 },
        { Name = "InvasionWrapper", Type = "QuestTagType", EnumValue = 11 },
        { Name = "FactionAssault", Type = "QuestTagType", EnumValue = 12 },
        { Name = "Islands", Type = "QuestTagType", EnumValue = 13 },
        { Name = "Threat", Type = "QuestTagType", EnumValue = 14 },
        { Name = "CovenantCalling", Type = "QuestTagType", EnumValue = 15 },
        { Name = "DragonRiderRacing", Type = "QuestTagType", EnumValue = 16 },
        { Name = "Capstone", Type = "QuestTagType", EnumValue = 17 },
        { Name = "WorldBoss", Type = "QuestTagType", EnumValue = 18 },
    },
]]
--------------------------------------------------------------------------------
--@end-do-not-package@
