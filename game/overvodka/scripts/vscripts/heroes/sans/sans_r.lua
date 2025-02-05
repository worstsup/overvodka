sans_r = class({})
LinkLuaModifier( "modifier_sans_r", "heroes/sans/sans_r", LUA_MODIFIER_MOTION_NONE )
k = 0

function sans_r:Precache(context)
	PrecacheResource( "soundfile", "soundevents/sans_r_1.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/sans_r_2.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/sans_r_start.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/sans_r_start_1.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/sans_r_start_2.vsndevts", context )
	PrecacheResource( "particle", "particles/sans_r.vpcf", context)
end
function sans_r:OnAbilityPhaseStart()
	if k % 2 == 0 then
		EmitSoundOn( "sans_r_start_1", self:GetCaster() )
	else
		EmitSoundOn( "sans_r_start_2", self:GetCaster() )
	end
	EmitSoundOn("sans_r_start", self:GetCaster())
end
function sans_r:OnSpellStart()
	if not IsServer() then return end
	if k % 2 == 0 then
		EmitSoundOn( "sans_r_1", self:GetCaster() )
	else
		EmitSoundOn( "sans_r_2", self:GetCaster() )
	end
	k = k + 1
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sans_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_sans_r = class({})

function modifier_sans_r:IsPurgable()
    return false
end

function modifier_sans_r:OnCreated()
    if not IsServer() then return end
	self.bonus_ms = self:GetAbility():GetSpecialValueFor("bonus_ms")
    local parent = self:GetParent()
    self.particle = ParticleManager:CreateParticle( "particles/sans_r.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
	ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_l", self:GetParent():GetAbsOrigin(), true )
end

function modifier_sans_r:OnRefresh()
	if not IsServer() then return end
	self.bonus_ms = self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_sans_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_sans_r:GetModifierMoveSpeedBonus_Percentage()
	return 15
end

function modifier_sans_r:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
