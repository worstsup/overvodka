
function rearm_start( keys )
    local caster = keys.caster
    local ability = keys.ability
    local abilityLevel = ability:GetLevel()
    ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_" .. abilityLevel .. "_datadriven", {} )
    if caster:GetUnitName() == "npc_dota_hero_tinker" then
        local Talent = caster:FindAbilityByName("special_bonus_unique_enigma_4")
        if Talent:GetLevel() == 1 then
            caster:AddNewModifier(caster, caster, "modifier_invisible", { duration = 1 })
        end
    end
end

--[[
    Author: kritth
    Date: 7.1.2015.
    Refresh cooldown
]]
function rearm_refresh_cooldown( keys )
    local caster = keys.caster
    local ability = keys.ability
    if caster:GetUnitName() == "npc_dota_hero_tinker" then
    -- Reset cooldown for abilities that is not rearm
        for i = 0, caster:GetAbilityCount() - 1 do
            local ability = caster:GetAbilityByIndex( i )
            if ability and ability ~= keys.ability then
                ability:EndCooldown()
            end
        end
    end
    ability:ApplyDataDrivenModifier( caster, caster, "modifier_uron", {})
end
