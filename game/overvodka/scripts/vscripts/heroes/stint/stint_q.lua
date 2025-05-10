LinkLuaModifier("modifier_stint_q_barrier", "heroes/stint/stint_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_q_trigger", "heroes/stint/stint_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stint_q_nelya",   "heroes/stint/stint_q", LUA_MODIFIER_MOTION_NONE)

stint_q = class({})

function stint_q:Precache(context)
    PrecacheResource("soundfile", "soundevents/stint_q.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stint_q_appear.vsndevts", context)
    PrecacheResource("model", "models/heroes/marci/marci_base.vmdl", context)
    PrecacheResource("particle", "particles/econ/events/ti10/mjollnir_shield_ti10.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_golden_staff_lvlup_globe_spawn.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_game_spawn_v2.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_shard_hypothermia_death_v2.vpcf", context)
end

function stint_q:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    local shieldMod = caster:FindModifierByName("modifier_stint_q_barrier")
    if shieldMod then shieldMod:Destroy() end
    caster:AddNewModifier(caster, self, "modifier_stint_q_barrier", {duration = duration})

    local trig = caster:FindModifierByName("modifier_stint_q_trigger")
    if trig then trig:Destroy() end
    caster:AddNewModifier(caster, self, "modifier_stint_q_trigger", {duration = duration})

    EmitSoundOn("stint_q", caster)
end

modifier_stint_q_barrier = class({})

function modifier_stint_q_barrier:IsPurgable() return true end

function modifier_stint_q_barrier:OnCreated()
    if not IsServer() then return end
    local effect = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_golden_staff_lvlup_globe_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(effect, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect, 5, Vector(1, 1, 1))
    ParticleManager:ReleaseParticleIndex(effect)
    self.max_shield = self:GetAbility():GetSpecialValueFor("shield") * self:GetParent():GetMaxHealth() / 100
    self:SetStackCount(self.max_shield)
end

function modifier_stint_q_barrier:OnRefresh()
    if not IsServer() then return end
    self.max_shield = self:GetAbility():GetSpecialValueFor("shield") * self:GetParent():GetMaxHealth() / 100
    self:SetStackCount(self.max_shield)
end

function modifier_stint_q_barrier:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_stint_q_barrier:GetModifierIncomingDamageConstant(params)
    if IsClient() then
        if params.report_max then
            return self.max_shield or self:GetStackCount()
        else 
            return self:GetStackCount()
        end 
    end
    if params.damage>=self:GetStackCount() then
        self:Destroy()
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end

function modifier_stint_q_barrier:GetEffectName()
    return "particles/econ/events/ti10/mjollnir_shield_ti10.vpcf"
end

function modifier_stint_q_barrier:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_stint_q_trigger = class({})

function modifier_stint_q_trigger:IsHidden()    return false end
function modifier_stint_q_trigger:IsPurgable()  return true end
function modifier_stint_q_trigger:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_stint_q_trigger:OnCreated()
    if not IsServer() then return end
    self.attacker_next_spawn = {}
    self.dispel = self:GetAbility():GetSpecialValueFor("dispel")
    if self.dispel > 0 then
        self:StartIntervalThink(self.dispel)
        self:OnIntervalThink()
    end
end

function modifier_stint_q_trigger:OnIntervalThink()
    self:GetParent():Purge( false, true, false, true, false )
end

function modifier_stint_q_trigger:OnTakeDamage(params)
    if not IsServer() then return end
    local ability = self:GetAbility()
    local parent = self:GetParent()
    local attacker = params.attacker
    if params.unit ~= parent then return end
    if attacker:GetTeamNumber() == parent:GetTeamNumber() then return end
    local radius = ability:GetSpecialValueFor("radius")
    if (attacker:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > radius then
        return
    end
    local now = GameRules:GetGameTime()
    local key = attacker:entindex()
    local nextOK = self.attacker_next_spawn[key] or 0
    local cd = ability:GetSpecialValueFor("cooldown_single")
    if now < nextOK then
        return
    end
    self.attacker_next_spawn[key] = now + cd
    local hits   = ability:GetSpecialValueFor("hits")
    local dmg    = ability:GetSpecialValueFor("base_damage") + ability:GetSpecialValueFor("level_damage") * parent:GetLevel()
    local fv     = RandomVector(100)
    local nelya  = CreateUnitByName("npc_nelya", attacker:GetAbsOrigin() + fv, true, parent, parent, parent:GetTeamNumber())
    nelya:AddNewModifier(parent, ability, "modifier_stint_q_nelya", {
        duration = 1.5,
        hits     = hits,
        damage   = dmg,
    })
    nelya:SetForceAttackTarget(attacker)
    local effect_cast = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_game_spawn_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, nelya)
    ParticleManager:SetParticleControl(effect_cast, 0, nelya:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    EmitSoundOn("stint_q_appear", nelya)
end


modifier_stint_q_nelya = class({})

function modifier_stint_q_nelya:IsHidden()   return true end
function modifier_stint_q_nelya:IsPurgable() return false end

function modifier_stint_q_nelya:OnCreated(kv)
    if not IsServer() then return end
    self.hits   = kv.hits   or 1
    self.damage = kv.damage or 0
    self.attack_rate = 0.9 / self.hits
end

function modifier_stint_q_nelya:DeclareFunctions()
    return {
      MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
      MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
      MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_stint_q_nelya:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
        [MODIFIER_STATE_MAGIC_IMMUNE]      = true,
    }
end

function modifier_stint_q_nelya:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_stint_q_nelya:GetModifierFixedAttackRate()
    return self.attack_rate
end

function modifier_stint_q_nelya:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    self.hits = self.hits - 1
    if self.hits <= 0 then
        local effect_cast = ParticleManager:CreateParticle("particles/econ/items/drow/drow_arcana/drow_arcana_shard_hypothermia_death_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)
        UTIL_Remove(self:GetParent())
    end
end

function modifier_stint_q_nelya:OnDestroy()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/econ/items/drow/drow_arcana/drow_arcana_shard_hypothermia_death_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    UTIL_Remove(self:GetParent())
end