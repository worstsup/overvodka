LinkLuaModifier("modifier_kolibri_e",         "heroes/kolibri/kolibri_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kolibri_e_evasion", "heroes/kolibri/kolibri_e", LUA_MODIFIER_MOTION_NONE)

kolibri_e = class({})

function kolibri_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/kolibri_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", context)
    PrecacheResource("particle", "particles/kolibri_e.vpcf", context)
end

function kolibri_e:GetBehavior()
	local additive = self:GetCaster():HasTalent("special_bonus_unique_kolibri_7") and 2099200 or 0
    local behavior = self.BaseClass.GetBehavior(self)
    return tonumber(tostring(behavior)) + additive
end

function kolibri_e:GetIntrinsicModifierName()
    if not self:GetCaster():IsIllusion() then
        return "modifier_kolibri_e"
    end
end

function kolibri_e:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    if not caster:IsAlive() then return end

    local intrinsic = caster:FindModifierByName(self:GetIntrinsicModifierName())
    self.intrinsic_modifier = intrinsic

    if intrinsic
        and intrinsic.instances_health and intrinsic.instances_health[1]
        and intrinsic.instances_mana and intrinsic.instances_mana[1]
        and intrinsic.instances_position and intrinsic.instances_position[1]
    then
        local hp_before = caster:GetHealth()
        local max_hp    = caster:GetMaxHealth()

        caster:EmitSound("kolibri_e")

        local time_lapse_particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_weaver/weaver_timelapse.vpcf",
            PATTACH_WORLDORIGIN,
            caster
        )
        ParticleManager:SetParticleControl(time_lapse_particle, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(time_lapse_particle, 2, intrinsic.instances_position[1] + Vector(0,0,200))
        ParticleManager:ReleaseParticleIndex(time_lapse_particle)

        local per = ParticleManager:CreateParticle("particles/kolibri_e.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(per, 3, caster:GetAbsOrigin() + Vector(0,0,200))
        ParticleManager:ReleaseParticleIndex(per)

        ProjectileManager:ProjectileDodge(caster)
        caster:Purge(false, true, false, true, true)
        caster:Stop()

        local hp_after = math.max(intrinsic.instances_health[1], 1)
        caster:SetHealth(hp_after)
        caster:SetMana(intrinsic.instances_mana[1])
        FindClearSpaceForUnit(caster, intrinsic.instances_position[1], true)

        if self:GetSpecialValueFor("give_evasion") > 0 then
            local hp_after_real = caster:GetHealth()
            local restored = math.max(0, hp_after_real - hp_before)

            local evasion_pct = 0
            if max_hp and max_hp > 0 then
                evasion_pct = (restored / max_hp) * 100
            end

            evasion_pct = math.floor(evasion_pct + 0.5)
            if evasion_pct > 100 then evasion_pct = 100 end

            local duration = self:GetSpecialValueFor("duration")
            if duration and duration > 0 and evasion_pct > 0 then
                caster:AddNewModifier(caster, self, "modifier_kolibri_e_evasion", {duration = duration, evasion = evasion_pct})
            end
        end

        if caster:HasScepter() then
            local q = caster:FindAbilityByName("kolibri_q")
            if q then
                q:EndCooldown()
                q:RefreshCharges()
            end

            local w = caster:FindAbilityByName("kolibri_w")
            if w then
                w:EndCooldown()
            end
        end
    end
end

modifier_kolibri_e = class({})

function modifier_kolibri_e:IsPurgable()  return false end
function modifier_kolibri_e:IsDebuff()    return false end
function modifier_kolibri_e:IsHidden()    return true  end

function modifier_kolibri_e:OnCreated()
    if not IsServer() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.lapsed_time        = ability:GetSpecialValueFor("time_back")
    self.instances_health   = {}
    self.instances_mana     = {}
    self.instances_position = {}
    self.interval           = 0.05
    self.total_saved_points = self.lapsed_time / self.interval

    self:OnIntervalThink()
    self:StartIntervalThink(self.interval)
end

function modifier_kolibri_e:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if parent:IsAlive() then
        table.insert(self.instances_health, parent:GetHealth())
        table.insert(self.instances_mana, parent:GetMana())
        table.insert(self.instances_position, parent:GetAbsOrigin())

        if #self.instances_health >= self.total_saved_points then
            table.remove(self.instances_health, 1)
            table.remove(self.instances_mana, 1)
            table.remove(self.instances_position, 1)
        end
    end
end


modifier_kolibri_e_evasion = class({})

function modifier_kolibri_e_evasion:IsPurgable() return true  end
function modifier_kolibri_e_evasion:IsDebuff()   return false end
function modifier_kolibri_e_evasion:IsHidden()   return false end

function modifier_kolibri_e_evasion:OnCreated(kv)
    local ev = 0
    if IsServer() then
        ev = tonumber(kv and kv.evasion) or 0
        if ev < 0 then ev = 0 end
        if ev > 100 then ev = 100 end
        self:SetStackCount(ev)
    end
end

function modifier_kolibri_e_evasion:OnRefresh(kv)
    if not IsServer() then return end
    local ev = tonumber(kv and kv.evasion) or self:GetStackCount()
    if ev < 0 then ev = 0 end
    if ev > 100 then ev = 100 end
    self:SetStackCount(ev)
end

function modifier_kolibri_e_evasion:DeclareFunctions()
    return { MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function modifier_kolibri_e_evasion:GetModifierEvasion_Constant()
    return self:GetStackCount()
end