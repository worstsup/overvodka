LinkLuaModifier("modifier_prince_q_caster", "heroes/prince/prince_q", LUA_MODIFIER_MOTION_NONE)

prince_q = class({})

function prince_q:Precache(ctx)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", ctx)
    PrecacheResource("particle", "particles/status_fx/status_effect_omnislash.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/prince_sounds.vsndevts", ctx)
end

function prince_q:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function prince_q:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function prince_q:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function prince_q:OnOwnerDied()
    if not self:IsActivated() then
        self:SetActivated(true)
    end
end

function prince_q:OnOwnerSpawned()
    self:OnOwnerDied()
end

function prince_q:OnSpellStart()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    self.previous_position = self.caster:GetAbsOrigin()
    if self.target:TriggerSpellAbsorb(self) then return end

    self.caster:AddNewModifier(self.caster, self, "modifier_prince_q_caster", {
        target_entindex = self.target:entindex()
    })

    self:SetActivated(false)

    local prince_r = self:GetCaster():FindAbilityByName("prince_r")
    if prince_r then
        prince_r:SetActivated(false)
    end

    FindClearSpaceForUnit(self.caster, self.target:GetAbsOrigin() + RandomVector(128), false)

    self.caster:EmitSound("Hero_Juggernaut.OmniSlash")
    EmitSoundOn("prince_q", self.caster)

    self.current_position = self.caster:GetAbsOrigin()

    local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControl(particle, 0, self.previous_position)
    ParticleManager:SetParticleControl(particle, 1, self.current_position)
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_prince_q_caster = class({})

function modifier_prince_q_caster:IsHidden() return false end
function modifier_prince_q_caster:IsPurgable() return false end
function modifier_prince_q_caster:IsDebuff() return false end

function modifier_prince_q_caster:OnCreated(kv)
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.target = EntIndexToHScript(tonumber(kv.target_entindex))
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.attacks_left = self.ability:GetSpecialValueFor("attacks")
    self.attack_interval = self.ability:GetSpecialValueFor("attack_interval")

    self.magic_lifesteal = 0
    if self.caster:HasScepter() then
        self.magic_lifesteal = self.ability:GetSpecialValueFor("magic_lifesteal")
    end

    if not self.target or self.target:IsNull() or (not self.target:IsAlive()) then
        self:Destroy()
        return
    end
    Timers:CreateTimer(FrameTime(), function()
        if (not self.parent:IsNull()) then
            self.caster:StartGesture(ACT_DOTA_ATTACK_EVENT)
            self:PerformSlash()
            self:StartIntervalThink(self.attack_interval)
        end
    end)
end

function modifier_prince_q_caster:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_prince_q_caster:OnTakeDamage(params)
    if not IsServer() then return end
    if self.magic_lifesteal <= 0 then return end
    if not self.caster or self.caster:IsNull() then return end

    if params.attacker ~= self.caster then return end
    if not params.inflictor then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then return end
    if not params.unit or params.unit:IsNull() or params.unit == self.caster then return end
    if params.unit:IsBuilding() or params.unit:IsOther() or params.unit:IsWard() then return end
    if params.damage <= 0 then return end

    local heal = params.damage * (self.magic_lifesteal * 0.01)
    if heal > 0 then
        self.caster:Heal(heal, self.ability)
        local p = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:ReleaseParticleIndex(p)
    end
end

function modifier_prince_q_caster:OnIntervalThink()
    if not IsServer() then return end
    if not self.target or self.target:IsNull() then
        self:Destroy()
        return
    end
    if not self.target:IsAlive() then
        self:Destroy()
        return
    end
    self:PerformSlash()
end

function modifier_prince_q_caster:PerformSlash()
    if not IsServer() then return end

    local caster = self.caster
    local target = self.target
    local ability = self.ability
    if not ability or ability:IsNull() then return end
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

    local previous_position = caster:GetAbsOrigin()
    FindClearSpaceForUnit(caster, target:GetAbsOrigin() + RandomVector(100), false)
    local current_position = caster:GetAbsOrigin()
    caster:FaceTowards(target:GetAbsOrigin())
    AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), 200, 1, false)
    caster:StartGesture(ACT_DOTA_ATTACK_EVENT)
    target:EmitSound("Hero_Abaddon.Attack")

    local hit_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
    ParticleManager:SetParticleControlEnt( hit_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true )
    ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
    ParticleManager:ReleaseParticleIndex(hit_pfx)

    local trail_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
    ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
    ParticleManager:ReleaseParticleIndex(trail_pfx)

    local dmg = self.damage
    if caster:HasTalent("special_bonus_unique_prince_8") then
        dmg = dmg + caster:GetAverageTrueAttackDamage(nil) * self:GetAbility():GetSpecialValueFor("damage_pct") * 0.01
    end
    caster:PerformAttack(target, true, true, true, false, false, true, true)
    ApplyDamage({
        attacker = caster,
        victim = target,
        ability = ability,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL
    })

    self.attacks_left = self.attacks_left - 1
    if self.attacks_left <= 0 then
        self:Destroy()
    end
end

function modifier_prince_q_caster:StatusEffectPriority()
    return 20
end

function modifier_prince_q_caster:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_prince_q_caster:OnDestroy()
    if not IsServer() then return end
    if self.caster and not self.caster:IsNull() then
        self.caster:FadeGesture(ACT_DOTA_ATTACK_EVENT)
        self.ability:SetActivated(true)
        local prince_r = self.caster:FindAbilityByName("prince_r")
        if prince_r then
            prince_r:SetActivated(true)
        end
        self.caster:MoveToPositionAggressive(self.caster:GetAbsOrigin())
    end
end

function modifier_prince_q_caster:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end