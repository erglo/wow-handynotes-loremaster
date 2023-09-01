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
        ["*"] = true,
        ["collapseType_zonestory"] = "auto",
        ["collapseType_questline"] = "show",
        ["collapseType_campaign"] = "auto",
	},
}
ns.pluginInfo.options = function()
    return {
        type = 'group',
        name = ns.pluginInfo.title:gsub("HandyNotes: ", ''),  --> "Loremaster"
        desc = ns.pluginInfo.description,
        childGroups = "tab",
        get = function(info) return ns.settings[info.arg] end,
        set = function(info, value)
            ns.settings[info.arg] = value
            if ( strsplit("_", info.arg) == "collapseType") then
                LocalOptionUtils:printOption(LocalOptionUtils.collapseTypeList[value], true)
            else
                LocalOptionUtils:printOption(info.option.name, value)
            end
        end,
        args = {
            about = {
                type = "group",
                name = "About this plugin",                                     --> TODO - L10n
                order = 9,
                args = {
                    header = {
                        type = "description",
                        name = LocalOptionUtils:CreateAboutHeader(),
                        fontSize = "medium",
                        order = 0,
                    },
                    description = {
                        type = "description",
                        name = "|n"..ns.pluginInfo.description,
                        order = 1,
                    },
                    body = {
                        type = "description",
                        name = LocalOptionUtils:CreateAboutBody(),
                        order = 2,
                    },
                }
            },  --> about
            tooltip_settings = {
                type = "group",
                name = "Tooltip Content",
                desc = "Select the tooltip details which should be shown when hovering a quest icon on the world map.",
                order = 1,
                args = {
                    description = {
                        type = "description",
                        name = "Select the tooltip details which should be shown when hovering a quest icon on the world map.".."|n|n",
                        -- fontSize = "medium",
                        order = 0,
                    },
                    plugin_name = {
                        type = "toggle",
                        name = "Show Plugin Name",
                        desc = "The plugin name indicates that everything below it is content created by this plugin. Deactivate to hide the name.",
                        arg = "showPluginName",
                        -- width = "double",
                        width = 1.0,
                        order = 1,
                    },                                                          --> TODO - Show quest ID, trivial quests ???
                    category_names = {
                        type = "toggle",
                        name = "Show Category Names",
                        desc = "Each content category is indicated by its name. Deactivate to hide those names.",
                        arg = "showCategoryNames",
                        width = "double",
                        -- width = 1.0,
                        order = 2,
                    },
                    quest_type = {
                        type = "toggle",
                        name = "Show Quest Type",
                        desc = "Show or hide the type of a quest. Blizzard shows you this detail only after accepting a quest."..LocalOptionUtils:AddExampleLine(CALENDAR_TYPE_RAID, "raid"),
                        arg = "showQuestType",
                        -- width = "double",
                        order = 3,
                    },
                    quest_turn_in = {
                        type = "toggle",
                        name = format("Show %s message", string.gsub(QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN, "|cff20ff20", "|cff999999")),
                        desc = "Show or hide this message. This option affects active quests only.",
                        arg = "showQuestTurnIn",
                        width = "double",
                        order = 4,
                    },
                    zs_group = {
                        type = "group",
                        name = ZONE,
                        inline = true,
                        order = 10,
                        args = {
                            show_zone_story = {
                                type = "toggle",
                                name = "Show Zone Story",
                                desc = "Show or hide story details of the currently viewed zone.",
                                arg = "showZoneStory",
                                -- width = "double",
                                order = 1,
                            },
                            collapse_type = {
                                type = "select",
                                -- style = "radio",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_zonestory",
                                values = LocalOptionUtils.collapseTypeList,
                                order = 2,
                            },
                        },
                    },
                    ql_group = {
                        type = "group",
                        name = "Questline",
                        inline = true,
                        order = 20,
                        args = {
                            questline = {
                                type = "toggle",
                                name = "Show Questline",
                                desc = "Show or hide questline details associated with the hovered quest.",
                                arg = "showQuestLine",
                                order = 1,
                            },
                            collapse_type = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_questline",
                                values = LocalOptionUtils.collapseTypeList,
                                order = 2,
                            },
                        },
                    },
                    cp_group = {
                        type = "group",
                        name = TRACKER_HEADER_CAMPAIGN_QUESTS,
                        inline = true,
                        order = 30,
                        args = {
                            campaign = {
                                type = "toggle",
                                name = "Show Campaign",
                                desc = "Show or hide story campaign details associated with the hovered quest.",
                                arg = "showCampaign",
                                order = 1,
                            },
                            collapse_type = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_campaign",
                                values = LocalOptionUtils.collapseTypeList,
                                order = 2,
                            },
                        },
                    },
                }
            },  --> tooltip_settings
            notification_settings = {
                type = "group",
                name = "Notifications",
                desc = "Choose how or whether you want to be notified of plugin changes.",
                order = 2,
                args = {
                    description = {
                        type = "description",
                        name = "Choose how or whether you want to be notified of plugin changes.".."|n|n",
                        order = 0,
                    },
                    chat_notifications = {
                        type = "group",
                        name = CHAT_LABEL.." - "..FEATURE_NOT_YET_AVAILABLE,
                        desc = FEATURE_NOT_YET_AVAILABLE,
                        disabled = true,
                        inline = true,
                        order = 1,
                        args = {
                            incomplete_zone_stories_msg = {
                                type = "toggle",
                                name = "Incomplete Zone Stories",
                                desc = "Notifies you of Zone Stories which haven't been completed on the currently viewed map.",
                                arg = "showIncompleteZoneStories",
                                width ="double",
                                order = 10,
                            },
                            incomplete_questlines_msg = {
                                type = "toggle",
                                name = "Incomplete Questlines",
                                desc = "Notifies you of questlines which haven't been completed on the currently viewed map.",
                                arg = "showIncompleteQuestLines",
                                width ="double",
                                order = 20,
                            },
                            incomplete_campaigns_msg = {
                                type = "toggle",
                                name = "Incomplete Campaigns",
                                desc = "Notifies you of story campaigns which haven't been completed, yet.",
                                arg = "showIncompleteCampaigns",
                                width ="double",
                                order = 30,
                            },
                        },
                    },  --> chat_notifications
                },
            },  --> notification_settings
        } --> root parent group
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

LocalOptionUtils.CreateAboutHeader = function(self)
    local versionString = GRAY_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.version)
    local pluginName = NORMAL_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title)
    return "|n"..pluginName.."  "..versionString
end

LocalOptionUtils.CreateAboutBody = function(self)
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

----- Collapse Type ----------

LocalOptionUtils.collapseTypeList = {
    auto = "Auto-Collapse",  -- ..GRAY_FONT_COLOR:WrapTextInColorCode(" ("..DEFAULT..")"),
    hide = "Collapsed",
    show = "Opened",
}

LocalOptionUtils.GetCollapseTypeDescription = function(self)
    local desc = "Choose how the details in this category should be displayed."
    desc = desc.."|n|n"
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.auto..HEADER_COLON)
    desc = desc.." ".."Automatically collapse this category's details when completed."
    desc = desc.."|n|n"
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.hide..HEADER_COLON)
    desc = desc.." ".."Always show category details collapsed."
    desc = desc.."|n|n"
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.show..HEADER_COLON)
    desc = desc.." ".."Always show full category details."

    return desc
end

-- LocalOptionUtils.SetCollapseType = function(self, info, value)
--     ns.settings[info.arg] = value
--     LocalOptionUtils:printOption(info.option.name, value)
-- end

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

-- welcome_msg = {
--     type = "toggle",
--     name = "Show Plugin-is-Ready Message",
--     desc = format("Show or hide the \"%s\" message on startup.", YELLOW(LFG_READY_CHECK_PLAYER_IS_READY:format(ns.pluginInfo.title))),
--     arg = "showWelcomeMessage",
--     width ="double",
--     order = 1,
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