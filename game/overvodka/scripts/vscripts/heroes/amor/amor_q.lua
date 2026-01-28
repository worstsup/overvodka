LinkLuaModifier( "modifier_amor_q", "heroes/amor/amor_q", LUA_MODIFIER_MOTION_NONE )

amor_q = class({})

function amor_q:Precache( ctx )
    PrecacheResource( "soundfile", "soundevents/amor_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_slardar/slardar_sprint.vpcf", ctx )
end

function amor_q:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_amor_q", { duration = self:GetSpecialValueFor( "duration" ) } )
	caster:EmitSound("amor_q")
end


modifier_amor_q = class({})

function modifier_amor_q:IsHidden() return false end
function modifier_amor_q:IsDebuff() return false end
function modifier_amor_q:IsPurgable() return true end

function modifier_amor_q:OnCreated()
	self.bonus_speed = self:GetAbility():GetSpecialValueFor( "bonus_speed" )
    if not IsServer() then return end
    self.mod = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_item_vindicators_axe", {} )
end

function modifier_amor_q:OnDestroy()
    if not IsServer() then return end
    if self.mod then
        self.mod:Destroy()
    end
end

function modifier_amor_q:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_amor_q:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_speed
end

function modifier_amor_q:CheckState()
	return {
	    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_amor_q:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end

function modifier_amor_q:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end