function Dmg (keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local demeg = ability:GetSpecialValueFor("damage")
    local istrtr = ability:GetSpecialValueFor("istrtr")
    local target_location = target:GetAbsOrigin()
    local target_teams = ability:GetAbilityTargetTeam()
    local target_types = ability:GetAbilityTargetType()
    local target_flags = ability:GetAbilityTargetFlags()
    local maxmana = caster:GetMaxMana() * 0.9
    local nowmana = caster:GetMana()
    if target:TriggerSpellAbsorb(ability) then return end
    -- dmg + mana
    local dadada = demeg + caster:GetMaxMana() * 0.15
    if istrtr == 15 then
        if nowmana >= maxmana * 0.9 then
            dadada = dadada * 1.15
        end
    end
    local damage_table = {}
    -- aghanim buff
    local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, 350, target_teams, target_types, 0, 0, false)

    damage_table.damage = dadada
    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    if caster:HasScepter() then
        damage_table.damage_type = DAMAGE_TYPE_PURE
    end
    damage_table.ability = ability
    if caster:GetUnitName() == "npc_dota_hero_lion" then
        local Talent = caster:FindAbilityByName("special_bonus_unique_lion_2")
        if Talent:GetLevel() == 1 then
            for i,unit in ipairs(units) do
                damage_table.victim = unit
                ApplyDamage(damage_table)
            end
        else
            damage_table.victim = target
            ApplyDamage(damage_table)
        end
    else
        damage_table.victim = target
        ApplyDamage(damage_table)
    end
end
