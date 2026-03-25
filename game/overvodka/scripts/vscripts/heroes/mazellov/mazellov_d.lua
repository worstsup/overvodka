LinkLuaModifier("modifier_mazellov_w", "heroes/mazellov/mazellov_d", LUA_MODIFIER_MOTION_NONE)

if not Mazellov_DisableReturnAbility then
    function Mazellov_DisableReturnAbility(caster)
        if not IsServer() then return end
        if not caster or caster:IsNull() then return end
        if not caster.mazellov_orb_return_enabled then return end

        local return_name = caster.mazellov_orb_return_name or "mazellov_d"
        local return_ability = caster:FindAbilityByName(return_name)
        local base_name = caster.mazellov_orb_return_base_name
        local base_ability = base_name and caster:FindAbilityByName(base_name) or nil

        if base_ability and not base_ability:IsNull() and return_ability and not return_ability:IsNull() then
            caster:SwapAbilities(base_ability:GetAbilityName(), return_ability:GetAbilityName(), true, false)
            base_ability:SetHidden(false)
            base_ability:SetActivated(true)
            return_ability:SetHidden(true)
            return_ability:SetActivated(false)
        elseif return_ability and not return_ability:IsNull() then
            return_ability:SetActivated(false)
        end

        caster.mazellov_orb_return_enabled = nil
        caster.mazellov_orb_return_base_name = nil
        caster.mazellov_orb_return_name = nil
        caster.mazellov_orb_return_added_temporarily = nil
    end
end

mazellov_d = class({})

function mazellov_d:Spawn()
    if not IsServer() then return end
    self:SetActivated( false )
end

function mazellov_d:IsStealable() return false end

function mazellov_d:OnSpellStart()
    local caster = self:GetCaster()
    local expire = caster.mazellov_orb_expire or 0

    if caster.mazellov_orb_teleported then
        if Mazellov_DisableReturnAbility then
            Mazellov_DisableReturnAbility(caster)
        end
        caster:Interrupt()
        return
    end

    if GameRules:GetGameTime() <= expire then
        local dir = caster.mazellov_orb_direction or Vector(1, 0, 0)
        local start_pos = caster.mazellov_orb_start or caster:GetAbsOrigin()
        local speed = caster.mazellov_orb_speed or 0
        local time_passed = GameRules:GetGameTime() - (caster.mazellov_orb_start_time or 0)

        local current_pos = start_pos + dir * speed * time_passed

        FindClearSpaceForUnit(caster, current_pos, true)
        ProjectileManager:ProjectileDodge( caster )
        if caster.mazellov_orb_projectile then
            ProjectileManager:DestroyLinearProjectile(caster.mazellov_orb_projectile)
            caster.mazellov_orb_projectile = nil
        end

        caster.mazellov_orb_teleported = true
    else
        caster:Interrupt()
    end
    self:SetActivated( false )
    if Mazellov_DisableReturnAbility then
        Mazellov_DisableReturnAbility(caster)
    end
end
