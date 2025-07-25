invincible_e = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invincible_e_buff", "heroes/invincible/invincible_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invincible_e_debuff", "heroes/invincible/invincible_e", LUA_MODIFIER_MOTION_NONE )

function invincible_e:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

function invincible_e:Precache(context)
	PrecacheResource("soundfile", "soundevents/invincible_e.vsndevts", context)
	PrecacheResource("particle", "particles/invincible_e.vpcf", context)
	PrecacheResource("particle", "particles/invincible_e_heal.vpcf", context)
	PrecacheResource("particle", "particles/bloodseeker_rupture_new.vpcf", context)
end

function invincible_e:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "invincible_e_arcana"
    end
    return "invincible_e"
end

function invincible_e:OnSpellStart()
end

function invincible_e:OnOrbImpact( params )
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = params.target
	if target:IsBuilding() or target:IsWard() or target:GetUnitName() == "npc_factory" then return end
	EmitSoundOn("invincible_e", target)
	local damage = self:GetSpecialValueFor("bonus_damage")
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
	local dmg = (params.damage + damage) * self:GetSpecialValueFor("lifesteal") * 0.01
	caster:HealWithParams(dmg, self, false, true, caster, false)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, dmg, caster:GetPlayerOwner())
	local effect_cast_caster = ParticleManager:CreateParticle( "particles/invincible_e_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast_caster, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast_caster, 1, caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast_caster )
	local effect_cast = ParticleManager:CreateParticle( "particles/invincible_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
	ParticleManager:SetParticleControlForward( effect_cast, 1, (caster:GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	local radius = self:GetSpecialValueFor("facet_radius")
	if radius > 0 then
		local heal = dmg * self:GetSpecialValueFor("facet_pct") * 0.01
		local friends = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
		for _,unit in pairs(friends) do
			if unit ~= caster then
				unit:HealWithParams(heal, self, false, true, caster, false)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, heal, unit:GetPlayerOwner())
				local effect_cast_unit = ParticleManager:CreateParticle( "particles/invincible_e_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
				ParticleManager:SetParticleControl( effect_cast_unit, 0, unit:GetAbsOrigin() )
				ParticleManager:SetParticleControl( effect_cast_unit, 1, unit:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( effect_cast_unit )
			end
		end
	end
	if caster:HasShard() and target and not target:IsNull() and not target:IsDebuffImmune() then
		target:AddNewModifier( caster, self, "modifier_invincible_e_debuff", { duration = self:GetSpecialValueFor("shard_duration") } )
		caster:AddNewModifier( caster, self, "modifier_invincible_e_buff", { duration = self:GetSpecialValueFor("shard_duration") } )
	end
end

modifier_invincible_e_debuff = class({})

function modifier_invincible_e_debuff:IsHidden() return false end
function modifier_invincible_e_debuff:IsDebuff() return true end
function modifier_invincible_e_debuff:IsPurgable() return true end

function modifier_invincible_e_debuff:OnCreated()
    if not IsServer() then return end
end

function modifier_invincible_e_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_invincible_e_debuff:GetModifierDamageOutgoing_Percentage()
    return -self:GetAbility():GetSpecialValueFor("pct_damage")
end

function modifier_invincible_e_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
	return state
end

function modifier_invincible_e_debuff:GetEffectName()
    return "particles/bloodseeker_rupture_new.vpcf"
end

function modifier_invincible_e_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_invincible_e_buff = class({})

function modifier_invincible_e_buff:IsHidden() return false end
function modifier_invincible_e_buff:IsDebuff() return false end
function modifier_invincible_e_buff:IsPurgable() return true end

function modifier_invincible_e_buff:OnCreated(kv)
    if not IsServer() then return end
end

function modifier_invincible_e_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_invincible_e_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("pct_damage")
end

function modifier_invincible_e_buff:GetEffectName()
    return "particles/bloodseeker_rupture_new.vpcf"
end

function modifier_invincible_e_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end