t2x2_e = class({})
LinkLuaModifier( "modifier_t2x2_e", "heroes/t2x2/t2x2_e", LUA_MODIFIER_MOTION_NONE )

function t2x2_e:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", context )
	PrecacheResource( "particle", "particles/t2x2_e_purge.vpcf", context )
end

function t2x2_e:Spawn()
	if not IsServer() then return end
end

function t2x2_e:GetIntrinsicModifierName()
	return "modifier_t2x2_e"
end

modifier_t2x2_e = class({})

function modifier_t2x2_e:IsHidden() return true end
function modifier_t2x2_e:IsDebuff() return false end
function modifier_t2x2_e:IsPurgable() return false end
function modifier_t2x2_e:AllowIllusionDuplicate() return true end

function modifier_t2x2_e:OnCreated( kv )
	self.parent = self:GetParent()
	self.block = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
	self.purge = self:GetAbility():GetSpecialValueFor( "damage_cleanse" )
	self.reset = self:GetAbility():GetSpecialValueFor( "damage_reset_interval" )

	if not IsServer() then return end
	self.damage = 0
end

function modifier_t2x2_e:OnRefresh( kv )
	self.block = self:GetAbility():GetSpecialValueFor( "damage_reduction" )
	self.purge = self:GetAbility():GetSpecialValueFor( "damage_cleanse" )
	self.reset = self:GetAbility():GetSpecialValueFor( "damage_reset_interval" )
end

function modifier_t2x2_e:OnRemoved()
end

function modifier_t2x2_e:OnDestroy()
end

function modifier_t2x2_e:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}

	return funcs
end

function modifier_t2x2_e:OnTakeDamage( params )
	if not IsServer() then return end
	if self:GetAbility():GetSpecialValueFor("has_facet") == 0 then return end
	if params.unit~=self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if not params.attacker:GetPlayerOwner() then return end
	self:StartIntervalThink( self.reset )
	self.damage = self.damage + params.damage
	if self.damage < self.purge then return end
	self.damage = 0
	self.parent:Purge( false, true, false, true, true )
	self:PlayEffects()
end

function modifier_t2x2_e:GetModifierPhysical_ConstantBlock()
	if self.parent:PassivesDisabled() then return 0 end
	return self.block + self.parent:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("damage_reduction_hp") * 0.01
end

function modifier_t2x2_e:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self.damage = 0
end

function modifier_t2x2_e:PlayEffects()
	local particle_cast = "particles/t2x2_e_purge.vpcf"
	local sound_cast = "Hero_Tidehunter.KrakenShell"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl(effect_cast, 3, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect_cast, 4, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self.parent )
end