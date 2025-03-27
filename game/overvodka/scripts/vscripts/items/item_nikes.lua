function modifier_item_skadi_datadriven_on_orb_impact(keys)
    if keys.target.GetInvulnCount == nil then
        if keys.caster:IsRangedAttacker() then
            keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationRanged})
        else
            keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationMelee})
        end
    end
end