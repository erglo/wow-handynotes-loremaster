# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Zone Story: added details to a zone's corresponding Loremaster achievement.

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
* World map hook for active quest pins.
* World map hook for storyline quest pins.
* New slash commands: `/lm`, `/loremaster`
* Basic file structure for a HandyNotes plugin using Ace3.
