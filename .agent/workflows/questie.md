---
description: Comprehensive reference for Questie development, including corrections, database structure, and debugging.
---

# Questie Development Reference

This workflow aggregates vital information from the [Questie Wiki](https://github.com/Questie/Questie/wiki) for developers.

## 1. Development Environment & Contributing

**Wiki Page:** [Contributing](https://github.com/Questie/Questie/wiki/Contributing)

### Setup
*   **Fork & Clone:** Fork the repo and clone it *outside* your WoW directory.
*   **Symlink:** Create a symlink from your Clone to `Interface/AddOns/Questie`.
    *   **Windows:** `mklink /J "C:\Path\To\WoW\_classic_\Interface\AddOns\Questie" "C:\Dev\Questie"`
    *   **MacOS:** `ln -s ~/Dev/Questie /Applications/World\ of\ Warcraft/_classic_/Interface/AddOns/Questie`
*   **IDE:** Recommended: IntelliJ + EmmyLua or VSCode + Lua Extension (sumneko).

### Commit Messages (Changelog)
Prefix commits to auto-generate changelog entries:
*   `[quest]` e.g., `[quest] Fix pre quest for "Warm Welcome"`
*   `[db]` e.g., `[db] Fix location of "Lar'korwi"`
*   `[fix]` e.g., `[fix] Fix DMF dates for Era`
*   `[feature]` e.g., `[feature] Add gold reward`
*   `[locale]` e.g., `[locale] Add translation for "Next in chain"`

## 2. Database Architecture

**Wiki Page:** [Database](https://github.com/Questie/Questie/wiki/Database)

### Structure
*   **Base Data:** Located in `Database/<Expansion>/` (e.g., `classicQuestDB.lua`). **DO NOT EDIT DIRECTLY.**
*   **Corrections:** Located in `Database/Corrections/`. THIS is where you make changes.

### Loading Order
1.  **Base Data** for the running expansion is loaded (e.g., TBC).
2.  **Corrections** are applied in order: Classic -> TBC -> WotLK.
    *   TBC corrections apply to WotLK.
    *   Classic corrections apply to TBC and WotLK.
    *   *Note:* Corrections in later files can overwrite earlier ones.

### Verification
*   **In-Game Journey:** Enable "Advanced Options" -> "Debug", open Journey (Minimap/Options), use Search tab. This shows the *final* data after corrections.

## 3. Corrections System

**Wiki Page:** [Corrections](https://github.com/Questie/Questie/wiki/Corrections)

Corrections patch the runtime database.

### Syntax
```lua
-- Database/Corrections/tbcQuestFixes.lua
[8300] = {
    [questKeys.startedBy] = {nil,nil,{1234}}, -- Started by Item 1234
    [questKeys.preQuestSingle] = {},           -- Remove pre-quest requirement
},
```

### Critical Keys (QuestieDB.questKeys)
*   `startedBy` / `finishedBy`: `{ {Creature_IDs}, {Object_IDs}, {Item_IDs} }`.
    *   Use `nil` for empty slots. Example: `{{123}, nil, nil}`.
*   `preQuestSingle`: List of required pre-quests.
*   `exclusiveTo`: List of quests that hide this one.
*   `nextQuestInChain`: ID of the next quest.
*   `questLevel`: Set to `-1` to hide/disable? (needs verification with source).
*   `requiredRaces`: Bitmask (use `QuestieDB.raceKeys`).

## 4. Localization

**Wiki Page:** [Localization](https://github.com/Questie/Questie/wiki/Localization-to-more-languages)

To test or add translations locally, use `QUESTIE_LOCALES_OVERRIDE` in a global scope (e.g. `Questie.lua` top):
```lua
QUESTIE_LOCALES_OVERRIDE = {
    locale = 'deDE',
    localeName = 'Deutsch',
    translations = {
        ["Objects"] = "Об'єкти", -- Key is original string
    },
    itemLookup = { [31] = "Alte Löwenstatue" }, -- ID -> Name
    npcNameLookup = { [3] = {"Fleischfresser", nil} }, -- ID -> {Name, Title}
    objectLookup = { [31] = "Alte Löwenstatue" },
    questLookup = { [2] = {"Title", {"Description"}, {"Objective"}} },
}
```

## 5. Common Solutions

### No Objectives Shown
**Page:** [No Objectives](https://github.com/Questie/Questie/wiki/Example%3A-No-Objectives)
*   **Cause:** Quest references an item/object/NPC that has no spawn data.
*   **Fix:**
    1.  Check `QuestieDB.questData[ID].objectives`.
    2.  If it's an item, check if that item has `npcDrops`.
    3.  If the dropper NPC has no spawns, ADD spawns to the NPC.
    4.  *Alternative:* Use `itemFixes.lua` to link the item to a generic mob that *does* have spawns.

### Breadcrumb Quests
**Page:** [Breadcrumb Quests](https://github.com/Questie/Questie/wiki/Example%3A-Breadcrumb-quests)
*   **Fix:** Make the breadcrumb exclusive to the follow-up quest so it hides when the main path is taken.
    ```lua
    [9327] = { [questKeys.nextQuestInChain] = 9130, },
    ```

## 6. Debugging Tools

**Wiki Page:** [Debugging](https://github.com/Questie/Questie/wiki/Debugging)

*   **Mocking Player State:** Add to top of `Questie.lua`:
    ```lua
    UnitLevel = function() return 10; end
    UnitRace = function() return "nightelf", "nightelf"; end
    ```
*   **Module Access:**
    ```lua
    QuestieLoader:ImportModule("QuestieDB").GetQuest(123)
    ```

## 7. Extracting Spawns
**Page:** [Extracting Spawns](https://github.com/Questie/Questie/wiki/Extracting-spawn-locations-from-wowhead)
*   Use the Javascript snippet on Wowhead maps to generate Lua table output `{{x,y},...}`.

## 8. Quest Tags (Bitmask)
See `QuestieDB.lua`.
*   1: Group
*   41: PvP
*   62: Raid
*   81: Dungeon
