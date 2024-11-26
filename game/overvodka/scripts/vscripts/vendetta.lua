function vendetta_attack( keys )
    if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then        -- This is to fail check if it is item. If it is item, error is expected
        -- Variables
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local modifierName = "modifier_vendetta_buff_datadriven"
        local break_duration = ability:GetLevelSpecialValueFor( "break_duration", ability:GetLevel() - 1 )
        local abilityDamage = ability:GetLevelSpecialValueFor( "bonus_damage", ability:GetLevel() - 1 )
        local abilityDamageType = ability:GetAbilityDamageType()
        if caster:GetUnitName() == "npc_dota_hero_monkey_king" then
            local Talented = caster:FindAbilityByName("special_bonus_unique_medusa_6")
            if Talented:GetLevel() == 1 then
                abilityDamageType = DAMAGE_TYPE_PURE
            end
        end
    
        -- Deal damage and show VFX
        target:AddNewModifier(caster, ability, "modifier_silver_edge_debuff", {duration = break_duration})
        StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
        
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = abilityDamage,
            damage_type = abilityDamageType
        }
        ApplyDamage( damageTable )

        
        keys.caster:RemoveModifierByName( modifierName )
    end
end