# Pikachu True Potential

**Let your Pokémon Yellow partner Pikachu reach its true potential—without evolving!**

Pikachu True Potential is a mod for **Pokémon Yellow on G1R Deluxe / Gen1Recomp**. Oak's starter Pikachu gradually gains stronger base stats as it levels up, reaching **Raichu's base stats at level 30**, while staying Pikachu and keeping its familiar Yellow partner experience.

> **Only Oak's starter Pikachu gets these upgrades.** Wild and traded Pikachu, and Raichu, remain unchanged. There is no in-game choice between the original and enhanced starter: enabling the mod gives you True Potential Pikachu.

## What this mod does

- Base stats start at ordinary Pikachu values at level 5 and reach Raichu values at level 30; levels in between scale gradually.
- At level 30 and above, its base stats remain equal to Raichu's; it does not become stronger than Raichu.
- **Additional level-up moves:** Learn Double Kick at level 9 and Amnesia at level 31. The original Agility move at level 33 is preserved.
- **Inspired by Pokémon: Let's Go, Pikachu!:** Gain compatibility with Fly, Surf, Strength, Earthquake, and Dig.

### Move changes

| When | Move | What changes |
| --- | --- | --- |
| Level 9 | **Double Kick** | Added move |
| Level 31 | **Amnesia** | Added move |
| Level 33 | **Agility** | Original Pikachu level-up move; preserved |
| HM02 | **Fly** | Extra HM compatibility |
| HM03 | **Surf** | Extra HM compatibility |
| HM04 | **Strength** | Extra HM compatibility |
| TM26 | **Earthquake** | Extra TM compatibility |
| TM28 | **Dig** | Extra TM compatibility |

**Good to know:** You still need the appropriate badges and must meet the game's normal requirements to use HMs outside battle. The learnset changes apply when a Pokémon reaches the relevant level; they do not retroactively change moves on Pokémon that have already passed that level.

### Stat comparison

Compare **Gen 1 base stats** side by side. Only Oak's **True Potential Pikachu** gains base stats as it levels up; regular Pikachu and Raichu keep their usual base stats.

#### Level 5

| Stat | Regular Pikachu | Raichu | ⚡ True Potential Pikachu |
| :--- | ---: | ---: | ---: |
| HP | 35 | 60 | **35** |
| Attack | 55 | 90 | **55** |
| Defense | 30 | 55 | **30** |
| Speed | 90 | 100 | **90** |
| Special | 50 | 90 | **50** |
| **Base stat total** | **260** | **395** | **260** |

#### Level 20

| Stat | Regular Pikachu | Raichu | ⚡ True Potential Pikachu |
| :--- | ---: | ---: | ---: |
| HP | 35 | 60 | **50** |
| Attack | 55 | 90 | **76** |
| Defense | 30 | 55 | **45** |
| Speed | 90 | 100 | **96** |
| Special | 50 | 90 | **74** |
| **Base stat total** | **260** | **395** | **341** |

#### Level 30 and above

| Stat | Regular Pikachu | Raichu | ⚡ True Potential Pikachu |
| :--- | ---: | ---: | ---: |
| HP | 35 | 60 | **60** |
| Attack | 55 | 90 | **90** |
| Defense | 30 | 55 | **55** |
| Speed | 90 | 100 | **100** |
| Special | 50 | 90 | **90** |
| **Base stat total** | **260** | **395** | **395** |

**Important:** These are **base stats**, not the numbers shown on the in-game summary screen. Actual HP and other stats at higher levels also depend on DVs and stat experience. From level 30 onward, True Potential Pikachu has the same base stats as Raichu; with identical DVs and stat experience, they have the same battle stats at the same level.

### Mod compatibility: player-tested

The following mods were used alongside Pikachu True Potential in gameplay and **worked well**, with the one known Pokédex display discrepancy noted below. This is a report of the tested setup, not a guarantee for every version or mod combination.

| Mod | Observed result |
| --- | --- |
| `all_tm_shop` | Worked |
| `crystal_animated_sprites_with_shiny_visuals` | Worked; partner sprite/visual compatibility tested |
| `DRAMATIC_SHAPE` | Worked |
| `exp_share` | Worked |
| `free_rare_candy` | Worked |
| `guaranteed_catch` | Worked |
| `hm_anywhere` | Worked |
| `modern_pc_ui` | Worked |
| `move_inspector` | Worked |
| `move_learn_stats` | Worked |
| `moves_manager` | Worked |
| `pokedex_plus` | **Minor Pokédex count discrepancy** (see below) |
| `quality_of_life` | Worked |
| `reusable_machines` | Worked |
| `running_shoes` | Worked |

**Known `pokedex_plus` discrepancy:** Its Pokédex display may count True Potential Pikachu as a separate Pokémon, showing **two owned Pokémon where Professor Oak recognizes one**. This is a display/count inconsistency between the mods; it has not prevented the reported gameplay setup from working. True Potential Pikachu still represents Pikachu #025, and this mod preserves the normal Oak progression check.

### Installation

**Easiest: install through G1R Deluxe.** Open the app's **mod search/list**, find **Pikachu True Potential**, then install and enable it. In-app availability depends on the mod list submission being approved and published.

**Manual alternative:** Download the [latest release ZIP](https://github.com/twgrodd/G1R-Deluxe_Yellow_mod_Pikachu-True-Potential/releases/latest), drag it into the app, and enable the mod.

You must have **Pokémon Yellow imported** into G1R Deluxe / Gen1Recomp. Start a new Yellow game and receive Pikachu from Professor Oak as usual. You can nickname your partner normally. The mod does **not** include Pokémon Yellow ROM data or extracted assets.

**Restart G1R Deluxe after enabling, disabling, or changing mods.** Already-learned moves are not changed retroactively.

---

# Technical information

## Implementation and compatibility

Oak's Yellow starter is replaced through the `pokemon.before_give` event. The internal species `TRUE_POTENTIAL_PIKACHU` is distinct from ordinary `PIKACHU`, but its display name and Pokédex identity remain Pikachu #025. The standard starter confirmation is **not** a choice between the variants: install/enable the mod to receive True Potential Pikachu; leave it disabled for the vanilla starter. The normal nickname prompt remains available.

`growth.lua` calculates the effective base stats used by the Gen 1 stat formula. `engine_bridge.lua` still requires `engine_internals` for `Stats.calc`, Pokédex normalization around gift/owned-count operations, and selected Yellow follower/happiness compatibility functions. It now uses the public `world.follower.spawn` hook rather than overriding the engine's private spawn predicate; ordinary Pikachu cannot substitute for the custom partner. The existing `give_pokemon` wrapper also temporarily adjusts Oak's starter nickname question so the partner's internal species ID does not overflow the dialogue box, then restores the original prompt. The redundant `onMoveLearned` override has been removed. A process-local guard prevents duplicate installation of the six engine wrappers. The public follower hook is tracked separately per hook bus, so a newly created hook bus can receive the hook after reload without stacking engine wrappers. This is **not** complete unload/reload support; restarting G1R Deluxe is recommended after enabling or disabling the mod. **Every remaining engine replacement, including exactly how it works and why it is needed, is documented in [docs/ENGINE_OVERRIDES.md](docs/ENGINE_OVERRIDES.md).**

Pokédex migration normalizes the custom species key to ordinary Pikachu #025 while the partner is in the party. This preserves Oak's Parcel progression and repairs known older save cases; boxed-only historical data and interactions with other mods remain edge cases.

Upstream: https://github.com/bryanthaboi/gen1recomp (branch `dev`). No ROM data or extracted assets are included.

## Testing (development)

Run `lua tests/growth_test.lua`, `lua tests/bridge_test.lua`, and `lua tests/tmhm_test.lua` from the repository root. The bridge suite uses mock engine modules to check follower selection, Pokédex migration, happiness, move-learning compatibility, stat isolation, duplicate installation and replacement hook buses. These tests are not a substitute for gameplay tests.

After integration into a Gen1Recomp source checkout, copy the mod folder into `mods/pikachu_true_potential` and run:

```sh
python3 tools/modkit.py validate mods/pikachu_true_potential --base imported
python3 tools/modkit.py lint mods/pikachu_true_potential
```

**Automated GitHub Actions validation runs** Lua syntax checks, the three Lua test suites, manifest metadata checks, and `tools/release_metadata.py`. These are separate from the optional upstream modkit `validate`/`lint` commands above, which have **not been confirmed as run**. Automated checks do not replace in-game testing.

## Release versioning policy

**One release = one version, everywhere.** Before publishing a new version:

1. Update `manifest.json`'s `version` (for example, `0.2.0`).
2. Add a new **topmost versioned** `## [0.2.0] - YYYY-MM-DD` section in `CHANGELOG.md` with actual changes. An optional unversioned `## Unreleased` section can remain above it; keep older version entries.
3. Merge those changes into `main`; run the validation workflow.
4. The release workflow automatically runs when `manifest.json` changes on `main`; it can also be triggered manually with the same version.

The workflow refuses to release if the requested version, manifest, or newest **versioned** changelog section differ. It ignores the unversioned `Unreleased` heading when selecting the version. It derives the GitHub tag (`v0.2.0`) and ZIP filename (`pikachu_true_potential-0.2.0.zip`) directly from the manifest version, includes the changelog in the ZIP, and uses that version's changelog section as GitHub Release notes. Existing tags/releases are never overwritten.

Check locally using `python3 tools/release_metadata.py`. For example, `python3 tools/release_metadata.py --version 0.2.0` validates an intended release. A workflow-only change does not itself require a version bump; bump the version and changelog when publishing a new release.

**Note:** A successful packaging job is not a substitute for in-game testing. Report compatibility issues with reproduction steps and enabled mod versions.
