# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6.0-beta+100205] - 2024-01-29

### Added

* Zone Story: added manually optional zone stories for `Zaralek Cavern`, `Forbidden Reach` and `Emerald Dream`. These are additional storylines and not part of any Loremaster achievement.
* Settings: added slider for adjusting `continent icon size + transparency`.
* Settings: added slider for adjusting the `questline tooltip's scroll speed`.

### Changed

* World Map: continent icons will now auto-scale with the size of the map.
* World Map: increased continent icon size 1.5x and reduced transparency to 75 %.
* Settings: modified layout for continent icon options.
* Settings: modified layout for quest tooltip options.
* Tooltip: increased scrolling speed for the questline tooltip.
* Quest filter: updated obsolete quest IDs.

### Fixed

* Active quests: fixed unnecessary blank line which appeared under the "Ready for turn-in" message.
* Quest type tags: fixed multiple tag icons for turn-in quests appearing in questline quest lists.

## [v0.5.0-beta+100205] - 2024-01-20

### Added

* Quest type tags: added faction group tags.
* Campaign: added optional `campaign description`. Some campaigns provide further information about themselves.
* Questlines: added highlight and counter for displaying the number of active (ongoing) quests.
* New `tooltip handler` [LibQTip](https://www.curseforge.com/wow/addons/libqtip-1-0) for better organizing and displaying the tooltip content.

### Changed

* Updated TOC file version to `WoW 10.2.5`.
* Quest type tags: combined account-wide quest types with the player's faction group, when they are limited to that, as can be seen in the game's quest log tooltip.
* Quest type tags: quest types shown by Blizzard in the active quest tooltip will be ignored since they're already shown, eg. raids or dungeons.
* Quest type tags: active (ongoing) quests now show a completion icon suitable for their own type.
* Tooltip: content categories can now be separated into `multiple tooltips`.
* Tooltip: `tooltips are now scrollable` and clamped to the screen.
* Tooltip: the plugin name in active quests is now only showing when at least the "Ready for turn-in" message is activated. Without any tooltip content there's no need for the plugin name to be shown. In short: w/o content from this plugin, the tooltip mimics Blizzard's default look and feel.

### Fixed

* Questlines: story quests now are now recognized properly, as long as zone story chapters provide additional information about them.

## [v0.4.2-alpha+100200] - 2024-01-05

### Fixed

* Not all external library files have been included correctly in the previous release.

## [v0.4.0-alpha+100200] - 2024-01-04

### Added

* Zone Story: added optional `chapter quests`. Some story chapter are directly linked to a quest which can be displayed.
* A `waypoint` can now be created to the currently hovered quest icon.
* Campaign: added optional `chapter description`. Only some campaign chapters have those, eg. when they are linked to other campaigns.
* Settings: added option to get notified in `chat` whenever a `lore-relevant quest` has been accepted or turned-in.
* Settings: added option to get notified in `chat` whenever a `lore-relevant achievement` or criteria has been earned.
* Settings: added option to hide the icons over zones with a completed story.
* Zone Story: added manually `zone stories for Shadowlands and Dragonflight`; their main zones have each two stories which are required for the Loremaster achievements (Dragonflight is not yet part of the achievement).
* Zone Story: added completion check to the Worldmap's `continent view` with two icons (a green checkmark for complete and a red X for incomplete achievements).
* Questlines: `active quests` can now display chapter details; by default Blizzard does not provide any questline information for active quests.
* Questlines: story quests can now optionally be highlighted in a distinctive text color.
* Questlines: completing `recurring quests` can now optionally be remembered once they have been turned in, despite the eg. daily or weekly reset.

### Changed

* Settings: moved chat notifications to the about section.
* Zone Story: a story achievement can now be displayed in a single line or in multiple more detailed lines.
* Zone Story: a zone's Loremaster achievement name is now shown in the Zone tooltip details.

## [0.3.0-alpha+100107] - 2023-10-14

### Added

* Settings: Quest type tags can optionally be displayed as text instead of icons.
* Quest type tag icons for currently hovered quest and for questline quests.

### Changed

* Refined quest type classification. Now showing more than one quest type when hovering a quest icon.
* Refined automated packaging and releasing.

## [0.2.0-alpha+100107] - 2023-09-27

### Added

* Counter for displaying the number of daily and weekly quests in questlines.
* Automated packaging and releasing for `CurseForge`, `Wago`, `WoWInterface` and `GitHub`.

### Fixed

* Meta files for packaging and releasing didn't include the embedded libraries correctly.

## [0.1.1-alpha+100107] - 2023-09-07

### Changed

* Updated TOC file version to `WoW 10.1.7`.

### Fixed

* Dragonflight: The questline "Bonus Event Holiday Quests" now appears properly again.

## [0.1.0-alpha+100105] - 2023-09-04

### Added

* Files for packaging + releasing.
* Settings menu with basic options.
* Manual quest filter for following quest types: daily, weekly, faction group, class, race and obsolete.
* Basic caching system for questlines, map infos, zone stories and their quests.
* Availability and completion check for campaign quests.
* Availability and completion check for story line quests.
* Availability and completion check for zone story quests.
* Quest type details, eg. "Raid", "Dungeon", etc.
* World Map hook for active quest pins.
* World Map hook for storyline quest pins.
* New slash commands: `/lm`, `/loremaster`
* Basic file structure for a HandyNotes plugin using Ace3.
