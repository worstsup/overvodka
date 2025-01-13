modifier_serega_song_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
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

--------------------------------------------------------------------------------
-- Initializations
function modifier_serega_song_debuff:OnCreated( kv )
	-- references
	self.rate = self:GetAbility():GetSpecialValueFor( "animation_rate" )

	if not IsServer() then return end
end

function modifier_serega_song_debuff:OnRefresh( kv )
	
end

function modifier_serega_song_debuff:OnRemoved()
end

function modifier_serega_song_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_serega_song_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_serega_song_debuff:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_serega_song_debuff:GetOverrideAnimationRate()
	return self.rate
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_serega_song_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
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