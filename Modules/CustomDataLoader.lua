---@class CustomDataLoader
---@type table
local CustomDataLoader = QuestieLoader:CreateModule("CustomDataLoader")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local _overridesInjected = false

local function _LoadIfString(data, label)
    if not data then return nil end
    if type(data) == "string" then
        local fn, err = loadstring(data)
        if not fn then
            if Questie and Questie.Debug then
                Questie:Debug(Questie.DEBUG_CRITICAL,
                    "[CustomDataLoader] loadstring failed for " .. tostring(label) .. ": " .. tostring(err))
            end
            return nil
        end
        local ok, tbl = pcall(fn)
        if not ok then
            if Questie and Questie.Debug then
                Questie:Debug(Questie.DEBUG_CRITICAL,
                    "[CustomDataLoader] executing chunk failed for " .. tostring(label) .. ": " .. tostring(tbl))
            end
            return nil
        end
        return tbl
    end
    return data
end

local function _MergeInto(dst, src)
    if type(dst) ~= "table" or type(src) ~= "table" then return end
    for id, entry in pairs(src) do
        dst[id] = entry
    end
end
local serverNameOverrides = {
    ["91.134.44.123"] = "Ebonhold",
    ["logon.ascension.gg"] = "Ascension",
}

-- Get current Server and Realm
-- For most private servers, SetCVar("realmList") is used.
-- We can fallback to GetRealmName() if needed.
function CustomDataLoader:GetServerInfo()
    local realmName = GetRealmName()
    local realmList = GetCVar("realmList") or "UnknownServer"

    -- Check for override
    if serverNameOverrides[realmList] then
        realmList = serverNameOverrides[realmList]
    end

    return realmList, realmName
end

-- Inject Custom tables into QuestieDB *Overrides*
function CustomDataLoader:InjectOverrides()
    if _overridesInjected then return end
    _overridesInjected = true

    local server, realm = CustomDataLoader:GetServerInfo()

    -- Ensure structure exists in Questie.db.global
    if not Questie.db.global.serverData then Questie.db.global.serverData = {} end
    if not Questie.db.global.serverData[server] then Questie.db.global.serverData[server] = {} end
    if not Questie.db.global.serverData[server][realm] then
        Questie.db.global.serverData[server][realm] = {
            npcData = {},
            objectData = {},
            itemData = {},
            questData = {},
            missingData = {}
        }
        Questie:Print("[Questie] Initialized custom database for " .. server .. " - " .. realm)
    end

    local customDB = Questie.db.global.serverData[server][realm]

    -- SANITIZATION: Fix existing corruption where reports were saved as questData
    if customDB.questData then
        local badKeys = {}
        for qid, entry in pairs(customDB.questData) do
            -- A valid quest name (index 1) should be a string. If it's a table, it's a report.
            if type(entry) == "table" and type(entry[1]) == "table" then
                if not customDB.missingData then customDB.missingData = {} end
                if not customDB.missingData[qid] then customDB.missingData[qid] = {} end

                -- Move bad data to missingData
                for _, report in ipairs(entry) do
                    table.insert(customDB.missingData[qid], report)
                end
                table.insert(badKeys, qid)
            end
        end
        for _, qid in ipairs(badKeys) do
            customDB.questData[qid] = nil
        end
        if #badKeys > 0 then
            Questie:Print("[Questie] Migrated " .. #badKeys .. " invalid quest records to missing data report.")
        end
    end

    QuestieDB.npcDataOverrides = QuestieDB.npcDataOverrides or {}
    QuestieDB.objectDataOverrides = QuestieDB.objectDataOverrides or {}
    QuestieDB.itemDataOverrides = QuestieDB.itemDataOverrides or {}
    QuestieDB.questDataOverrides = QuestieDB.questDataOverrides or {}

    _MergeInto(QuestieDB.npcDataOverrides, customDB.npcData)
    _MergeInto(QuestieDB.objectDataOverrides, customDB.objectData)
    _MergeInto(QuestieDB.itemDataOverrides, customDB.itemData)
    _MergeInto(QuestieDB.questDataOverrides, customDB.questData)
    -- Do NOT merge missingData

    -- Keep a lightweight list of custom quest ids for search/UI
    if type(customDB.questData) == "table" then
        QuestieDB.customQuestIds = QuestieDB.customQuestIds or {}
        for questId, _ in pairs(customDB.questData) do
            if type(questId) == "number" then
                QuestieDB.customQuestIds[questId] = true
            end
        end
    end
end

-- Hook QuestieDB.Initialize to guarantee timing for overrides
do
    local originalInitialize = QuestieDB and QuestieDB.Initialize
    if type(originalInitialize) == "function" then
        function QuestieDB:Initialize(...)
            -- 1) Inject overrides before the DB handles are created
            CustomDataLoader:InjectOverrides()

            return originalInitialize(self, ...)
        end
    end
end

return CustomDataLoader
