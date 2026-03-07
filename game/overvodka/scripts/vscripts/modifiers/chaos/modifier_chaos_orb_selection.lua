modifier_chaos_orb_selection = class({})

function modifier_chaos_orb_selection:IsHidden() return true end
function modifier_chaos_orb_selection:IsPurgable() return false end
function modifier_chaos_orb_selection:IsPurgeException() return false end
function modifier_chaos_orb_selection:RemoveOnDeath() return true end

function modifier_chaos_orb_selection:OnCreated()
    if not IsServer() then return end

    self:GetParent():Stop()
    self:GetParent():Interrupt()

	local p = ParticleManager:CreateParticle("particles/orb_choosing.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt( p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( p, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle(p, false, false, 1, false, true)
end

function modifier_chaos_orb_selection:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    FindClearSpaceForUnit(parent, GetGroundPosition(parent:GetAbsOrigin(), parent), true)
end

function modifier_chaos_orb_selection:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_chaos_orb_selection:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_chaos_orb_selection:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_FLYING] = true,
    }
end