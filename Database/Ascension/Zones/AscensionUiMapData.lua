---@class AscensionUiMapData
AscensionUiMapData = AscensionUiMapData or {}

AscensionUiMapData.uiMapData = {
	    [1222] = {
        [1] = 323.25,
        [2] = 215.5,
        [3] = -445.875,
        [4] = -8985.0,
        instance = 0,
        mapID = 1222,
        name = "Jasperlode mine",
        mapType = 3,
        parentMapID = 10126,
    },
		[1220] = {
        [1] = 240.0,
        [2] = 160.0,
        [3] = 281.75,
        [4] = -9700.0,
        instance = 0,
        mapID = 1220,
        name = "Upper Fargodeep Mine",
        mapType = 3,
        parentMapID = 10124,
    },
		[1221] = {
        [1] = 255.0,
        [2] = 170.0,
        [3] = 289.25,
        [4] = -9710.0,
        instance = 0,
        mapID = 1221,
        name = "Lower Fargodeep Mine",
        mapType = 3,
        parentMapID = 10125,
    },
		[1238] = {
        [1] = 968.75,
        [2] = 645.8400000000001,
        [3] = 187.5,
        [4] = -8570.83,
		["mapType"] = 3,
		["parentMapID"] = 10138,
		["mapID"] = 1238,
		["instance"] = 0,
		["name"] = "Northshire Valley",
	},
		[1226] = {
        [1] = 279.0,
        [2] = 186.0,
        [3] = -27.0,
        [4] = -8500.0,
		["mapType"] = 3,
		["parentMapID"] = 10130,
		["mapID"] = 1226,
		["instance"] = 0,
		["name"] = "Echo Ridge Mine",
	},
		[2028] = {
		[1] = 1300.008,
		[2] = 866.67,
		[3] = 266.658,
		[4] = -7933.33,
		mapType     = 3,
		parentMapID = 10196,
		mapID       = 2028,
		instance    = 0,
		name        = "Shadewell Spring",
	},
		[1202] = {
		[1] = 204.99,
		[2] = 136.67,
		[3] = -660.0,
		[4] = 2948.83,
		mapType     = 3,
		parentMapID = 796,
		mapID       = 1202,
		instance    = 0,
		name        = "Scarlet Monastery Entrance",
	},
		[2001] = {
		[1] = 4000.002,
		[2] = 2666.67,
		[3] = 533.332,
		[4] = 11733.3,
		mapType     = 3,
		parentMapID = 10007,
		mapID       = 2001,
		instance    = 920,
		name        = "SpellDevMap",
	},
		[2029] = {
		[1] = 499.9961,
		[2] = 333.33,
		[3] = -66.6719,
		[4] = -8500.0,
		mapType     = 3,
		parentMapID = 10197,
		mapID       = 2029,
		instance    = 0,
		name        = "Secret Inquisitorial Dungeon",
	},

	--
		[1239] = {
		[1] = 1266.8,
		[2] = 842.0,
		[3] = 1200.0,
		[4] = -5724.66,
		mapType     = 3,
		parentMapID = 10139,
		mapID       = 1239,
		instance    = 0,
		name        = "Coldridge Valley",
		},
	--
	    [1244] = {
        [1] = 1350.0,
        [2] = 900.0,
        [3] = -3641.67,
        [4] = 0.0,
        instance = 1,
        mapID = 1244,
        name = "Valley of Trials",
        mapType = 3,
        parentMapID = 10144,
    },

}

local function ApplyUiMapData()
    if not QuestieCompat then return end
    if not AscensionUiMapData or not AscensionUiMapData.uiMapData then return end

    QuestieCompat.UiMapData = QuestieCompat.UiMapData or {}

    for uiMapId, data in pairs(AscensionUiMapData.uiMapData) do
        if QuestieCompat.UiMapData[uiMapId] == nil then
            QuestieCompat.UiMapData[uiMapId] = data
        end
    end
end

if QuestieCompat and QuestieCompat.LoadUiMapData then
    hooksecurefunc(QuestieCompat, "LoadUiMapData", ApplyUiMapData)
end
    ApplyUiMapData()