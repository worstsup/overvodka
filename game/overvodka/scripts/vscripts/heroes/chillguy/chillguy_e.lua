chillguy_e = class({})
LinkLuaModifier( "modifier_chillguy_e", "heroes/chillguy/chillguy_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_blind", "heroes/chillguy/chillguy_e", LUA_MODIFIER_MOTION_NONE )

function chillguy_e:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	local effect_cast = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_blink_arrival_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetCaster():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	local duration = self:GetSpecialValueFor( "duration" )
	local blindness_dur = self:GetSpecialValueFor( "blindness_dur" )
	target:AddNewModifier( caster, self, "modifier_chillguy_e", { duration = duration * (1 - target:GetStatusResistance()) } )
	target:AddNewModifier( caster, self, "modifier_chillguy_blind", { duration = blindness_dur * (1 - target:GetStatusResistance()) } )
	ApplyDamage( { victim = target, attacker = caster, damage = self:GetSpecialValueFor( "damage" ), damage_type = DAMAGE_TYPE_PURE, ability = self } )
end


modifier_chillguy_e = class({})

function modifier_chillguy_e:IsHidden() return false end
function modifier_chillguy_e:IsDebuff() return true end
function modifier_chillguy_e:IsStunDebuff() return false end
function modifier_chillguy_e:IsPurgable() return false end

function modifier_chillguy_e:OnCreated()
	if not IsServer() then return end
	local effect_cast = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_explosion_white_arcana1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle( effect_cast, false, false, MODIFIER_PRIORITY_SUPER_ULTRA, false, false )
	EmitSoundOn( "chillguy_photo", self:GetParent() )
end

function modifier_chillguy_e:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
	}
end

function modifier_chillguy_e:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_chillguy_e:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

modifier_chillguy_blind = class({})

function modifier_chillguy_blind:IsHidden() return true end
function modifier_chillguy_blind:IsDebuff() return true end
function modifier_chillguy_blind:IsStunDebuff() return false end
function modifier_chillguy_blind:IsPurgable() return false end

function modifier_chillguy_blind:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
end

function modifier_chillguy_blind:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_chillguy_blind:GetBonusDayVision()
	return -1600
end

function modifier_chillguy_blind:GetBonusNightVision()
	return -600
end