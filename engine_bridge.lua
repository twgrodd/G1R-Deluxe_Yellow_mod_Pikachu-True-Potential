-- Engine bridge for the independent Yellow partner species.
-- Requires the declared engine_internals permission.
local Bridge = {}
local ID = "TRUE_POTENTIAL_PIKACHU"

function Bridge.install(mod, Growth)
  local Stats = require("src.pokemon.Stats")
  local Follower = require("src.world.PikachuFollower")
  local Commands = require("src.script.Commands")

  -- Avoid stacking global engine wrappers when the bridge is loaded twice.
  if not Stats.__pikachuTruePotentialBridgeInstalled then
    Bridge.installEngineWrappers(Stats, Follower, Commands, Growth)
    Stats.__pikachuTruePotentialBridgeInstalled = true
  end

  -- The bridge file is loaded as a fresh chunk each time. Store the weak
  -- per-bus registry on the persistent Stats module, not in this chunk.
  local hookedBuses = Stats.__pikachuTruePotentialHookedBuses
  if not hookedBuses then
    hookedBuses = setmetatable({}, { __mode = "k" })
    Stats.__pikachuTruePotentialHookedBuses = hookedBuses
  end
  if hookedBuses[mod.hooks] then
    mod.log:info("True Potential: follower spawn hook already registered")
    return
  end
  hookedBuses[mod.hooks] = true

  -- The engine already exposes this follower hook. Prefer it over
  -- replacing the engine's private shouldSpawn predicate.
  mod.hooks:wrap("world.follower.spawn", function(next, game, ow)
    local save = game and game.save
    if not (save and save.party) then return false end
    local hasPartner = false
    for _, mon in ipairs(save.party) do
      if mon.species == ID and (mon.hp or 0) > 0 then
        hasPartner = true
        break
      end
    end
    if not hasPartner then return false end

    -- The vanilla predicate contains the authoritative Yellow gates
    -- (starter event, rival battle, ball state, bike, surf and sprite).
    -- It checks ordinary PIKACHU, so provide a temporary *party view*
    -- solely for the predicate. Never mutate the saved party.
    local view = {}
    for key, value in pairs(save) do view[key] = value end
    view.party = {}
    for i, mon in ipairs(save.party) do
      if mon.species == ID then
        local surrogate = {}
        for key, value in pairs(mon) do surrogate[key] = value end
        surrogate.species = "PIKACHU"
        view.party[i] = surrogate
      else
        -- Hide ordinary Pikachu from the vanilla follower predicate.
        local surrogate = {}
        for key, value in pairs(mon) do surrogate[key] = value end
        if surrogate.species == "PIKACHU" then surrogate.species = "__NOT_PARTNER__" end
        view.party[i] = surrogate
      end
    end
    local gameView = {}
    for key, value in pairs(game) do gameView[key] = value end
    gameView.save = view
    return next(gameView, ow)
  end)

  mod.log:info("True Potential: follower spawn hook registered")
end

-- These six internal wrappers are installed only once per Lua process.
-- See docs/ENGINE_OVERRIDES.md for the rationale and upstream API gaps.
function Bridge.installEngineWrappers(Stats, Follower, Commands, Growth)
  -- The species definition stays immutable. Only calculations for the
  -- internal partner species receive a level-specific copy.
  local originalCalc = Stats.calc
  Stats.calc = function(speciesDef, level, dvs, statExp)
    if speciesDef and speciesDef.id == ID then
      local effective = {}
      for key, value in pairs(speciesDef) do effective[key] = value end
      effective.baseStats = Growth.baseStats(level)
      return originalCalc(effective, level, dvs, statExp)
    end
    return originalCalc(speciesDef, level, dvs, statExp)
  end

  -- Repair existing v0.1.0 saves opportunistically when Yellow checks the
  -- partner follower. No extra species or Pokédex slot is introduced.
  local function syncPartnerDex(save)
    if not (save and save.party and save.pokedex) then return end
    local found = false
    for _, mon in ipairs(save.party) do
      if mon.species == ID then found = true break end
    end
    if not found then return end
    save.pokedex.seen = save.pokedex.seen or {}
    save.pokedex.owned = save.pokedex.owned or {}
    save.pokedex.seen.PIKACHU = true
    save.pokedex.owned.PIKACHU = true
    -- The engine counts species keys, not National Dex numbers.
    -- Never let the custom internal ID count as a second owned Pokémon.
    save.pokedex.seen[ID] = nil
    save.pokedex.owned[ID] = nil
  end

  -- Existing saves may contain both species keys from v0.1.1/0.1.2.
  -- Normalize before Oak checks the count so his parcel cutscene is reachable.
  local originalDexCheck = Commands.check_dex_owned
  Commands.check_dex_owned = function(ctx, count)
    syncPartnerDex(ctx and ctx.save)
    return originalDexCheck(ctx, count)
  end

  -- The engine adds the custom species key after pokemon.before_give.
  -- Normalize once the gift and optional nickname prompt are finished.
  local originalGive = Commands.give_pokemon
  Commands.give_pokemon = function(ctx, ...)
    local result = originalGive(ctx, ...)
    syncPartnerDex(ctx and ctx.save)
    return result
  end

  Follower.starterInParty = function(save, healthy)
    syncPartnerDex(save)
    for _, mon in ipairs(save.party or {}) do
      if mon.species == ID and (not healthy or (mon.hp or 0) > 0) then
        return mon
      end
    end
    return nil
  end

  local originalIdentity = Follower.isStarterPikachu
  Follower.isStarterPikachu = function(save, mon)
    if mon and mon.species == ID then
      local player = save.player or {}
      return mon.otId == player.id and mon.ot == player.name
    end
    return originalIdentity(save, mon)
  end

  -- Other vanilla mood/happiness callers expect species == PIKACHU.
  -- Give the original handler a temporary identity view without altering
  -- the saved partner or changing normal Pikachu's rules.
  local originalHappiness = Follower.modifyHappiness
  Follower.modifyHappiness = function(save, reason, mon)
    if mon and mon.species == ID then
      local view = {}
      for key, value in pairs(mon) do view[key] = value end
      view.species = "PIKACHU"
      return originalHappiness(save, reason, view)
    end
    return originalHappiness(save, reason, mon)
  end

end

return Bridge
