LinkLuaModifier("modifier_kolyan_r_trigger", "heroes/kolyan/kolyan_r", LUA_MODIFIER_MOTION_NONE)

kolyan_r = class({})

function kolyan_r:Precache(context)
    PrecacheResource("soundfile", "soundevents/kolyan_r.vsndevts", context)
    PrecacheUnitByNameSync("npc_kolyan_guard", context)
    PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_spawn.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/sniper/sniper_charlie/sniper_base_attack_charlie.vpcf", context)
    PrecacheResource("particle", "particles/kolyan_r_death.vpcf", context)
end

function kolyan_r:OnAbilityPhaseInterrupted()
	StopSoundOn( "kolyan_r_cast", self:GetCaster() )
end

function kolyan_r:OnAbilityPhaseStart()
	EmitSoundOn( "kolyan_r_cast", self:GetCaster() )
	return true
end

function kolyan_r:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local forward = caster:GetForwardVector()
    local right = Vector(-forward.y, forward.x, 0):Normalized()
    local fv = right * 225
    EmitSoundOn("kolyan_r", caster)
    local guard = CreateUnitByName(
        "npc_kolyan_guard",
        caster:GetAbsOrigin() + fv,
        true,
        caster,
        caster:GetOwner(),
        caster:GetTeamNumber()
    )
    guard:SetControllableByPlayer(caster:GetPlayerID(), false)
    guard:SetOwner(caster)
    guard:AddNewModifier(caster, self, "modifier_kolyan_r_trigger", {duration = duration})
    local guard2 = CreateUnitByName(
        "npc_kolyan_guard",
        caster:GetAbsOrigin() - fv,
        true,
        caster,
        caster:GetOwner(),
        caster:GetTeamNumber()
    )
    guard2:SetControllableByPlayer(caster:GetPlayerID(), false)
    guard2:SetOwner(caster)
    guard2:AddNewModifier(caster, self, "modifier_kolyan_r_trigger", {duration = duration})
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, guard)
    ParticleManager:SetParticleControl(p, 0, guard:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, guard2)
    ParticleManager:SetParticleControl(p2, 0, guard2:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p2)
    if self:GetSpecialValueFor("num") == 3 then
        local v = caster:GetForwardVector() * 225
        local guard3 = CreateUnitByName(
            "npc_kolyan_guard",
            caster:GetAbsOrigin() - v,
            true,
            caster,
            caster:GetOwner(),
            caster:GetTeamNumber()
        )
        guard3:SetControllableByPlayer(caster:GetPlayerID(), false)
        guard3:SetOwner(caster)
        guard3:AddNewModifier(caster, self, "modifier_kolyan_r_trigger", {duration = duration})
        local p3 = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, guard3)
        ParticleManager:SetParticleControl(p3, 0, guard3:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p3)
    end
end

modifier_kolyan_r_trigger = class({})

function modifier_kolyan_r_trigger:IsHidden()  return false end
function modifier_kolyan_r_trigger:IsPurgable()  return false end

function modifier_kolyan_r_trigger:OnCreated()
    if not IsServer() then return end
    local ab = self:GetAbility()
    self.radius    = ab:GetSpecialValueFor("radius")
    self.busy      = false
    self.currentTarget = nil
    self.damage = ab:GetSpecialValueFor("damage")
    self:StartIntervalThink(0.2)
end

function modifier_kolyan_r_trigger:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_kolyan_r_trigger:GetModifierFixedAttackRate()
    return 0.2
end

function modifier_kolyan_r_trigger:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_ATTACK_LANDED,  
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
    }
end

function modifier_kolyan_r_trigger:GetAttackSound()
	return "kolyan_r_shoot"
end

function modifier_kolyan_r_trigger:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetAbility() then
        self:Destroy()
        return
    end
    local guard  = self:GetParent()
    local caster = self:GetCaster()
    if self:GetAbility():GetSpecialValueFor("has_facet") > 0 then
        local everyone = FindUnitsInRadius(caster:GetTeamNumber(), guard:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _,enemy in pairs(everyone) do
            enemy:AddNewModifier(caster, self:GetAbility(), "modifier_truesight", {duration = 0.3})
        end
    end
    if not caster:IsAlive() then
        self:Destroy()
    end
    local now = GameRules:GetGameTime()
    if not self.busy and (guard:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 2000 then
        FindClearSpaceForUnit( guard, caster:GetAbsOrigin() + RandomVector(200), false )
    end
    if not self.busy and (guard:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 300 then
        guard:MoveToPosition(caster:GetAbsOrigin() + RandomVector(200))
    end
    if self.busy and self.currentTarget then
         if (not self.currentTarget:IsAlive())
         or not caster:CanEntityBeSeenByMyTeam( self.currentTarget ) or self.currentTarget:IsAttackImmune()
         or not self.currentTarget:IsPositionInRange(caster:GetAbsOrigin(), self.radius + 500) then
             self:FinishRun()
             return
         end
     end
    if self.busy and (guard:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 700 then
        self:FinishRun()
        return
    end
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetAbsOrigin(), nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
        FIND_CLOSEST,
        false
    )
    local target = enemies[1]
    if not target then
        local creeps = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetAbsOrigin(), nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
            FIND_CLOSEST,
            false
        )
        target = creeps[1]
        if not target then
            return
        end
    end
    self.busy = true
    self.currentTarget = target
    guard:MoveToTargetToAttack(target)
    --local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, guard)
    --ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn("kolyan_r_appear", guard)
end

function modifier_kolyan_r_trigger:FinishRun()
    if not IsServer() then return end
    local guard  = self:GetParent()
    local caster = self:GetCaster()
    self.busy        = false
    self.currentTarget = nil
    guard:Stop()
    guard:MoveToPosition(caster:GetAbsOrigin() + RandomVector(200))
end

function modifier_kolyan_r_trigger:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local caster = self:GetCaster()
    if caster:HasScepter() then
        local heal = self:GetAbility():GetSpecialValueFor("lifesteal") * params.damage * 0.01
        caster:HealWithParams(heal, self, false, true, caster, false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, caster:GetPlayerOwner())
    end
end

function modifier_kolyan_r_trigger:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
    local effect_cast = ParticleManager:CreateParticle("particles/kolyan_r_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    UTIL_Remove(self:GetParent())
end

function modifier_kolyan_r_trigger:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end