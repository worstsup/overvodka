chillguy_e = class({})
LinkLuaModifier( "modifier_chillguy_e", "heroes/chillguy/modifier_chillguy_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_blind", "heroes/chillguy/modifier_chillguy_blind", LUA_MODIFIER_MOTION_NONE )

function chillguy_e:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	local effect_cast = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_blink_arrival_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	local duration = self:GetSpecialValueFor( "duration" )
	local blindness_dur = self:GetSpecialValueFor( "blindness_dur" )
	if target:IsDebuffImmune() or target:IsMagicImmune() then return end
	local damage = self:GetSpecialValueFor( "damage" )
	self.damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
	}
	ApplyDamage( self.damageTable )
	target:AddNewModifier(
		caster,
		self,
		"modifier_chillguy_e",
		{ duration = duration * (1 - target:GetStatusResistance()) }
	)
	target:AddNewModifier(
		caster,
		self,
		"modifier_chillguy_blind",
		{ duration = blindness_dur * (1 - target:GetStatusResistance()) }
	)
end