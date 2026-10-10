-- Mock-engine regression tests for the partner bridge.
local Growth = dofile("growth.lua")
local ID = "TRUE_POTENTIAL_PIKACHU"
local Stats = { calc = function(def, level) return def.baseStats, level end }
local Follower = {
  starterInParty = function(save) return save.party[1] end,
  isStarterPikachu = function(_, mon) return mon.species == "PIKACHU" end,
  modifyHappiness = function(save, _, mon)
    if mon and mon.species == "PIKACHU" then
      save.pikachuHappiness = (save.pikachuHappiness or 0) + 1
    end
  end,
  onMoveLearned = function(save, mon, move)
    if move == "THUNDERBOLT" and Follower.isStarterPikachu(save, mon) then
      save.pikachuMood = 133
    end
  end,
}
local originalLearned = Follower.onMoveLearned
local modules = {
  ["src.pokemon.Stats"] = Stats,
  ["src.world.PikachuFollower"] = Follower,
}
local realRequire = require
require = function(name) return modules[name] or realRequire(name) end
local wrappers = {}
local mod = {
  hooks = { wrap = function(_, name, fn)
    assert(name == "world.follower.spawn")
    wrappers[#wrappers + 1] = fn
  end },
  log = { info = function() end },
}
local bridge = dofile("engine_bridge.lua")
bridge.install(mod, Growth)
assert(#wrappers == 1)
local wrappedCalc = Stats.calc
local wrappedStarter = Follower.starterInParty
bridge.install(mod, Growth)
assert(#wrappers == 1 and Stats.calc == wrappedCalc)
assert(Follower.starterInParty == wrappedStarter)
assert(Follower.onMoveLearned == originalLearned, "move-learning override must not be installed")

local partner = { species = ID, hp = 20, otId = 7, ot = "ASH" }
local ordinary = { species = "PIKACHU", hp = 20, otId = 7, ot = "ASH" }
local save = { party = { ordinary }, player = { id = 7, name = "ASH" } }
assert(Follower.starterInParty(save) == nil, "ordinary Pikachu is not partner")
save.party = { ordinary, partner }
assert(Follower.starterInParty(save) == partner)
assert(Follower.isStarterPikachu(save, partner))
partner.hp = 0
assert(Follower.starterInParty(save, true) == nil)
partner.hp = 20

Follower.modifyHappiness(save, "OTHER", partner)
assert(save.pikachuHappiness == 1 and partner.species == ID)
Follower.onMoveLearned(save, partner, "THUNDERBOLT")
assert(save.pikachuMood == 133, "vanilla move handler should use patched identity")

local base = { hp = 35, attack = 55, defense = 30, speed = 90, special = 50 }
local partnerDef = { id = ID, baseStats = base }
local ordinaryDef = { id = "PIKACHU", baseStats = base }
assert(Stats.calc(partnerDef, 30).attack == 90)
assert(Stats.calc(ordinaryDef, 30) == base)
assert(partnerDef.baseStats == base)

local spawn = wrappers[1]
local game = { save = save }
local vanilla = function(viewGame)
  for _, mon in ipairs(viewGame.save.party) do
    if mon.species == "PIKACHU" and mon.hp > 0 then return true end
  end
  return false
end
assert(spawn(vanilla, game, { player = {} }) == true)
assert(save.party[2].species == ID and save.party[1].species == "PIKACHU")
save.party = { ordinary }
assert(spawn(vanilla, game, { player = {} }) == false)
save.party = { partner }
partner.hp = 0
assert(spawn(vanilla, game, { player = {} }) == false)
print("Pikachu True Potential: bridge regression tests passed")
