-- Standalone Lua tests; run from repository root: lua tests/growth_test.lua
local growth = dofile("growth.lua")
local fields = { "hp", "attack", "defense", "speed", "special" }
local expectations = {
  [5]  = { 35, 55, 30, 90, 50 },
  [10] = { 40, 62, 35, 92, 58 },
  [15] = { 45, 69, 40, 94, 66 },
  [20] = { 50, 76, 45, 96, 74 },
  [25] = { 55, 83, 50, 98, 82 },
  [30] = { 60, 90, 55, 100, 90 },
  [100] = { 60, 90, 55, 100, 90 },
}
for level, expected in pairs(expectations) do
  local actual = growth.baseStats(level)
  for i, field in ipairs(fields) do
    assert(actual[field] == expected[i],
      ("level %d %s: expected %d, got %s"):format(
        level, field, expected[i], tostring(actual[field])))
  end
end
for _, field in ipairs(fields) do
  assert(growth.baseStats(1)[field] == growth.baseStats(5)[field])
end
print("Pikachu True Potential: growth curve tests passed")
