modifier_serega_radiance = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_serega_radiance:IsHidden()
	return true
end

function modifier_serega_radiance:IsDebuff()
	return false
end

function modifier_serega_radiance:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_serega_radiance:OnCreated( kv )
	-- references
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
	-- references
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.base_miss = self:GetAbility():GetSpecialValueFor( "base_miss" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
	self:PlayEffects( self:GetParent() )
end

function modifier_serega_radiance:OnDestroy( kv )
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_serega_radiance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end
function modifier_serega_radiance:OnIntervalThink()
	if not self:GetCaster():IsAlive() then return end
	self.dmg = self:GetCaster():GetLevel() * self.base_damage * self.interval
	self.miss = self.base_miss + self:GetCaster():GetLevel()
	if self:GetParent():IsIllusion() then
		self.dmg = self.dmg / 2
	end
	-- find enemies
	if self:GetParent():HasModifier("modifier_silver_edge_debuff") then return end
	if self:GetParent():HasModifier("modifier_break") then return end
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	self.damageTable = {
		-- victim = target,
		attacker = self:GetParent(),
		damage = self.dmg,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}
	-- damage enemies
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