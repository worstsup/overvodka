shkolnik_w = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shkolnik_armor", "heroes/shkolnik/shkolnik_w", LUA_MODIFIER_MOTION_NONE )

function shkolnik_w:Precache(context)
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", context )
	PrecacheResource( "particle", "particles/marci_unleash_stack_number_new.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/dvoika.vsndevts", context )
end

function shkolnik_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then
		return
	end
	local duration = self:GetSpecialValueFor( "stun_duration" )
	local damage = self:GetSpecialValueFor( "fireblast_damage" )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}
	target:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_generic_stunned_lua", 
		{duration = duration}
	)
	target:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_shkolnik_armor", 
		{duration = duration}
	)
	self:PlayEffects( target )
	self:PlayEffects1( target )
	ApplyDamage( damageTable )
end
function shkolnik_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "dvoika", target )
end

function shkolnik_w:PlayEffects1( target )
	local particle_cast = "particles/marci_unleash_stack_number_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, target )
end

modifier_shkolnik_armor = class({})

function modifier_shkolnik_armor:IsHidden()
	return true
end
function modifier_shkolnik_armor:IsDebuff()
	return true
end
function modifier_shkolnik_armor:IsStunDebuff()
	return false
end
function modifier_shkolnik_armor:IsPurgable()
	return true
end

function modifier_shkolnik_armor:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_shkolnik_armor:OnRefresh()
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_shkolnik_armor:OnRemoved()
end

function modifier_shkolnik_armor:OnDestroy()
end
function modifier_shkolnik_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_shkolnik_armor:GetModifierPhysicalArmorBonus()
	return self.armor
end