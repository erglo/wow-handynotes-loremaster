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

ns.currentLocale = GetLocale()
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local format = string.format

local LocalOptionUtils = {}

ns.pluginInfo = {}
ns.pluginInfo.title = GetAddOnMetadata(AddonID, "Title")
ns.pluginInfo.icon = GetAddOnMetadata(AddonID, "IconTexture") or GetAddOnMetadata(AddonID, "IconAtlas")
ns.pluginInfo.version = GetAddOnMetadata(AddonID, "Version")
ns.pluginInfo.description = GetAddOnMetadata(AddonID, "Notes-"..ns.currentLocale) or GetAddOnMetadata(AddonID, "Notes")
ns.pluginInfo.defaultOptions = {
	profile = {
		enabled = true,
        ["**"] = true,
        -- showQuesType = true,
        -- showZoneStory = true,
        -- showQuestLine = true,
        -- showCampaign = true,
        -- tooltip_settings = {
        --     ["**"] = true,
        -- }
	},
}
ns.pluginInfo.options = function(optionsHandler, currentDatabase)
    -- local HandyNotesPlugin = optionsHandler
    -- local db = currentDatabase
    return {                                                                  --> TODO - L10n
        type = 'group',
        name = ns.pluginInfo.title:gsub("HandyNotes: ", ''),  --> "Loremaster"
        desc = ns.pluginInfo.description,
        childGroups = "tab",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable plugin",
                desc = "Enable or disable this plugin.",
                order = 0,
                get = function(info) return ns.db.enabled end,
                set = function(info, value)
                    ns.db.enabled = value
                    -- HandyNotes.db.profile.enabledPlugins[AddonID] = value
                    -- if value then ns:Enable() else ns:Disable() end
                    LocalOptionUtils:printOption(info.option.name, value)
                end,
                hidden = true,
                -- disabled = ns.db.enabled,
            },
            about = {
                type = "group",
                name = "About this plugin",
                order = 9,
                args = {
                    header = {
                        type = "description",
                        name = LocalOptionUtils:GenerateAboutHeader(),
                        fontSize = "medium",
                        order = 0,
                    },
                    description = {
                        type = "description",
                        name = "|n"..ns.pluginInfo.description,
                        -- fontSize = "small",
                        order = 1,
                    },
                    body = {
                        type = "description",
                        name = LocalOptionUtils:GenerateAboutBody(),
                        -- fontSize = "medium",
                        order = 2,
                    },
                }
            },  --> about
            tooltip_settings = {
                type = "group",
                name = "Tooltip Settings",
                get = function(info) return ns.db[info.arg] end,
                set = function(info, value)
                    ns.db[info.arg] = value
                    LocalOptionUtils:printOption(info.option.name, value)
                end,
                order = 1,
                args = {
                    description = {
                        type = "description",
                        name = "Select the tooltip details which should be shown when hovering a quest icon on the world map.".."|n|n",
                        -- fontSize = "medium",
                        order = 0,
                    },
                    quest_type = {
                        type = "toggle",
                        name = "Show Quest Type",
                        desc = "Show or hide the type of a quest before accepting it."..LocalOptionUtils:AddExampleLine(CALENDAR_TYPE_RAID, "raid"),
                        arg = "showQuesType",
                        width = "full",
                        order = 5,
                    },
                    zone_story = {
                        type = "toggle",
                        name = "Show Zone Story",
                        desc = "Show or hide story details of the currently viewed zone.",
                        arg = "showZoneStory",
                        width = "double",
                        order = 10,
                    },
                    questline = {
                        type = "toggle",
                        name = "Show Questline",
                        desc = "Show or hide questline details associated with the hovered quest.",
                        arg = "showQuestLine",
                        width = "double",
                        order = 20,
                    },
                   campaign = {
                        type = "toggle",
                        name = "Show Campaign",
                        desc = "Show or hide story campaign details associated with the hovered quest.",
                        arg = "showCampaign",
                        width ="double",
                        order = 30,
                    },
                }
            },  --> tooltip_settings
        }
    }
end

----- Utility functions ----------

LocalOptionUtils.statusFormatString = SLASH_TEXTTOSPEECH_HELP_FORMATSTRING
LocalOptionUtils.statusEnabledString = VIDEO_OPTIONS_ENABLED
LocalOptionUtils.statusDisabledString = VIDEO_OPTIONS_DISABLED
LocalOptionUtils.tocKeys = {"Author", "X-Email", "X-Website", "X-License"}
LocalOptionUtils.newline = "|n|n"
LocalOptionUtils.dashLine = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s"

LocalOptionUtils.printOption = function(self, text, isEnabled)
    -- Print a user-friendly chat message about the currently selected setting.
    local msg = isEnabled and self.statusEnabledString or self.statusDisabledString
    ns:cprintf(self.statusFormatString, text, NORMAL_FONT_COLOR:WrapTextInColorCode(msg))
end

LocalOptionUtils.GenerateAboutHeader = function(self)
    local versionString = GRAY_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.version)
    local pluginName = NORMAL_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title)
    return "|n"..pluginName.."  "..versionString
end

LocalOptionUtils.GenerateAboutBody = function(self)
    local text = self.newline
    for i, key in ipairs(self.tocKeys) do
        local keyString = string.gsub(key, "X[-]", '')
        text = text..NORMAL_FONT_COLOR_CODE..keyString..FONT_COLOR_CODE_CLOSE
        text = text..HEADER_COLON.." "..GetAddOnMetadata(AddonID, key)
        text = text..self.newline
    end
    return text
end

LocalOptionUtils.AddExampleLine = function(self, text, questTypeName)
    local exampleText = "|n|n"..EXAMPLE_TEXT.."|n"
    local coloredExampleText = NORMAL_FONT_COLOR:WrapTextInColorCode(exampleText)
    -- Add type icon to text
    local iconString = format("|A:questlog-questtypeicon-%s:16:16:0:-1|a", questTypeName)
    if (questTypeName == "raid") then
        return exampleText..iconString.." "..NORMAL_FONT_COLOR:WrapTextInColorCode(text)
    end
    local lineText = self.dashLine:format(text)
    return coloredExampleText..lineText.." "..iconString
end

--@do-not-package@
--------------------------------------------------------------------------------
--[[ Tests
--------------------------------------------------------------------------------

-- function List_Plugins()
--     for pluginName, pluginHandler in pairs(HandyNotes.plugins) do
-- 		print(pluginName == pluginHandler.name, pluginName, "-->", pluginHandler.name)
-- 	end
-- end

-- Achievement IDs
local LOREMASTER_OF_THE_DRAGON_ISLES_ID = 16585

-- expand_zone_story = {
--     type = "toggle",
--     name = "Always Expand Zone Story",
--     desc = "Always show the zone story details expanded, instead of collapsed.",
--     width = 2.0,
--     order = 11,
-- },

-- campaign_questline = {
--     type = "toggle",
--     name = "Show Campaign Questline",
--     desc = "Show or hide questline details associated with a campaign.",
--     width = 2.0,
--     order = 35,
-- },

-- type_icons_settings = {
--     type = "group",
--     -- disabled = true,
--     name = "Type Icons in Quest Names",
--     order = 50,
--     args = {
--         type_icons_quests = {
--             type = "toggle",
--             name = "Quest Type",
--             desc = "Show or hide the quest type icon."..LocalOptionUtils:AddExampleLine("Quest Name", "dungeon"),
--         },
--         type_icons_factions = {
--             type = "toggle",
--             name = "Faction Type",
--             desc = "Show or hide the faction group icon."..LocalOptionUtils:AddExampleLine("Quest Name", "horde"),
--         },
--         type_icons_recurring = {
--             type = "toggle",
--             name = "Recurring Type",
--             desc = "Show or hide the quest type icon for recurring quests."..LocalOptionUtils:AddExampleLine("Quest Name", "monthly"),
--         },
--     },
-- },  --> type_icons_settings

-- quest_name_tags = {
--     type = "multiselect",
--     name = "Type Icons in Quest Names",
--     desc = "Select a type...",
--     values = {
--         showFactionTypeTags = "Faction Type",
--         showQuestTypeTags = "Quest Type",
--         showRecurringTypeTags = "Recurring Type",
--     },
--     order = 60,
-- },

]]
--@end-do-not-package@