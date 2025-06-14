LinkLuaModifier("modifier_mazellov_w", "heroes/mazellov/mazellov_d", LUA_MODIFIER_MOTION_NONE)

mazellov_d = class({})

function mazellov_d:Spawn()
	if not IsServer() then return end
	self:SetActivated( false )
end

function mazellov_d:OnSpellStart()
    local caster = self:GetCaster()
    local expire = caster.mazellov_orb_expire or 0

    if caster.mazellov_orb_teleported then
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
end
