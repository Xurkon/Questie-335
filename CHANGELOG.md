<<<<<<< HEAD
# Changelog

## v9.6.5

- **Fix**: Resolved nil concatenation error in `QuestieLib` causing crashes for some users (Discord report).
- **Update**: QuestieLib now correctly handles nil names with a fallback ("Unknown Quest").
=======
# Questie-335 Changelog

## [9.6.4]

### Added
- **Self Learning**: Implemented a self-learning feature that allows Questie to record and save quest data (objectives, locations, etc.) encountered during gameplay that may be missing or incorrect in the database.
- **Quest Log Validation Fix**: Resolved an issue where a mismatch between the reported number of quests and valid quest data would cause a "Game Cache has still a broken quest log" error. The addon now retries validation instead of crashing.
>>>>>>> 635ffae5831739ca87beb271f0ca426250b0970e
