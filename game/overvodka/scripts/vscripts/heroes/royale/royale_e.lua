LinkLuaModifier("modifier_royale_e", "heroes/royale/royale_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_e_rage", "heroes/royale/royale_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_e_freeze", "heroes/royale/royale_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_e_freeze_aura", "heroes/royale/royale_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_e_rage_aura", "heroes/royale/royale_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

royale_e = class({})

function royale_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_freeze_stacks.vpcf", context)
    PrecacheResource("particle", "particles/royale_rage.vpcf", context)
    PrecacheResource("particle", "particles/royale_freeze.vpcf", context)
    PrecacheResource("particle", "particles/royale_freeze_effect.vpcf", context)
end

function royale_e:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_royale_5" )
end

function royale_e:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function royale_e:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_e:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_e:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_royale_e") then
		return "royale_e_2"
	end
	return "royale_e"
end

function royale_e:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _,unit in pairs(units) do
        ApplyDamage({ victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end
    if self:GetCaster():HasModifier("modifier_royale_e") then
        CreateModifierThinker(caster, self, "modifier_royale_e_rage_aura", {duration = self:GetSpecialValueFor("rage_duration")}, point, caster:GetTeamNumber(), false)
        EmitSoundOnLocationWithCaster(point, "Royale.Rage", caster)
        caster:RemoveModifierByName("modifier_royale_e")
    else
        for _,unit in pairs(units) do
            if unit and not unit:IsNull() then
                unit:AddNewModifier(caster, self, "modifier_royale_e_freeze", {duration = self:GetSpecialValueFor("freeze_duration") * (1 - unit:GetStatusResistance())})
            end
        end
        CreateModifierThinker(caster, self, "modifier_royale_e_freeze_aura", {duration = self:GetSpecialValueFor("freeze_duration")}, point, caster:GetTeamNumber(), false)
        EmitSoundOnLocationWithCaster(point, "Royale.Freeze", caster)
        caster:AddNewModifier(caster, self, "modifier_royale_e", {})
    end
end

modifier_royale_e_rage_aura = class({})
function modifier_royale_e_rage_aura:IsHidden() return true end
function modifier_royale_e_rage_aura:IsPurgable() return false end
function modifier_royale_e_rage_aura:IsAura() return true end
function modifier_royale_e_rage_aura:GetModifierAura() return "modifier_royale_e_rage" end
function modifier_royale_e_rage_aura:GetAuraDuration() return 0.1 end
function modifier_royale_e_rage_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_royale_e_rage_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_royale_e_rage_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_royale_e_rage_aura:GetAuraSearchFlags() return 0 end

function modifier_royale_e_rage_aura:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle( "particles/royale_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self:GetAbility():GetSpecialValueFor("radius"), 1, 1 ) )
    ParticleManager:SetParticleControl( effect_cast, 15, Vector( 191, 64, 191 ) )
    ParticleManager:SetParticleControl( effect_cast, 16, Vector( 191, 64, 191 ) )
	self:AddParticle(effect_cast, false, false,	-1,	false, false)
end

modifier_royale_e_freeze_aura = class({})
function modifier_royale_e_freeze_aura:IsHidden() return true end
function modifier_royale_e_freeze_aura:IsPurgable() return false end
function modifier_royale_e_freeze_aura:OnCreated()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius") + 75
    local effect_cast = ParticleManager:CreateParticle( "particles/royale_freeze.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( radius, radius, radius ) )
	self:AddParticle(effect_cast, false, false,	-1,	false, false)
end

modifier_royale_e_freeze = class({})
function modifier_royale_e_freeze:IsHidden() return false end
function modifier_royale_e_freeze:IsPurgable() return true end
function modifier_royale_e_freeze:IsDebuff() return true end
function modifier_royale_e_freeze:IsStunDebuff() return true end
function modifier_royale_e_freeze:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/royale_freeze_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 2, self:GetParent():GetOrigin() )
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_royale_e_freeze:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true, }
	return state
end

function modifier_royale_e_freeze:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_royale_e_freeze:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_royale_e_freeze:GetTexture()
    return "royale_e"
end

modifier_royale_e_rage = class({})
function modifier_royale_e_rage:IsHidden() return false end
function modifier_royale_e_rage:IsPurgable() return false end

function modifier_royale_e_rage:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetRenderColor(160, 32, 240)
end

function modifier_royale_e_rage:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SetRenderColor(255, 255, 255) 
end

function modifier_royale_e_rage:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_royale_e_rage:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_royale_e_rage:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end

function modifier_royale_e_rage:GetTexture()
    return "royale_e_2"
end

modifier_royale_e = class({})
function modifier_royale_e:IsHidden() return true end
function modifier_royale_e:IsPurgable() return false end
function modifier_royale_e:RemoveOnDeath() return false end