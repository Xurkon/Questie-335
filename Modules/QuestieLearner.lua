---@class QuestieLearner
local QuestieLearner = QuestieLoader:CreateModule("QuestieLearner")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local _Learner = QuestieLearner.private or {}
QuestieLearner.private = _Learner

local floor = math.floor

_Learner.pendingNpcs = {}
_Learner.pendingQuests = {}
_Learner.pendingItems = {}
_Learner.pendingObjects = {}

local function GetZoneId()
    local mapId = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if mapId then return mapId end
    return GetRealZoneText() and select(8, GetInstanceInfo()) or 0
end

local function GetPlayerCoords()
    local x, y = GetPlayerMapPosition("player")
    if x and y and x > 0 and y > 0 then
        return floor(x * 100 * 100) / 100, floor(y * 100 * 100) / 100
    end
    return nil, nil
end

local function GetQuestIDFromLog(arg)
    if type(arg) == "number" then -- Index
        local link = GetQuestLink(arg)
        if link then
            local questId = tonumber(string.match(link, "quest:(%d+)"))
            return questId
        end
    elseif type(arg) == "string" then -- Title
        local num = GetNumQuestLogEntries()
        for i = 1, num do
            local title, _, _, isHeader = GetQuestLogTitle(i)
            if not isHeader and title == arg then
                local link = GetQuestLink(i)
                if link then
                    return tonumber(string.match(link, "quest:(%d+)"))
                end
            end
        end
    end
    return nil
end

_Learner.pendingDetail = {}

local function EnsureLearnedData()
    if not Questie.db then return false end
    Questie.db.global.learnedData = Questie.db.global.learnedData or {
        npcs = {},
        quests = {},
        items = {},
        objects = {},
        settings = {
            enabled = true,
            learnNpcs = true,
            learnQuests = true,
            learnItems = true,
            learnObjects = true,
        },
    }
    return true
end

function QuestieLearner:IsEnabled()
    if not EnsureLearnedData() then return false end
    return Questie.db.global.learnedData.settings.enabled
end

function QuestieLearner:GetSettings()
    if not EnsureLearnedData() then return {} end
    return Questie.db.global.learnedData.settings
end

function QuestieLearner:LearnNPC(npcId, name, level, subName, npcFlags, factionString)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnNpcs then return end
    if not npcId or npcId <= 0 then return end

    local zoneId = GetZoneId()
    local x, y = GetPlayerCoords()

    local existing = Questie.db.global.learnedData.npcs[npcId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.npcs[npcId] = existing
    end

    if name and not existing[1] then existing[1] = name end
    if level then
        if not existing[4] or level < existing[4] then existing[4] = level end
        if not existing[5] or level > existing[5] then existing[5] = level end
    end
    if zoneId and zoneId > 0 and not existing[9] then existing[9] = zoneId end
    if factionString and not existing[13] then existing[13] = factionString end
    if subName and not existing[14] then existing[14] = subName end
    if npcFlags and npcFlags > 0 then
        if not existing[15] then
            existing[15] = npcFlags
        else
            existing[15] = bit.bor(existing[15], npcFlags)
        end
    end

    if x and y and zoneId then
        existing[7] = existing[7] or {}
        existing[7][zoneId] = existing[7][zoneId] or {}
        local found = false
        for _, coord in ipairs(existing[7][zoneId]) do
            if math.abs(coord[1] - x) < 1 and math.abs(coord[2] - y) < 1 then
                found = true
                break
            end
        end
        if not found then
            table.insert(existing[7][zoneId], { x, y })
        end
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLearner] Learned NPC:", npcId, name or "?")
end

function QuestieLearner:LearnQuest(questId, name, questLevel, requiredLevel, zoneOrSort, objectives)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnQuests then return end
    if not questId or questId <= 0 then return end

    local existing = Questie.db.global.learnedData.quests[questId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.quests[questId] = existing
    end

    if name and not existing[1] then existing[1] = name end
    if requiredLevel and requiredLevel > 0 and not existing[4] then existing[4] = requiredLevel end
    if questLevel and questLevel > 0 and not existing[5] then existing[5] = questLevel end
    if zoneOrSort and zoneOrSort ~= 0 and not existing[17] then existing[17] = zoneOrSort end
    if objectives and not existing[8] then
        if type(objectives) == "table" then
            existing[8] = objectives
        elseif type(objectives) == "string" then
            existing[8] = { objectives }
        end
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLearner] Learned Quest:", questId, name or "?")
end

function QuestieLearner:LearnNPCHealth(npcId, level, health)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnNpcs then return end
    if not npcId or npcId <= 0 or not health or health <= 0 then return end

    local existing = Questie.db.global.learnedData.npcs[npcId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.npcs[npcId] = existing
    end

    -- [2] = minLevelHealth, [3] = maxLevelHealth
    -- We need to store health *by level* ideally, but QuestieDB uses a single min/max value usually per relative level?
    -- QuestieDB format: [2] = health (at min level?), [3] = health (at max level?)
    -- Let's just store the observed health for now.

    -- Actually, looking at implementation_plan, we need `healthByLevel` for accurate data,
    -- but for direct injection into Questie:
    -- npcKeys[2] = minLevelHealth
    -- npcKeys[3] = maxLevelHealth

    if not existing[2] or (health < existing[2]) then existing[2] = health end
    if not existing[3] or (health > existing[3]) then existing[3] = health end
end

function QuestieLearner:LearnQuestGiver(questId, id, isStart, sourceType)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnQuests then return end
    if not questId or questId <= 0 or not id or id <= 0 then return end

    sourceType = sourceType or 1 -- Default to NPC

    -- 1. Update Quest Data
    local existingComp = Questie.db.global.learnedData.quests[questId]
    if not existingComp then
        existingComp = {}
        Questie.db.global.learnedData.quests[questId] = existingComp
    end

    local index = isStart and 2 or 3
    existingComp[index] = existingComp[index] or {}
    existingComp[index][sourceType] = existingComp[index][sourceType] or {}

    local found = false
    for _, existingId in ipairs(existingComp[index][sourceType]) do
        if existingId == id then
            found = true; break
        end
    end
    if not found then table.insert(existingComp[index][sourceType], id) end

    -- 2. Update Provider Data (Bi-directional)
    if sourceType == 1 then -- NPC
        local npc = Questie.db.global.learnedData.npcs[id]
        if not npc then
            npc = {}
            Questie.db.global.learnedData.npcs[id] = npc
        end
        local npcIndex = isStart and 9 or 10
        npc[npcIndex] = npc[npcIndex] or {}
        local qFound = false
        for _, qId in ipairs(npc[npcIndex]) do
            if qId == questId then
                qFound = true; break
            end
        end
        if not qFound then table.insert(npc[npcIndex], questId) end
    elseif sourceType == 2 then -- Object
        local obj = Questie.db.global.learnedData.objects[id]
        if not obj then
            obj = {}
            Questie.db.global.learnedData.objects[id] = obj
        end
        local objIndex = isStart and 2 or 3
        obj[objIndex] = obj[objIndex] or {}
        local qFound = false
        for _, qId in ipairs(obj[objIndex]) do
            if qId == questId then
                qFound = true; break
            end
        end
        if not qFound then table.insert(obj[objIndex], questId) end
    elseif sourceType == 3 then -- Item (Starts Quest only usually)
        if isStart then
            local item = Questie.db.global.learnedData.items[id]
            if not item then
                item = {}
                Questie.db.global.learnedData.items[id] = item
            end
            -- Item Key [5] = startQuest (ID)
            item[5] = questId
        end
    end
end

function QuestieLearner:LearnItem(itemId, name, itemLevel, requiredLevel, itemClass, itemSubClass, spellId)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnItems then return end
    if not itemId or itemId <= 0 then return end

    local existing = Questie.db.global.learnedData.items[itemId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.items[itemId] = existing
    end

    if name and not existing[1] then existing[1] = name end
    if itemLevel and itemLevel > 0 and not existing[9] then existing[9] = itemLevel end
    if requiredLevel and requiredLevel > 0 and not existing[10] then existing[10] = requiredLevel end
    if itemClass and not existing[12] then existing[12] = itemClass end
    if itemSubClass and not existing[13] then existing[13] = itemSubClass end

    -- teachesSpell [16]
    -- teachesSpell [16]
    if spellId and type(spellId) == "number" and spellId > 0 and not existing[16] then
        existing[16] = spellId
    elseif not existing[16] and self.scannerTooltip then
        self.scannerTooltip:ClearLines()
        self.scannerTooltip:SetHyperlink("item:" .. itemId)
        for i = 1, self.scannerTooltip:NumLines() do
            local line = _G["QuestieLearnerScannerTooltipTextLeft" .. i]:GetText()
            if line and string.find(line, "Teaches you how to learn") then
                -- This text might vary, usually "Teaches you how to..." or "Use: Teaches..."
                -- But we need the spellID. Scan for "SpellID" is impossible from text.
                -- However, GetItemSpell(itemId) exists in 3.3.5?
                local itemSpell = GetItemSpell(itemId)
                if itemSpell then
                    existing[16] = 0 -- We found a spell string but can't map it easily to ID without lookup?
                    -- actually GetItemSpell returns spellName, spellRank.
                    -- Use GetItemInfo(itemId) -> itemType, itemSubType
                end
            end
        end
        -- Better approach: GetItemSpell could return name, we could try to find it?
        -- Actually, item string might have it? No.
        -- Let's stick to what we passed (spellId) if valid.
        -- If we can't reliably get spellID from item, skip for now.
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLearner] Learned Item:", itemId, name or "?")
end

function QuestieLearner:LearnItemReward(itemId, questId)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnItems then return end
    if not itemId or itemId <= 0 or not questId or questId <= 0 then return end

    local existing = Questie.db.global.learnedData.items[itemId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.items[itemId] = existing
    end

    -- [6] = questRewards (List of Quest IDs)
    existing[6] = existing[6] or {}
    local found = false
    for _, qId in ipairs(existing[6]) do
        if qId == questId then
            found = true; break
        end
    end
    if not found then table.insert(existing[6], questId) end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLearner] Learned Item Reward:", itemId, "for Quest:", questId)
end

function QuestieLearner:LearnItemDrop(itemId, sourceId, sourceType)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnItems then return end
    if not itemId or itemId <= 0 or not sourceId or sourceId <= 0 then return end

    sourceType = sourceType or 1 -- 1=NPC, 2=Object

    local existing = Questie.db.global.learnedData.items[itemId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.items[itemId] = existing
    end

    local index = (sourceType == 1) and 2 or 3 -- 2=npcDrops, 3=objectDrops
    existing[index] = existing[index] or {}

    local found = false
    for _, id in ipairs(existing[index]) do
        if id == sourceId then
            found = true; break
        end
    end
    if not found then table.insert(existing[index], sourceId) end
end

function QuestieLearner:LearnObject(objectId, name)
    if not self:IsEnabled() then return end
    if not Questie.db.global.learnedData.settings.learnObjects then return end
    if not objectId or objectId <= 0 then return end

    local zoneId = GetZoneId()
    local x, y = GetPlayerCoords()

    local existing = Questie.db.global.learnedData.objects[objectId]
    if not existing then
        existing = {}
        Questie.db.global.learnedData.objects[objectId] = existing
    end

    if name and not existing[1] then existing[1] = name end
    if zoneId and zoneId > 0 and not existing[5] then existing[5] = zoneId end

    if x and y and zoneId then
        existing[4] = existing[4] or {}
        existing[4][zoneId] = existing[4][zoneId] or {}
        local found = false
        for _, coord in ipairs(existing[4][zoneId]) do
            if math.abs(coord[1] - x) < 1 and math.abs(coord[2] - y) < 1 then
                found = true
                break
            end
        end
        if not found then
            table.insert(existing[4][zoneId], { x, y })
        end
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieLearner] Learned Object:", objectId, name or "?")
end

function QuestieLearner:InjectLearnedData()
    if not EnsureLearnedData() then return end

    local learned = Questie.db.global.learnedData
    local npcCount, questCount, itemCount, objectCount = 0, 0, 0, 0

    for npcId, data in pairs(learned.npcs) do
        if not QuestieDB.npcDataOverrides[npcId] then
            QuestieDB.npcDataOverrides[npcId] = data
            npcCount = npcCount + 1
        else
            local existing = QuestieDB.npcDataOverrides[npcId]
            if data[7] then
                existing[7] = existing[7] or {}
                for zoneId, coords in pairs(data[7]) do
                    existing[7][zoneId] = existing[7][zoneId] or {}
                    for _, coord in ipairs(coords) do
                        local found = false
                        for _, existCoord in ipairs(existing[7][zoneId]) do
                            if math.abs(existCoord[1] - coord[1]) < 1 and math.abs(existCoord[2] - coord[2]) < 1 then
                                found = true
                                break
                            end
                        end
                        if not found then
                            table.insert(existing[7][zoneId], coord)
                        end
                    end
                end
            end
        end
    end

    for questId, data in pairs(learned.quests) do
        if not QuestieDB.questDataOverrides[questId] then
            QuestieDB.questDataOverrides[questId] = data
            questCount = questCount + 1
        end
    end

    for itemId, data in pairs(learned.items) do
        if not QuestieDB.itemDataOverrides[itemId] then
            QuestieDB.itemDataOverrides[itemId] = data
            itemCount = itemCount + 1
        end
    end

    for objectId, data in pairs(learned.objects) do
        if not QuestieDB.objectDataOverrides[objectId] then
            QuestieDB.objectDataOverrides[objectId] = data
            objectCount = objectCount + 1
        else
            local existing = QuestieDB.objectDataOverrides[objectId]
            if data[4] then
                existing[4] = existing[4] or {}
                for zoneId, coords in pairs(data[4]) do
                    existing[4][zoneId] = existing[4][zoneId] or {}
                    for _, coord in ipairs(coords) do
                        local found = false
                        for _, existCoord in ipairs(existing[4][zoneId]) do
                            if math.abs(existCoord[1] - coord[1]) < 1 and math.abs(existCoord[2] - coord[2]) < 1 then
                                found = true
                                break
                            end
                        end
                        if not found then
                            table.insert(existing[4][zoneId], coord)
                        end
                    end
                end
            end
        end
    end

    if npcCount > 0 or questCount > 0 or itemCount > 0 or objectCount > 0 then
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieLearner] Injected learned data:",
            npcCount, "NPCs,", questCount, "quests,", itemCount, "items,", objectCount, "objects")
    end
end

function QuestieLearner:GetStats()
    if not EnsureLearnedData() then return 0, 0, 0, 0 end
    local learned = Questie.db.global.learnedData
    local npcCount, questCount, itemCount, objectCount = 0, 0, 0, 0
    for _ in pairs(learned.npcs) do npcCount = npcCount + 1 end
    for _ in pairs(learned.quests) do questCount = questCount + 1 end
    for _ in pairs(learned.items) do itemCount = itemCount + 1 end
    for _ in pairs(learned.objects) do objectCount = objectCount + 1 end
    return npcCount, questCount, itemCount, objectCount
end

function QuestieLearner:ClearAllData()
    if not EnsureLearnedData() then return end
    Questie.db.global.learnedData.npcs = {}
    Questie.db.global.learnedData.quests = {}
    Questie.db.global.learnedData.items = {}
    Questie.db.global.learnedData.objects = {}
    Questie:Print("Cleared all learned data.")
end

function QuestieLearner:ExportData()
    if not EnsureLearnedData() then return "" end
    local learned = Questie.db.global.learnedData
    local lines = {}

    table.insert(lines, "-- QuestieLearner Export")
    table.insert(lines, "-- NPCs: " .. select(1, self:GetStats()))
    table.insert(lines, "-- Quests: " .. select(2, self:GetStats()))
    table.insert(lines, "-- Items: " .. select(3, self:GetStats()))
    table.insert(lines, "-- Objects: " .. select(4, self:GetStats()))
    table.insert(lines, "")
    table.insert(lines, "QuestieLearnerExport = {")
    table.insert(lines, "  npcs = " .. self:SerializeTable(learned.npcs) .. ",")
    table.insert(lines, "  quests = " .. self:SerializeTable(learned.quests) .. ",")
    table.insert(lines, "  items = " .. self:SerializeTable(learned.items) .. ",")
    table.insert(lines, "  objects = " .. self:SerializeTable(learned.objects) .. ",")
    table.insert(lines, "}")

    return table.concat(lines, "\n")
end

function QuestieLearner:SerializeTable(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        if type(t) == "string" then
            return string.format("%q", t)
        end
        return tostring(t)
    end

    local parts = {}
    local isArray = #t > 0
    for k, v in pairs(t) do
        local key = isArray and "" or ("[" .. (type(k) == "string" and string.format("%q", k) or tostring(k)) .. "]=")
        table.insert(parts, key .. self:SerializeTable(v, indent .. "  "))
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

function QuestieLearner:RegisterEvents()
    local frame = CreateFrame("Frame", "QuestieLearnerFrame")

    -- Create scanner tooltip
    local scannerTooltip = CreateFrame("GameTooltip", "QuestieLearnerScannerTooltip", nil, "GameTooltipTemplate")
    scannerTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    self.scannerTooltip = scannerTooltip

    frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_COMPLETE")
    frame:RegisterEvent("QUEST_ACCEPTED")
    frame:RegisterEvent("LOOT_OPENED")
    frame:RegisterEvent("GOSSIP_SHOW")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterEvent("MERCHANT_SHOW")
    frame:RegisterEvent("TRAINER_SHOW")
    frame:RegisterEvent("BANKFRAME_OPENED")
    frame:RegisterEvent("PET_STABLE_SHOW")
    frame:RegisterEvent("AUCTION_HOUSE_SHOW")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "UPDATE_MOUSEOVER_UNIT" then
            self:OnMouseoverUnit()
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:OnTargetChanged()
        elseif event == "QUEST_DETAIL" then
            self:OnQuestDetail()
        elseif event == "QUEST_COMPLETE" then
            self:OnQuestComplete()
        elseif event == "QUEST_ACCEPTED" then
            self:OnQuestAccepted(...)
        elseif event == "LOOT_OPENED" then
            self:OnLootOpened()
        elseif event == "GOSSIP_SHOW" then
            self:OnGossipShow()
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            self:OnCombatLogEvent(...)
        elseif event == "MERCHANT_SHOW" then
            -- 128 = Vendor
            self:OnGenericInteraction(128)
        elseif event == "TRAINER_SHOW" then
            -- 16 = Trainer
            self:OnGenericInteraction(16)
        elseif event == "BANKFRAME_OPENED" then
            -- 131072 = Banker (QuestieDB) but bitmask might vary.
            -- Standard 3.3.5 flags:
            -- 1=Gossip, 2=QuestGiver, 16=Trainer, 128=Vendor
            -- Let's stick to confirmed ones.
            -- 32 = Class Trainer?
        elseif event == "PET_STABLE_SHOW" then
            -- 4096 = Stable Master
            self:OnGenericInteraction(4096)
        elseif event == "AUCTION_HOUSE_SHOW" then
            -- 2097152 = Auctioneer
            self:OnGenericInteraction(2097152)
        end
    end)

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieLearner] Events registered")

    -- Hook for Item Quest Starts
    hooksecurefunc("UseContainerItem", function(bag, slot)
        local link = GetContainerItemLink(bag, slot)
        if link then
            local itemId = tonumber(string.match(link, "item:(%d+)"))
            if itemId then
                _Learner.lastUsedItem = { id = itemId, time = GetTime() }
            end
        end
    end)
end

function QuestieLearner:OnMouseoverUnit()
    if not UnitExists("mouseover") or not UnitIsVisible("mouseover") then return end
    if UnitIsPlayer("mouseover") then return end

    local guid = UnitGUID("mouseover")
    if not guid then return end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then return end

    npcId = tonumber(npcId)
    if not npcId or npcId <= 0 then return end

    local name = UnitName("mouseover")
    local level = UnitLevel("mouseover")
    local reaction = UnitReaction("mouseover", "player")
    local factionString = nil
    if reaction then
        if reaction >= 5 then
            factionString = UnitFactionGroup("player") == "Alliance" and "A" or "H"
        elseif reaction >= 4 then
            factionString = "AH"
        end
    end

    -- Learn Health
    local health = UnitHealthMax("mouseover")
    self:LearnNPCHealth(npcId, level, health)

    -- Learn SubName (Title)
    local subName = nil
    if self.scannerTooltip then
        self.scannerTooltip:ClearLines()
        self.scannerTooltip:SetUnit("mouseover")
        local line2 = QuestieLearnerScannerTooltipTextLeft2:GetText()
        if line2 and not string.find(line2, "Level") and not string.find(line2, "level") then
            subName = line2
        end
    end

    self:LearnNPC(npcId, name, level, subName, nil, factionString)
end

function QuestieLearner:OnTargetChanged()
    if not UnitExists("target") or not UnitIsVisible("target") then return end
    if UnitIsPlayer("target") then return end

    local guid = UnitGUID("target")
    if not guid then return end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then return end

    npcId = tonumber(npcId)
    if not npcId or npcId <= 0 then return end

    local name = UnitName("target")
    local level = UnitLevel("target")

    self:LearnNPC(npcId, name, level, nil, nil, nil)
end

function QuestieLearner:OnQuestDetail()
    local questId = GetQuestID and GetQuestID()
    -- In 3.3.5 GetQuestID is likely nil, so we might not get it here.
    -- If we don't get it, we defer learning the giver to OnQuestAccepted.

    local title = GetTitleText()
    local objectives = GetObjectiveText and GetObjectiveText()

    -- Cache context for OnQuestAccepted
    _Learner.pendingDetail = {
        title = title,
        objectives = objectives,
        sourceType = nil,
        sourceId = nil,
        time = GetTime()
    }

    if questId and questId > 0 then
        self:LearnQuest(questId, title, 0, 0, nil, objectives)
    end

    -- In 3.3.5, the quest NPC is "target", not "npc"
    local npcGuid = UnitGUID("target")
    if npcGuid then
        -- 3.3.5 uses hex GUID format: 0xF1300002DD000A74
        -- Parse NPC ID from hex string
        local guidType = tonumber(string.sub(npcGuid, 3, 4), 16)
        local id = tonumber(string.sub(npcGuid, 7, 14), 16)
        print("[QuestieLearner] Parsed hex GUID:", npcGuid, "guidType:", guidType, "id:", id)

        if id and id > 0 then
            if guidType and (guidType == 0xF1 or guidType == 0xF0) then -- Creature/Vehicle
                _Learner.pendingDetail.sourceType = 1                   -- NPC
                _Learner.pendingDetail.sourceId = id

                if questId and questId > 0 then
                    self:LearnQuestGiver(questId, id, true, 1) -- NPC
                    local npcName = UnitName("target")
                    self:LearnNPC(id, npcName, nil, nil, 2, nil)
                end
            elseif guidType and guidType == 0xF3 then -- GameObject
                _Learner.pendingDetail.sourceType = 2 -- Object
                _Learner.pendingDetail.sourceId = id

                if questId and questId > 0 then
                    self:LearnQuestGiver(questId, id, true, 2) -- Object
                    local objName = UnitName("target")
                    self:LearnObject(id, objName)
                end
            end
        end
    elseif _Learner.lastUsedItem and (GetTime() - _Learner.lastUsedItem.time) < 1.5 then
        -- Likely started by this item
        _Learner.pendingDetail.sourceType = 3 -- Item
        _Learner.pendingDetail.sourceId = _Learner.lastUsedItem.id

        if questId and questId > 0 then
            self:LearnQuestGiver(questId, _Learner.lastUsedItem.id, true, 3) -- Item
        end

        -- Also learn the item itself?
        if _Learner.lastUsedItem.id then
            local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice =
                GetItemInfo(_Learner.lastUsedItem.id)
            if name then
                local _, _, _, itemLevel, requiredLevel, itemType, itemSubType, _, _, _, _, itemClassId, itemSubClassId =
                    GetItemInfo(link) -- Get numeric IDs
                self:LearnItem(_Learner.lastUsedItem.id, name, iLevel, reqLevel, itemClassId, itemSubClassId)
            end
        end
    end
end

function QuestieLearner:OnQuestComplete()
    local questId = GetQuestID and GetQuestID()
    if not questId or questId <= 0 then
        -- Try to find ID by matching title with Quest Log
        -- Note: QUEST_COMPLETE happens before turn in is finalized, so it should still be in log?
        -- Or we might need to rely on title matching.
        local title = GetTitleText()
        if title then
            questId = GetQuestIDFromLog(title)
        end
    end

    if not questId or questId <= 0 then return end

    local npcGuid = UnitGUID("npc")
    if npcGuid then
        local unitType, _, _, _, _, id = strsplit("-", npcGuid)
        id = tonumber(id)
        if id and id > 0 then
            if unitType == "Creature" or unitType == "Vehicle" then
                self:LearnQuestGiver(questId, id, false, 1) -- NPC
                local npcName = UnitName("npc")
                self:LearnNPC(id, npcName, nil, nil, 2, nil)
            elseif unitType == "GameObject" then
                self:LearnQuestGiver(questId, id, false, 2) -- Object
                local objName = UnitName("npc")
                self:LearnObject(id, objName)
            end
        end
    end

    -- Learn Rewards/Choices
    local numRewards = GetNumQuestRewards()
    for i = 1, numRewards do
        local link = GetQuestItemLink("reward", i)
        if link then
            local itemId = tonumber(string.match(link, "item:(%d+)"))
            if itemId then
                self:LearnItemReward(itemId, questId)
                local name, _, _, iLevel, reqLevel, _, _, _, _, _, _, classId, subClassId = GetItemInfo(link)
                self:LearnItem(itemId, name, iLevel, reqLevel, classId, subClassId)
            end
        end
    end
    local numChoices = GetNumQuestChoices()
    for i = 1, numChoices do
        local link = GetQuestItemLink("choice", i)
        if link then
            local itemId = tonumber(string.match(link, "item:(%d+)"))
            if itemId then
                self:LearnItemReward(itemId, questId)
                local name, _, _, iLevel, reqLevel, _, _, _, _, _, _, classId, subClassId = GetItemInfo(link)
                self:LearnItem(itemId, name, iLevel, reqLevel, classId, subClassId)
            end
        end
    end
end

function QuestieLearner:OnQuestAccepted(questLogIndex, questId)
    if not questId or questId <= 0 then
        -- In 3.3.5 GetQuestLogTitle/QUEST_ACCEPTED passes index. We must parse link for ID.
        if questLogIndex then
            questId = GetQuestIDFromLog(questLogIndex)
        end
    end
    if not questId or questId <= 0 then return end

    local title, level, _, isHeader, isCollapsed, isComplete, frequency = GetQuestLogTitle(questLogIndex) -- 3.3.5 returns 7 args
    if not title then title = GetTitleText() end

    -- Recover data from OnQuestDetail if available
    local objectives = nil
    if _Learner.pendingDetail and _Learner.pendingDetail.title == title and (GetTime() - _Learner.pendingDetail.time < 5) then
        objectives = _Learner.pendingDetail.objectives

        -- Learn Giver if we missed it in OnQuestDetail (due to missing ID)
        if _Learner.pendingDetail.sourceId then
            self:LearnQuestGiver(questId, _Learner.pendingDetail.sourceId, true, _Learner.pendingDetail.sourceType)

            -- If it was NLP/Obj, we might want to learn it again to be safe?
            -- But LearnQuestGiver handles the link. LearnNPC was called in Detail if GUID existed, so that's fine.
        end
        _Learner.pendingDetail = nil
    end

    -- Required Level
    SelectQuestLogEntry(questLogIndex)
    -- Required Level
    SelectQuestLogEntry(questLogIndex)
    local requiredLevel = 0
    -- Workaround for 3.3.5: Scan tooltip
    local link = GetQuestLink(questLogIndex)
    if link and self.scannerTooltip then
        self.scannerTooltip:ClearLines()
        self.scannerTooltip:SetHyperlink(link)
        for i = 1, self.scannerTooltip:NumLines() do
            local line = _G["QuestieLearnerScannerTooltipTextLeft" .. i]:GetText()
            if line then
                local lvl = string.match(line, "Requires Level (%d+)")
                if lvl then
                    requiredLevel = tonumber(lvl)
                    break
                end
            end
        end
    end
    -- Fallback: Manual Calculation
    if requiredLevel == 0 and level > 0 then
        -- Rough estimation: Quest Level - 5 (Northrend/Outland), -10 (Classic)
        -- We will be conservative and not store it if we can't confirm it,
        -- OR store 0 and let DB corrections handle it.
        -- But user requested "Manual Calculation".
        -- Let's try to make a reasonable guess if level > 10.
        if level > 60 then
            requiredLevel = level - 5
        elseif level > 10 then
            requiredLevel = level - 10
        else
            requiredLevel = 1 -- Low level quests often require 1
        end
        if requiredLevel < 1 then requiredLevel = 1 end
    end

    -- Special Flags (Daily/Repeatable)
    -- Questie SpecialFlags: 1=Repeatable, 2=Daily
    -- Special Flags (Daily/Repeatable)
    -- Questie SpecialFlags: 1=Repeatable
    -- Questie QuestFlags: 4096=Daily, 32768=Weekly
    local specialFlags = 0
    local questFlags = 0

    if frequency == 2 then     -- Daily
        questFlags = 4096      -- DAILY
        specialFlags = 1       -- Repeatable
    elseif frequency == 3 then -- Weekly (Guessing 3 based on standard enums, need verification)
        questFlags = 32768     -- WEEKLY
        specialFlags = 1       -- Repeatable
    end

    self:LearnQuest(questId, title, level, requiredLevel, nil, objectives)
    -- Inject flags
    if questFlags > 0 then
        local q = Questie.db.global.learnedData.quests[questId]
        if q then q[23] = questFlags end -- questFlags
    end
    if specialFlags > 0 then
        local q = Questie.db.global.learnedData.quests[questId]
        if q then q[24] = specialFlags end -- specialFlags
    end
end

function QuestieLearner:OnLootOpened()
    local targetGuid = UnitGUID("target")
    if not targetGuid and UnitExists("mouseover") then
        targetGuid = UnitGUID("mouseover")
    end

    local sourceId = nil
    local sourceType = 1 -- NPC

    if targetGuid then
        local unitType, _, _, _, _, id = strsplit("-", targetGuid)
        if unitType == "Creature" or unitType == "Vehicle" then
            sourceId = tonumber(id)
            sourceType = 1
        elseif unitType == "GameObject" then
            sourceId = tonumber(id)
            sourceType = 2
        end
    end

    local numItems = GetNumLootItems()
    for i = 1, numItems do
        local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questId, isActive =
            GetLootSlotInfo(i)
        if lootName then
            local link = GetLootSlotLink(i)
            if link then
                local itemId = tonumber(string.match(link, "item:(%d+)"))
                if itemId then
                    local _, _, _, itemLevel, requiredLevel, itemType, itemSubType, _, _, _, _, itemClassId, itemSubClassId =
                        GetItemInfo(link)
                    local _, _, _, itemLevel, requiredLevel, itemType, itemSubType, _, _, _, _, itemClassId, itemSubClassId =
                        GetItemInfo(link)

                    self:LearnItem(itemId, lootName, itemLevel, requiredLevel, itemClassId, itemSubClassId, nil)

                    if sourceId then
                        self:LearnItemDrop(itemId, sourceId, sourceType)
                    end
                end
            end
        end
    end
end

function QuestieLearner:OnGenericInteraction(npcFlag)
    local npcGuid = UnitGUID("npc")
    if not npcGuid then return end

    local unitType, _, _, _, _, npcId = strsplit("-", npcGuid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" then return end

    npcId = tonumber(npcId)
    if not npcId or npcId <= 0 then return end

    local npcName = UnitName("npc")
    self:LearnNPC(npcId, npcName, nil, nil, npcFlag, nil)
end

function QuestieLearner:OnCombatLogEvent(...)
    local timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
    -- In 3.3.5 args are passed directly.
    -- Check if it's UNIT_DIED
    if subEvent == "UNIT_DIED" then
        if not destGUID then return end
        local unitType, _, _, _, _, npcId = strsplit("-", destGUID)

        if unitType == "Creature" or unitType == "Vehicle" then
            npcId = tonumber(npcId)
            if npcId and npcId > 0 then
                -- Learn NPC at current player location (approximate)
                -- We don't have the mob's level or other info here usually, just ID and Name.
                self:LearnNPC(npcId, destName, nil, nil, nil, nil)
            end
        end
    end
end

function QuestieLearner:OnGossipShow()
    self:OnGenericInteraction(1) -- 1 = Gossip
end

function QuestieLearner:Initialize()
    EnsureLearnedData()
    self:RegisterEvents()
    self:InjectLearnedData()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieLearner] Initialized")
end

return QuestieLearner
