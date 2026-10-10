-- Engine bridge for the independent Yellow partner species.
-- Requires the declared engine_internals permission.
local Bridge = {}
local ID = "TRUE_POTENTIAL_PIKACHU"

function Bridge.install(mod, Growth)
  local Stats = require("src.pokemon.Stats")
  local Follower = require("src.world.PikachuFollower")

  -- Engine modules persist across mod reloads. Do not stack wrappers or
  -- register the same follower hook twice in a single Lua process.
  if Stats.__pikachuTruePotentialBridgeInstalled then
    mod.log:info("True Potential: bridge already installed; skipping duplicate")
    return
  end

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

  -- Only the distinct partner species qualifies as Yellow's starter.
  -- An ordinary wild/traded Pikachu must never substitute for it.
  Follower.starterInParty = function(save, healthy)
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

  Stats.__pikachuTruePotentialBridgeInstalled = true
  mod.log:info("True Potential: installed stat and Yellow follower bridges")
end

return Bridge
