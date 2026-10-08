-- Effective base stat progression for Yellow's distinct partner species.
-- This is a pure module, independent from the game's stat calculator.
-- Actual mon.stats must still be recomputed using the engine's Gen 1
-- DV / stat experience formula at every appropriate engine entry point.
local Growth = {}

local START_LEVEL, FULL_LEVEL = 5, 30
local PIKACHU = { hp = 35, attack = 55, defense = 30, speed = 90, special = 50 }
local RAICHU  = { hp = 60, attack = 90, defense = 55, speed = 100, special = 90 }
local KEYS = { "hp", "attack", "defense", "speed", "special" }

function Growth.baseStats(level)
  level = tonumber(level) or START_LEVEL
  local progress = math.max(0, math.min(1,
    (level - START_LEVEL) / (FULL_LEVEL - START_LEVEL)))
  local result = {}
  for _, key in ipairs(KEYS) do
    result[key] = math.floor(PIKACHU[key]
      + (RAICHU[key] - PIKACHU[key]) * progress + 0.5)
  end
  return result
end

Growth.startLevel = START_LEVEL
Growth.fullLevel = FULL_LEVEL
return Growth
