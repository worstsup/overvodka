LinkLuaModifier( "modifier_chillzone_thinker", "heroes/chillguy/chillzone", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillzone_effect", "heroes/chillguy/chillzone", LUA_MODIFIER_MOTION_NONE )

chillzone = class({})

function chillzone:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function chillzone:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor( "duration" )
	local vision = self:GetSpecialValueFor( "vision_radius" )
	self.thinker = CreateModifierThinker( caster, self, "modifier_chillzone_thinker", { duration = duration }, point, caster:GetTeamNumber(), false )
	self.thinker = self.thinker:FindModifierByName( "modifier_chillzone_thinker" )
	AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision, duration, false )
end


modifier_chillzone_thinker = class({})

function modifier_chillzone_thinker:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if not IsServer() then return end

	local effect_cast = ParticleManager:CreateParticle( "particles/rubick_faceless_void_chronosphere_new.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
	self:AddParticle( effect_cast, false, false, -1, false, false )
	EmitSoundOn( "Hero_FacelessVoid.Chronosphere", self:GetParent() )
	EmitSoundOn( "chillzone", self:GetParent() )
end

function modifier_chillzone_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_chillzone_thinker:CheckState()
	return {
		[MODIFIER_STATE_FROZEN] = true,
	}
end

function modifier_chillzone_thinker:IsAura() return true end
function modifier_chillzone_thinker:GetModifierAura() return "modifier_chillzone_effect" end
function modifier_chillzone_thinker:GetAuraRadius() return self.radius end
function modifier_chillzone_thinker:GetAuraDuration() return 0.01 end
function modifier_chillzone_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_chillzone_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_chillzone_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end


modifier_chillzone_effect = class({})

function modifier_chillzone_effect:IsHidden() return false end
function modifier_chillzone_effect:IsDebuff() return not self:NotAffected() end
function modifier_chillzone_effect:IsStunDebuff() return not self:NotAffected() end
function modifier_chillzone_effect:IsPurgable() return false end
function modifier_chillzone_effect:GetPriority() return MODIFIER_PRIORITY_ULTRA end

function modifier_chillzone_effect:NotAffected()
	if self:GetParent()==self:GetCaster() then return true end
	if self:GetParent():GetPlayerOwnerID()==self:GetCaster():GetPlayerOwnerID() then return true end
end

function modifier_chillzone_effect:OnCreated()
	self.speed = 550
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		if not self:NotAffected() then
			self:GetParent():InterruptMotionControllers( false )
		else
			self:PlayEffects()
		end
	end
end

function modifier_chillzone_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
	}
end

function modifier_chillzone_effect:GetModifierMoveSpeed_AbsoluteMin()
	if self:NotAffected() then return self.speed end
end

function modifier_chillzone_effect:GetModifierMoveSpeedBonus_Percentage()
	if not self:NotAffected() then return self.slow end
end

function modifier_chillzone_effect:GetModifierIncomingPhysicalDamage_Percentage()
	return -100
end

function modifier_chillzone_effect:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end

function modifier_chillzone_effect:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false )
end