-- Engine bridge for the independent Yellow partner species.
-- Requires the declared engine_internals permission.
local Bridge = {}
local ID = "TRUE_POTENTIAL_PIKACHU"

function Bridge.install(mod, Growth)
  local Stats = require("src.pokemon.Stats")
  local Follower = require("src.world.PikachuFollower")
  local Version = require("src.core.GameVersion")

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

  local originalStarter = Follower.starterInParty
  Follower.starterInParty = function(save, healthy)
    for _, mon in ipairs(save.party or {}) do
      if mon.species == ID and (not healthy or (mon.hp or 0) > 0) then
        return mon
      end
    end
    return originalStarter(save, healthy)
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

  local previousSpawn = Follower.setShouldSpawn(function(game, ow)
    if not Version.isYellow() then return false end
    local save = game.save
    if not (save and save.flags and save.flags.EVENT_GOT_STARTER) then return false end
    if save.pikachuInBall == nil then
      if not save.flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB then return false end
    elseif save.pikachuInBall then
      return false
    end
    if save.onBike or (ow.player and ow.player.surfing) then return false end
    if not (game.data.sprites and game.data.sprites.SPRITE_PIKACHU) then return false end
    for _, mon in ipairs(save.party or {}) do
      if mon.species == ID and (mon.hp or 0) > 0 then return true end
    end
    return false
  end)
  -- Preserve the vanilla follower when the player has an ordinary Pikachu.
  -- This is set as a second wrapper so the previous callback remains intact.
  Follower.setShouldSpawn(function(game, ow)
    if previousSpawn(game, ow) then return true end
    local save = game.save
    if not (save and save.party) then return false end
    -- Only the true partner can activate this alternate path.
    local partner
    for _, mon in ipairs(save.party) do
      if mon.species == ID and (mon.hp or 0) > 0 then partner = mon break end
    end
    if not partner then return false end
    if not Version.isYellow() or not (save.flags and save.flags.EVENT_GOT_STARTER) then return false end
    if save.pikachuInBall == nil then
      if not save.flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB then return false end
    elseif save.pikachuInBall then return false end
    if save.onBike or (ow.player and ow.player.surfing) then return false end
    return game.data.sprites and game.data.sprites.SPRITE_PIKACHU ~= nil or false
  end)

  mod.log:info("True Potential: installed stat and Yellow follower bridges")
end

return Bridge
