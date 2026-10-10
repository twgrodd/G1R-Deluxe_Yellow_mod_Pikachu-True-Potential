-- Verify partner-only TM/HM compatibility without modifying level-up moves.
local normal = {
  id = "PIKACHU", name = "PIKACHU",
  baseStats = { hp = 35 },
  level1Moves = { "THUNDERSHOCK", "GROWL" },
  learnset = { { level = 9, move = "QUICK_ATTACK" } },
  tmhm = { "THUNDERBOLT", "DIG" },
  evolutions = { { species = "RAICHU" } },
}
local registered
local events = {}
local mod = {
  read = function(_, path)
    if path == "growth.lua" then
      return 'return { startLevel = 5, baseStats = function() return { hp = 35 } end }'
    end
    if path == "engine_bridge.lua" then return 'return { install = function() end }' end
  end,
  content = { pokemon = {
    get = function(_, id) assert(id == "PIKACHU"); return normal end,
    register = function(_, id, def)
      assert(id == "TRUE_POTENTIAL_PIKACHU")
      registered = def
    end,
  } },
  events = { on = function(_, name, fn) events[name] = fn end },
  log = { warn = function() error("unexpected warning") end, info = function() end },
}
dofile("main.lua")(mod)
assert(registered and registered.tmhm ~= normal.tmhm)
assert(registered.learnset == normal.learnset, "level-up learnset must be unchanged")
assert(registered.level1Moves == normal.level1Moves, "starting moves must be unchanged")
assert(#normal.tmhm == 2 and normal.tmhm[1] == "THUNDERBOLT")
local count = {}
for _, move in ipairs(registered.tmhm) do count[move] = (count[move] or 0) + 1 end
for _, move in ipairs({ "FLY", "SURF", "STRENGTH", "EARTHQUAKE", "DIG", "THUNDERBOLT" }) do
  assert(count[move] == 1, "missing or duplicate machine move: " .. move)
end
assert(registered.evolutions ~= normal.evolutions)
assert(#registered.evolutions == 0)
print("Pikachu True Potential: partner TM/HM tests passed")
