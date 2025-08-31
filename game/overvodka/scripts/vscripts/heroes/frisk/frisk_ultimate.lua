LinkLuaModifier("modifier_frisk_save_handler", "heroes/frisk/frisk_ultimate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frisk_save_evasion", "heroes/frisk/frisk_ultimate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frisk_save_anchor",  "heroes/frisk/frisk_ultimate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frisk_save_pulse_slow", "heroes/frisk/frisk_ultimate", LUA_MODIFIER_MOTION_NONE)

frisk_ultimate = class({})

function frisk_ultimate:Precache(context)
    PrecacheResource("particle", "particles/frisk_r.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
    PrecacheResource("model", "models/items/pedestals/pedestal_2/pedestal_2.vmdl", context)
    PrecacheResource("particle", "particles/frisk_r_tp.vpcf", context)
    PrecacheUnitByNameSync("npc_frisk_save", context)
end

function frisk_ultimate:GetIntrinsicModifierName()
    return "modifier_frisk_save_handler"
end


local function DoSavedPulse(caster, ability, origin)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    local radius    = ability:GetSpecialValueFor("pulse_radius")
    if radius <= 0 then return end

    local base      = ability:GetSpecialValueFor("pulse_base_damage")
    local int_mult  = ability:GetSpecialValueFor("pulse_int_mult")
    local slow_pct  = ability:GetSpecialValueFor("pulse_slow_pct")
    local slow_dur  = ability:GetSpecialValueFor("pulse_slow_duration")

    local pos = origin or caster:GetAbsOrigin()
    local damage = base + (caster:GetIntellect(false)) * int_mult / 100

    local p = ParticleManager:CreateParticle("particles/frisk_r_tp.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(p, 0, pos)
    ParticleManager:SetParticleControl(p, 1, pos)
    ParticleManager:SetParticleControl(p, 2, Vector(radius,radius,radius))
    ParticleManager:SetParticleControl(p, 3, pos)
    ParticleManager:SetParticleControl(p, 5, pos)
    ParticleManager:ReleaseParticleIndex(p)

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), pos, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
    )
    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and not enemy:IsInvulnerable() then
            enemy:AddNewModifier(
                caster,
                ability,
                "modifier_knockback",
                    {
                        center_x = pos.x,
                        center_y = pos.y,
                        center_z = pos.z,
                        duration = 0.4,
                        knockback_duration = 0.4,
                        knockback_distance = 250,
                        knockback_height = 75,
                    }
            )
            enemy:AddNewModifier(caster, ability, "modifier_frisk_save_pulse_slow", {
                duration = slow_dur * (1 - enemy:GetStatusResistance())
            })
            ApplyDamage({
                victim = enemy,
                attacker = caster,
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = ability
            })
        end
    end
end

local function ApplyInspireFromSave(caster, source_ability, duration)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local debuffs = 0
    for _,m in pairs(caster:FindAllModifiers() or {}) do
        if m and not m:IsNull() and m.IsDebuff and m:IsDebuff() then
            debuffs = debuffs + 1
        end
    end
    local e = caster:FindAbilityByName("frisk_r_alt")

    local magic_res = (e and e:GetSpecialValueFor("magic_resist_pct")) or 60
    local base_str  = (e and e:GetSpecialValueFor("bonus_str"))       or 7
    local base_reg  = (e and e:GetSpecialValueFor("bonus_hpregen"))   or 8
    local per_eff   = (e and e:GetSpecialValueFor("bonus_per_effect"))or 3
    caster:AddNewModifier(
        caster,
        e or source_ability,
        "modifier_frisk_r_alt_buff",
        {
            duration  = duration or 3.0,
            debuffs   = debuffs,
            override  = 1,
            magic_res = magic_res,
            base_str  = base_str,
            base_reg  = base_reg,
            per_eff   = per_eff,
        }
    )
end

function frisk_ultimate:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() or caster:IsIllusion() then return end

    local anchor = caster._frisk_save_anchor
    if anchor and not anchor:IsNull() and anchor:IsAlive() then
        local pos = anchor:GetAbsOrigin()
        FindClearSpaceForUnit(caster, pos, true)
        caster:Stop()
        ParticleManager:ReleaseParticleIndex(
            ParticleManager:CreateParticle("particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", PATTACH_ABSORIGIN, caster)
        )
        EmitSoundOn("frisk_r_tp", caster)
        local amod = anchor:FindModifierByName("modifier_frisk_save_anchor")
        if amod then
            local maxhp   = caster:GetMaxHealth()
            local maxmana = caster:GetMaxMana()

            local target_hp   = math.max(1, math.min(amod.saved_hp   or maxhp,   maxhp))
            local target_mana = math.max(0, math.min(amod.saved_mana or maxmana, maxmana))

            caster:SetHealth(target_hp)
            caster:SetMana(target_mana)
        end
        if self:GetSpecialValueFor("pulse_radius") > 0 then
            DoSavedPulse(caster, self, pos)
        end
        if caster:HasTalent("special_bonus_unique_frisk_7") then
            ApplyInspireFromSave(caster, self, self:GetSpecialValueFor("buff_duration"))
        end
        local buff = caster:FindModifierByName("modifier_frisk_save_evasion")
        if not buff then
            buff = caster:AddNewModifier(caster, self, "modifier_frisk_save_evasion", {})
        end
        if buff then
            local evasion_max = (self and self:GetSpecialValueFor("evasion_max")) or 60
            local evasion     = (self and self:GetSpecialValueFor("evasion_per_stack")) or 2
            local cur         = buff:GetStackCount() or 0
            buff:SetStackCount(math.min(evasion_max, cur + evasion))
        end

        anchor:ForceKill(false)
        caster._frisk_save_anchor = nil
        return
    end

    local pos = caster:GetAbsOrigin()
    local unit = CreateUnitByName("npc_frisk_save", pos, false, caster, caster, caster:GetTeamNumber())
    unit:SetOwner(caster)
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    unit:AddNewModifier(caster, self, "modifier_frisk_save_anchor", {
        caster_eidx = caster:entindex(),
        hp = caster:GetHealth(),
        mana = caster:GetMana()
    })

    caster._frisk_save_anchor = unit
    EmitSoundOn("frisk_r_save", caster)

    self:EndCooldown()
end

modifier_frisk_save_handler = class({})

function modifier_frisk_save_handler:IsHidden() return true end
function modifier_frisk_save_handler:IsPurgable() return false end
function modifier_frisk_save_handler:RemoveOnDeath() return false end

function modifier_frisk_save_handler:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_RESPAWN }
end

function modifier_frisk_save_handler:OnDeath(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    local caster = self:GetParent()
    local anchor = caster._frisk_save_anchor
    self._should_return_on_respawn = (anchor and not anchor:IsNull() and anchor:IsAlive()) or false
end

function modifier_frisk_save_handler:OnRespawn(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    local caster = self:GetParent()
    if not self._should_return_on_respawn then return end

    local anchor = caster._frisk_save_anchor
    if anchor and not anchor:IsNull() and anchor:IsAlive() then
        local pos = anchor:GetAbsOrigin()
        FindClearSpaceForUnit(caster, pos, true)
        caster:Stop()
        ParticleManager:ReleaseParticleIndex(
            ParticleManager:CreateParticle("particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", PATTACH_ABSORIGIN, caster)
        )
        EmitSoundOn("frisk_r_tp", caster)

        local amod = anchor:FindModifierByName("modifier_frisk_save_anchor")
        if amod then
            local maxhp   = caster:GetMaxHealth()
            local maxmana = caster:GetMaxMana()

            local target_hp   = math.max(1, math.min(amod.saved_hp   or maxhp,   maxhp))
            local target_mana = math.max(0, math.min(amod.saved_mana or maxmana, maxmana))

            caster:SetHealth(target_hp)
            caster:SetMana(target_mana)
        end
        if self:GetAbility():GetSpecialValueFor("pulse_radius") > 0 then
            DoSavedPulse(caster, self:GetAbility(), pos)
        end
        if caster:HasTalent("special_bonus_unique_frisk_7") then
            ApplyInspireFromSave(caster, self:GetAbility(), 3.0)
        end
        local buff = caster:FindModifierByName("modifier_frisk_save_evasion")
        if not buff then
            buff = caster:AddNewModifier(caster, self:GetAbility(), "modifier_frisk_save_evasion", {})
        end
        if buff then
            local ability = self.GetAbility and self:GetAbility() or nil
            local evasion_max = (ability and ability:GetSpecialValueFor("evasion_max")) or 60
            local evasion     = (ability and ability:GetSpecialValueFor("evasion_per_stack")) or 2

            local cur = buff:GetStackCount() or 0
            buff:SetStackCount(math.min(evasion_max, cur + evasion))
        end
    end

    self._should_return_on_respawn = false
end

modifier_frisk_save_evasion = class({})

function modifier_frisk_save_evasion:IsHidden() return false end
function modifier_frisk_save_evasion:IsPurgable() return false end
function modifier_frisk_save_evasion:RemoveOnDeath() return false end

function modifier_frisk_save_evasion:OnCreated()
    if not IsServer() then return end
    if self:GetStackCount() == 0 then self:SetStackCount(0) end
end

function modifier_frisk_save_evasion:DeclareFunctions()
    return { MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function modifier_frisk_save_evasion:GetModifierEvasion_Constant()
    local ability = self:GetAbility()
    local cap = (ability and ability:GetSpecialValueFor("evasion_max")) or (self.evasion_max or 60)
    local stacks = self:GetStackCount() or 0
    return math.min(cap, stacks)
end


modifier_frisk_save_anchor = class({})

function modifier_frisk_save_anchor:IsHidden() return true end
function modifier_frisk_save_anchor:IsPurgable() return false end

function modifier_frisk_save_anchor:OnCreated(kv)
    if not IsServer() then return end
    self._caster = EntIndexToHScript(kv.caster_eidx or -1)
    local parent = self:GetParent()
    local pos = GetGroundPosition(parent:GetAbsOrigin(), parent)

    self._pedestal = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/pedestals/pedestal_2/pedestal_2.vmdl"
    })
    self._pedestal:SetAbsOrigin(pos)
    self._pedestal:SetModelScale(1.0)
    self._pedestal:FollowEntity(parent, false)

    self.saved_hp   = tonumber(kv.hp)   or (self._caster and self._caster:GetHealth() or 1)
    self.saved_mana = tonumber(kv.mana) or (self._caster and self._caster:GetMana()   or 0)
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_frisk_save_anchor:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if not self:GetAbility() or self:GetAbility():IsNull()
       or not self._caster or self._caster:IsNull() then
        self:Destroy()
        return
    end

    local pos = parent:GetAbsOrigin()
    pos.z = pos.z + 80
    local jitter = RandomVector(12); jitter.z = math.random(6,12)

    local p = ParticleManager:CreateParticle("particles/frisk_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(p, 0, pos + jitter)
    ParticleManager:ReleaseParticleIndex(p)
end

function modifier_frisk_save_anchor:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_frisk_save_anchor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
end

function modifier_frisk_save_anchor:GetModifierDisableTurning()
    return 1
end

function modifier_frisk_save_anchor:OnDestroy()
    if not IsServer() then return end

    if self._pedestal and not self._pedestal:IsNull() then
        UTIL_Remove(self._pedestal)
        self._pedestal = nil
    end

    local parent = self:GetParent()
    local p = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/ta_2022_immortal/ta_2022_immortal_trap_gold_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    if self._caster and not self._caster:IsNull() and self._caster._frisk_save_anchor == parent then
        self._caster._frisk_save_anchor = nil
    end
    if parent and not parent:IsNull() then
        UTIL_Remove(parent)
    end
end


frisk_save_destroy = class({})

function frisk_save_destroy:OnSpellStart()
    if not IsServer() then return end
    local parent = self:GetCaster()
    parent:ForceKill(false)
end


modifier_frisk_save_pulse_slow = class({})

function modifier_frisk_save_pulse_slow:IsPurgable() return true end
function modifier_frisk_save_pulse_slow:IsDebuff() return true end

function modifier_frisk_save_pulse_slow:OnCreated()
    if not IsServer() then return end
end

function modifier_frisk_save_pulse_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_frisk_save_pulse_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("pulse_slow_pct")
end