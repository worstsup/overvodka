batya_radiance = class({})
LinkLuaModifier( "modifier_batya_radiance", "heroes/zolo/batya_radiance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_batya_radiance_debuff", "heroes/zolo/batya_radiance", LUA_MODIFIER_MOTION_NONE )

function batya_radiance:GetIntrinsicModifierName()
	return "modifier_batya_radiance"
end

modifier_batya_radiance = class({})

function modifier_batya_radiance:IsHidden()
	return true
end
function modifier_batya_radiance:IsDebuff()
	return false
end
function modifier_batya_radiance:IsPurgable()
	return false
end

function modifier_batya_radiance:OnCreated()
	if not IsServer() then return end
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(),PATTACH_POINT_FOLLOW,"attach_hitloc",Vector(0,0,75),true)
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_batya_radiance:OnRefresh()
	if not IsServer() then return end
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
end

function modifier_batya_radiance:OnDestroy()
end

function modifier_batya_radiance:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():IsAlive() then
		self:Destroy()
		return
	end
	self.dmg = self.base_damage * self.interval
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	self.damageTable = {
		attacker = self:GetParent(),
		damage = self.dmg,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end
end

function modifier_batya_radiance:IsAura() return true end

function modifier_batya_radiance:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_batya_radiance:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_batya_radiance:GetModifierAura()
    return "modifier_batya_radiance_debuff"
end

function modifier_batya_radiance:GetAuraDuration()
    return 0.5
end

function modifier_batya_radiance:GetAuraRadius()
    if self:GetAbility() then
        return self.radius
    end
end

modifier_batya_radiance_debuff = class({})

function modifier_batya_radiance_debuff:IsHidden()
	return false
end
function modifier_batya_radiance_debuff:IsDebuff()
	return true
end
function modifier_batya_radiance_debuff:IsPurgable()
	return false
end
function modifier_batya_radiance_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end
function modifier_batya_radiance_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function modifier_batya_radiance_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
