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
LocalOptionUtils.new_paragraph = "|n|n"
LocalOptionUtils.newline = "|n"

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
        ["showQuestTypeAsText"] = false,
        ["showSingleLineAchievements"] = false,
        ["hideCompletedZonesIcon"] = false,
	},
}
ns.pluginInfo.options = function(HandyNotes)
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
            tooltip_details_zone = {
                type = "group",
                -- name = "Tooltip Content",
                name = "Tooltip"..ITEM_NAME_DESCRIPTION_DELIMITER..PARENS_TEMPLATE:format(ZONE),
                desc = "Select the tooltip details which should be shown when hovering a quest icon on the world map.",
                order = 1,
                args = {
                    description = {
                        type = "description",
                        name = "Select the tooltip details which should be shown when hovering a quest icon on the world map."..LocalOptionUtils.new_paragraph,
                        -- fontSize = "medium",
                        order = 0,
                    },
                    plugin_name = {
                        type = "toggle",
                        name = "Show Plugin Name",
                        desc = "The plugin name indicates that everything below it is content created by this plugin. Deactivate to hide the name.",
                        arg = "showPluginName",
                        width = 1.0,
                        order = 1,
                    },                                                          --> TODO - Show quest ID, trivial quests ???
                    category_names = {
                        type = "toggle",
                        name = "Show Category Names",
                        desc = "Each content category is indicated by its name. Deactivate to hide those names.",
                        arg = "showCategoryNames",
                        width = "double",
                        order = 2,
                    },
                    quest_type = {
                        type = "toggle",
                        name = "Show Quest Type",
                        desc = "Show or hide the type name and icon of a quest. Blizzard shows you this detail only after accepting a quest."..LocalOptionUtils:AddExampleLine(CALENDAR_TYPE_RAID, "raid"),
                        arg = "showQuestType",
                        -- width = "double",
                        order = 3,
                    },
                    quest_turn_in = {
                        type = "toggle",
                        name = format("Show %s Message", string.gsub(QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN, "|cff20ff20", "|cff999999")),
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
                                order = 1,
                            },
                            collapse_type = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_zonestory",
                                values = LocalOptionUtils.collapseTypeList,
                                order = 2,
                            },
                            single_line_achievements = {
                                type = "toggle",
                                name = "Single Line Achievements",
                                desc = "Displays earned story achievements in a single line instead of multiple (auto-collapsible) lines.",
                                arg = "showSingleLineAchievements",
                                width = "double",
                                order = 3,
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
                            quest_type_in_names = {
                                type = "toggle",
                                name = "Show Quest Type as Text",
                                desc = "Displays the quest type in quest titles as text instead of using icons."..LocalOptionUtils:AddExampleLine("Quest Name", WEEKLY, true, true).."|n"..PET_BATTLE_UI_VS..LocalOptionUtils:AddExampleLine("Quest Name", "WEEKLY", true, false, true),
                                arg = "showQuestTypeAsText",
                                width = "double",
                                order = 3,
                            },
                            highlight_story_quests = {
                                type = "toggle",
                                name = "Highlight Story Quests",
                                desc = format("Quests needed for a zone's Loremaster achievement will be displayed in an %s text color.", ORANGE_FONT_COLOR:WrapTextInColorCode("orange")),
                                arg = "highlightStoryQuests",
                                width = "double",
                                order = 4,
                            },
                            save_recurring_quests = {
                                type = "toggle",
                                name = "Remember Recurring Quests",
                                desc = "By default Blizzard resets recurring quests eg. daily or weekly.|nActivate to display recurring quests as completed, once they've been turned in.",
                                arg = "saveRecurringQuests",
                                width = "double",
                                order = 5,
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
            },  --> tooltip_details_zone
            tooltip_details_continent = {
                type = "group",
                name = CONTINENT,
                desc = "Select the tooltip details which should be shown when hovering a completion-check icon in continent view on the world map.",
                order = 2,
                args = {
                    description = {
                        type = "description",
                        name = "Select the tooltip details which should be shown when hovering a completion-check icon in continent view on the world map."..LocalOptionUtils.new_paragraph,
                        order = 0,
                    },
                    completed_zone_icons = {
                        type = "toggle",
                        name = "Hide Completed Zone Icon",
                        desc = "Hide the check mark icons on a continent from zones with a completed achievement.",
                        arg = "hideCompletedZonesIcon",
                        set = function(info, value)
                            ns.settings[info.arg] = value
                            HandyNotes.WorldMapDataProvider:RefreshAllData()
                        end,
                        width ="double",
                        order = 1,
                        -- disabled = true,
                    },
                },
            },  --> tooltip_details_continent
            notification_settings = {
                type = "group",
                name = "Notifications",
                desc = "Choose how or whether you want to be notified of lore relevant content.",
                order = 3,
                args = {
                    description = {
                        type = "description",
                        name = "Choose how or whether you want to be notified of plugin changes.".."|n|n",
                        order = 0,
                    },
                    chat_notifications_group = {
                        type = "group",
                        name = CHAT_LABEL,
                        inline = true,
                        order = 10,
                        args = {
                            welcome_msg = {
                                type = "toggle",
                                name = "Show Plugin-is-Ready Message",
                                desc = format("Show or hide the \"%s\" message on startup.", LFG_READY_CHECK_PLAYER_IS_READY:format(ns.pluginInfo.title)),
                                arg = "showWelcomeMessage",
                                width ="double",
                                order = 1,
                            },
                            criteria_earned_msg = {
                                type = "toggle",
                                name = "Show Progress Message",
                                desc = "Notifies you in chat when you earned a lore-relevant achievement or criteria.",
                                arg = "showCriteriaEarnedMessage",
                                width ="double",
                                order = 2,
                            },
                            -- incomplete_zone_stories_msg = {
                            --     type = "toggle",
                            --     name = "Incomplete Zone Stories",
                            --     desc = "Notifies you of Zone Stories which haven't been completed on the currently viewed map.",
                            --     arg = "showIncompleteZoneStories",
                            --     width ="double",
                            --     order = 10,
                            --     disabled = true,
                            -- },
                            -- incomplete_questlines_msg = {
                            --     type = "toggle",
                            --     name = "Incomplete Questlines",
                            --     desc = "Notifies you of questlines which haven't been completed on the currently viewed map.",
                            --     arg = "showIncompleteQuestLines",
                            --     width ="double",
                            --     order = 20,
                            --     disabled = true,
                            -- },
                            -- incomplete_campaigns_msg = {
                            --     type = "toggle",
                            --     name = "Incomplete Campaigns",
                            --     desc = "Notifies you of story campaigns which haven't been completed, yet.",
                            --     arg = "showIncompleteCampaigns",
                            --     width ="double",
                            --     order = 30,
                            --     disabled = true,
                            -- },
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
LocalOptionUtils.dashLine = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s"

LocalOptionUtils.printOption = function(self, text, isEnabled)
    -- Print a user-friendly chat message about the currently selected setting.
    local msg = isEnabled and self.statusEnabledString or self.statusDisabledString
    ns:cprintf(self.statusFormatString, text, NORMAL_FONT_COLOR:WrapTextInColorCode(msg))
end

LocalOptionUtils.CreateAboutHeader = function(self)
    local versionString = GRAY_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.version)
    local pluginName = NORMAL_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title)
    return self.newline..pluginName.."  "..versionString
end

LocalOptionUtils.CreateAboutBody = function(self)
    local text = self.new_paragraph
    for i, key in ipairs(self.tocKeys) do
        local keyString = string.gsub(key, "X[-]", '')
        text = text..NORMAL_FONT_COLOR_CODE..keyString..FONT_COLOR_CODE_CLOSE
        text = text..HEADER_COLON.." "..GetAddOnMetadata(AddonID, key)
        text = text..self.new_paragraph
    end
    return text..self.new_paragraph
end

LocalOptionUtils.AddExampleLine = function(self, text, tagName, prepend, asText, skipHeader)
    local exampleText = skipHeader and self.newline or self.new_paragraph..EXAMPLE_TEXT..self.newline
    local tagString = asText and BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(PARENS_TEMPLATE:format(tagName)) or format("|A:questlog-questtypeicon-%s:16:16:0:-1|a", tagName)
    if (tagName == "raid") then
        return exampleText..tagString..ITEM_NAME_DESCRIPTION_DELIMITER..NORMAL_FONT_COLOR:WrapTextInColorCode(text)
    end
    if prepend then
        return exampleText..format(self.dashLine, tagString)..ITEM_NAME_DESCRIPTION_DELIMITER..NORMAL_FONT_COLOR:WrapTextInColorCode(text)
    end
    return exampleText..format(self.dashLine, NORMAL_FONT_COLOR:WrapTextInColorCode(text))..ITEM_NAME_DESCRIPTION_DELIMITER..tagString
end

----- Collapse Type ----------

LocalOptionUtils.collapseTypeList = {
    auto = "Auto-Collapse",  -- ..GRAY_FONT_COLOR:WrapTextInColorCode(" ("..DEFAULT..")"),
    hide = "Collapsed",
    show = "Opened",
}

LocalOptionUtils.GetCollapseTypeDescription = function(self)
    local desc = "Choose how the details in this category should be displayed."
    desc = desc..LocalOptionUtils.new_paragraph
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.auto..HEADER_COLON)
    desc = desc.." ".."Automatically collapse this category's details when completed."
    desc = desc..LocalOptionUtils.new_paragraph
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.hide..HEADER_COLON)
    desc = desc.." ".."Always show category details collapsed."
    desc = desc..LocalOptionUtils.new_paragraph
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.show..HEADER_COLON)
    desc = desc.." ".."Always show full category details."

    return desc
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