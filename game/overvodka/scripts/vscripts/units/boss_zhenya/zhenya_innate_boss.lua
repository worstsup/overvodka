LinkLuaModifier("modifier_zhenya_innate_boss", "units/boss_zhenya/zhenya_innate_boss", LUA_MODIFIER_MOTION_NONE)

zhenya_innate_boss = class({})

function zhenya_innate_boss:Precache(context)
    PrecacheResource("particle", "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", context)
    PrecacheResource("soundfile", "soundevents/zhenya_w.vsndevts", context)
end

function zhenya_innate_boss:GetIntrinsicModifierName() 
	return "modifier_zhenya_innate_boss"
end

modifier_zhenya_innate_boss = class({})

function modifier_zhenya_innate_boss:IsPurgable() return false end
function modifier_zhenya_innate_boss:IsHidden() return true end

function modifier_zhenya_innate_boss:OnCreated()
	self:StartIntervalThink(0.5)
end

function modifier_zhenya_innate_boss:OnIntervalThink()
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then return end
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if self:GetParent():IsAlive() then
		for _,unit in pairs(targets) do
			self:GetParent():EmitSound("zhenya_stomp")
			local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, 0, 0))
			ApplyDamage({victim = unit, attacker = self:GetParent(), damage = self.damage * 0.5, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
		end
	end
end