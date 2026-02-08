# Questie-335 Changelog

## [Unreleased]

### Added
- **Self Learning**: Implemented a self-learning feature that allows Questie to record and save quest data (objectives, locations, etc.) encountered during gameplay that may be missing or incorrect in the database.
- **Quest Log Validation Fix**: Resolved an issue where a mismatch between the reported number of quests and valid quest data would cause a "Game Cache has still a broken quest log" error. The addon now retries validation instead of crashing.
