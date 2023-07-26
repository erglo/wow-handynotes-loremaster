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
local CreateAtlasMarkup = CreateAtlasMarkup

ns.pluginInfo = {}
ns.pluginInfo.title = GetAddOnMetadata(AddonID, "Title")
ns.pluginInfo.icon = GetAddOnMetadata(AddonID, "IconTexture") or GetAddOnMetadata(AddonID, "IconAtlas")
ns.pluginInfo.version = GetAddOnMetadata(AddonID, "Version")
ns.pluginInfo.description = GetAddOnMetadata(AddonID, "Notes-"..ns.currentLocale) or GetAddOnMetadata(AddonID, "Notes")
ns.pluginInfo.optionsID = select(2, strsplit("_", AddonID))  --> "LM09"
ns.pluginInfo.options = function(optionsHandler)
    -- local db = optionsHandler.db
    return {                                                                  --> TODO - L10n
        type = 'group',
        name = ns.pluginInfo.title:gsub("HandyNotes: ", ''),  --> "Loremaster"
        desc = ns.pluginInfo.description,
        -- handler = optionsHandler,
        args = {
            icon_settings = {
                type = "group",
                name = "Icon settings",
                inline = true,
                order = 10,
                args = {
                    desc = {
                        type = "description",
                        name = "These settings control the look and feel of the icon.",
                        order = 0,
                    },
                    icon_scale = {
                        type = "range",
                        name = "Icon Scale",
                        desc = "The overall scale of the icons on the World Map",
                        min = 0.25, max = 2, step = 0.01,
                        arg = "icon_scale",
                        order = 10,
                    },
                    icon_alpha = {
                        type = "range",
                        name = "Icon Alpha",
                        desc = "The transparency of the icons on the World Map",
                        min = 0, max = 1, step = 0.01,
                        order = 20,
                    },
                    show_on_continent = {
                        type = "toggle",
                        name = "Show on Continents",
                        desc = "Toggle icons in continent view.",
                        -- get = function(info, k)
                        --     return db.enabledPlugins[k]
                        -- end,
                        order = 30,
                    },
                    show_in_zones = {
                        type = "toggle",
                        name = "Show in Zones",
                        desc = "Toggle icons in zone view.",
                        order = 40,
                    },
                    default_icon_selection = {
                        type = "select",
                        name = "Default Icon",
                        desc = "Select an icon as default for this plugin.",
                        values = {
                            CheckmarkJailerstower = CreateAtlasMarkup("jailerstower-wayfinder-rewardcheckmark", 20, 20) .. " Jailers Tower Checkmark",  --> 42, 43
                            CheckmarkOrange = CreateAtlasMarkup("Adventures-Checkmark", 20, 20) .. " Orange Checkmark",  --> 42, 41
                            CheckmarkWorldquest = CreateAtlasMarkup("worldquest-tracker-checkmark", 20, 20) .. " World Quest Tracker Checkmark",  --> 40, 35
                            CommonCheckmark = CreateAtlasMarkup("common-icon-checkmark", 20, 20) .. " Green Checkmark",  --> 25, 25
                            CommonCheckmarkYellow = CreateAtlasMarkup("common-icon-checkmark-yellow", 20, 20) .. " Yellow Checkmark",  --> 256, 256
                        },
                        order = 50,
                    },
                    worldmap_button = {
                        type = "toggle",
                        name = "World Map Button",
                        desc = "Toggle the button on the world map for more options",
                        -- set = function(info, v)
                        --     ns.db[info[#info]] = v
                        --     if WorldMapFrame.RefreshOverlayFrames then
                        --         WorldMapFrame:RefreshOverlayFrames()
                        --     end
                        -- end,
                        -- hidden = function(info)
                        --     if not ns.SetupMapOverlay then
                        --         return true
                        --     end
                        --     return ns.options.hidden(info)
                        -- end,
                        order = 60,
                    }
                }
            },  --> icon_settings
            about = {
                type = "group",
                name = "About this plugin",
                inline = true,
                order = 20,
                args = {
                    desc = {
                        type = "description",
                        name = ns.pluginInfo.description,
                        order = 0,
                    },
                }
            },  --> about
        }
    }
end

-- function List_Plugins()
--     for pluginName, pluginHandler in pairs(HandyNotes.plugins) do
-- 		print(pluginName == pluginHandler.name, pluginName, "-->", pluginHandler.name)
-- 	end
-- end

-- Achievement IDs
local LOREMASTER_OF_THE_DRAGON_ISLES_ID = 16585
