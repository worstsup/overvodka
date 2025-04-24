LinkLuaModifier( "modifier_stray_innate", "heroes/stray/stray_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stray_innate_debuff", "heroes/stray/stray_innate", LUA_MODIFIER_MOTION_NONE )

stray_innate = class({})

function stray_innate:Precache(context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_innate.vsndevts", context)
    PrecacheResource("particle", "particles/stray_innate.vpcf", context)
end

function stray_innate:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_innate:GetIntrinsicModifierName()
    return "modifier_stray_innate"
end

function stray_innate:OnProjectileHit( target, vLocation )
    if not IsServer() then return end
    if target then
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetCaster():GetAverageTrueAttackDamage(nil)
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        target:EmitSound("Hero_Tiny_Tree.Impact")
        for _,enemy in pairs(enemies) do
            local duration = self:GetSpecialValueFor("duration")
            local stun_duration = self:GetSpecialValueFor("stun_duration")
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_stray_innate_debuff", {duration = duration * (1-enemy:GetStatusResistance())})
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
        end
    end
    return true
end

modifier_stray_innate = class({})

function modifier_stray_innate:IsHidden()
    return true
end

function modifier_stray_innate:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_stray_innate:OnAttackLanded( params )
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not self:GetAbility():IsFullyCastable() then return end
    if self:GetParent():IsIllusion() then return end
    if not params.attacker:IsRealHero() then return end
    if params.attacker:IsAttackImmune() or params.attacker:IsInvulnerable() then return end
    if params.attacker:GetUnitName() == "npc_nelya" then return end
    if params.attacker:IsBuilding() then return end
    local info = 
    {
        EffectName = "particles/stray_innate.vpcf",
        Ability = self:GetAbility(),
        iMoveSpeed = 1000,
        Source = self:GetCaster(),
        Target = params.attacker,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    ProjectileManager:CreateTrackingProjectile(info)
    self:GetCaster():EmitSound("stray_innate")
    self:GetAbility():UseResources(false, false, false, true)
end

modifier_stray_innate_debuff = class({})

function modifier_stray_innate_debuff:IsPurgable() return true end
function modifier_stray_innate_debuff:IsDebuff() return true end

function modifier_stray_innate_debuff:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_stray_innate_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end
