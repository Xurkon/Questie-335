<div align="center">

# Questie-335

![Version](https://img.shields.io/badge/version-v9.6.5-blue.svg?style=for-the-badge)
![Downloads](https://img.shields.io/github/downloads/Xurkon/Questie-335/total?style=for-the-badge&color=e67e22)
[![Patreon](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/Xurkon)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.me/Xurkon)
![License](https://img.shields.io/github/license/Xurkon/Questie-335?style=for-the-badge&color=2980b9)
![Lua](https://img.shields.io/badge/LUA-5.1-blue?style=for-the-badge&logo=lua&logoColor=white)
![Platform](https://img.shields.io/badge/PLATFORM-3.3.5a-blue?style=for-the-badge&logo=windows&logoColor=white)

<br/>
**A fork of the WoW Classic Questie addon compatibility with Ascension (Bronzebeard) & Project Ebonhold**

[⬇ **Download Latest**](https://github.com/Xurkon/Questie-335/releases/latest) &nbsp;&nbsp;•&nbsp;&nbsp; [📂 **View Source**](https://github.com/Xurkon/Questie-335)

</div>

## Installation
- [Download](https://github.com/3majed/Questie-335/releases) the archive.
- Extract it into the `Interface/AddOns/` directory. The folder name should be `Questie-335`.
- If you are playing on a custom server that emulates a previous expansion using the **3.3.5** client, you can add `-Classic` or `-TBC` to the addon folder name to load only the required files for the chosen expansion.
- If your server doesn't provide a patch for the world map, enable the in-game setting: `Options → Advanced → Use WotLK map data`.

## Fixes
- **Nameplates**
  - Skips **Project Ascension Nameplates** and works with other addons.

- **Tracker**
  1. Compatible with the Project Ebonhold API and doesn't fail with auto-turn-in quests.
  2. No more missing header issues.
  3. Refreshes correctly when accepting, completing, or abandoning quests.

- **Tooltips**
  1. Fixed all errors.
  2. New: shows if an NPC drops an item that starts a quest.

- **Custom IDs**
  - Supports large integer IDs.

- **Minimap**
  - Fixed errors when zooming the minimap.

- **World Map**
  1. Supports Project Ebonhold `WorldMapFrame` when minimized and draws icons correctly.
  2. Works with **Mapster** and **Magnify-WotLK**.

- **New Content (Maps & Quests)**
  - Currently supports **Elwynn Forest only**.



## Features

### Project Ascension Scaling system
- Scaling all quest to character level like Project Ascension Scaling system
> [!WARNING]
> This feature is intended for **Project Ascension** realms only. Please disable this option if you are playing on other 3.3.5 servers to avoid incorrect quest data.

### Self Learning
- Questie now includes a self-learning feature that records quest data (objectives, locations, etc.) as you play.
- This data is saved locally to improve accuracy for quests that may be missing or incorrect in the base database.
- Helpful for custom content or server-specific quest modifications.

### Show quests on map
- Show notes for quest start points, turn in points, and objectives.

![Questie Quest Givers](https://i.imgur.com/4abi5yu.png)
![Questie Complete](https://i.imgur.com/DgvBHyh.png)
![Questie Tooltip](https://i.imgur.com/uPykHKC.png)

### Quest Tracker
- Improved quest tracker:
    - Automatically tracks quests on accepting (instead of progressing)
    - Can show all 20 quests from the log (instead of default 5)
    - Left click quest to open quest log (configurable)
    - Right-click for more options, e.g.:
        - Focus quest (makes other quest icons translucent)
        - Point arrow towards objective (requires TomTom addon)

![QuestieTracker](https://user-images.githubusercontent.com/8838573/67285596-24dbab00-f4d8-11e9-9ae1-7dd6206b5e48.png)

### Quest Communication
- You can see party members quest progress on the tooltip.
- At least Questie version 5.0.0 is required by everyone in the party for it to work, tell your friends to update!


### Tooltips
- Show tooltips on map notes and quest NPCs/objects.
- Holding Shift while hovering over a map icon displays more information, like quest XP.


#### Quest Information
- Event quests are shown when events are active!

#### Waypoints
- Waypoint lines for quest givers showing their pathing.

### Journey Log
- Questie records the steps of your journey in the "My Journey" window. (right-click on minimap button to open)

![Journey](https://user-images.githubusercontent.com/8838573/67285651-3cb32f00-f4d8-11e9-95d8-e8ceb2a8d871.png)

### Quests by Zone
- Questie lists all the quests of a zone divided between completed and available quest. Gotta complete 'em all. (right-click on minimap button to open)

![QuestsByZone](https://user-images.githubusercontent.com/8838573/67285665-450b6a00-f4d8-11e9-9283-325d26c7c70d.png)

### Search
- Questie's database can be searched. (right-click on minimap button to open)

![Search](https://user-images.githubusercontent.com/8838573/67285691-4f2d6880-f4d8-11e9-8656-b3e37dce2f05.png)

### Configuration
- Extensive configuration options. (left-click on minimap button to open)

![config](https://user-images.githubusercontent.com/8838573/67285731-61a7a200-f4d8-11e9-9026-b1eeaad0d721.png)

