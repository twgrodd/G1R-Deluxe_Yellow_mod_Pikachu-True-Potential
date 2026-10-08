-- True Potential Pikachu: distinct internal species, vanilla Pokédex identity.
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
  local bridgeSource = mod:read("engine_bridge.lua")
  if not bridgeSource then
    mod.log:warn("engine_bridge.lua missing; starter replacement disabled")
    return
  end
  local bridgeChunk, bridgeErr = load(bridgeSource, "@pikachu_true_potential/engine_bridge.lua")
  if not bridgeChunk then
    mod.log:warn("Could not load engine bridge: %s", tostring(bridgeErr))
    return
  end
  bridgeChunk().install(mod, Growth)

  local function originalYellowStarter(ctx)
    local save = ctx and ctx.save
    local map = ctx and ctx.overworld and ctx.overworld.map
    return map and map.id == "OAKS_LAB"
      and save and save.flags and not save.flags.EVENT_GOT_STARTER
      and #(save.party or {}) == 0
  end

  mod.events:on("pokemon.before_give", function(gift)
    if gift.species ~= "PIKACHU" or not originalYellowStarter(gift.ctx) then
      return
    end
    -- Dex bookkeeping uses species keys, not shared dex numbers.\n    -- Mirror the owned/seen record to vanilla Pikachu (#025).\n    local dex = gift.ctx and gift.ctx.save and gift.ctx.save.pokedex\n    if dex then\n      dex.seen = dex.seen or {}\n      dex.owned = dex.owned or {}\n      dex.seen.PIKACHU = true\n      dex.owned.PIKACHU = true\n    end\n    gift.species = PARTNER_ID
    mod.log:info("Oak's Yellow starter is now True Potential Pikachu")
  end)

  mod.log:info("Registered %s and enabled Yellow starter replacement", PARTNER_ID)
end
