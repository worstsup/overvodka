LinkLuaModifier("modifier_eldzhey_e", "heroes/eldzhey/eldzhey_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_eldzhey_e_root", "heroes/eldzhey/eldzhey_e", LUA_MODIFIER_MOTION_NONE)

eldzhey_e = class({})

function eldzhey_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/parit.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf", context)
	PrecacheResource("particle", "particles/compendium_2024_teleport_endcap_smoke_new.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_beam.vpcf", context)
end

function eldzhey_e:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	EmitSoundOn("parit", caster)
	local cooldown = caster:FindAbilityByName("eldzhey_w"):GetCooldownTimeRemaining()
	caster:FindAbilityByName("eldzhey_w"):StartCooldown(cooldown + 6)
	caster:AddNewModifier(caster, self, "modifier_eldzhey_e", {duration = self:GetSpecialValueFor("duration")})
end

modifier_eldzhey_e = class({})

function modifier_eldzhey_e:IsPurgable() return true end
function modifier_eldzhey_e:IsHidden() return false end

function modifier_eldzhey_e:OnCreated()
	if not IsServer() then return end
	local smoke_particle = ParticleManager:CreateParticle( "particles/compendium_2024_teleport_endcap_smoke_new.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( smoke_particle, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( smoke_particle )
	local run_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(run_particle, false, false, -1, false, false)
end

function modifier_eldzhey_e:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_eldzhey_e:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_as")
end

function modifier_eldzhey_e:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")
end

function modifier_eldzhey_e:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_eldzhey_e:OnAttackLanded(params)
    if not IsServer() then return end
	if self:GetAbility():GetSpecialValueFor("chance") <= 0 then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsBuilding() then return end
	local target = params.target
	if RollPercentage( self:GetAbility():GetSpecialValueFor("chance") ) then
		target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_eldzhey_e_root", {duration = self:GetAbility():GetSpecialValueFor("root_duration") * (1 - target:GetStatusResistance())})
	end
end

modifier_eldzhey_e_root = class({})

function modifier_eldzhey_e_root:IsPurgable() return true end
function modifier_eldzhey_e_root:IsHidden() return false end

function modifier_eldzhey_e_root:OnCreated()
	if not IsServer() then return end
	local root_particle = ParticleManager:CreateParticle("particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( root_particle, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( root_particle )
end

function modifier_eldzhey_e_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end