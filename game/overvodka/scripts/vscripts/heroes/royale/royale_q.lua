LinkLuaModifier("modifier_royale_q", "heroes/royale/royale_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_q_stun", "heroes/royale/royale_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_q_snowball_slow", "heroes/royale/royale_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)

royale_q = class({})

function royale_q:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/royale_zap.vpcf", context)
    PrecacheResource("particle", "particles/royale_snowball.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/snowball/snowball_projectile_ability_endcap.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_freeze_stacks.vpcf", context)
end

function royale_q:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function royale_q:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_q:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_q:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_royale_q") then
		return "royale_q_2"
	end
	return "royale_q"
end

function royale_q:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    if self:GetCaster():HasModifier("modifier_royale_q") then
        local travel_distance   = (point - caster:GetAbsOrigin()):Length2D()
        local direction = (point - caster:GetAbsOrigin()):Normalized()
        direction.z = 0
        local info = {
            Source              = caster,
            Ability             = self,
            bVisibleToEnemies   = true,
            bProvidesVision     = true,
            iVisionRadius       = 300,
            iVisionTeamNumber   = caster:GetTeamNumber(),
            vVelocity           = direction * 1200,
            fDistance           = travel_distance,
            vSpawnOrigin        = caster:GetAbsOrigin(),
            EffectName         = "particles/royale_snowball.vpcf",
        }
        ProjectileManager:CreateLinearProjectile(info)
        EmitSoundOn("Royale.Snowball.Throw", caster)
        caster:RemoveModifierByName("modifier_royale_q")
    else
        local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _,unit in pairs(units) do
            local damageTable = { victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self}
            unit:AddNewModifier(caster, self, "modifier_royale_q_stun", {duration = self:GetSpecialValueFor("stun_duration") * (1 - unit:GetStatusResistance())})
            ApplyDamage(damageTable)
        end
        EmitSoundOnLocationWithCaster(point, "Royale.Zap", caster)	
        local p = ParticleManager:CreateParticle("particles/royale_zap.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(p, 0, point)
        ParticleManager:SetParticleControl(p, 1, Vector(radius, radius, radius))
        caster:AddNewModifier(caster, self, "modifier_royale_q", {})
    end
end

function royale_q:OnProjectileHit_ExtraData(target, location, extra)
    if not location then return end
    if not IsServer() then return end
    local caster = self:GetCaster()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),location,nil,self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,0,0,false)

    for _,unit in pairs(enemies) do
        local unit_pos = unit:GetAbsOrigin()
        local knockback_direction = (unit_pos - location):Normalized()
        ApplyDamage({victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        unit:AddNewModifier(caster, self, "modifier_royale_q_snowball_slow", {duration = self:GetSpecialValueFor("slow_duration") * (1 - unit:GetStatusResistance())})
        unit:AddNewModifier( caster, self, "modifier_generic_knockback_lua", 
            { duration = 0.4, distance = self:GetSpecialValueFor("knockback_distance"), height = 0, direction_x = knockback_direction.x, direction_y = knockback_direction.y })
    end
    local p = ParticleManager:CreateParticle("particles/econ/events/snowball/snowball_projectile_ability_endcap.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, location)
    ParticleManager:SetParticleControl(p, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)
    EmitSoundOnLocationWithCaster(location, "Royale.Snowball.Impact", caster)
end

modifier_royale_q_stun = class({})
function modifier_royale_q_stun:IsHidden() return false end
function modifier_royale_q_stun:IsPurgable() return true end
function modifier_royale_q_stun:IsDebuff() return true end
function modifier_royale_q_stun:IsStunDebuff() return true end

function modifier_royale_q_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true, }
	return state
end

function modifier_royale_q_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_royale_q_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_royale_q_stun:GetTexture()
    return "royale_q"
end

modifier_royale_q_snowball_slow = class({})

function modifier_royale_q_snowball_slow:IsHidden() return false end
function modifier_royale_q_snowball_slow:IsDebuff() return true end
function modifier_royale_q_snowball_slow:IsPurgable() return true end

function modifier_royale_q_snowball_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_royale_q_snowball_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_royale_q_snowball_slow:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("slow_as")
end

function modifier_royale_q_snowball_slow:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_freeze_stacks.vpcf"
end

function modifier_royale_q_snowball_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_royale_q_snowball_slow:GetTexture()
    return "royale_q_2"
end

modifier_royale_q = class({})
function modifier_royale_q:IsHidden() return true end
function modifier_royale_q:IsPurgable() return false end
function modifier_royale_q:RemoveOnDeath() return false end