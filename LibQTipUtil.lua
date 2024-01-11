--------------------------------------------------------------------------------
--[[ LibQTipUtil.lua ]]--
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
--------------------------------------------------------------------------------
-- 
-- This is a collection of wrapper functions around LibQTip tooltip functions.
-- Many of these functions are heavily inspired by the WoW GameTooltip API. See
-- <SharedTooltipTemplates.lua> for more.
--
-- REF.: <https://www.wowace.com/projects/libqtip-1-0/pages/api-reference>  <br>
-- REF.: <https://www.townlong-yak.com/framexml/live/SharedTooltipTemplates.lua>
--
-- REF.: <https://www.townlong-yak.com/framexml/live/Helix/GlobalColors.lua>
-- REF.: <https://www.townlong-yak.com/framexml/live/SharedColorConstants.lua>
--------------------------------------------------------------------------------

local AddonID, ns = ...

local LibQTipUtil = {}
ns.utils.LibQTipUtil = LibQTipUtil

-- Adds a new empty line to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddBlankLineToTooltip(tooltip, ...)
    return tooltip:AddLine(" ")
end

-- Adds a new line with text in given font color to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param FontColor ColorMixin A color from eg. <GlobalColors.lua> or <SharedColorConstants.lua>
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddColoredLine(tooltip, FontColor, ...)
    local lineIndex, columnIndex = tooltip:AddLine(...)
    tooltip:SetLineTextColor(lineIndex, FontColor:GetRGBA())
    return lineIndex, columnIndex
end

-- Adds a new line with GRAY text to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddDisabledLine(tooltip, ...)
    local lineIndex, columnIndex = tooltip:AddLine(...)
    tooltip:SetLineTextColor(lineIndex, DISABLED_FONT_COLOR:GetRGBA())
    return lineIndex, columnIndex
end

-- Adds a new line with 'highlighted' (white) text color to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddHighlightLine(tooltip, ...)
    local lineIndex, columnIndex = tooltip:AddLine(...)
    tooltip:SetLineTextColor(lineIndex, HIGHLIGHT_FONT_COLOR:GetRGBA())
    return lineIndex, columnIndex
end

-- Adds a new line with GREEN text to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddInstructionLine(tooltip, ...)
    local lineIndex, columnIndex = tooltip:AddLine(...)
    tooltip:SetLineTextColor(lineIndex, GREEN_FONT_COLOR:GetRGBA())
    return lineIndex, columnIndex
end

-- Adds a new line with 'normal' (golden) text color to the bottom of the LibQTip tooltip.
--> See `LibQTip.Tooltip.AddLine` for more.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddLine`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:AddNormalLine(tooltip, ...)
    local lineIndex, columnIndex = tooltip:AddLine(...)
    tooltip:SetLineTextColor(lineIndex, NORMAL_FONT_COLOR:GetRGBA())
    return lineIndex, columnIndex
end

-- Adds a new header line with 'highlighted' (white) text color to the bottom of the LibQTip tooltip.
---@param tooltip LibQTip.Tooltip The `LibQTip.Tooltip` frame.
---@param ... any Values redirected to `LibQTip.Tooltip.AddHeader`.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function LibQTipUtil:SetTitle(tooltip, ...)
    local lineIndex, columnIndex = tooltip:AddHeader(...)
    tooltip:SetLineTextColor(lineIndex, HIGHLIGHT_FONT_COLOR:GetRGBA())
    return lineIndex, columnIndex
end
