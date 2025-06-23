modifier_stariy_bolt = class({})
peterka = 0
function modifier_stariy_bolt:IsHidden()
	return true
end

function modifier_stariy_bolt:IsDebuff()
	return false
end

function modifier_stariy_bolt:IsPurgable()
	return false
end

function modifier_stariy_bolt:OnCreated( kv )
	if not IsServer() then return end
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
	if not IsServer() then return end
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
	for _,enemy in pairs(enemies) do
		local debuff = enemy:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_stariy_bolt_debuff",
			{
				duration = self.duration,
			}
		)
		self:PlayEffectsNew( self:GetParent() )
		self:PlayEffects( enemy )
		if self:GetParent():HasScepter() then
			CreateModifierThinker( self:GetParent(), self:GetAbility(), "modifier_stariy_lasers_linger_thinker", { duration = self:GetAbility():GetSpecialValueFor( "linger_time" ) }, enemy:GetAbsOrigin(), self:GetParent():GetTeamNumber(), false )
		end
		local dmg = self.damage + self.percent * enemy:GetMaxHealth() * 0.01
		if enemy:GetUnitName() == "npc_dota_hero_necrolyte" then
			dmg = 0
			if peterka == 0 then
				EmitSoundOn( "stariy_peterka", self:GetParent() )
			end
			peterka = peterka + 1
			if peterka == 10 then
				peterka = 0
			end
		end
		if enemy:IsCreep() then
			dmg = dmg * self:GetAbility():GetSpecialValueFor("creep_mult")
		end
		ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		self:GetAbility():UseResources(false, false, false, true)
	end
end

function modifier_stariy_bolt:PlayEffects( target )
	local particle_cast = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf"
	if not target then return end
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