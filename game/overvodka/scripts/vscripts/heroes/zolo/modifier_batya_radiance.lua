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

function modifier_batya_radiance:OnCreated( kv )
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_batya_radiance:OnRefresh( kv )
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
end

function modifier_batya_radiance:OnDestroy( kv )
end
function modifier_batya_radiance:OnIntervalThink()
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():PassivesDisabled() then return end
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
		local debuff = enemy:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_batya_radiance_debuff",
			{
				duration = self.duration,
			}
		)
	end
end