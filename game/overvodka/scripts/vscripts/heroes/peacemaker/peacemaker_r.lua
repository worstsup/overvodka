LinkLuaModifier("modifier_peacemaker_r_caster", "heroes/peacemaker/peacemaker_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_peacemaker_r_debuff", "heroes/peacemaker/peacemaker_r", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    if not PeacemakerR_ListenerRegistered then
        PeacemakerR_ListenerRegistered = true

        CustomGameEventManager:RegisterListener("peacemaker_r_close_clicked", function(_, keys)
            local playerID = keys.PlayerID
            if playerID == nil or playerID == -1 then return end

            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if not hero or hero:IsNull() then return end

            local mods = hero:FindAllModifiersByName("modifier_peacemaker_r_debuff")
            for _,mod in ipairs(mods) do
                if mod and not mod:IsNull() and not mod.close_applied then
                    local remaining = mod:GetRemainingTime()
                    if remaining > 0 then
                        mod.close_applied = true
                        mod:SetDuration(remaining * 0.5, true)
                    end
                end
            end
        end)
    end
end

peacemaker_r = class({})

function peacemaker_r:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/huskar/huskar_2021_immortal/huskar_2021_immortal_burning_spear_debuff_gold.vpcf", ctx)
    PrecacheResource("particle", "particles/peacemaker_r.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_whirling_death_spin.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx)
end

function peacemaker_r:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function peacemaker_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function peacemaker_r:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("duration")
    local radius   = self:GetSpecialValueFor("radius")

    caster:AddNewModifier(caster, self, "modifier_peacemaker_r_caster", {duration = duration})

    local p = ParticleManager:CreateParticle("particles/peacemaker_r.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(p)
    caster:EmitSound("Peacemaker.Intro")

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, false)

    for _,enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            local dur = duration * (1 - enemy:GetStatusResistance())
            if dur > 0 then
                enemy:AddNewModifier(caster, self, "modifier_peacemaker_r_debuff", {duration = dur})
            end
        end
    end
end


modifier_peacemaker_r_caster = class({})

function modifier_peacemaker_r_caster:IsHidden()      return false end
function modifier_peacemaker_r_caster:IsPurgable()    return false end
function modifier_peacemaker_r_caster:IsDebuff()      return false end
function modifier_peacemaker_r_caster:IsBuff()        return true end

function modifier_peacemaker_r_caster:GetEffectName()
    return "particles/econ/items/huskar/huskar_2021_immortal/huskar_2021_immortal_burning_spear_debuff_gold.vpcf"
end

function modifier_peacemaker_r_caster:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_peacemaker_r_caster:OnCreated()
    self.ability = self:GetAbility()

    self.bonus_damage_pct = self.ability:GetSpecialValueFor("bonus_attack_damage_pct") or 0
    self.cdr_pct = self.ability:GetSpecialValueFor("cooldown_reduction_pct") or 0
end

function modifier_peacemaker_r_caster:OnDestroy()
    if not IsServer() then return end
end

function modifier_peacemaker_r_caster:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_peacemaker_r_caster:GetModifierDamageOutgoing_Percentage()
    return self.bonus_damage_pct or 0
end

function modifier_peacemaker_r_caster:GetModifierPercentageCooldown()
    return self.cdr_pct or 0
end


modifier_peacemaker_r_debuff = class({})

function modifier_peacemaker_r_debuff:IsHidden()      return false end
function modifier_peacemaker_r_debuff:IsDebuff()      return true end
function modifier_peacemaker_r_debuff:IsBuff()        return false end
function modifier_peacemaker_r_debuff:IsPurgable()    return false end

function modifier_peacemaker_r_debuff:GetEffectName()
    return "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
end

function modifier_peacemaker_r_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_peacemaker_r_debuff:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_peacemaker_r_debuff:OnCreated(kv)
    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.damage_per_sec = 0
    self.spin_speed_deg = 720
    self.damage_per_sec = self.ability and self.ability:GetSpecialValueFor("damage") or 0

    self.video_shown = false
    self.waiting_for_no_debuff_immune = false
    self.close_applied = false

    if IsServer() then
        if self.caster and not self.caster:IsNull()
        and self.parent and not self.parent:IsNull() then
            if not self.parent:IsDebuffImmune() then
                self.parent:FaceTowards(self.caster:GetAbsOrigin())
                self:ShowIntroVideo()
            else
                self.waiting_for_no_debuff_immune = true
            end
        end

        self.time = 0
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_peacemaker_r_debuff:ShowIntroVideo()
    if self.video_shown then return end

    local parent = self.parent or self:GetParent()
    if not parent or parent:IsNull() then return end

    local playerID = parent:GetPlayerOwnerID()
    if playerID ~= nil and playerID ~= -1 then
        local player = PlayerResource:GetPlayer(playerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "PeacemakerRIntroShow", {})
            self.video_shown = true
            self.waiting_for_no_debuff_immune = false
        end
    end
end

function modifier_peacemaker_r_debuff:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        local playerID = parent:GetPlayerOwnerID()
        if playerID ~= nil and playerID ~= -1 then
            local player = PlayerResource:GetPlayer(playerID)
            if player then
                CustomGameEventManager:Send_ServerToPlayer(player, "PeacemakerRIntroHide", {})
            end
        end
    end
end

function modifier_peacemaker_r_debuff:OnIntervalThink()
    if not IsServer() then return end

    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end
    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end
    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end
    if not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    if self.waiting_for_no_debuff_immune and not self.parent:IsDebuffImmune() then
        if self.caster and not self.caster:IsNull() then
            self.parent:FaceTowards(self.caster:GetAbsOrigin())
        end
        self:ShowIntroVideo()
    end

    if self.time == 0 then
        local p = ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_whirling_death_spin.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 1, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 3, self.parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
    end

    local dt = FrameTime()
    self.time = self.time + dt
    if self.time >= 0.4 then
        self.time = 0
    end

    if self.parent:IsDebuffImmune() then return end

    local ang = self.parent:GetAnglesAsVector()
    local new_yaw = ang.y + self.spin_speed_deg * dt
    self.parent:SetAngles(ang.x, new_yaw, ang.z)

    ApplyDamage({
            victim       = self.parent,
            attacker     = self.caster,
            damage       = self.damage_per_sec * dt,
            damage_type  = DAMAGE_TYPE_PURE,
            ability      = self.ability,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
    })
end
