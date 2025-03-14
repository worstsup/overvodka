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

function modifier_serega_song:OnRemoved()
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

function modifier_serega_song:GetAuraEntityReject( hEntity )
	if IsServer() then
		
	end

	return false
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