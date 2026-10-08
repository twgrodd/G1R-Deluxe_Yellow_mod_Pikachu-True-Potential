-- Initial species registry for Pikachu True Potential.
-- Intentionally *does not* replace Oak's Pikachu yet: the upstream Yellow
-- follower / happiness code checks for literal species == "PIKACHU".
-- Starter replacement will be enabled only with compatibility support.
local PARTNER_ID = "TRUE_POTENTIAL_PIKACHU"

return function(mod)
  local source = mod:read("growth.lua")
  if not source then
    mod.log:warn("growth.lua is missing; reinstall Pikachu True Potential")
    return
  end
  local chunk, err = load(source, "@pikachu_true_potential/growth.lua")
  if not chunk then
    mod.log:warn("Unable to load growth.lua: %s; reinstall the mod", tostring(err))
    return
  end
  local Growth = chunk()
  local normal = mod.content.pokemon:get("PIKACHU")
  if not normal then
    mod.log:warn("PIKACHU missing from imported Yellow data; "
      .. "partner species registration skipped. Import Pokémon Yellow first.")
    return
  end

  local partner = {}
  for key, value in pairs(normal) do partner[key] = value end
  partner.id = PARTNER_ID
  partner.name = "PIKACHU"
  partner.baseStats = Growth.baseStats(Growth.startLevel)
  -- A separate species retains Pikachu's vanilla moves and visuals.
  -- Never evolve our internal partner entry.
  partner.evolutions = {}

  mod.content.pokemon:register(PARTNER_ID, partner)
  mod.log:info("Registered %s (starter replacement and growth not yet active)",
    PARTNER_ID)
end
