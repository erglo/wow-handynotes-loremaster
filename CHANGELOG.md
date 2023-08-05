# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Campaign criteria hint for active and story line quests.
- Meta files for packaging w/o releasing.
- Basic caching system for quest lines, zone stories and their quests.
- Availability and completion check for story line quests.
- Availability and completion check for zone story quests.
- World map hook for active quest pins.
- World map hook for storyline quest pins.
- New slash commands: `/lm`, `/loremaster`
- Basic file structure for a HandyNotes plugin using Ace3.

---- TODO

(A) 2023-08-04 Change in Zone Story mapID to active map @ZoneStory +pinTooltip
(A) 2023-08-04 Add Availability and completion check for campaigns @Campaign +pinTooltip
(C) Continent view @HNLM +map
(C) Add navigation to pin @HNLM +map +quests
Show active QLs in minimap button @HNLM +map +quests +button
x 2023-08-04 Compare `assetIDs` with `questIDs` @HNLM +achievement +quests pri:B
