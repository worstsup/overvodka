LinkLuaModifier( "modifier_ebanko_q", "heroes/ebanko/ebanko_q.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_q_slow", "heroes/ebanko/ebanko_q.lua", LUA_MODIFIER_MOTION_NONE )

ebanko_q = class({})

function ebanko_q:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/ebanul_moroz.vsndevts", context )
	PrecacheResource( "particle", "particles/econ/items/crystal_maiden/cm_screeauk/cm_screeauk_arcana_body_ambient.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/zima_holoda.vsndevts", context )
end

function ebanko_q:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
		FIND_ANY_ORDER,
		false
	)
	local k = caster._ebanko_q_sound_index or 0
	if (k % 2 == 0) then
		EmitSoundOn("zima_holoda", caster)
	else
		EmitSoundOn("ebanul_moroz", caster)
	end
	caster._ebanko_q_sound_index = k + 1
	for _,unit in pairs(targets) do
		unit:AddNewModifier(caster, self, "modifier_ebanko_q", {duration = duration})
	end
end

modifier_ebanko_q = class({})
function modifier_ebanko_q:IsHidden() return false end
function modifier_ebanko_q:IsDebuff() return true end
function modifier_ebanko_q:IsPurgable() return true end
function modifier_ebanko_q:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_ebanko_q:OnIntervalThink()
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	})
end

function modifier_ebanko_q:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
	return state
end

function modifier_ebanko_q:GetEffectName()
	return "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf"
end

function modifier_ebanko_q:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ebanko_q:OnDestroy()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ebanko_q_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_dur")})
end

modifier_ebanko_q_slow = class({})
function modifier_ebanko_q_slow:IsHidden() return false end
function modifier_ebanko_q_slow:IsDebuff() return true end
function modifier_ebanko_q_slow:IsPurgable() return true end
function modifier_ebanko_q_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_ebanko_q_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_slow")
end

function modifier_ebanko_q_slow:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("as_slow")
end

function modifier_ebanko_q_slow:GetEffectName()
	return "particles/econ/items/crystal_maiden/cm_screeauk/cm_screeauk_arcana_body_ambient.vpcf"
end

function modifier_ebanko_q_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end