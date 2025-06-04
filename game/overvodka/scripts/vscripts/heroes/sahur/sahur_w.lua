sahur_w = class({})
LinkLuaModifier("modifier_sahur_w", "heroes/sahur/sahur_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sahur_w_stun", "heroes/sahur/sahur_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sahur_w_silence", "heroes/sahur/sahur_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sahur_w_disarm", "heroes/sahur/sahur_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sahur_w_mute", "heroes/sahur/sahur_w", LUA_MODIFIER_MOTION_NONE)

function sahur_w:GetIntrinsicModifierName()
    return "modifier_sahur_w"
end

function sahur_w:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context)
    PrecacheResource("particle", "particles/kirill_stun.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf", context)
    PrecacheResource("particle", "particles/items4_fx/nullifier_mute.vpcf", context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_bashed.vpcf", context)
	PrecacheResource("soundfile", "soundevents/chto.vsndevts", context )
end

modifier_sahur_w = class({})

function modifier_sahur_w:IsHidden() return true end
function modifier_sahur_w:IsPurgable() return false end
function modifier_sahur_w:IsDebuff() return false end

function modifier_sahur_w:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_sahur_w:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker:IsIllusion() and not params.attacker:HasModifier("modifier_item_aghanims_shard") then return end
    local parent = self:GetParent()
    local target = params.target
    local ability = self:GetAbility()

    if params.attacker ~= parent then return end
    if not ability or parent:PassivesDisabled() then return end
    if not target:IsAlive() or target:IsMagicImmune() or target:IsDebuffImmune() or target:IsInvulnerable() or target:IsOutOfGame() then return end
    if target:IsBuilding() then return end

    if RandomInt(0, 100) > ability:GetSpecialValueFor("chance") then return end
    if params.attacker:HasModifier("modifier_item_aghanims_shard") and not params.attacker:IsIllusion() then
        local illusions = CreateIllusions(
            parent,
            parent,
            {
                outgoing_damage = self:GetAbility():GetSpecialValueFor("illusion_damage_outgoing") - 100,
                incoming_damage = self:GetAbility():GetSpecialValueFor("illusion_damage_incoming") - 100,
                duration = self:GetAbility():GetSpecialValueFor("illusion_duration"),
            },
            1,
            50,
            false,
            true
        )
        local illusion = illusions[1]
        illusion:SetAbsOrigin(target:GetAbsOrigin())
        FindClearSpaceForUnit(illusion, target:GetAbsOrigin(), true)
        illusion:SetOwner(parent)
        local order = {
            UnitIndex = illusion:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:entindex(),
        }
        ExecuteOrderFromTable( order )
    end
    local effects = {}

    local random_int = RandomInt(1, 4)
    if random_int == 1 then
        table.insert(effects, {
            modifier = "modifier_sahur_w_stun",
            duration = ability:GetSpecialValueFor("stun_duration")
        })
    end

    if random_int == 2 then
        table.insert(effects, {
            modifier = "modifier_sahur_w_silence",
            duration = ability:GetSpecialValueFor("silence_duration")
        })
    end

    if random_int == 3 then
        table.insert(effects, {
            modifier = "modifier_sahur_w_disarm",
            duration = ability:GetSpecialValueFor("disarm_duration")
        })
    end

    if random_int == 4 then
        table.insert(effects, {
            modifier = "modifier_sahur_w_mute",
            duration = ability:GetSpecialValueFor("mute_duration")
        })
    end

    if #effects > 0 then
        local chosen = effects[RandomInt(1, #effects)]
        local actual_duration = chosen.duration * (1 - target:GetStatusResistance())
        target:AddNewModifier(parent, ability, chosen.modifier, { duration = actual_duration })
        EmitSoundOn("chto", parent)
        local particle = ParticleManager:CreateParticle("particles/kirill_stun.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(50, 0, 0))
        ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
    end
end


modifier_sahur_w_stun = class({})
function modifier_sahur_w_stun:IsHidden() return false end
function modifier_sahur_w_stun:IsPurgable() return true end
function modifier_sahur_w_stun:IsDebuff() return true end

function modifier_sahur_w_stun:GetEffectName()
    return "particles/generic_gameplay/generic_bashed.vpcf"
end
function modifier_sahur_w_stun:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sahur_w_stun:CheckState()
    return {[MODIFIER_STATE_STUNNED] = true}
end

modifier_sahur_w_silence = class({})
function modifier_sahur_w_silence:IsHidden() return false end
function modifier_sahur_w_silence:IsPurgable() return true end
function modifier_sahur_w_silence:IsDebuff() return true end
function modifier_sahur_w_silence:CheckState()
    return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_sahur_w_silence:GetEffectName()
    return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf"
end
function modifier_sahur_w_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_sahur_w_disarm = class({})
function modifier_sahur_w_disarm:IsHidden() return false end
function modifier_sahur_w_disarm:IsPurgable() return true end
function modifier_sahur_w_disarm:IsDebuff() return true end
function modifier_sahur_w_disarm:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_sahur_w_disarm:GetEffectName()
    return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf"
end
function modifier_sahur_w_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_sahur_w_mute = class({})
function modifier_sahur_w_mute:IsHidden() return false end
function modifier_sahur_w_mute:IsPurgable() return true end
function modifier_sahur_w_mute:IsDebuff() return true end
function modifier_sahur_w_mute:CheckState()
    return {[MODIFIER_STATE_MUTED] = true}
end
function modifier_sahur_w_mute:GetEffectName()
    return "particles/items4_fx/nullifier_mute.vpcf"
end
function modifier_sahur_w_mute:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end