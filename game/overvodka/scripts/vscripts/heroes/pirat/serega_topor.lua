serega_topor = class({})
LinkLuaModifier( "modifier_serega_topor", "heroes/pirat/modifier_serega_topor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_ring_lua", "modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_topor", "heroes/pirat/modifier_topor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_lifesteal_lua", "modifier_generic_lifesteal_lua", LUA_MODIFIER_MOTION_NONE )

function serega_topor:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/serega_topor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_start.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_marci_sidekick.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_axe.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_attack.vpcf", context )
	PrecacheResource( "particle", "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf", context )
end

function serega_topor:Spawn()
	if not IsServer() then return end
end

function serega_topor:OnSpellStart()
	local caster = self:GetCaster()
	local topor_duration = self:GetSpecialValueFor( "topor_duration" )
	caster:AddNewModifier( caster, self, "modifier_topor", { duration = topor_duration } )
	local radius = self:GetSpecialValueFor( "radius" )
	local speed = self:GetSpecialValueFor( "speed" )
	local buff_duration = self:GetSpecialValueFor( "buff_duration" )
	local effect = self:PlayEffects( radius, speed )
	local effect_new = self:PlayEffectsNew()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_lifesteal_lua",
		{ duration = buff_duration }
	)
	local pulse = caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_ring_lua",
		{
			end_radius = radius,
			speed = speed,
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY,
			target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}
	)
	pulse:SetCallback( function( enemy )
		self:OnHit( enemy )
	end)
end

function serega_topor:OnHit( enemy )
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor( "radius" )
	local damage_min = self:GetSpecialValueFor( "damage_min" )
	local damage_max = self:GetSpecialValueFor( "damage_max" )
	local slow_min = self:GetSpecialValueFor( "slow_min" )
	local slow_max = self:GetSpecialValueFor( "slow_max" )
	local duration = self:GetSpecialValueFor( "slow_duration" )
	local distance = (enemy:GetOrigin()-caster:GetOrigin()):Length2D()
	local pct = distance/radius
	pct = math.min(pct,1)
	local damage = damage_min + (damage_max-damage_min)*pct
	local slow = slow_min + (slow_max-slow_min)*pct
	EmitSoundOn( "Ability.PlasmaFieldImpact", enemy )
	local damageTable = {
		victim = enemy,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	ApplyDamage(damageTable)
	if enemy and not enemy:IsNull() then
		enemy:AddNewModifier(caster, self, "modifier_dark_willow_debuff_fear", {duration = duration})
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_serega_topor",
			{
				duration = duration,
				slow = slow,
			}
		)
	end
end

function serega_topor:PlayEffects( radius, speed )
	local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf"
	local sound_cast = "serega_topor"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( speed, radius, 1 ) )
	EmitSoundOn( sound_cast, self:GetCaster() )
	return effect_cast
end

function serega_topor:PlayEffectsNew()
	local particle_cast = "particles/pirat_r_start.vpcf"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast_new )
end
