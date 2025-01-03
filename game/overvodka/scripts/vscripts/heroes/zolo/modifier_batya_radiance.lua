modifier_batya_radiance = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_batya_radiance:IsHidden()
	return true
end

function modifier_batya_radiance:IsDebuff()
	return false
end

function modifier_batya_radiance:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_batya_radiance:OnCreated( kv )
	-- references
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
	-- references
	self.base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.duration = 1
end

function modifier_batya_radiance:OnDestroy( kv )
end
function modifier_batya_radiance:OnIntervalThink()
	-- find enemies
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():HasModifier("modifier_silver_edge_debuff") then return end
	if self:GetParent():HasModifier("modifier_break") then return end
	self.dmg = self.base_damage * self.interval
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
			"modifier_batya_radiance_debuff",
			{
				duration = self.duration,
			}
		)
	end
end