LinkLuaModifier("modifier_frisk_q_alt_charm", "heroes/frisk/frisk_q_alt", LUA_MODIFIER_MOTION_NONE)

frisk_q_alt = class({})

function frisk_q_alt:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_dazzle/dazzle_lucky_charm.vpcf", ctx)
    PrecacheResource("particle", "particles/frisk_q_alt.vpcf", ctx)
end

function frisk_q_alt:GetBehavior()
    local caster = self:GetCaster()
    if caster and caster:HasShard() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function frisk_q_alt:GetAOERadius()
    local caster = self:GetCaster()
    if caster and caster:HasShard() then
        local r = self:GetSpecialValueFor("shard_radius")
        return (r ~= 0 and r) or 300
    end
    return 0
end

function frisk_q_alt:OnSpellStart()
    if not IsServer() then return end
    local caster  = self:GetCaster()
    if not caster or caster:IsNull() then return end
    if caster:HasShard() then
        local point  = self:GetCursorPosition()
        local radius = self:GetAOERadius()

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER, false
        )

        local base_dur = self:GetSpecialValueFor("duration")
        for _,enemy in ipairs(enemies) do
            if enemy and enemy:IsAlive() and not enemy:IsMagicImmune() then
                local dur = base_dur * (1 - enemy:GetStatusResistance())
                enemy:AddNewModifier(caster, self, "modifier_frisk_q_alt_charm", { duration = dur, undispellable = 1 })
            end
        end
        EmitSoundOnLocationWithCaster(point, "frisk_q_alt", caster)
        return
    end
    local target  = self:GetCursorTarget()
    if not target or target:IsNull() then return end

    if target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self) then
        return
    end

    local duration = self:GetSpecialValueFor("duration")
    duration = duration * (1 - target:GetStatusResistance())

    target:AddNewModifier(caster, self, "modifier_frisk_q_alt_charm", {duration = duration})
    EmitSoundOn("frisk_q_alt", caster)
end


modifier_frisk_q_alt_charm = class({})

function modifier_frisk_q_alt_charm:IsHidden() return false end
function modifier_frisk_q_alt_charm:IsPurgable() return not (self.undispellable == 1) end
function modifier_frisk_q_alt_charm:IsDebuff() return true end
function modifier_frisk_q_alt_charm:GetEffectName() return "particles/frisk_q_alt.vpcf" end
function modifier_frisk_q_alt_charm:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_frisk_q_alt_charm:OnCreated(kv)
    if not IsServer() then
        self.undispellable = kv.undispellable or 0
        return
    end
    self.undispellable = kv.undispellable or 0
    self.move_tick   = 0.10
    self.interval    = self:GetAbility():GetSpecialValueFor("interval")
    self.dps         = self:GetAbility():GetSpecialValueFor("damage") + self:GetAbility():GetSpecialValueFor("int_damage") * self:GetCaster():GetIntellect(false) * 0.01
    self._acc        = 0

    self.parent_acq_old = self:GetParent():GetAcquisitionRange()
    self:GetParent():SetAcquisitionRange(0)
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_lucky_charm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
    self:StartIntervalThink(self.move_tick)
end

function modifier_frisk_q_alt_charm:OnDestroy()
    if not IsServer() then return end
    if self.parent_acq_old ~= nil and not self:GetParent():IsNull() then
        self:GetParent():SetAcquisitionRange(self.parent_acq_old)
    end
    if self:GetParent() and not self:GetParent():IsNull() and self:GetParent():IsAlive() then
        self:GetParent():Stop()
    end
end

function modifier_frisk_q_alt_charm:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local parent = self:GetParent()

    if not caster or caster:IsNull() then
        self:Destroy()
        return
    end
    if not caster:IsAlive() then
        self:Destroy()
        return
    end
    parent:MoveToNPC(caster)
    self._acc = self._acc + self.move_tick
    if self._acc + 1e-6 >= self.interval then
        self._acc = self._acc - self.interval
        local per_tick = self.dps * self.interval
        ApplyDamage({
            victim = parent,
            attacker = caster,
            damage = per_tick,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        })
    end
end

function modifier_frisk_q_alt_charm:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_DISARMED]           = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_TAUNTED]             = true,
        [MODIFIER_STATE_SILENCED]           = true,
        [MODIFIER_STATE_MUTED]              = true,
    }
end

function modifier_frisk_q_alt_charm:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_frisk_q_alt_charm:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")
end
