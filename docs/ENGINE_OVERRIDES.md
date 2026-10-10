# Engine function replacement audit

This document describes **every G1R Deluxe engine function replaced by this mod** as of the unreleased bridge lifecycle improvement. These are Lua module-function assignments, not public mod hooks. All six require the manifest's `engine_internals` permission. Source references are to upstream `bryanthaboi/gen1recomp` on `dev`; revisit them when updating engine versions.

The mod's independent internal species is `TRUE_POTENTIAL_PIKACHU` (`ID`). It displays as ordinary Pikachu, Pokédex #025. **Ordinary Pikachu must never qualify as the partner.** Engine wrappers are installed once per Lua process; public hooks are registered separately per hook bus.

## Replacement inventory

### 1. `src.pokemon.Stats.calc`

**Why:** Upstream `Stats.calc(speciesDef, level, dvs, statExp)` reads static `speciesDef.baseStats`. The partner's base stats must interpolate from Pikachu at level 5 to Raichu at level 30 and remain capped afterward. The public species registry cannot express level-dependent base stats.

**How:** Capture the original `Stats.calc`; for definitions whose `id == ID`, shallow-copy the definition, replace only `baseStats` with `Growth.baseStats(level)`, and invoke the original with unchanged `level`, `dvs`, and `statExp`. For all other species, call the original unmodified. The registered definition itself is never mutated.

**Risks:** Another mod wrapping `Stats.calc` before/after ours may change call order; no supported stat-calculation hook was identified. Verify level-ups, boxed/withdrawn stat rebuilds, and stat isolation.

### 2. `src.script.Commands.check_dex_owned`

**Why:** Upstream counts owned Pokédex **species keys** rather than National Dex numbers. Historical saves may contain both `PIKACHU` and `ID`, causing Oak's Parcel gate to count two species incorrectly.

**How:** Capture the original command; call `syncPartnerDex(ctx.save)` immediately before delegating with the original `ctx` and `count`. Migration sets seen/owned `PIKACHU` and clears the custom key when the partner is in the party.

**Risks:** Migration currently requires a party partner, so boxed-only historical cases remain unhandled. A documented pre-script/save-load migration hook could replace this wrapper, but has not been established.

### 3. `src.script.Commands.give_pokemon`

**Why:** Upstream emits `pokemon.before_give` *before* creating the Pokémon, then writes `dex.seen[species]` and `dex.owned[species]` after adding it. Our event changes `species` to `ID`, so a pre-gift correction alone cannot prevent the extra Pokédex key.

**How:** Capture the original `give_pokemon`, call it with the original context and varargs, then call `syncPartnerDex(ctx.save)`, and return the original result. All original gift, naming, party/box, and script behavior remains in the original function.

**Risks:** Post-gift normalization is party-dependent. A supported `pokemon.after_give` event could remove this wrapper, but no such event exists at this call site in the inspected upstream source.

### 4. `src.world.PikachuFollower.starterInParty`

**Why:** Upstream looks for literal `PIKACHU` and may accept an unrelated wild/traded Pikachu. Yellow's partner-only interactions and happiness require the distinct `ID`, not an ordinary Pikachu substitute.

**How:** Replace the function with a party search for `mon.species == ID`, respecting the `healthy` flag. Call `syncPartnerDex(save)` as an additional historical-save repair point. Return the matching Pokémon or `nil`, never fall back to ordinary Pikachu.

**Risks:** Global replacement changes all engine callers of this helper; the public `world.follower.spawn` hook controls spawning only, not other callers.

### 5. `src.world.PikachuFollower.isStarterPikachu`

**Why:** Upstream checks `mon.species == "PIKACHU"` before checking the original trainer. The distinct partner otherwise fails identity-dependent mood and move-learning behavior.

**How:** Capture the original. For `ID`, compare `mon.otId` and `mon.ot` against `save.player.id` and `save.player.name`. For all other species, delegate to the original. This also lets the **unmodified** `onMoveLearned` function recognize our partner.

**Risks:** Upstream's original function still recognizes ordinary Pikachu when called directly; we preserve that behavior for non-partner inputs rather than altering the global vanilla contract.

### 6. `src.world.PikachuFollower.modifyHappiness`

**Why:** Upstream directly rejects non-`PIKACHU` species for per-Pokémon reasons, even though Yellow's happiness and mood live on the save (`save.pikachuHappiness`, `save.pikachuMood`). Partner happiness events would otherwise be missed.

**How:** Capture the original. When the target mon is `ID`, pass a shallow copy with only `species` changed to `PIKACHU`; do **not** change the real mon or save. Delegate unchanged for other inputs. The original engine function still computes happiness bands, mood and clamping.

**Risks:** Depends on the upstream handler continuing to mutate the save rather than the mon copy. Review this assumption when updating the engine.

## Public extension points (not engine replacements)

- `pokemon.before_give` event in `main.lua`: identifies Oak's original Yellow gift and substitutes `ID`. Runs **before** the engine's Pokédex bookkeeping.
- `world.follower.spawn` hook in `engine_bridge.lua`: requires a healthy partner and passes a temporary game/save/party view to the vanilla predicate so vanilla event, ball, bicycle, surfing and sprite gates remain authoritative. Never mutates the actual save. Ordinary Pikachu are masked in the temporary view.
- `PikachuFollower.onMoveLearned` is **not** replaced; it calls the wrapped identity helper.
- The private `PikachuFollower.setShouldSpawn` predicate is **not** replaced.

## Installation and lifecycle

The engine wrappers are process-wide module mutations, protected by `Stats.__pikachuTruePotentialBridgeInstalled`. The public follower hook uses a separate weak-key registration table stored on the persistent `Stats` module: repeated loads on the **same** bus do not add another hook; a **new** bus receives the hook even though global engine wrappers remain installed.

**Limitations:** This is not complete unload support. The mod cannot currently restore overwritten engine functions safely if another mod has wrapped them in the meantime. A hook bus that removes the mod's listeners and then reuses the same bus object is not automatically re-registered by this guard. Restart the game after disabling/re-enabling mods; test hot reload separately before claiming support.

## Tests and future removal criteria

Run `lua tests/growth_test.lua` and `lua tests/bridge_test.lua`. The mock-engine suite checks stat isolation, Pokédex migration, follower eligibility, happiness, move learning, and duplicate/new-bus installation. These do not establish full in-game compatibility.

Remove a replacement only when a supported upstream hook/event can reproduce its behavior **including old-save migration and ordinary Pikachu isolation**. In particular, a pre-gift event cannot substitute for post-gift Pokédex normalization, and the follower spawn hook cannot substitute for every starter identity helper call.
