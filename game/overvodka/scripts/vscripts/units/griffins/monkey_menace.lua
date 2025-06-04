LinkLuaModifier("modifier_monkey_menace", "units/griffins/monkey_menace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_menace_fear_debuff", "units/griffins/monkey_menace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_monkey_menace_dot", "units/griffins/monkey_menace.lua", LUA_MODIFIER_MOTION_NONE)

monkey_menace = class({})

function monkey_menace:GetIntrinsicModifierName()
    return "modifier_monkey_menace"
end

modifier_monkey_menace = class({})

function modifier_monkey_menace:IsHidden() return true end
function modifier_monkey_menace:IsPurgable() return false end

function modifier_monkey_menace:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_monkey_menace:OnAttackLanded(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if keys.attacker == parent and keys.target ~= nil and not keys.target:IsMagicImmune() and not keys.target:IsInvulnerable() then
        if ability:IsCooldownReady() then
            local fear_duration = ability:GetSpecialValueFor("fear_duration")
            local dot_duration = ability:GetSpecialValueFor("dot_duration")

            keys.target:AddNewModifier(parent, ability, "modifier_monkey_menace_fear_debuff", {duration = fear_duration})
            keys.target:AddNewModifier(parent, ability, "modifier_monkey_menace_dot", {duration = dot_duration})

            ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
        end
    end
end

modifier_monkey_menace_fear_debuff = class({})

function modifier_monkey_menace_fear_debuff:IsDebuff() return true end
function modifier_monkey_menace_fear_debuff:IsPurgable() return true end

function modifier_monkey_menace_fear_debuff:CheckState()
    return {
        [MODIFIER_STATE_FEARED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_monkey_menace_fear_debuff:OnCreated(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and parent and not parent:IsNull() then
        local direction = (parent:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        local flee_distance = 500
        local run_position = parent:GetAbsOrigin() + direction * flee_distance

        parent:MoveToPosition(run_position)
    end
end

modifier_monkey_menace_dot = class({})

function modifier_monkey_menace_dot:IsDebuff() return true end
function modifier_monkey_menace_dot:IsPurgable() return true end

function modifier_monkey_menace_dot:OnCreated()
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage_per_second")
    self:StartIntervalThink(1.0)
end

function modifier_monkey_menace_dot:OnIntervalThink()
    if not IsServer() then return end
    local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
end
