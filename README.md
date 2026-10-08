# Pikachu True Potential ⚡

A Pokémon Yellow mod for G1R Deluxe / Gen1Recomp. Yellow's original partner Pikachu will grow from ordinary Pikachu strength at level 5 to Raichu-level potential at level 30, without evolving.

**Status: early development / not playable yet.** This repository currently implements the independent partner-species definition and a pure growth formula. The starter replacement, all stat-recalculation paths, and Yellow follower compatibility are still being integrated. Please do not install it expecting complete gameplay behavior.

## Design

- Yellow only; wild and traded PIKACHU stay unchanged.
- Independent internal species ID: `TRUE_POTENTIAL_PIKACHU`; displayed name remains PIKACHU.
- Level 5 starts at Pikachu's Gen 1 base stats; level 30 reaches Raichu's Gen 1 base stats.
- Linear stat interpolation, clamped at levels 5 and 30, rounded to the nearest integer.
- Preserve Pikachu moves, appearance, friendship and no-evolution rule.
- Keep original DVs and stat experience. Friendship never affects stats.

| Level | HP | Attack | Defense | Speed | Special |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 5 | 35 | 55 | 30 | 90 | 50 |
| 10 | 40 | 62 | 35 | 92 | 58 |
| 15 | 45 | 69 | 40 | 94 | 66 |
| 20 | 50 | 76 | 45 | 96 | 74 |
| 25 | 55 | 83 | 50 | 98 | 82 |
| 30 | 60 | 90 | 55 | 100 | 90 |

## Architecture and next integration steps

The new species must be registered before Yellow's starter gift is created. However, the current upstream `src/world/PikachuFollower.lua` checks for the literal species ID `PIKACHU` in following, happiness, and identity handling. Simply replacing the gift with a new ID **would break Yellow's partner behavior**. That requires a compatibility bridge before enabling the gift replacement.

Similarly, the Gen 1 `src/pokemon/Stats.lua` stat calculator reads static species base stats. Replacing a species's baseStats at runtime would affect unrelated instances and may produce inconsistent stats. The mod must compute effective stats only for its distinct partner and integrate with all stat recalculation and leveling paths. The independent `growth.lua` module is the single source of truth for the proposed effective base stats.

Upstream: https://github.com/bryanthaboi/gen1recomp (branch `dev`). No ROM data or extracted assets are included.

## Testing (development)

Run `lua tests/growth_test.lua` (or `luajit tests/growth_test.lua`) from the repository root.

After integration into a Gen1Recomp source checkout, copy the mod folder into `mods/pikachu_true_potential` and run:

```sh
python3 tools/modkit.py validate mods/pikachu_true_potential --base imported
python3 tools/modkit.py lint mods/pikachu_true_potential
```

These modkit checks have **not** been run yet.

## Release versioning policy

**One release = one version, everywhere.** Before publishing a new version:

1. Update `manifest.json`'s `version` (for example, `0.2.0`).
2. Add a new **topmost** `## [0.2.0] - YYYY-MM-DD` section in `CHANGELOG.md` with actual changes. Keep older entries.
3. Merge those changes into `main`; run the validation workflow.
4. Trigger **Release Pikachu True Potential** with the exact same version.

The workflow refuses to release if the requested version, manifest, or newest changelog section differ. It derives the GitHub tag (`v0.2.0`) and ZIP filename (`pikachu_true_potential-0.2.0.zip`) directly from the manifest version, includes the changelog in the ZIP, and uses that version's changelog section as GitHub Release notes. Existing tags/releases are never overwritten.

Check locally using `python3 tools/release_metadata.py`. For example, `python3 tools/release_metadata.py --version 0.2.0` validates an intended release. A workflow-only change does not itself require a version bump; bump the version and changelog when publishing a new release.

**Note:** The mod is currently unfinished. A successful release packaging job does not imply that starter substitution, follower compatibility, or in-game stat growth have been implemented.
