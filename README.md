# Pikachu True Potential ⚡

A Pokémon Yellow mod for G1R Deluxe / Gen1Recomp. Yellow's original partner Pikachu will grow from ordinary Pikachu strength at level 5 to Raichu-level potential at level 30, without evolving.

**Status: experimental (v0.1.5), extensively gameplay-tested through level 100 on v0.1.3.** Starter acquisition, level-dependent stats, following and interactions, Pokédex #025 ownership, Oak's Parcel, and PC deposit/save/restart/withdraw were tested by a player. v0.1.4 changed follower integration and v0.1.5 improves hook-bus registration; both require fresh in-game regression testing. Other-mod compatibility and hot disabling/re-enabling without restarting remain unverified.

## Design

- Yellow only; wild and traded PIKACHU stay unchanged.
- Independent internal species ID: `TRUE_POTENTIAL_PIKACHU`; displayed name remains PIKACHU.
- Level 5 starts at Pikachu's Gen 1 base stats; level 30 reaches Raichu's Gen 1 base stats.
- Linear stat interpolation, clamped at levels 5 and 30, rounded to the nearest integer.
- Preserve Pikachu level-up moves, appearance, friendship and no-evolution rule.
- Partner-only machine additions: HM02 Fly, HM03 Surf, HM04 Strength, TM26 Earthquake and TM28 Dig. Ordinary Pikachu retains its original compatibility; existing learned moves are not modified.
- Keep original DVs and stat experience. Friendship never affects stats.

| Level | HP | Attack | Defense | Speed | Special |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 5 | 35 | 55 | 30 | 90 | 50 |
| 10 | 40 | 62 | 35 | 92 | 58 |
| 15 | 45 | 69 | 40 | 94 | 66 |
| 20 | 50 | 76 | 45 | 96 | 74 |
| 25 | 55 | 83 | 50 | 98 | 82 |
| 30 | 60 | 90 | 55 | 100 | 90 |

## Implementation and compatibility

Oak's Yellow starter is replaced through the `pokemon.before_give` event. The internal species `TRUE_POTENTIAL_PIKACHU` is distinct from ordinary `PIKACHU`, but its display name and Pokédex identity remain Pikachu #025. The standard starter confirmation is **not** a choice between the variants: install/enable the mod to receive True Potential Pikachu; leave it disabled for the vanilla starter. The normal nickname prompt remains available.

`growth.lua` calculates the effective base stats used by the Gen 1 stat formula. `engine_bridge.lua` still requires `engine_internals` for `Stats.calc`, Pokédex normalization around gift/owned-count operations, and selected Yellow follower/happiness compatibility functions. It now uses the public `world.follower.spawn` hook rather than overriding the engine's private spawn predicate; ordinary Pikachu cannot substitute for the custom partner. The redundant `onMoveLearned` override has been removed. A process-local guard prevents duplicate installation of the six engine wrappers. The public follower hook is tracked separately per hook bus, so a newly created hook bus can receive the hook after reload without stacking engine wrappers. This is **not** complete unload/reload support; restarting G1R Deluxe is recommended after enabling or disabling the mod. **Every remaining engine replacement, including exactly how it works and why it is needed, is documented in [docs/ENGINE_OVERRIDES.md](docs/ENGINE_OVERRIDES.md).**

Pokédex migration normalizes the custom species key to ordinary Pikachu #025 while the partner is in the party. This preserves Oak's Parcel progression and repairs known older save cases; boxed-only historical data and interactions with other mods remain edge cases.

Upstream: https://github.com/bryanthaboi/gen1recomp (branch `dev`). No ROM data or extracted assets are included.

## Testing (development)

Run `lua tests/growth_test.lua` and `lua tests/bridge_test.lua` from the repository root. The bridge suite uses mock engine modules to check follower selection, Pokédex migration, happiness, move-learning compatibility, stat isolation, duplicate installation and replacement hook buses. These tests are not a substitute for gameplay tests.

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
4. The release workflow automatically runs when `manifest.json` changes on `main`; it can also be triggered manually with the same version.

The workflow refuses to release if the requested version, manifest, or newest changelog section differ. It derives the GitHub tag (`v0.2.0`) and ZIP filename (`pikachu_true_potential-0.2.0.zip`) directly from the manifest version, includes the changelog in the ZIP, and uses that version's changelog section as GitHub Release notes. Existing tags/releases are never overwritten.

Check locally using `python3 tools/release_metadata.py`. For example, `python3 tools/release_metadata.py --version 0.2.0` validates an intended release. A workflow-only change does not itself require a version bump; bump the version and changelog when publishing a new release.

**Note:** A successful packaging job does not prove that new engine compatibility changes work in-game. Keep the mod experimental until the v0.1.5 follower and save regressions are retested.
