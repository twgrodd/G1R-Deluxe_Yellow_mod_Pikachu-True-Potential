# Pikachu True Potential ⚡

**Let your Pokémon Yellow partner Pikachu reach its true potential—without evolving!**

Pikachu True Potential is a mod for **Pokémon Yellow on G1R Deluxe / Gen1Recomp**. Oak's starter Pikachu gradually gains stronger base stats as it levels up, reaching **Raichu's base stats at level 30**, while staying Pikachu and keeping its familiar Yellow partner experience.

> **Only Oak's starter Pikachu gets these upgrades.** Wild and traded Pikachu, and Raichu, remain unchanged. There is no in-game choice between the original and enhanced starter: enabling the mod gives you True Potential Pikachu.

## What your partner can do

- **Grow stronger without evolving.** Base stats start at ordinary Pikachu values at level 5 and reach Raichu values at level 30; levels in between scale gradually.
- **Stay your Yellow partner.** Pikachu still follows you, can be interacted with, uses Yellow's happiness mechanics, and can be nicknamed normally.
- **Learn Double Kick at level 9.** This is an *additional* level-up move; it does not replace the existing level-9 move.
- **Learn Amnesia at level 33 instead of Agility.** Other original level-up moves are preserved.
- **Learn five extra machines:** **HM02 Fly**, **HM03 Surf**, **HM04 Strength**, **TM26 Earthquake**, and **TM28 Dig**. Regular Pikachu keeps its normal TM/HM compatibility.
- **Never evolve.** Your partner remains Pikachu, even after reaching Raichu-level stats.

### New moves at a glance

| When | Move | What changes |
| --- | --- | --- |
| Level 9 | **Double Kick** | Added alongside the original level-up move |
| Level 33 | **Amnesia** | Replaces Agility for your special partner |
| HM02 | **Fly** | Extra HM compatibility |
| HM03 | **Surf** | Extra HM compatibility |
| HM04 | **Strength** | Extra HM compatibility |
| TM26 | **Earthquake** | Extra TM compatibility |
| TM28 | **Dig** | Extra TM compatibility |

**Good to know:** You still need the appropriate badges and normal game conditions to use HMs outside battle. These changes affect future move learning; Pokémon that already passed a level or learned a move will not have their moves retroactively rewritten.

### Stat growth

These are **base stats**, not the numbers shown on Pikachu's summary screen. Actual stats also depend on level, DVs, and stat experience.

| Level | HP | Attack | Defense | Speed | Special |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 5 | 35 | 55 | 30 | 90 | 50 |
| 10 | 40 | 62 | 35 | 92 | 58 |
| 15 | 45 | 69 | 40 | 94 | 66 |
| 20 | 50 | 76 | 45 | 96 | 74 |
| 25 | 55 | 83 | 50 | 98 | 82 |
| **30+** | **60** | **90** | **55** | **100** | **90** |

## Getting started

Install and enable the mod in **G1R Deluxe / Gen1Recomp with Pokémon Yellow imported**, then begin a Yellow game and receive Pikachu from Professor Oak as usual. The usual nickname prompt remains available. This mod does **not** include Pokémon Yellow ROM data or extracted assets.

If you enable or disable the mod, **restart G1R Deluxe** before playing. Already-learned moves are not automatically changed.

## Current status and testing

**Experimental — latest published baseline: v0.1.5.** The Double Kick, Amnesia, Fly, Surf, Strength, Earthquake, and Dig additions described above are **on the open development PR #8 and are not yet part of the published release**: [see upcoming changes](https://github.com/twgrodd/G1R-Deluxe_Yellow_mod_Pikachu-True-Potential/pull/8).

Earlier v0.1.3 gameplay testing covered levels 5–100, partner following/interactions, Pokédex #025, Oak's Parcel, and PC/save/restart behavior. Later follower changes and the new move additions still need fresh in-game testing. Compatibility with other mods and hot disabling/re-enabling have not been verified.

---

# Technical information

## Implementation and compatibility

Oak's Yellow starter is replaced through the `pokemon.before_give` event. The internal species `TRUE_POTENTIAL_PIKACHU` is distinct from ordinary `PIKACHU`, but its display name and Pokédex identity remain Pikachu #025. The standard starter confirmation is **not** a choice between the variants: install/enable the mod to receive True Potential Pikachu; leave it disabled for the vanilla starter. The normal nickname prompt remains available.

`growth.lua` calculates the effective base stats used by the Gen 1 stat formula. `engine_bridge.lua` still requires `engine_internals` for `Stats.calc`, Pokédex normalization around gift/owned-count operations, and selected Yellow follower/happiness compatibility functions. It now uses the public `world.follower.spawn` hook rather than overriding the engine's private spawn predicate; ordinary Pikachu cannot substitute for the custom partner. The redundant `onMoveLearned` override has been removed. A process-local guard prevents duplicate installation of the six engine wrappers. The public follower hook is tracked separately per hook bus, so a newly created hook bus can receive the hook after reload without stacking engine wrappers. This is **not** complete unload/reload support; restarting G1R Deluxe is recommended after enabling or disabling the mod. **Every remaining engine replacement, including exactly how it works and why it is needed, is documented in [docs/ENGINE_OVERRIDES.md](docs/ENGINE_OVERRIDES.md).**

Pokédex migration normalizes the custom species key to ordinary Pikachu #025 while the partner is in the party. This preserves Oak's Parcel progression and repairs known older save cases; boxed-only historical data and interactions with other mods remain edge cases.

Upstream: https://github.com/bryanthaboi/gen1recomp (branch `dev`). No ROM data or extracted assets are included.

## Testing (development)

Run `lua tests/growth_test.lua`, `lua tests/bridge_test.lua`, and `lua tests/tmhm_test.lua` from the repository root. The bridge suite uses mock engine modules to check follower selection, Pokédex migration, happiness, move-learning compatibility, stat isolation, duplicate installation and replacement hook buses. These tests are not a substitute for gameplay tests.

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
