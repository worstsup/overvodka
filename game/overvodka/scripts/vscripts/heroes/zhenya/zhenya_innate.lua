LinkLuaModifier("modifier_zhenya_innate", "heroes/zhenya/zhenya_innate", LUA_MODIFIER_MOTION_NONE)

zhenya_innate = class({})

function zhenya_innate:Precache(context)
    PrecacheResource("particle", "particles/zhenya/vernon_stomp.vpcf", context)
    PrecacheResource("soundfile", "soundevents/zhenya_w.vsndevts", context)
end

function zhenya_innate:GetIntrinsicModifierName() 
	return "modifier_zhenya_innate"
end

modifier_zhenya_innate = class({})

function modifier_zhenya_innate:IsPurgable() return false end
function modifier_zhenya_innate:IsHidden() return true end

function modifier_zhenya_innate:OnCreated()
	self:StartIntervalThink(0.5)
end

function modifier_zhenya_innate:OnIntervalThink()
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if self:GetParent():IsAlive() then
		for _,unit in pairs(targets) do
			self:GetParent():EmitSound("zhenya_stomp")
			local effect_cast = ParticleManager:CreateParticle( "particles/zhenya/vernon_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ApplyDamage({victim = unit, attacker = self:GetParent(), damage = self.damage * 0.5, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
		end
	end
end

function modifier_zhenya_innate:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end