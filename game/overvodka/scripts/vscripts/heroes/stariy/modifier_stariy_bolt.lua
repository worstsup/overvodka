modifier_stariy_bolt = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_stariy_bolt:IsHidden()
	return true
end

function modifier_stariy_bolt:IsDebuff()
	return false
end

function modifier_stariy_bolt:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_stariy_bolt:OnCreated( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self.microstun = self:GetAbility():GetSpecialValueFor( "microstun" )
	self.percent = self:GetAbility():GetSpecialValueFor( "damage_percent" )
	self.cooldown = self:GetAbility():GetCooldown(1)
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_stariy_bolt:OnRefresh( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self.percent = self:GetAbility():GetSpecialValueFor( "damage_percent" )
	self.microstun = self:GetAbility():GetSpecialValueFor( "microstun" )
	self.cooldown = self:GetAbility():GetCooldown(1)
end

function modifier_stariy_bolt:OnDestroy( kv )

end

function modifier_stariy_bolt:OnIntervalThink()
	if self:GetParent():IsIllusion() then return end
	if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
	if not self:GetParent():IsAlive() then return end
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

	-- damage enemies
	for _,enemy in pairs(enemies) do
		local debuff = enemy:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_stariy_bolt_debuff",
			{
				duration = self.duration,
			}
		)
		-- enemy:AddNewModifier(
		-- 	self:GetParent(),
		--	self:GetAbility(),
		--	"modifier_generic_stunned_lua", 
		--	{duration = self.microstun}
		--)
		local dmg = self.damage + self.percent * enemy:GetMaxHealth() * 0.01
		ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		-- Play effects
		self:PlayEffectsNew( self:GetParent() )
		self:PlayEffects( enemy )
		if self:GetParent():HasScepter() and self:GetParent():HasModifier("modifier_stariy_fly") then
			self:GetAbility():StartCooldown(1.0)
		else
			self:GetAbility():StartCooldown(self.cooldown)
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_stariy_bolt:PlayEffects( target )
	local particle_cast = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	EmitSoundOn( "Hero_Zuus.LightningBolt", target )	
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_stariy_bolt:PlayEffectsNew( target )
	local particle_cast = "particles/earthshaker_arcana_totem_cast_clouds_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	EmitSoundOn( "yo", target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end