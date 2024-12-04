chillguy_e = class({})
LinkLuaModifier( "modifier_chillguy_e", "modifier_chillguy_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_blind", "modifier_chillguy_blind", LUA_MODIFIER_MOTION_NONE )

function chillguy_e:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor( "duration" )
	local blindness_dur = self:GetSpecialValueFor( "blindness_dur" )
	local damage = self:GetSpecialValueFor( "damage" )
	self.damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self, --Optional.
	}
	ApplyDamage( self.damageTable )
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_chillguy_e", -- modifier name
		{ duration = duration } -- kv
	)
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_chillguy_blind", -- modifier name
		{ duration = blindness_dur } -- kv
	)
	local effect_cast = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_blink_arrival_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end