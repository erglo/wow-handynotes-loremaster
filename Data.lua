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
local utils = ns.utils

local LocalLoreUtil = {}  -- {debug=true, debug_prefix="LORE:"}                 --> TODO: Include debugging tools
ns.lore = LocalLoreUtil

local loremasterAchievementID = 7520  -- "The Loremaster" (category "Quests")

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
    -- [2133] = nil,  --> "Zaralek Cavern"
    -- [2151] = nil,  --> "Forbidden Reach"
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
    -- [1543] = nil,  --> "The Maw"
    -- [1970] = nil,  --> "Zereth Mortis"
}

--------------------------------------------------------------------------------

-- Convert an achievement to a criteria info table.
---@param achievementID number
---@param criteriaType number|nil
---@return table criteriaInfo
--
--> REF.: <https://wowpedia.fandom.com/wiki/API_GetAchievementCriteriaInfo>
--
local function GetWrappedCriteriaInfoByAchievementID(achievementID, criteriaType)
    local achievementInfo = ns.utils.achieve.GetWrappedAchievementInfo(achievementID)
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
    local criteriaInfoList = achievementID and ns.utils.achieve.GetAchievementCriteriaInfoList(achievementID) -- or self.criteriaInfoList
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
    self.criteriaInfoList = ns.utils.achieve.GetAchievementCriteriaInfoList(loremasterAchievementID)

    -- Add Dragonflight's "Loremaster of the Dragon Isles"
    local dfCriteriaInfo = GetWrappedCriteriaInfoByAchievementID(16585)
    tinsert(self.criteriaInfoList, dfCriteriaInfo)

    self:GetStoryQuests()
end

----- Tests ----------

TestList = ns.utils.achieve.GetAchievementCriteriaInfoList
-- TestList(7520)

Test_GetWrappedCriteriaInfoByAchievementID = GetWrappedCriteriaInfoByAchievementID
-- Test_GetWrappedCriteriaInfoByAchievementID(16585)
-- Test_GetWrappedCriteriaInfoByAchievementID(6541)

Test_PrepareData = function() return LocalLoreUtil:PrepareData() end

--@do-not-package@
--------------------------------------------------------------------------------

------------------------- (2023-10-16)
--  7520 "The Loremaster"
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

-- [1978] = {},  --> "Dragonflight"
-- [2133] = nil,  --> "Zaralek Cavern"
-- [2151] = nil,  --> "Forbidden Reach"
-- [1550] = {},  --> "Shadowlands"
-- [1543] = nil,  --> "The Maw"
-- [1970] = nil,  --> "Zereth Mortis"

-- local MissingStoryAchievementIDs = {
--     [16585] = {  --> "Loremaster of the Dragon Isles"
--         16334,  -- "Waking Hope"
--         16401,  -- "Sojourner of the Waking Shores"
--         15394,  -- "Ohn'a'Roll"
--         16405,  -- "Sojourner of Ohn'ahran Plains"
--         16336,  -- "Azure Spanner"
--         16428,  -- "Sojourner of Azure Span"
--         16363,  -- "Just Don't Ask Me to Spell It"
--         16398,  -- "Sojourner of Thaldraszus"
--     },
--     [14280] = {  --> "Loremaster of Shadowlands"
--         14281,  -- "The Path to Ascension"
--         14801,  -- "Sojourner of Bastion"
--         14206,  -- "Blade of the Primus"
--         14799,  -- "Sojourner of Maldraxxus"
--         14164,  -- "Awaken, Ardenweald"
--         14800,  -- "Sojourner of Ardenweald"
--         13878,  -- "The Master of Revendreth"
--         14798,  -- "Sojourner of Revendreth"
--     },
-- }

--@end-do-not-package@
