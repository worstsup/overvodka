LinkLuaModifier("modifier_azazin_e", "heroes/azazin/azazin_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_e_caster", "heroes/azazin/azazin_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_e_enemy", "heroes/azazin/azazin_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_e_debuff", "heroes/azazin/azazin_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

azazin_e = class({})
k = 0
function azazin_e:Precache(context)
    PrecacheResource("particle", "particles/azazin_e_stack.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf", context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_lifesteal.vpcf", context)
    PrecacheResource("particle", "particles/azazin_e_debuff.vpcf", context)
    PrecacheResource("particle", "particles/azazin_e_exp.vpcf", context)
    PrecacheResource("soundfile", "soundevents/azazin_e_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/azazin_e_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/azazin_e_3.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/azazin_e_4.vsndevts", context)
end

function azazin_e:GetIntrinsicModifierName() 
    return "modifier_azazin_e"
end

modifier_azazin_e = class({})

function modifier_azazin_e:IsHidden() 
    return true
end
function modifier_azazin_e:IsPurgable() 
    return false 
end

function modifier_azazin_e:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_azazin_e:OnCreated()
    if not IsServer() then return end
end

function modifier_azazin_e:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.no_attack_cooldown then return end
    if self:GetParent():PassivesDisabled() then return end
    if self:GetParent():IsIllusion() then return end
    if params.target:IsBuilding() then return end

    local target = params.target
    local ability = self:GetAbility()
    local required_hits = ability:GetSpecialValueFor("required_hits")
    local counter_duration = ability:GetSpecialValueFor("counter_duration")
    local effect_duration = ability:GetSpecialValueFor("effect_duration")
    local stun_duration = ability:GetSpecialValueFor("stun_duration")
    if target:HasModifier("modifier_azazin_e_enemy") then
        local enemyMod = target:FindModifierByName("modifier_azazin_e_enemy")
        enemyMod:IncrementStackCount()
        enemyMod:SetDuration(counter_duration, true)
        if enemyMod:GetStackCount() >= required_hits then
            enemyMod:Destroy()
            if self:GetParent():HasScepter() then
                self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_azazin_e_caster", { duration = effect_duration })
            end
            target:AddNewModifier(self:GetParent(), ability, "modifier_generic_stunned_lua", { duration = stun_duration })
            target:AddNewModifier(self:GetParent(), ability, "modifier_azazin_e_debuff", { duration = effect_duration })
            if self:GetAbility():GetSpecialValueFor("break_duration") > 0 then
                target:AddNewModifier(self:GetParent(), ability, "modifier_break", { duration = self:GetAbility():GetSpecialValueFor("break_duration") })
            end
            if k == 0 then
                EmitSoundOn("azazin_e_1", target)
                k = 1
            elseif k == 1 then
                EmitSoundOn("azazin_e_2", target)
                k = 2
            elseif k == 2 then
                EmitSoundOn("azazin_e_3", target)
                k = 3
            elseif k == 3 then
                EmitSoundOn("azazin_e_4", target)
                k = 0
            end
            local effect_cast = ParticleManager:CreateParticle("particles/azazin_e_exp.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(
                effect_cast,
                3,
                target,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                Vector(0,0,0),
                true
            )
            ParticleManager:ReleaseParticleIndex( effect_cast )
        end
    else
        target:AddNewModifier(self:GetParent(), ability, "modifier_azazin_e_enemy", { duration = counter_duration })
        local enemyMod = target:FindModifierByName("modifier_azazin_e_enemy")
        if enemyMod then
            enemyMod:SetStackCount(1)
        end
    end
end

modifier_azazin_e_enemy = class({})

function modifier_azazin_e_enemy:IsHidden() 
    return false 
end

function modifier_azazin_e_enemy:IsDebuff() 
    return true 
end

function modifier_azazin_e_enemy:IsPurgable() 
    return false 
end

function modifier_azazin_e_enemy:RemoveOnDeath() 
    return true 
end

function modifier_azazin_e_enemy:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(1)
    self.particle = ParticleManager:CreateParticle("particles/azazin_e_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_azazin_e_enemy:OnStackCountChanged(previous_stacks)
    if not IsServer() then return end
    if not self.particle then return end
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0, self:GetStackCount(), 0))
end

function modifier_azazin_e_enemy:OnRefresh(kv)
    if not IsServer() then return end
    self:IncrementStackCount()
end

modifier_azazin_e_caster = class({})

function modifier_azazin_e_caster:IsPurgable() 
    return false 
end

function modifier_azazin_e_caster:OnCreated()
    if not IsServer() then return end
    self.particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle1, 0, self:GetParent():GetAbsOrigin())
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle1, false, false, -1, false, false)
    self:AddParticle(self.particle, false, false, -1, false, true)
end

function modifier_azazin_e_caster:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_azazin_e_caster:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsBuilding() or params.target:IsOther() or params.target:IsWard() then return end
    local bonus_magic_damage = self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
    local damageTable = {
        victim = params.target,
        attacker = self:GetParent(),
        damage = bonus_magic_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

function modifier_azazin_e_caster:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor ~= nil and not self:GetParent():IsIllusion() then
        local heal = self:GetAbility():GetSpecialValueFor("magic_lifesteal") / 100 * params.damage
        self:GetParent():Heal(heal, self:GetAbility())
        local effect_cast = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
end

modifier_azazin_e_debuff = class({})
function modifier_azazin_e_debuff:IsDebuff() return true end
function modifier_azazin_e_debuff:IsPurgable() return true end

function modifier_azazin_e_debuff:OnCreated()
    if not IsServer() then return end
    self.interval = 0.5
    self:StartIntervalThink(self.interval)
end

function modifier_azazin_e_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("tick_damage") * self.interval
    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end

function modifier_azazin_e_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_azazin_e_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_reduction")
end
function modifier_azazin_e_debuff:GetEffectName()
    return "particles/azazin_e_debuff.vpcf"
end
function modifier_azazin_e_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end