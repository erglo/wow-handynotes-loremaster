--------------------------------------------------------------------------------
--[[ HandyNotes: Loremaster - Options ]]--
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
-- REF.: <https://wowpedia.fandom.com/wiki/API_C_AddOns.GetAddOnMetadata>
-- (see also the function comments section for more reference)
--
--------------------------------------------------------------------------------

local AddonID, ns = ...

local LocalAchievementUtil = ns.utils.achieve
local LocalMapUtils = ns.utils.worldmap

local LocalLoreUtil = {}  -- {debug=true, debug_prefix="LORE:"}                 --> TODO: Include debugging tools
ns.lore = LocalLoreUtil

local loremasterAchievementID = 7520  -- "The Loremaster" (category "Quests")

----- Faction Groups -----------------------------------------------------------

-- Quest faction groups: {Alliance=1, Horde=2, Neutral=3}
local QuestFactionGroupID = EnumUtil.MakeEnum(PLAYER_FACTION_GROUP[1], PLAYER_FACTION_GROUP[0], "Neutral")
QuestFactionGroupID["Player"] = QuestFactionGroupID[ UnitFactionGroup("player") ]

ns.QuestFactionGroupID = QuestFactionGroupID

--------------------------------------------------------------------------------

LocalLoreUtil.OptionalAchievements = {
    -- 16585, -- "Loremaster of the Dragon Isles" (still optional in 10.2.5)
    15325, 15638, 17739, 19026, -- Dragonflight
    14961, 15259, 15579,        -- Shadowlands
    13553, 13700, 13709, 13710, -- Battle for Azeroth
    10617,                      -- Legion
     9492,  9491,               -- Draenor
     7928,  7929,  8099,        -- Pandaria
}

LocalLoreUtil.AchievementsLocationMap = {
    [2022] = { --> "Waken Shore"                        --> "Dragonflight"
        16334, -- "Waking Hope"
        16401, -- "Sojourner of the Waking Shores"
    },
    [2023] = { --> "Ohn'ahran Plains"
        15394, -- "Ohn'a'Roll"
        16405, -- "Sojourner of Ohn'ahran Plains"
    },
    [2024] = { --> "Azure Span"
        16336, -- "Azure Spanner"
        16428, -- "Sojourner of Azure Span"
    },
    [2025] = { --> "Thaldraszus"
        16363, -- "Just Don't Ask Me to Spell It"
        16398, -- "Sojourner of Thaldraszus"
    },
    [2133] = { --> "Zaralek Cavern"
        17739, -- (extra storyline) "Embers of Neltharion"
    },
    [2151] = { --> "Forbidden Reach"
        -- 15325, -- (extra storyline) "Dracthyr, Awaken" (Alliance)
        -- 15638, -- (extra storyline) "Dracthyr, Awaken" (Horde)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 15638 or 15325,
    },
    [2200] = { --> "Emerald Dream"
        19026, -- (extra storyline) "Defenders of the Dream"
    },
    [1525] = { --> "Revendreth"                         --> "Shadowlands"
        13878, -- "The Master of Revendreth"
        14798, -- "Sojourner of Revendreth"
    },
    [1533] = { --> "Bastion"
        14281, -- "The Path to Ascension"
        14801, -- "Sojourner of Bastion"
    },
    [1536] = { --> "Maldraxxus"
        14206, -- "Blade of the Primus"
        14799, -- "Sojourner of Maldraxxus"
    },
    [1565] = { --> "Ardenweald"
        14164, -- "Awaken, Ardenweald"
        14800, -- "Sojourner of Ardenweald"
    },
    [1543] = { --> "The Maw"
        14961, -- (extra storylines) "Chains of Domination"
    },
    [LocalMapUtils.ZERETH_MORTIS_MAP_ID] = { --> "Zereth Mortis"
        15259, -- (extra storylines) "Secrets of the First Ones"
        -- 15515, -- (extra storylines) "Path to Enlightenment"
        -- 15514, -- (meta) "Unlocking the Secrets"
    },

    ----- Battle for Azeroth -----

    [LocalMapUtils.NAZJATAR_MAP_ID] = {
        -- 13709, -- (extra storyline) "Unfathomable" (Horde)
        -- 13710, -- (extra storyline) "Sunken Ambitions" (Alliance)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 13709 or 13710,
        -- 13638, -- (meta achievement) "Undersea Usurper"  --> "Complete the Nazjatar achievements listed below."
    },
    [LocalMapUtils.MECHAGON_ISLAND_MAP_ID] = {
        -- 13700,  -- (extra storyline) "The Mechagonian Threat" (Horde)
        -- 13553,  -- (extra storyline) "The Mechagonian Threat" (Alliance)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 13700 or 13553,
        -- 13541, -- (meta achievement) "Mecha-Done"  --> "Complete the Mechagon achievements listed below."
    },

    ----- Legion -----

    [680] = { --> Suramar
        11124, -- "Good Suramaritan"
        10617, -- (extra storylines) "Nightfallen But Not Forgotten"  --> "Establish relations with the Nightfallen by completing the storylines below."
        -- 11340, -- (meta) "Insurrection"  --> "Complete the Suramar storylines listed below."
    },

    ----- Draenor -----

    [QuestFactionGroupID.Player == QuestFactionGroupID.Horde and LocalMapUtils.FROSTFIRE_RIDGE_MAP_ID or LocalMapUtils.SHADOWMOON_VALLEY_MAP_ID] = {
        -- 8671, -- "You'll Get Caught Up In The... Frostfire!" (Horde)
        -- 8845, -- "As I Walk Through the Valley of the Shadow of Moon" (Alliance)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 8671 or 8845,
        -- 9492, -- (extra) "The Garrison Campaign" (Horde)
        -- 9491, -- (extra) "The Garrison Campaign" (Alliance)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 9492 or 9491,
        -- 9529, -- (optional) "On the Shadow's Trail" (Horde)      --> "Complete the Frostfire Ridge storyline listed below."
        -- 9528, -- (optional) "On the Shadow's Trail" (Alliance)   --> "Complete the Shadowmoon Valley storyline listed below."
    },
    -- [534] = { --> Tanaan Jungle
    --     10072, -- (meta) "Rumble in the Jungle" (Alliance)
    --     10265, -- (meta) "Rumble in the Jungle" (Horde)
    --     QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 10265 or 10072,
    -- },

    ----- Pandaria -----

    [418] = { --> Krasarang Wilds
        -- 6535, -- "Mighty Roamin' Krasaranger" (Alliance)
        -- 6536, -- "Mighty Roamin' Krasaranger" (Horde)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 6536 or 6535,
        -- 7928, -- (extra storylines) "Operation: Shieldwall Campaign" (Alliance)
        -- 7929, -- (extra storylines) "Dominance Offensive Campaign" (Horde)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 7929 or 7928,
    },
    [504] = { --> Isle of Thunder
        8099, -- (extra storylines) "Isle of Thunder"
        -- 8121, -- (meta) "Stormbreaker"  --> "Complete the Isle of Thunder achievements listed below.""
    },

    ----- Northrend -----

    [121] = { --> Zul'Drak
        36, -- "The Empire of Zul'Drak"
        1596, -- (extra storyline) "Guru of Drakuru"
    },

    ----- Continents -----

    [LocalMapUtils.DRAGON_ISLES_MAP_ID] = {
        16585, -- "Loremaster of the Dragon Isles"
        -- 19790, -- (meta) "The Archives Called, You Answered"
    },
    [LocalMapUtils.THE_SHADOWLANDS_MAP_ID] = {
        14280, -- "Loremaster of Shadowlands"
    },
    [QuestFactionGroupID.Player == QuestFactionGroupID.Horde and LocalMapUtils.ZANDALAR_MAP_ID or LocalMapUtils.KUL_TIRAS_MAP_ID] = {
        -- 12593, -- "Loremaster of Kul Tiras" (Alliance)
        -- 13294, -- "Loremaster of Zandalar" (Horde)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 13294 or 12593,
    },
    [LocalMapUtils.BROKEN_ISLES_MAP_ID] = {
        11157, -- "Loremaster of Legion"
        -- 11544, -- (optional) "Defender of the Broken Isles"
        -- 11186, -- (optional) "Tehd & Marius' Excellent Adventure"
        -- 11240, -- (optional) "Harbinger"  --> "Unearth the stories of the Harbingers of the Legion's invasion."
    },
    [LocalMapUtils.ARGUS_MAP_ID] = {
        12066, -- "You Are Now Prepared!" (part of "Loremaster of Legion", but needs workaround)
    },
    [LocalMapUtils.DRAENOR_MAP_ID] = {
        -- 9833, -- "Loremaster of Draenor" (Alliance)
        -- 9923, -- "Loremaster of Draenor" (Horde)
        QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 9923 or 9833,
        -- 9564, -- (optional) "Securing Draenor" (Alliance)  --> "Complete the Draenor bonus objectives listed below."
        -- 9562, -- (optional) "Securing Draenor" (Horde)  --> "Complete the Draenor bonus objectives listed below."
        -- QuestFactionGroupID.Player == QuestFactionGroupID.Horde and 9562 or 9564,
    },
    [LocalMapUtils.PANDARIA_MAP_ID] = {
        6541, -- "Loremaster of Pandaria"
    },
    [LocalMapUtils.THE_MAELSTROM_MAP_ID] = {
        4875, -- "Loremaster of Cataclysm"
    },
    [LocalMapUtils.NORTHREND_MAP_ID] = {
        41, -- "Loremaster of Northrend"
    },
    [LocalMapUtils.OUTLAND_MAP_ID] = {
        1262, -- "Loremaster of Outland"
    },
    [LocalMapUtils.EASTERN_KINGDOMS_MAP_ID] = {
        1676, -- "Loremaster of Eastern Kingdoms"
    },
    [LocalMapUtils.KALIMDOR_MAP_ID] = {
        1678, -- "Loremaster of Kalimdor"
    },
    [LocalMapUtils.AZEROTH_MAP_ID] = {
        1678, -- "Loremaster of Kalimdor"
        1676, -- "Loremaster of Eastern Kingdoms"
    },
}
-- [] = {},

--------------------------------------------------------------------------------

-- Convert an achievement to a criteria info table.
---@param achievementID number
---@param criteriaType number|nil
---@return table criteriaInfo
--
--> REF.: <https://wowpedia.fandom.com/wiki/API_GetAchievementCriteriaInfo>
--
local function GetWrappedCriteriaInfoByAchievementID(achievementID, criteriaType)
    local achievementInfo = LocalAchievementUtil.GetWrappedAchievementInfo(achievementID)
    -- Default return values for GetAchievementInfo(): 
	-- 1:achievementID, 2:name, 3:points, 4:completed, 5:month, 6:day, 7:year,
	-- 8:description, 9:flags, 10:icon, 11:rewardText, 12:isGuild,
	-- 13:wasEarnedByMe, 14:earnedBy, 15:isStatistic
    local criteriaInfo = {
        assetID = achievementInfo.achievementID,
        charName = achievementInfo.wasEarnedByMe and UnitName("player") or achievementInfo.earnedBy,
        completed = achievementInfo.completed,
        criteriaID = 0,  -- Not (yet) added by Blizzard
        criteriaString = achievementInfo.name,
        criteriaType = criteriaType or 8,  -- 8: Another achievement (achievementID)
        duration = achievementInfo.completed and 0 or nil,
        elapsed = achievementInfo.completed and (time() - time({year=achievementInfo.year+2000, month=achievementInfo.month, day=achievementInfo.day})) or nil,
        eligible = true,
        flags = achievementInfo.flags,
        quantity = achievementInfo.completed and 1 or 0,
        quantityString = achievementInfo.completed and "1" or "0",
        reqQuantity = 1,
        -- icon = achievementInfo.icon,
    }

    return criteriaInfo
end

-- REF.: <https://wowpedia.fandom.com/wiki/API_GetAchievementCriteriaInfo>
--
local LocalCriteriaType = {
    Achievement = 8,
    Quest = 27,
}

LocalLoreUtil.storyQuests = {}

-- Get the criteria info list for given achievement or use LocalLoreUtil.criteriaInfoList.
---@param achievementID number|nil
--
function LocalLoreUtil:GetStoryQuests(achievementID)
    local criteriaInfoList = achievementID and LocalAchievementUtil.GetAchievementCriteriaInfoList(achievementID) -- or self.criteriaInfoList
    if criteriaInfoList then
        for i, criteriaInfo in ipairs(criteriaInfoList) do
            if C_AchievementInfo.IsValidAchievement(criteriaInfo.assetID) then
                self:GetStoryQuests(criteriaInfo.assetID)
            elseif (criteriaInfo.LocalCriteriaType == LocalCriteriaType.Quest) then
                local questID = criteriaInfo.assetID and criteriaInfo.assetID or criteriaInfo.criteriaID
                tinsert(self.storyQuests, tostring(questID))
            end
        end
    end
end

--------------------------------------------------------------------------------

function LocalLoreUtil:PrepareData()
    -- "The Loremaster" main achievement 
    self.criteriaInfoList = LocalAchievementUtil.GetAchievementCriteriaInfoList(loremasterAchievementID)

    -- Add Dragonflight's "Loremaster of the Dragon Isles"
    local dfCriteriaInfo = GetWrappedCriteriaInfoByAchievementID(16585)
    tinsert(self.criteriaInfoList, dfCriteriaInfo)

    self:GetStoryQuests()
end

--@do-not-package@
--------------------------------------------------------------------------------

----- Tests ----------

TestList = LocalAchievementUtil.GetAchievementCriteriaInfoList
-- TestList(7520)

Test_GetWrappedCriteriaInfoByAchievementID = GetWrappedCriteriaInfoByAchievementID
-- Test_GetWrappedCriteriaInfoByAchievementID(16585)
-- Test_GetWrappedCriteriaInfoByAchievementID(6541)

Test_PrepareData = function() return LocalLoreUtil:PrepareData() end

--------------------------------------------------------------------------------

------------------------- (2023-10-16)
--  7520 "The Loremaster" (Horde)
------------------------- (criteriaID, assetID, name)
-- 01.   6143  1676 Loremaster of Eastern Kingdoms
-- 02.   6144  1678 Loremaster of Kalimdor
-- 03.   6145  1262 Loremaster of Outland
-- 04.   6146    41 Loremaster of Northrend
-- 05.  16021  4875 Loremaster of Cataclysm
-- 06.  19386  6541 Loremaster of Pandaria
-- 07.  27859  9923 Loremaster of Draenor
-- 08.  32157 11157 Loremaster of Legion
-- 09a. 43881 13294 Loremaster of Zandalar
-- 09b. ----- Loremaster of Kul Tiras
-- 10.  50305 14280 Loremaster of Shadowlands
-- --.  ----- 16585 Loremaster of the Dragon Isles  (not yet added by Blizzard)

--------------------------------------------------------------------------------

-- 
-- Note: "optional" means that the achievement is NOT part of the Loremaster achievement, but
-- might be part of a storyline.
-- 
LocalLoreUtil.LoremasterAchievementsLocationMap = {

    ----- Dragonflight -----

    ["1978"] = { -- Dragon Isles
        { id = 16585, type = "continent", fallbackName = "Loremaster of the Dragon Isles" },  --> (not yet added by Blizzard to the main Loremaster achievement)
        { id = 19307, type = "continent", fallbackName = "Dragon Isles Pathfinder" },
    },
    ["2022"] = { -- Waken Shore
        { id = 16334, type = "criteria", fallbackName = "Waking Hope", criteriaIDs = {"16585", "19307"} },
        { id = 16401, type = "criteria", fallbackName = "Sojourner of the Waking Shores", criteriaID = 16585 },
        -- { id = 16292, type = "storyline", fallbackName = "Mastering the Waygates", questLineID = 1363 },  -- (optional)
    },
    ["2023"] = { -- Ohn'ahran Plains
        {id = 15394, type = "criteria", fallbackName = "Ohn'a'Roll", criteriaIDs = {"16585", "19307"} },
        {id = 16405, type = "criteria", fallbackName = "Sojourner of Ohn'ahran Plains", criteriaID = 16585 },
        {id = 16574, type = "interaction", fallbackName = "Sleeping on the Job", includeDescription = true},  -- (optional)
    },
    ["2024"] = { -- Azure Span
        { id = 16336, type = "criteria", fallbackName = "Azure Spanner", criteriaIDs = {"16585", "19307"} },
        { id = 16428, type = "criteria", fallbackName = "Sojourner of Azure Span", criteriaID = 16585 },
        { id = 16580, type = "quests", fallbackName = "Lend a Helping Span", includeDescription = true},  -- (optional)
    },
    [2025] = { --> Thaldraszus
        { id = 16363, type = "criteria", fallbackName = "Just Don't Ask Me to Spell It", criteriaIDs = {"16585", "19307"} },
        { id = 16398, type = "criteria", fallbackName = "Sojourner of Thaldraszus", criteriaID = 16585 },
        { id = 16808, type = "reputation", fallbackName = "Friend of the Dragon Isles", includeDescription = true},  -- (optional)
    },
    [2133] = { --> Zaralek Cavern
        17739, -- (extra storyline) "Embers of Neltharion"   ==>  / 
        -- 17785, -- (noteworthy) "Que Zara(lek), Zara(lek)" ==> 18804, "Neltharion's Legacy"
    },
    [2151] = { --> Forbidden Reach (extra storyline)
        { id = 15325, type = "storyline", fallbackName = "Dracthyr, Awaken", factionGroupID = QuestFactionGroupID.Alliance, questLineIDs = {1261, 1270, 1271, 1272, 1274, 1275, 1276} },
        { id = 15638, type = "storyline", fallbackName = "Dracthyr, Awaken", factionGroupID = QuestFactionGroupID.Horde, questLineIDs = {1261, 1270, 1271, 1272, 1274, 1275, 1311} },
    },
    [2200] = { --> Emerald Dream
        19026, -- (extra storyline) "Defenders of the Dream"
    },
    -- [830] = { --> Krokuun
    --     12066, -- (optional) "You Are Now Prepared!"
    --     18854, -- (optional, single ac) "Seeing Red" (Added in patch 10.1.7)
    -- },
    -- [217] = { --> Gilneas
    --     19719, -- "Reclamation of Gilneas"  (Added in patch 10.2.5)
    --     --> storyline: 5538, "The Gilneas Reclamation"
    -- },




    ----- Cataclysm -----

    -- [198] = { --> Mount Hyjal
    --     5879, -- (meta) "Veteran of the Molten Front"
    -- },

    ----- Outland -----

    -- [107] = { --> Nagrand
    --     939, -- (noteworthy) "Hills Like White Elekk"  --> "Complete all of Hemet Nesingwary quests in Nagrand up to and including The Ultimate Bloodsport."
    -- },

    -- 941, -- "Hemet Nesingwary: The Collected Quests"
    --> 938, -- "The Snows of Northrend"
    --> 939, -- "Hills Like White Elekk" (Nagrand, Outland)
    --> 940, -- "The Green Hills of Stranglethorn" (Eastern Kingdoms)

}

--@end-do-not-package@
