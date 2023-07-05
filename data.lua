
-- REF.: <https://wowpedia.fandom.com/wiki/API_GetAchievementCriteriaInfo>

local DRAGON_ISLES_MAP_ID = 1978
local LOREMASTER_OF_THE_DRAGON_ISLES_ID = 16585

local LOREMASTER_09_DRAGON_ISLES_ACHIEVEMENT = {
	["achievements"] = {
		[16585] = { -- "Loremaster of the Dragon Isles"
			-- ["description"] = "Schließt die unten aufgelisteten Questerfolge auf den Dracheninseln ab.",
			-- ["wasEarnedByMe"] = false,
			-- ["isGuild"] = false,
			-- ["rewardText"] = "",
			-- ["completed"] = false,
			["achievementID"] = 16585,
			-- ["name"] = "Meister der Lehren der Dracheninseln",
			-- ["flags"] = 131072,
			-- ["points"] = 10,
			-- ["icon"] = 4672500,
			-- ["isStatistic"] = false,
            ---------------------------------- custom entries
            ["mapID"] = 1978,
		},
	},
}

local LOREMASTER_09_DRAGON_ISLES_CRITERIA = {
	["achievements"] = {
		[16585] = {  -- Meister der Lehren der Dracheninseln"
			{
				["criteriaID"] = 55855,
				["quantityString"] = "1",
				["elapsed"] = 1688495523,
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Erwachende Hoffnung",
				["assetID"] = 16334,
				["flags"] = 32,
				["criteriaType"] = 8,  --> (Earn achievement "{Achievement}")
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 55853,
				["quantityString"] = "1",
				["elapsed"] = 1688495523,
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Besucher der Küste des Erwachens",
				["assetID"] = 16401,
				["flags"] = 32,
				["criteriaType"] = 8,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 55856,
				["quantityString"] = "1",
				["elapsed"] = 1688495525,
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Ohn'e Fleiß kein Preis",
				["assetID"] = 15394,
				["flags"] = 32,
				["criteriaType"] = 8,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 55852,
				["quantityString"] = "0",
				["eligible"] = true,
				["completed"] = false,
				["quantity"] = 0,
				["name"] = "Besucher der Ebenen von Ohn'ahra",
				["assetID"] = 16405,
				["flags"] = 32,
				["criteriaType"] = 8,
				["reqQuantity"] = 1,
			}, -- [4]
			{
				["criteriaID"] = 55858,
				["quantityString"] = "1",
				["elapsed"] = 1688495523,
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Azurblaue Alpinisten",
				["assetID"] = 16336,
				["flags"] = 32,
				["criteriaType"] = 8,
				["reqQuantity"] = 1,
			}, -- [5]
			{
				["criteriaID"] = 55851,
				["quantityString"] = "0",
				["eligible"] = true,
				["completed"] = false,
				["quantity"] = 0,
				["name"] = "Besucher des Azurblauen Gebirges",
				["assetID"] = 16428,
				["flags"] = 32,
				["criteriaType"] = 8,
				["reqQuantity"] = 1,
			}, -- [6]
			{
				["criteriaID"] = 55857,
				-- ["completed"] = true,
				-- ["name"] = "Fragt mich nicht, wie man das schreibt",
				["assetID"] = 16363,
				-- ["criteriaType"] = 8,
			}, -- [7]
			{
				["criteriaID"] = 55854,
				["quantityString"] = "1",
				["elapsed"] = 1688495523,
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Besucher von Thaldraszus",
				["assetID"] = 16398,  --> achievementID
				["flags"] = 32,
				["criteriaType"] = 8, --> (Earn achievement "{Achievement}")
				["reqQuantity"] = 1,
			}, -- [8] "Besucher von Thaldraszus"
		},
	},
}

local function NPC(id, name, assetID, ...)
    -- SetHyperlink(("unit:Creature-0-0-0-0-%d"):format(point.npc))
    return {npcID=id, name=name, mapID=uiMapID, locations=SafePack(...)}
end

local NPC_LOCATIONS = {
    ["2023"] = {  -- Ohn'ahran Plains
        NPC(192621, "Healer Selbekh", 69096, "52802980", "61204000", "61803860"),
        NPC(190014, "Initiate Radiya", 66676, "47405420", "48205640", "48205660", "54806640", "56207580", "56207700", "57007760", "57607240"),
        NPC(185726, "Felina Starrunner", 66011, "24406300", "24606400"),
        NPC(190025, "Scout Watu", 66684, "81005900", "84006080"),
        NPC(190164, "Elder Nazuun", 66690, "41605660"),
        NPC(193985, "Ohn'ir Initiate", 66658, "41026158"),  -- position from comments; NPC follows you around
        NPC(186649, "Khasar", 66006, "80603080", "83403240", "84202480"),
        NPC(191154, "Skyscribe Adenedal", 66700, "66202420"),
    },
}


local LOREMASTER_09_DRAGON_ISLES_SUB_CRITERIA = {
	["achievements"] = {
        [16334] = {  -- [1] "Erwachende Hoffnung"
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Die Drachenschuppenexpedition",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Drachen unter Druck",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Zur Verteidigung des Lebens",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Furorions Gambit",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [4]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Ein erneuerter Zweck",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [5]
		},
        [16401] = {  -- [2] "Besucher der Küste des Erwachens"
			{
				["criteriaID"] = 55229,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Jenseits der Barriere",
				["elapsed"] = 41650,
				["assetID"] = 66447,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 55243,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Mutige Forscher",
				["elapsed"] = 41650,
				["assetID"] = 69902,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 55227,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Professionelle Fotografie",
				["elapsed"] = 41650,
				["assetID"] = 66529,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Rubinrote Lebensberufung",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [4]
			{
				["criteriaID"] = 55241,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Rettet die Flusspferde!",
				["elapsed"] = 41650,
				["assetID"] = 66108,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [5]
			{
				["criteriaID"] = 55242,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Der Schatten seiner Schwingen",
				["elapsed"] = 41650,
				["assetID"] = 65691,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [6]
		},
        [15394] = {  -- [3] "Ohn'e Fleiß kein Preis"
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Zu den Ebenen",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Maruukai",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Ohn'ahras Segen",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Erneuerte Bande",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [4]
		},
		[16405] = {  -- [4] "Besucher der Ebenen von Ohn'ahra"
			{
				["criteriaID"] = 55230,
				["quantityString"] = "1",
				["charName"] = "Zuruat",  --> UnitName("player")
				["duration"] = 0,
				["eligible"] = true,  --> Used to determine whether to show the criteria line in the objectives tracker in red or not.
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Taivans Bestimmung",
				["elapsed"] = 24752,
				["assetID"] = 69096,   --> questID      --> start: "NPC#192621#Healer Selbekh"
				["flags"] = 16,
				["criteriaType"] = 27, --> (Complete quest "{QuestV2}")
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 55231,
				-- ["completed"] = true,
				-- ["name"] = "Initiandenausflug",
				["assetID"] = 66676,   --> questID      --> start: "NPC#190014#Initiate Radiya"
				-- ["criteriaType"] = 27,
			}, -- [2]
            {
				["criteriaID"] = 55232,
				["completed"] = true,
				["name"] = "Fliederstreifen",
				["assetID"] = 66011,                    --> start: "NPC#185726#Felina Starrunner"
				["criteriaType"] = 27,
			}, -- [3]
			{
				["criteriaID"] = 55233,
				["completed"] = true,
				["name"] = "Nadelholzposten",
				["assetID"] = 66684,                    --> start: "NPC#190025#Scout Watu"
				["criteriaType"] = 27,
			}, -- [4]
			{
				["criteriaID"] = 55235,
				["completed"] = false,
				["name"] = "Älteste Nazuun",
				["assetID"] = 66690,                    --> start: "NPC#190164#Elder Nazuun"
				["criteriaType"] = 27,
			}, -- [5]
			{
				["criteriaID"] = 55236,
				["completed"] = false,
				["name"] = "Ewige Kurgane",
				["assetID"] = 66658,                    --> start: "NPC#193985#Ohn'ir Initiate" "41026158"
				["criteriaType"] = 27,
			}, -- [6]
			{
				["criteriaID"] = 55238,
				["completed"] = true,
				["name"] = "Schlickflossendorf",
				["assetID"] = 66006,                    --> start: "NPC#186649#Khasar"
				["criteriaType"] = 27,
			}, -- [7]
			{
				["criteriaID"] = 55240,
				["completed"] = true,
				["name"] = "Ruinen von Nelthazan",
				["assetID"] = 66700,                    --> start: "NPC#191154#Skyscribe Adenedal"  Note: criteria name is NOT same as quest name!
				["criteriaType"] = 27,
			}, -- [8]
		},
        [16336] = {  -- [5] "Azurblaue Alpinisten"
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "In die Archive",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Sorgen der Tuskarr",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Verrottete Wurzeln",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Vakthros",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [4]
		},
        [16428] = {  -- [6] "Besucher des Azurblauen Gebirges"
			{
				["criteriaID"] = 55335,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Grimmhauers Unterschlupf",
				["elapsed"] = 42342,
				["assetID"] = 71135,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 55336,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Gorlocküste",
				["elapsed"] = 42342,
				["assetID"] = 66559,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 55337,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Schneebalglager",
				["elapsed"] = 42342,
				["assetID"] = 66730,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 55338,
				["quantityString"] = "0",
				["eligible"] = true,
				["completed"] = false,
				["quantity"] = 0,
				["name"] = "Slyvernsturz",
				["assetID"] = 70338,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [4]
			{
				["criteriaID"] = 55339,
				["quantityString"] = "0",
				["eligible"] = true,
				["completed"] = false,
				["quantity"] = 0,
				["name"] = "Brackenfellwasserstelle",
				["assetID"] = 66270,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [5]
			{
				["criteriaID"] = 55340,
				["quantityString"] = "0",
				["eligible"] = true,
				["completed"] = false,
				["quantity"] = 0,
				["name"] = "Bachzahnbau",
				["assetID"] = 65595,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [6]
			{
				["criteriaID"] = 55341,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Schaudernetztal",
				["elapsed"] = 42342,
				["assetID"] = 65834,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [7]
			{
				["criteriaID"] = 55342,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Kauriqweiler",
				["elapsed"] = 42342,
				["assetID"] = 66155,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [8]
			{
				["criteriaID"] = 55343,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Verlorene Ruinen",
				["elapsed"] = 42342,
				["assetID"] = 70970,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [9]
			{
				["criteriaID"] = 55344,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Ruinen von Karnthar",
				["elapsed"] = 42342,
				["assetID"] = 66429,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [10]
			{
				["criteriaID"] = 55345,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Rostkieferbau",
				["elapsed"] = 42342,
				["assetID"] = 66152,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [11]
			{
				["criteriaID"] = 55346,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Winterpelzhöhle",
				["elapsed"] = 42342,
				["assetID"] = 66556,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [12]
		},
        [16363] = {  -- [7]  "Fragt mich nicht, wie man das schreibt"
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Valdrakken, Stadt der Drachen",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Zeitmanagement",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 0,
				["quantityString"] = "1",
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Abenteurer der Extraklasse",
				["assetID"] = 0,
				["flags"] = 8208,
				["criteriaType"] = 0,
				["reqQuantity"] = 1,
			}, -- [3]
		},
        [16398] = {  -- [8] "Besucher von Thaldraszus"
			{
				["criteriaID"] = 55213,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Rundblick der Gelikyr",
				["elapsed"] = 42549,
				["assetID"] = 66472,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [1]
			{
				["criteriaID"] = 55214,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Schlüsse ziehen",
				["elapsed"] = 42549,
				["assetID"] = 66467,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [2]
			{
				["criteriaID"] = 55215,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Kreischerschwarmkabbelei",
				["elapsed"] = 42549,
				["assetID"] = 66299,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [3]
			{
				["criteriaID"] = 55216,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Gärten der Einigkeit",
				["elapsed"] = 42549,
				["assetID"] = 66412,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [4]
			{
				["criteriaID"] = 55217,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Tyrholdreservoir",
				["elapsed"] = 42549,
				["assetID"] = 65920,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [5]
			{
				["criteriaID"] = 55218,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Blutende Herzen",
				["elapsed"] = 42549,
				["assetID"] = 69934,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [6]
			{
				["criteriaID"] = 55219,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Bad der Ruhigen Träume",
				["elapsed"] = 42549,
				["assetID"] = 70745,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [7]
			{
				["criteriaID"] = 55220,
				["quantityString"] = "1",
				["charName"] = "Zuruat",
				["duration"] = 0,
				["eligible"] = true,
				["completed"] = true,
				["quantity"] = 1,
				["name"] = "Nebliges Tal",
				["elapsed"] = 42549,
				["assetID"] = 70879,
				["flags"] = 16,
				["criteriaType"] = 27,
				["reqQuantity"] = 1,
			}, -- [8]
		},
	},
}


