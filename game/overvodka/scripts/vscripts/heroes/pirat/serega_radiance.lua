serega_radiance = class({})
LinkLuaModifier( "modifier_serega_radiance", "heroes/pirat/serega_radiance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_radiance_debuff", "heroes/pirat/serega_radiance", LUA_MODIFIER_MOTION_NONE )

function serega_radiance:Precache(context)
	PrecacheResource( "particle", "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf", context )
	PrecacheResource( "particle", "particles/radiance_owner_fall2022_new.vpcf", context )
end
function serega_radiance:GetIntrinsicModifierName()
	return "modifier_serega_radiance"
end

modifier_serega_radiance = class({})

function modifier_serega_radiance:IsHidden()
	return true
end

function modifier_serega_radiance:IsDebuff()
	return false
end

function modifier_serega_radiance:IsPurgable()
	return false
end

function modifier_serega_radiance:OnCreated( kv )
	if not IsServer() then return end
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.base_miss = self:GetAbility():GetSpecialValueFor( "base_miss" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
	self:PlayEffects( self:GetParent() )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_serega_radiance:OnRefresh( kv )
	if not IsServer() then return end
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.base_miss = self:GetAbility():GetSpecialValueFor( "base_miss" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
	self:PlayEffects( self:GetParent() )
end

function modifier_serega_radiance:OnDestroy( kv )
end

function modifier_serega_radiance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end
function modifier_serega_radiance:OnIntervalThink()
	if not self:GetCaster():IsAlive() then return end
	if self:GetParent():PassivesDisabled() then return end
	self.dmg = self:GetCaster():GetLevel() * self.base_damage * self.interval
	self.miss = self.base_miss + self:GetCaster():GetLevel()
	if self:GetParent():IsIllusion() then
		self.dmg = self.dmg / 2
	end
	if self:GetParent():PassivesDisabled() then return end
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
		local debuff = enemy:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_serega_radiance_debuff",
			{
				duration = self.duration,
			}
		)
	end
end
function modifier_serega_radiance:GetModifierEvasion_Constant()
	return self.miss
end
function modifier_serega_radiance:PlayEffects( target )
	local particle_cast = "particles/radiance_owner_fall2022_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_serega_radiance_debuff = class({})

function modifier_serega_radiance_debuff:IsHidden()
	return true
end
function modifier_serega_radiance_debuff:IsDebuff()
	return true
end
function modifier_serega_radiance_debuff:IsPurgable()
	return false
end
function modifier_serega_radiance_debuff:OnCreated( kv )
end
function modifier_serega_radiance_debuff:OnRefresh( kv )
end
function modifier_serega_radiance_debuff:OnDestroy( kv )
end

function modifier_serega_radiance_debuff:GetEffectName()
	return "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf"
end

function modifier_serega_radiance_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end