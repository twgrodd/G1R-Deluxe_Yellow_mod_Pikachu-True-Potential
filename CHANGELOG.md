# Changelog

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
