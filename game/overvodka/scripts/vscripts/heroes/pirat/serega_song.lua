serega_song = class({})
LinkLuaModifier( "modifier_serega_song", "heroes/pirat/serega_song", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_debuff", "heroes/pirat/serega_song", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_scepter", "heroes/pirat/serega_song", LUA_MODIFIER_MOTION_NONE )

function serega_song:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	local modifier = caster:AddNewModifier(
		caster,
		self,
		"modifier_serega_song",
		{ duration = duration }
	)
	local ability = caster:FindAbilityByName( "serega_song_end" )
	if not ability then
		ability = caster:AddAbility( "serega_song_end" )
		ability:SetStolen( true )
	end
	ability:SetLevel( 1 )
	ability.modifier = modifier
	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)
	ability:StartCooldown( ability:GetCooldown( 1 ) )
end

serega_song_end = class({})
function serega_song_end:IsStealable() return false end
function serega_song_end:OnSpellStart()
	self.modifier:End()
	self.modifier = nil
end

modifier_serega_song = class({})

function modifier_serega_song:IsHidden()
	return false
end
function modifier_serega_song:IsDebuff()
	return false
end
function modifier_serega_song:IsPurgable()
	return false
end

function modifier_serega_song:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if not IsServer() then return end
	local caster = self:GetCaster()
	self.scepter = caster:AddNewModifier(
		caster,
		self:GetAbility(),
		"modifier_serega_song_scepter",
		{}
	)

	self:PlayEffects()
end

function modifier_serega_song:OnRefresh( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )	
end

function modifier_serega_song:OnDestroy()
	if not IsServer() then return end
	if self.scepter and not self.scepter:IsNull() then
		self.scepter:Destroy()
	end
	local ability = self:GetCaster():FindAbilityByName( "serega_song_end" )
	if not ability then return end
	self:GetCaster():SwapAbilities(
		self:GetAbility():GetAbilityName(),
		ability:GetAbilityName(),
		true,
		false
	)
end

function modifier_serega_song:End()
	local sound_cast = "serega_stop"
	local sound_stop = "Hero_NagaSiren.SongOfTheSiren.Cancel"
	StopSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_stop, self:GetCaster() )
	self:Destroy()
end

function modifier_serega_song:IsAura()
	return true
end

function modifier_serega_song:GetModifierAura()
	return "modifier_serega_song_debuff"
end

function modifier_serega_song:GetAuraRadius()
	return self.radius
end

function modifier_serega_song:GetAuraDuration()
	return 0.4
end

function modifier_serega_song:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_serega_song:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_serega_song:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_serega_song:PlayEffects()
	local particle_cast1 = "particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_siren/naga_siren_song_aura.vpcf"
	local sound_cast = "serega_stop"
	local caster = self:GetCaster()
	local effect_cast = ParticleManager:CreateParticle( particle_cast1, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_cast, caster )
end


modifier_serega_song_scepter = class({})

function modifier_serega_song_scepter:IsHidden()
	return true
end
function modifier_serega_song_scepter:IsDebuff()
	return false
end
function modifier_serega_song_scepter:IsPurgable()
	return false
end
function modifier_serega_song_scepter:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_serega_song_scepter:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen_rate" )
	self.regen_self = self:GetAbility():GetSpecialValueFor( "regen_rate_self" )
	if not IsServer() then return end
end

function modifier_serega_song_scepter:OnRefresh( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen_rate" )
	self.regen_self = self:GetAbility():GetSpecialValueFor( "regen_rate_self" )
	if not IsServer() then return end	
end

function modifier_serega_song_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end

function modifier_serega_song_scepter:GetModifierHealthRegenPercentage()
	if self:GetParent()==self:GetCaster() then
		return self.regen_self
	end
	return self.regen
end

function modifier_serega_song_scepter:IsAura()
	return self:GetParent()==self:GetCaster()
end

function modifier_serega_song_scepter:GetModifierAura()
	return "modifier_serega_song_scepter"
end

function modifier_serega_song_scepter:GetAuraRadius()
	return self.radius
end

function modifier_serega_song_scepter:GetAuraDuration()
	return 0.4
end

function modifier_serega_song_scepter:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_serega_song_scepter:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_serega_song_scepter:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_serega_song_scepter:GetAuraEntityReject( hEntity )
	return false
end


modifier_serega_song_debuff = class({})

function modifier_serega_song_debuff:IsHidden()
	return false
end
function modifier_serega_song_debuff:IsDebuff()
	return true
end
function modifier_serega_song_debuff:IsStunDebuff()
	return false
end
function modifier_serega_song_debuff:IsPurgable()
	return false
end
function modifier_serega_song_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_serega_song_debuff:OnCreated( kv )
	self.rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )
	if not IsServer() then return end
end

function modifier_serega_song_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
end

function modifier_serega_song_debuff:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_serega_song_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_serega_song_debuff:CheckState()
	return {
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

function modifier_serega_song_debuff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_song_debuff.vpcf"
end

function modifier_serega_song_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_serega_song_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_serega_song_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end