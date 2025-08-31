LinkLuaModifier("modifier_chara_q_handler",      "heroes/chara/chara_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chara_q_bleed",        "heroes/chara/chara_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chara_q_bleed_stack",  "heroes/chara/chara_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chara_q_armor_shred",  "heroes/chara/chara_q", LUA_MODIFIER_MOTION_NONE)

chara_q = class({})

function chara_q:GetIntrinsicModifierName()
	return "modifier_chara_q_handler"
end

function chara_q:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/chara_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", ctx)
    PrecacheResource("particle", "particles/chara_q.vpcf", ctx)
end

function chara_q:DoSlash(caster, target, is_repeat)
    local pct      = self:GetSpecialValueFor("attack_damage_pct")
    local flat     = self:GetSpecialValueFor("damage")
    local avgTrue  = caster:GetAverageTrueAttackDamage(nil)

    if is_repeat then
        local rpt_atk      = self:GetSpecialValueFor("scepter_repeat_attack_pct")
        local rpt_flat_pct = self:GetSpecialValueFor("scepter_repeat_flat_pct")
        pct  = rpt_atk
        flat = math.floor(flat * math.max(0, rpt_flat_pct) / 100)
    end

    local totalDmg = math.max(0, avgTrue * pct / 100 + flat)
    ApplyDamage({
        victim      = target,
        attacker    = caster,
        damage      = totalDmg,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability     = self
    })

    self:TryApplyBleed(caster, target, true)
    local dur = self:GetSpecialValueFor("armor_duration")
    if dur and dur > 0 then
        local per   = self:GetSpecialValueFor("hp_loss_armor")
        local decr  = self:GetSpecialValueFor("armor_decrease")
        if per > 0 and decr > 0 and target and target:IsAlive() and (not target:IsBuilding()) then
            local missing = math.max(0, 100 - target:GetHealthPercent())
            local stacks  = math.floor(missing / per) * decr
            if stacks > 0 then
                local mod = target:AddNewModifier(caster, self, "modifier_chara_q_armor_shred", {
                    duration = dur * (1 - target:GetStatusResistance()),
                })
                if mod then
                    mod:SetStackCount(stacks)
                end
            end
        end
    end
    local attachEnt = is_repeat and target or caster
    local p = ParticleManager:CreateParticle("particles/chara_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, attachEnt)
    if attachEnt == target then
        ParticleManager:SetParticleControlEnt(p, 0, attachEnt, PATTACH_POINT_FOLLOW, "attach_hitloc", attachEnt:GetAbsOrigin(), true)
    end
    ParticleManager:ReleaseParticleIndex(p)
    EmitSoundOn(is_repeat and "chara_q_scepter" or "chara_q", caster)
end

function chara_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end
    if target:TriggerSpellAbsorb(self) then return end

    self:DoSlash(caster, target, false)

    if caster:HasScepter() then
        local delay = self:GetSpecialValueFor("scepter_repeat_delay")
        local th1   = self:GetSpecialValueFor("scepter_repeat_threshold1")
        local th2   = self:GetSpecialValueFor("scepter_repeat_threshold2")

        Timers:CreateTimer(delay, function()
            if not self or self:IsNull() then return nil end
            if not caster or caster:IsNull() or not caster:IsAlive() then return nil end
            if not target or target:IsNull() or not target:IsAlive() then return nil end

            if target:GetHealthPercent() < th1 then
                self:DoSlash(caster, target, true)

                Timers:CreateTimer(delay, function()
                    if not self or self:IsNull() then return nil end
                    if not caster or caster:IsNull() or not caster:IsAlive() then return nil end
                    if not target or target:IsNull() or not target:IsAlive() then return nil end

                    if target:GetHealthPercent() < th2 then
                        self:DoSlash(caster, target, true)
                    end
                    return nil
                end)
            end

            return nil
        end)
    end
end


function chara_q:TryApplyBleed(attacker, target, activeHit)
    if not IsServer() then return end
    if not attacker or attacker:IsNull() or not target or target:IsNull() then return end
    if target:IsBuilding() then return end
    if attacker:IsIllusion() then return end
    if target:IsMagicImmune() then return end

    local chance = (activeHit and self:GetSpecialValueFor("bleed_chance_active")) or self:GetSpecialValueFor("bleed_chance_attack")
    if chance <= 0 or not RollPercentage(chance) then return end

    local dur = self:GetSpecialValueFor("bleed_duration")
    local mod_name = attacker:HasScepter() and "modifier_chara_q_bleed_stack" or "modifier_chara_q_bleed"
    target:AddNewModifier(attacker, self, mod_name, {
        duration = dur * (1 - target:GetStatusResistance())
    })
end


modifier_chara_q_handler = class({})

function modifier_chara_q_handler:IsHidden() return true end
function modifier_chara_q_handler:IsPurgable() return false end

function modifier_chara_q_handler:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_chara_q_handler:OnAttackLanded(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.attacker ~= parent then return end
    if parent:PassivesDisabled() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    local target = params.target
    if not target or target:IsNull() or target:GetTeamNumber() == parent:GetTeamNumber() then return end

    ability:TryApplyBleed(parent, target, false)
end


modifier_chara_q_bleed = class({})

function modifier_chara_q_bleed:IsDebuff() return true end
function modifier_chara_q_bleed:IsPurgable() return true end

function modifier_chara_q_bleed:OnCreated()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    self.interval = ability:GetSpecialValueFor("bleed_interval")
    self.dps      = ability:GetSpecialValueFor("bleed_dps")
    self.damage_per_tick = math.max(0, self.dps * self.interval)
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_chara_q_bleed:OnRefresh()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.interval = ability:GetSpecialValueFor("bleed_interval")
        self.dps      = ability:GetSpecialValueFor("bleed_dps")
        self.damage_per_tick = math.max(0, self.dps * self.interval)
    end
end

function modifier_chara_q_bleed:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility(); if not ability or ability:IsNull() then self:Destroy(); return end
    local caster  = self:GetCaster();  if not caster  or caster:IsNull()  then return end
    local victim  = self:GetParent();  if not victim  or victim:IsNull()  or not victim:IsAlive() then return end

    ApplyDamage({
        victim      = victim,
        attacker    = caster,
        damage      = self.damage_per_tick,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability     = ability
    })
end

function modifier_chara_q_bleed:GetEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end
function modifier_chara_q_bleed:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_chara_q_bleed_stack = class(modifier_chara_q_bleed)

function modifier_chara_q_bleed_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_chara_q_armor_shred = class({})

function modifier_chara_q_armor_shred:IsDebuff() return true end
function modifier_chara_q_armor_shred:IsPurgable() return true end

function modifier_chara_q_armor_shred:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_chara_q_armor_shred:GetModifierPhysicalArmorBonus()
    return - (self:GetStackCount() or 0)
end