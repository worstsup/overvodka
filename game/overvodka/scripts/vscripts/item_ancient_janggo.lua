function item_ancient_janggo_datadriven_on_spell_start(keys)    
    keys.caster:EmitSound("vivo")

    local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.EnduranceRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
            
    for i, nearby_ally in ipairs(nearby_allied_units) do  --Apply the buff modifier to every found ally.
        keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_ancient_janggo_datadriven_endurance", nil)
    end
end