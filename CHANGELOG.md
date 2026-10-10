# Changelog

## [0.1.6] - 2026-10-10

### New partner-only moves
- Learn Double Kick at level 9 in addition to Pikachu's existing level-up move.
- Learn Amnesia instead of Agility at level 33.
- Gain compatibility with HM02 Fly, HM03 Surf, HM04 Strength, TM26 Earthquake, and TM28 Dig.
- Keep ordinary wild/traded Pikachu's learnset and machine compatibility unchanged.

### Documentation and testing
- Reorganize README with player-facing features, stat table, and instructions first, and implementation details below.
- Add mock regression tests for machine compatibility and partner-only learnset changes.

### Experimental testing
- Intended for player testing of the new moves and combinations with other mods.
- In-game move learning, follower behavior after earlier changes, and cross-mod compatibility are not yet verified.
- Existing learned moves are not retroactively replaced; restart after changing enabled mods.

## [0.1.5] - 2026-10-10

### Improved
- Register the public follower spawn hook for newly created hook buses without stacking process-wide engine wrappers.
- Keep all six required engine replacements unchanged in gameplay behavior.

### Documentation and tests
- Document how and why every retained engine replacement works in `docs/ENGINE_OVERRIDES.md`.
- Expand mock-engine regression coverage for repeated bridge loading and replacement hook buses.
- Prepare an experimental build for combined testing with other RoddSoft mods.

### Known limitations
- Combined-mod gameplay compatibility and full hot disable/re-enable are not verified.
- Continue using a full game restart after enabling or disabling mods.

## [0.1.4] - 2026-10-10

### Changed
- Use the public `world.follower.spawn` hook instead of replacing the private follower spawn predicate.
- Require the actual True Potential starter for follower eligibility; ordinary Pikachu cannot stand in.
- Remove the redundant `PikachuFollower.onMoveLearned` override and retain the vanilla handler.
- Add a process-local duplicate-install guard for the engine bridge.

### Testing and documentation
- Add mock-engine regression tests for follower eligibility, happiness, move-learning, stat isolation, Pokédex migration, and duplicate installation; run them in CI and release builds.
- Update documentation with observed level 5–100 gameplay testing, PC persistence, and known compatibility limitations.
- Preserve the v0.1.3 Pokédex and Oak’s Parcel fixes; no new starter selection menu.

### Known limitations
- Requires in-game regression testing after changing the follower hook.
- Engine wrapper cleanup on hot disable/re-enable and cross-mod compatibility remain unverified.


## [0.1.3] - 2026-10-08

### Fixed
- Prevent True Potential Pikachu from counting as a second owned Pokédex species and blocking Oak's Parcel handover.
- Migrate v0.1.1/v0.1.2 save data during Oak's owned-count check and follower checks.
- Normalize the Pokédex after receiving the starter, while preserving the regular Pikachu #025 ownership entry.

### Pending
- Optional YES/NO starter variant selection requires a separate script-level interaction; the existing starter confirmation remains unchanged.

## [0.1.2] - 2026-10-08

### Fixed
- Repair literal escaped newline sequences in Lua code that caused `originalStarter` to be nil during Pokémon Center healing.
- Restore the Pokédex ownership migration and starter gift marking code that was accidentally commented out.

## [0.1.1] - 2026-10-08

### Fixed
- Register original Pikachu (#025) as seen and owned when Oak awards True Potential Pikachu.
- Repair Pokédex ownership for existing v0.1.0 saves when the partner follower is checked, without changing the custom species ID or the starter confirmation text.

## [0.1.0] - 2026-10-08

### Added
- Independent `TRUE_POTENTIAL_PIKACHU` species definition based on imported Yellow Pikachu.
- Pure level 5–30 Raichu-potential growth function and standalone table tests.
- Yellow-only mod manifest and initial architecture documentation.

### Manifest and packaging
- Aligned manifest metadata with G1R Deluxe documentation: explicit engine compatibility range, GAMEPLAY category, experimental flag, and link-affecting content declaration.

### Experimental implementation
- Added Yellow Oak's Lab starter gift replacement with a separate partner species.
- Added partner-specific effective base stats via the Gen 1 stat calculator.
- Added Yellow follower and friendship compatibility bridge for the separate species.
- Declared engine internals permission and included the bridge in release packaging.
- Added GitHub release metadata consistency checks and changelog-derived release notes.

### Not yet verified
- In-game starter-gift, leveling, evolution refusal, follower and happiness behavior.
- Save/load, PC box, battle and cross-mod compatibility.
