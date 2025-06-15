LinkLuaModifier("modifier_mazellov_innate", "heroes/mazellov/mazellov_innate.lua", LUA_MODIFIER_MOTION_NONE)

mazellov_innate = class({})

function mazellov_innate:GetIntrinsicModifierName()
    return "modifier_mazellov_innate"
end

function mazellov_innate:GetMinRadius()
    return self:GetSpecialValueFor("min_radius")
end

function mazellov_innate:GetMaxRadius()
    return self:GetSpecialValueFor("max_radius")
end

function mazellov_innate:GetMinBonus()
    return self:GetSpecialValueFor("min_bonus")
end

function mazellov_innate:GetMaxBonus()
    return self:GetSpecialValueFor("max_bonus")
end

modifier_mazellov_innate = class({})

function modifier_mazellov_innate:IsHidden() return true end
function modifier_mazellov_innate:IsPurgable() return false end
function modifier_mazellov_innate:RemoveOnDeath() return false end

function modifier_mazellov_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
end

function modifier_mazellov_innate:GetModifierSpellAmplify_Percentage()
    if not IsServer() then return 0 end
    
    local parent = self:GetParent()
    local ability = self:GetAbility()
    
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        ability:GetMaxRadius(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    if #enemies == 0 then
        return 0
    end
    
    local closest_enemy = enemies[1]
    local distance = (parent:GetAbsOrigin() - closest_enemy:GetAbsOrigin()):Length2D()
    
    local min_distance = ability:GetMinRadius()
    local max_distance = ability:GetMaxRadius()
    local min_bonus = ability:GetMinBonus()
    local max_bonus = ability:GetMaxBonus()
    
    distance = math.max(min_distance, math.min(max_distance, distance))
    
    local bonus = max_bonus + (min_bonus - max_bonus) * ((distance - min_distance) / (max_distance - min_distance))
    
    return bonus
end