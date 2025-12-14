LinkLuaModifier( "modifier_kolibri_e", "heroes/kolibri/kolibri_e", LUA_MODIFIER_MOTION_NONE)

kolibri_e = class({})

function kolibri_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/kolibri_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", context)
    PrecacheResource("particle", "particles/kolibri_e.vpcf", context)
end

function kolibri_e:GetIntrinsicModifierName()
    if not self:GetCaster():IsIllusion() then
        return "modifier_kolibri_e"
    end
end

function kolibri_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self.intrinsic_modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
        
    if self.intrinsic_modifier and self.intrinsic_modifier.instances_health and self.intrinsic_modifier.instances_health[1] and self.intrinsic_modifier.instances_mana and self.intrinsic_modifier.instances_mana[1] and self.intrinsic_modifier.instances_position and self.intrinsic_modifier.instances_position[1] then
        caster:EmitSound("kolibri_e")

        local time_lapse_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(time_lapse_particle, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(time_lapse_particle, 2, self.intrinsic_modifier.instances_position[1] + Vector(0,0,200))
        ParticleManager:ReleaseParticleIndex(time_lapse_particle)

        local per = ParticleManager:CreateParticle("particles/kolibri_e.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(per, 3, caster:GetAbsOrigin() + Vector(0,0,200))
        ParticleManager:ReleaseParticleIndex(per)

        ProjectileManager:ProjectileDodge(caster)
        caster:Purge(false, true, false, true, true)
        caster:Stop()
        caster:SetHealth(math.max(self.intrinsic_modifier.instances_health[1], 1))
        caster:SetMana(self.intrinsic_modifier.instances_mana[1])
        FindClearSpaceForUnit(caster, self.intrinsic_modifier.instances_position[1], true)
        
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
function modifier_kolibri_e:IsHidden()    return true end

function modifier_kolibri_e:OnCreated()
    if not IsServer() then return end
    self.lapsed_time        = self:GetAbility():GetSpecialValueFor("time_back")
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
    if self:GetParent():IsAlive() then
        table.insert(self.instances_health, self:GetParent():GetHealth())
        table.insert(self.instances_mana, self:GetParent():GetMana())
        table.insert(self.instances_position, self:GetParent():GetAbsOrigin())

        if #self.instances_health >= self.total_saved_points then
            table.remove(self.instances_health, 1)
            table.remove(self.instances_mana, 1)
            table.remove(self.instances_position, 1)
        end
    end
end