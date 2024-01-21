# HandyNotes: Loremaster

[![GitHub repo](https://img.shields.io/badge/repo-wow--handynotes--loremaster-gray?logo=github&color=%2324292E)](https://github.com/erglo/wow-handynotes-loremaster/ "Repo on GitHub")
![GitHub tag](https://img.shields.io/github/v/tag/erglo/wow-handynotes-loremaster?logo=github&label=latest&color=darkgreen)
![CurseForge Game Versions](https://img.shields.io/curseforge/game-versions/909254?logo=battle.net&logoColor=%23148EFF&label=WoW-retail)


This World of Warcraft™ addon helps you keep track of the Loremaster story quest achievements as well as questlines and campaigns.  
Simply **hover a quest icon** on the world map, if it is part of a questline or a story campaign additional details about your progress will appear in the icon's tooltip.

⚠️**Required addon:** [HandyNotes](https://www.curseforge.com/wow/addons/handynotes "Visit CurseForge.com")

Download available at:
[CurseForge.com](https://www.curseforge.com/wow/addons/handynotes-loremaster/files "CurseForge Files"),
[WoWInterface.com](https://www.wowinterface.com/downloads/info26628-HandyNotesLoremaster.html "WoWInterface"),
[Wago.io](https://addons.wago.io/addons/wow-handynotes-loremaster/versions?stability=beta "Wago Releases (beta)") and
[GitHub.com](https://github.com/erglo/wow-handynotes-loremaster/releases "GitHub Releases").  

_(**Note:** This is a playable release. Activate visibility for **beta** releases to find this addon.)_

## Features (_beta_)

* Extends quest icon tooltips on the worldmap with details about zone stories, questlines and campaigns.
* Shows an icon in continent view indicating whether you finished a zone's story achievement or not.
* _TODO (NYI)_: Adds an icon on the right top corner of the worldmap with details about available questlines on the active zone.
* **Many options**: eg. see the quest type in a quest's tooltip when hovering its icon or hide the content you're not interested in.

----

### Contributing

If you have a feature request or if you would like to report a bug, please visit the repository's [issue page at GitHub](https://github.com/erglo/wow-handynotes-loremaster/issues).

⚠️**Translators:** _Please do **not** provide any localizations, yet. All strings are still hard coded and many of them are subject to change in the current stage of development (beta)._  
_Note: Future changes and instruction details will be provided in this sections._

----

### Tools Used

* Microsoft's [Visual Studio Code](https://code.visualstudio.com) with ...
  + Sumneko's [Lua Language Server](https://github.com/LuaLS/lua-language-server) extension
  + Ketho's [World of Warcraft API](https://github.com/Ketho/vscode-wow-api) extension
  + Stanzilla's [World of Warcraft TOC Language Support](https://github.com/Stanzilla/vscode-wow-toc) extension
  + David Anson's [Markdown linting and style checking](https://github.com/DavidAnson/vscode-markdownlint) extension
* Version control management with [Git](https://git-scm.com) + [GitHub](https://github.com/)
  + Packaging and uploading: [BigWigsMods/packager](https://github.com/BigWigsMods/packager)
  + Changelog generating: [kemayo/actions-recent-changelog](https://github.com/kemayo/actions-recent-changelog)
* In-game development tools (addons):
  + [BugGrabber](https://www.curseforge.com/wow/addons/bug-grabber),
    [BugSack](https://www.curseforge.com/wow/addons/bugsack),
    [idTip](https://www.curseforge.com/wow/addons/idtip),
    [TextureViewer](https://www.curseforge.com/wow/addons/textureviewer),
    [WoWLua](https://www.curseforge.com/wow/addons/wowlua).  
* Game libraries:
  + [Ace3](https://www.curseforge.com/wow/addons/ace3),
    [CallbackHandler-1.0](https://www.curseforge.com/wow/addons/callbackhandler),
    [LibQTip-1.0](https://www.curseforge.com/wow/addons/libqtip-1-0),
    [LibStub](https://www.curseforge.com/wow/addons/libstub).

### References

* Townlong Yak's [FrameXML archive](https://www.townlong-yak.com/framexml/live)
* WoWpedia's [World of Warcraft API](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
* [Wowhead.com](https://www.wowhead.com)
* Matt Cone's ["The Markdown Guide"](https://www.markdownguide.org)
  *(Buy his [book](https://www.markdownguide.org/book)!)*
* [The Git Book](https://git-scm.com/book)
* [Documentation](https://code.visualstudio.com/docs) for Visual Studio Code
