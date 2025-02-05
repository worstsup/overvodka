LinkLuaModifier("modifier_shapeshift_speed_lua", "modifier_shapeshift_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: Pizzalol
    Date: 26.09.2015.
    Applies the shapeshift speed modifier if the target is owned by the caster]]
function ShapeshiftHaste( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    local duration = ability:GetLevelSpecialValueFor("aura_interval", ability_level)
    local caster_owner = caster:GetPlayerOwner() 
    local target_owner = target:GetPlayerOwner() 
    -- If they are the same then apply the modifier
    if caster_owner == target_owner then
        target:AddNewModifier(caster, ability, "modifier_shapeshift_speed_lua", {Duration = duration})
    end
end

--[[Applies the speed and model change Lua modifiers upon cast]]
function ShapeshiftStart( keys )
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local heal = caster:GetMaxHealth() * 0.25
    local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
    if caster:HasModifier("modifier_item_aghanims_shard") then
        caster:Heal(heal, self)
    end
    caster:AddNewModifier(caster, ability, "modifier_shapeshift_speed_lua", {duration = duration})
end