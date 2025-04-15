kirill_w = class({})
LinkLuaModifier("modifier_kirill_w", "heroes/kirill/kirill_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kirill_w_stun", "heroes/kirill/kirill_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kirill_w_silence", "heroes/kirill/kirill_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kirill_w_disarm", "heroes/kirill/kirill_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kirill_w_mute", "heroes/kirill/kirill_w", LUA_MODIFIER_MOTION_NONE)


function kirill_w:GetIntrinsicModifierName()
    return "modifier_kirill_w"
end

function kirill_w:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context)
	PrecacheResource("soundfile", "soundevents/chto.vsndevts", context )
end


modifier_kirill_w = class({})

function modifier_kirill_w:IsHidden() return true end
function modifier_kirill_w:IsPurgable() return false end
function modifier_kirill_w:IsDebuff() return false end

function modifier_kirill_w:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kirill_w:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local target = params.target
    local ability = self:GetAbility()

    if params.attacker ~= parent then return end
    if not ability or parent:PassivesDisabled() then return end
    if not target:IsAlive() or target:IsMagicImmune() or target:IsDebuffImmune() or target:IsInvulnerable() or target:IsOutOfGame() then return end

    if RandomInt(0, 100) > ability:GetSpecialValueFor("chance") then return end

    local effects = {}

    if RandomInt(1, 4) <= 1 then
        table.insert(effects, {
            modifier = "modifier_kirill_w_stun",
            duration = ability:GetSpecialValueFor("stun_duration")
        })
    end

    if RandomInt(1, 4) <= 2 then
        table.insert(effects, {
            modifier = "modifier_kirill_w_silence",
            duration = ability:GetSpecialValueFor("silence_duration")
        })
    end

    if RandomInt(1, 4) <= 3 then
        table.insert(effects, {
            modifier = "modifier_kirill_w_disarm",
            duration = ability:GetSpecialValueFor("disarm_duration")
        })
    end

    if RandomInt(1, 4) <= 4 then
        table.insert(effects, {
            modifier = "modifier_kirill_w_mute",
            duration = ability:GetSpecialValueFor("mute_duration")
        })
    end

    if #effects > 0 then
        local chosen = effects[RandomInt(1, #effects)]
        local actual_duration = chosen.duration * (1 - target:GetStatusResistance())
        target:AddNewModifier(parent, ability, chosen.modifier, { duration = actual_duration })
        EmitSoundOn("chto", self:GetParent())
    end
end


modifier_kirill_w_stun = class({})
function modifier_kirill_w_stun:IsHidden() return false end
function modifier_kirill_w_stun:IsPurgable() return true end
function modifier_kirill_w_stun:IsDebuff() return true end
function modifier_kirill_w_stun:CheckState()
    return {[MODIFIER_STATE_STUNNED] = true}
end

modifier_kirill_w_silence = class({})
function modifier_kirill_w_silence:IsHidden() return false end
function modifier_kirill_w_silence:IsPurgable() return true end
function modifier_kirill_w_silence:IsDebuff() return true end
function modifier_kirill_w_silence:CheckState()
    return {[MODIFIER_STATE_SILENCED] = true}
end

modifier_kirill_w_disarm = class({})
function modifier_kirill_w_disarm:IsHidden() return false end
function modifier_kirill_w_disarm:IsPurgable() return true end
function modifier_kirill_w_disarm:IsDebuff() return true end
function modifier_kirill_w_disarm:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true}
end

modifier_kirill_w_mute = class({})
function modifier_kirill_w_mute:IsHidden() return false end
function modifier_kirill_w_mute:IsPurgable() return true end
function modifier_kirill_w_mute:IsDebuff() return true end
function modifier_kirill_w_mute:CheckState()
    return {[MODIFIER_STATE_MUTED] = true}
end