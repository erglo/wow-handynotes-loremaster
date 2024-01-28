--------------------------------------------------------------------------------
--[[ HandyNotes: Loremaster - Options ]]--
--
-- by erglo <erglo.coder+HNLM@gmail.com>
--
-- Copyright (C) 2024  Erwin D. Glockner (aka erglo)
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
LocalOptionUtils.stringDelimiter = ITEM_NAME_DESCRIPTION_DELIMITER
LocalOptionUtils.statusFormatString = SLASH_TEXTTOSPEECH_HELP_FORMATSTRING
LocalOptionUtils.statusEnabledString = VIDEO_OPTIONS_ENABLED
LocalOptionUtils.statusDisabledString = VIDEO_OPTIONS_DISABLED
LocalOptionUtils.tocKeys = {"Author", "X-Email", "X-Website", "X-License"}
LocalOptionUtils.dashLine = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t %s"
LocalOptionUtils.dashIconString = "|TInterface\\Scenarios\\ScenarioIcon-Dash:16:16:0:-1|t"

ns.pluginInfo = {}
ns.pluginInfo.title = GetAddOnMetadata(AddonID, "Title")
ns.pluginInfo.icon = GetAddOnMetadata(AddonID, "IconTexture") or GetAddOnMetadata(AddonID, "IconAtlas")
ns.pluginInfo.version = GetAddOnMetadata(AddonID, "Version")
ns.pluginInfo.description = GetAddOnMetadata(AddonID, "Notes-"..ns.currentLocale) or GetAddOnMetadata(AddonID, "Notes")
ns.pluginInfo.defaultOptions = {
	profile = {
        ["*"] = true,
        ["collapseType_zonestory"] = "show",
        ["collapseType_questline"] = "show",
        ["collapseType_campaign"] = "show",
        ["collapseType_zoneStoryOnContinent"] = "auto",
        ["showSingleLineAchievements"] = false,
        ["showContinentSingleLineAchievements"] = false,
        ["hideCompletedContinentZoneIcons"] = false,
        ["showCampaignChapterDescription"] = false,
        ["showQuestTypeAsText"] = false,
        ["showQuestLineSeparately"] = false,
        ["scrollStep"] = 30,
        ["continentIconScale"] = 1.5,
        ["continentIconAlpha"] = 0.75,
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
                    heading = {
                        type = "description",
                        name = LocalOptionUtils:CreateAboutHeading(),
                        fontSize = "medium",
                        order = 0,
                    },
                    description = {
                        type = "description",
                        name = LocalOptionUtils.newline..ns.pluginInfo.description,
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
                name = "Tooltip"..LocalOptionUtils.stringDelimiter..PARENS_TEMPLATE:format(ZONE),
                desc = "Select the tooltip details which should be shown when hovering a quest icon on the World Map.",
                order = 1,
                childGroups = "tab",
                args = {
                    description = {
                        type = "description",
                        name = "Select the tooltip details which should be shown when hovering a quest icon on the World Map."..LocalOptionUtils.new_paragraph,
                        -- fontSize = "medium",
                        order = 0,
                    },
                    general_details = {
                        type = "group",
                        name = GENERAL_LABEL,
                        order = 1,
                        args = {
                            plugin_name = {
                                type = "toggle",
                                name = "Show Plugin Name",
                                desc = "The plugin name indicates that everything below it is content created by this plugin. Deactivate to hide the name.",
                                arg = "showPluginName",
                                width = "full",
                                order = 1,
                            },                                                          --> TODO - Show quest ID, trivial quests ???
                            category_names = {
                                type = "toggle",
                                name = "Show Category Names",
                                desc = "Each content category is indicated by its name. Deactivate to hide those names.",
                                arg = "showCategoryNames",
                                width = "full",
                                order = 2,
                            },
                            quest_type = {
                                type = "toggle",
                                name = "Show Quest Type",
                                desc = "Show or hide the type name and icon of a quest. Blizzard shows you this detail only after accepting a quest."..LocalOptionUtils:AddQuestTypeExampleLine(CALENDAR_TYPE_RAID, "raid"),
                                arg = "showQuestType",
                                width = "full",
                                order = 3,
                            },
                            quest_turn_in = {
                                type = "toggle",
                                name = format("Show %s Message", LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(QUEST_WATCH_QUEST_READY)),
                                desc = "Show or hide this message. This option affects active quests only.",
                                arg = "showQuestTurnIn",
                                width = "full",
                                order = 4,
                            },
                        },
                    },
                    zs_group = {
                        type = "group",
                        name = ZONE,
                        desc = "Show or hide story details of the currently viewed zone.",
                        inline = false,
                        order = 10,
                        args = {
                            show_zone_story = {
                                type = "toggle",
                                name = "Show Zone Story",
                                desc = "Show or hide story details of the currently viewed zone.",
                                arg = "showZoneStory",
                                width = 1.2,
                                order = 1,
                            },
                            collapse_type_sz = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_zonestory",
                                values = LocalOptionUtils.collapseTypeList,
                                disabled = function() return not ns.settings["showZoneStory"] end,
                                order = 2,
                            },
                            separate_tooltip_sz = {
                                type = "toggle",
                                name = "Use Separate Tooltip",
                                desc = "Shows the zone story details in a separate tooltip.",
                                arg = "showZoneStorySeparately",
                                disabled = function() return not ns.settings["showZoneStory"] end,
                                width = "double",
                                order = 3,
                            },
                            single_line_achievements_sz = {
                                type = "toggle",
                                name = "Single Line Achievements",
                                desc = "Displays each story achievement in a single line instead of multiple (auto-collapsible) lines.",
                                arg = "showSingleLineAchievements",
                                disabled = function() return not ns.settings["showZoneStory"] end,
                                width = "double",
                                order = 4,
                            },
                            show_chapter_quests_sz = {
                                type = "toggle",
                                name = "Include Chapter Quests",
                                desc = "Some chapters are directly linked to a quest. If activated, these will be shown below the chapter name."..LocalOptionUtils:AddExampleLine("QuestName", "SmallQuestBang"),
                                arg = "showStoryChapterQuests",
                                disabled = function() return ns.settings["showSingleLineAchievements"] or not ns.settings["showZoneStory"] end,
                                width = "double",
                                order = 5,
                            },
                            optional_stories_sz = {
                                type = "toggle",
                                name = "Include Optional Zone Stories",
                                desc = "Some zones have a story achievement of their own which is not part of any Loremaster achievement.",
                                arg = "showOptionalZoneStories",
                                disabled = function() return not ns.settings["showZoneStory"] end,
                                width = "double",
                                order = 6,
                            },
                        },
                    },
                    ql_group = {
                        type = "group",
                        name = "Questline",
                        desc = "Show or hide questline details associated with the hovered quest.",
                        inline = false,
                        order = 20,
                        args = {
                            show_questline = {
                                type = "toggle",
                                name = "Show Questline",
                                desc = "Show or hide questline details associated with the hovered quest.",
                                arg = "showQuestLine",
                                width = 1.2,
                                order = 1,
                            },
                            collapse_type_ql = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_questline",
                                values = LocalOptionUtils.collapseTypeList,
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                order = 2,
                            },
                            separate_tooltip_ql = {
                                type = "toggle",
                                name = "Use Separate Tooltip",
                                desc = "Shows the questline details in a separate tooltip.",
                                arg = "showQuestLineSeparately",
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                width = "double",
                                order = 3,
                            },
                            quest_type_names = {
                                type = "toggle",
                                name = "Quest Type Icons as Text",
                                desc = "Displays the quest type in quest names as text instead of using icons."..LocalOptionUtils:AddQuestTypeExampleLine("Quest Name", WEEKLY, true, true)..LocalOptionUtils.newline..PET_BATTLE_UI_VS..LocalOptionUtils:AddQuestTypeExampleLine("Quest Name", "WEEKLY", true, false, true),
                                arg = "showQuestTypeAsText",
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                width = "double",
                                order = 4,
                            },
                            highlight_story_quests = {
                                type = "toggle",
                                name = "Highlight Story Quests",
                                desc = "Lore-related quests will be highlighted in a different text color, if activated."..LocalOptionUtils:AddExampleLine("QuestName", nil, nil, nil, ORANGE_FONT_COLOR),
                                arg = "highlightStoryQuests",
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                width = "double",
                                order = 5,
                            },
                            save_recurring_quests = {
                                type = "toggle",
                                name = "Remember Recurring Quests",
                                desc = "By default Blizzard resets recurring quests eg. daily or weekly.|nActivate to display recurring quests as completed, once you've turned them in.",
                                arg = "saveRecurringQuests",
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                width = "double",
                                order = 6,
                            },
                            separator_pre_advanced_ql = {
                                type = "description",
                                name = LocalOptionUtils.newline,
                                order = 20,
                            },
                            header_advanced_ql = {
                                type = "header",
                                name = ADVANCED_OPTIONS,
                                desc = ADVANCED_OPTIONS_TOOLTIP,
                                width = "half",
                                order = 21,
                            },
                            separator_post_advanced_ql = {
                                type = "description",
                                name = LocalOptionUtils.newline,
                                order = 22,
                            },
                            tooltip_slider_speed_ql = {
                                type = "range",
                                name = "Tooltip Scroll Speed",
                                desc = function(info)
                                    local textTemplate = "Set the step size (speed) for the scrollbar."..LocalOptionUtils.new_paragraph..DEFAULT..HEADER_COLON..LocalOptionUtils.stringDelimiter.."%s."
                                    local valueString = tostring( ns.pluginInfo.defaultOptions.profile[info.arg] )
                                    return textTemplate:format(NORMAL_FONT_COLOR:WrapTextInColorCode(valueString))
                                end,
                                min = 10, max = 150, step = 10,
                                set = function(info, value)
                                    ns.settings[info.arg] = value
                                    -- ns:cprint(info.option.name, '-', NORMAL_FONT_COLOR:WrapTextInColorCode(tostring(value)))
                                end,
                                arg = "scrollStep",
                                disabled = function() return not ns.settings["showQuestLine"] end,
                                order = 30,
                            },
                        },
                    },
                    cp_group = {
                        type = "group",
                        name = TRACKER_HEADER_CAMPAIGN_QUESTS,
                        desc = "Show or hide story campaign details associated with the hovered quest.",
                        inline = false,
                        order = 30,
                        args = {
                            campaign = {
                                type = "toggle",
                                name = "Show Campaign",
                                desc = "Show or hide story campaign details associated with the hovered quest.",
                                arg = "showCampaign",
                                width = 1.2,
                                order = 1,
                            },
                            collapse_type_cp = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_campaign",
                                values = LocalOptionUtils.collapseTypeList,
                                disabled = function() return not ns.settings["showCampaign"] end,
                                order = 2,
                            },
                            separate_tooltip_cp = {
                                type = "toggle",
                                name = "Use Separate Tooltip",
                                desc = "Shows the campaign details in a separate tooltip.",
                                arg = "showCampaignSeparately",
                                disabled = function() return not ns.settings["showCampaign"] end,
                                width = "double",
                                order = 3,
                            },
                            chapter_description = {
                                type = "toggle",
                                name = "Include Chapter Description",
                                desc = "Some chapters have a description or an alternative chapter name.|nIf activated, these will be shown below the default chapter name."..LocalOptionUtils:AddExampleLine(DESCRIPTION, 132053),
                                arg = "showCampaignChapterDescription",
                                disabled = function() return not ns.settings["showCampaign"] end,
                                width = "double",
                                order = 4,
                            },
                            campaign_description = {
                                type = "toggle",
                                name = "Show Campaign Description",
                                desc = "Some campaigns have a description.|nIf activated, it will be shown below the chapter list."..LocalOptionUtils:AddExampleLine(DESCRIPTION),
                                arg = "showCampaignDescription",
                                disabled = function() return not ns.settings["showCampaign"] end,
                                width = "double",
                                order = 5,
                            },
                        },
                    },
                }
            },  --> tooltip_details_zone
            continent_settings = {
                type = "group",
                name = CONTINENT,
                desc = "Select the details for the continent view on the World Map.",
                childGroups = "tab",
                order = 2,
                args = {
                    description = {
                        type = "description",
                        name = "Select the details for the continent view on the World Map."..LocalOptionUtils.new_paragraph,
                        order = 0,
                    },
                    show_zone_icons = {
                        type = "toggle",
                        name = "Show Zone Icon",
                        desc = "Shows the check mark icons on a continent for zones with at least one achievement.",
                        set = function(info, value)
                            ns.settings[info.arg] = value
                            HandyNotes:UpdateWorldMapPlugin(AddonID)
                            LocalOptionUtils:printOption(info.option.name, value)
                        end,
                        arg = "showContinentZoneIcons",
                        width ="double",
                        order = 1,
                    },
                    completed_zone_icons = {
                        type = "toggle",
                        name = "Hide Completed Zone Icon",
                        desc = "Hide the check mark icons on a continent from zones with a completed achievement.",
                        set = function(info, value)
                            ns.settings[info.arg] = value
                            HandyNotes:UpdateWorldMapPlugin(AddonID)
                            LocalOptionUtils:printOption(info.option.name, value)
                        end,
                        arg = "hideCompletedContinentZoneIcons",
                        disabled = function() return not ns.settings["showContinentZoneIcons"] end,
                        width ="double",
                        order = 2,
                    },
                    optional_stories_szc = {
                        type = "toggle",
                        name = "Include Optional Zone Stories",
                        desc = "Some zones have a story achievement of their own which is not part of any Loremaster achievement.",
                        set = function(info, value)
                            ns.settings[info.arg] = value
                            wipe(ns.nodes)
                            HandyNotes:UpdateWorldMapPlugin(AddonID)
                        end,
                        arg = "showContinentOptionalZoneStories",
                        disabled = function() return not ns.settings["showContinentZoneIcons"] end,
                        width = "double",
                        order = 3,
                    },
                    continent_tooltip_group = {
                        type = "group",
                        name = "Tooltip",
                        inline = false,
                        disabled = function() return not ns.settings["showContinentZoneIcons"] end,
                        order = 10,
                        args = {
                            description = {
                                type = "description",
                                name = "Select the tooltip details which should be shown when hovering a completion-check icon in continent view on the World Map.", --..LocalOptionUtils.new_paragraph,
                                order = 0,
                            },
                            single_line_achievements_szc = {
                                type = "toggle",
                                name = "Single Line Achievements",
                                desc = "Displays story achievements in a single line instead of multiple (auto-collapsible) lines.",
                                arg = "showContinentSingleLineAchievements",
                                width = 1.2,
                                order = 1,
                            },
                            collapse_type_szc = {
                                type = "select",
                                name = "Select Display Type...",
                                desc = LocalOptionUtils.GetCollapseTypeDescription,
                                arg = "collapseType_zoneStoryOnContinent",
                                values = LocalOptionUtils.collapseTypeList,
                                order = 2,
                            },
                            chapter_quests_szc = {
                                type = "toggle",
                                name = "Include Chapter Quests",
                                desc = "Some chapters are directly linked to a quest.|nIf activated, these will be shown below the default chapter name."..LocalOptionUtils:AddExampleLine("QuestName", "SmallQuestBang"),
                                arg = "showContinentStoryChapterQuests",
                                disabled = function() return ns.settings["showContinentSingleLineAchievements"] end,
                                width = "double",
                                order = 3,
                            },
                        },
                    },  --> continent_tooltip_group
                    continent_advanced_group = {
                        type = "group",
                        name = ADVANCED_OPTIONS,
                        desc = ADVANCED_OPTIONS_TOOLTIP,
                        inline = false,
                        disabled = function() return not ns.settings["showContinentZoneIcons"] end,
                        order = 20,
                        args = {
                            description = {
                                type = "description",
                                name = ADVANCED_OPTIONS_TOOLTIP..LocalOptionUtils.new_paragraph,
                                order = 0,
                            },
                            icon_scale_szc = {
                                type = "range",
                                name = "World Map Icon Scale",
                                desc = "The size of the continent icons on the World Map",
                                min = 0.3,
                                max = 3,
                                step = 0.1,
                                set = function(info, value)
                                    ns.settings[info.arg] = value
                                    wipe(ns.nodes)
                                    HandyNotes:UpdateWorldMapPlugin(AddonID)
                                end,
                                arg = "continentIconScale",
                                order = 23,
                            },
                            icon_alpha_szc = {
                                type = "range",
                                name = "World Map Icon Alpha",
                                desc = "The overall alpha transparency of the icons on the World Map",
                                min = 0,
                                max = 1,
                                step = 0.01,
                                isPercent = true,
                                set = function(info, value)
                                    ns.settings[info.arg] = value
                                    wipe(ns.nodes)
                                    HandyNotes:UpdateWorldMapPlugin(AddonID)
                                end,
                                arg = "continentIconAlpha",
                                order = 24,
                            },
                        },
                    },  --> continent_advanced_group
                },
            },  --> continent_settings
            notification_settings = {
                type = "group",
                name = "Notifications",
                desc = "Choose how or whether you want to be notified of lore relevant content.",
                order = 3,
                args = {
                    description = {
                        type = "description",
                        name = "Choose how or whether you want to be notified of plugin changes."..LocalOptionUtils.new_paragraph,
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
                                name = "Show Achievement Progress Message",
                                desc = "Notifies you in chat when you earned a lore relevant achievement or criteria.",
                                arg = "showCriteriaEarnedMessage",
                                width ="double",
                                order = 2,
                            },
                            quest_is_questline_msg = {
                                type = "toggle",
                                name = "Show Questline Progress Message",
                                desc = "Notifies you in chat when you accepted or completed a questline quest.",
                                arg = "showQuestlineQuestProgressMessage",
                                width ="double",
                                order = 3,
                            },
                            quest_is_campaign_msg = {
                                type = "toggle",
                                name = "Show Campaign Progress Message",
                                desc = "Notifies you in chat when you accepted or completed a quest which is part of a campaign.",
                                arg = "showCampaignQuestProgressMessage",
                                width ="double",
                                order = 4,
                            },
                        },
                    },  --> chat_notifications
                },
            },  --> notification_settings
        } --> root parent group
    }
end

----- Utility functions ----------

LocalOptionUtils.printOption = function(self, text, isEnabled)
    -- Print a user-friendly chat message about the currently selected setting.
    local msg = isEnabled and self.statusEnabledString or self.statusDisabledString
    ns:cprintf(self.statusFormatString, text or '', NORMAL_FONT_COLOR:WrapTextInColorCode(msg))
end

LocalOptionUtils.CreateAboutHeading = function(self)
    local versionString = GRAY_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.version)
    local pluginName = NORMAL_FONT_COLOR:WrapTextInColorCode(ns.pluginInfo.title)
    return self.newline..pluginName..LocalOptionUtils.stringDelimiter..versionString
end

LocalOptionUtils.CreateAboutBody = function(self)
    local text = self.new_paragraph
    for i, key in ipairs(self.tocKeys) do
        local keyString = string.gsub(key, "X[-]", '')
        text = text..NORMAL_FONT_COLOR_CODE..keyString..FONT_COLOR_CODE_CLOSE
        text = text..HEADER_COLON..LocalOptionUtils.stringDelimiter..GetAddOnMetadata(AddonID, key)
        text = text..self.new_paragraph
    end
    return text..self.new_paragraph
end

LocalOptionUtils.AddQuestTypeExampleLine = function(self, text, tagName, prepend, asText, skipHeader)
    local exampleText = skipHeader and self.newline or self.new_paragraph..EXAMPLE_TEXT..self.newline
    local tagString = asText and BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(PARENS_TEMPLATE:format(tagName)) or format("|A:questlog-questtypeicon-%s:16:16:0:-1|a", tagName)
    if (tagName == "raid") then
        return exampleText..tagString..self.stringDelimiter..NORMAL_FONT_COLOR:WrapTextInColorCode(text)
    end
    if prepend then
        return exampleText..format(self.dashLine, tagString)..self.stringDelimiter..NORMAL_FONT_COLOR:WrapTextInColorCode(text)
    end
    return exampleText..format(self.dashLine, NORMAL_FONT_COLOR:WrapTextInColorCode(text))..self.stringDelimiter..tagString
end

LocalOptionUtils.AddExampleLine = function(self, text, icon, iconWidth, iconHeight, textColor)
    local exampleText = self.new_paragraph..EXAMPLE_TEXT..self.newline
    local TextColor = textColor or GRAY_FONT_COLOR
    if not icon then
        return exampleText..self.dashIconString..self.stringDelimiter..TextColor:WrapTextInColorCode(text)
    end
    local CreateMarkupFunction = type(icon) == "number" and CreateSimpleTextureMarkup or CreateAtlasMarkup
    local width = iconWidth or 16
    local height = iconHeight or 16
    return exampleText..CreateMarkupFunction(icon, width, height)..self.stringDelimiter..TextColor:WrapTextInColorCode(text)
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
    desc = desc..LocalOptionUtils.stringDelimiter.."Automatically collapse this category's details when completed."
    desc = desc..LocalOptionUtils.new_paragraph
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.hide..HEADER_COLON)
    desc = desc..LocalOptionUtils.stringDelimiter.."Always show category details collapsed."
    desc = desc..LocalOptionUtils.new_paragraph
    desc = desc..NORMAL_FONT_COLOR:WrapTextInColorCode(LocalOptionUtils.collapseTypeList.show..HEADER_COLON)
    desc = desc..LocalOptionUtils.stringDelimiter.."Always show full category details."

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
--             desc = "Show or hide the quest type icon."..LocalOptionUtils:AddQuestTypeExampleLine("Quest Name", "dungeon"),
--         },
--         type_icons_factions = {
--             type = "toggle",
--             name = "Faction Type",
--             desc = "Show or hide the faction group icon."..LocalOptionUtils:AddQuestTypeExampleLine("Quest Name", "horde"),
--         },
--         type_icons_recurring = {
--             type = "toggle",
--             name = "Recurring Type",
--             desc = "Show or hide the quest type icon for recurring quests."..LocalOptionUtils:AddQuestTypeExampleLine("Quest Name", "monthly"),
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