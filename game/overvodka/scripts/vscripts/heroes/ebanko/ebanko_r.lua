LinkLuaModifier( "modifier_ebanko_r", "heroes/ebanko/ebanko_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_scepter", "heroes/ebanko/ebanko_r", LUA_MODIFIER_MOTION_NONE )

ebanko_r = class({})

function ebanko_r:Precache(context)
    PrecacheResource("particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok_drips.vpcf", context)
    PrecacheResource("soundfile", "soundevents/ebi_menya.vsndevts", context )
end

function ebanko_r:GetIntrinsicModifierName()
    return "modifier_ebanko_scepter"
end

function ebanko_r:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function ebanko_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function ebanko_r:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_ebanko_r", { duration = duration })
    caster:EmitSound("ebi_menya")
end

modifier_ebanko_r = class({})

function modifier_ebanko_r:OnCreated()
    self.bonus_damage      = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.hp_regen          = self:GetAbility():GetSpecialValueFor("hp_regen")
    self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    self.bonus_ms          = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_ebanko_r:IsPurgable()
    return false
end

function modifier_ebanko_r:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("ebi_menya")
end

function modifier_ebanko_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_ebanko_r:GetModifierModelScale()
    return 20
end

function modifier_ebanko_r:GetModifierConstantHealthRegen()
    return self.hp_regen
end

function modifier_ebanko_r:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_ebanko_r:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_ebanko_r:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_ebanko_r:GetEffectName()
    return "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok_drips.vpcf"
end

function modifier_ebanko_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_ebanko_scepter = class({})

function modifier_ebanko_scepter:IsHidden()
    return true
end
function modifier_ebanko_scepter:IsPurgable()
    return false
end

function modifier_ebanko_scepter:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED,
    }
    return funcs
end

function modifier_ebanko_scepter:OnHeroKilled(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if params.attacker ~= parent then return end
    if not params.target or not params.target:IsRealHero() or params.target:IsIllusion() then return end
    if parent:HasScepter() then
        local ability = self:GetAbility()
        local existingBuff = parent:FindModifierByName("modifier_ebanko_r")
        if existingBuff then
            local newDuration = existingBuff:GetRemainingTime() + ability:GetSpecialValueFor("scepter_duration")
            existingBuff:SetDuration(newDuration, true)
        else
            parent:AddNewModifier(parent, ability, "modifier_ebanko_r", { duration = ability:GetSpecialValueFor("scepter_duration") })
            parent:EmitSound("ebi_menya")
        end
    end
end
