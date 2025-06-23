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
    PrecacheResource("particle", "particles/econ/items/marci/marci_lotus_keeper/marci_lotus_back_ambient_flower.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", context)
end

function stint_q:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    local shieldMod = caster:FindModifierByName("modifier_stint_q_barrier")
    if shieldMod then shieldMod:Destroy() end
    caster:AddNewModifier(caster, self, "modifier_stint_q_barrier", {duration = duration})
    local fv = RandomVector(150)
    local nelya = CreateUnitByName(
        "npc_nelya",
        caster:GetAbsOrigin() + fv,
        true,
        caster,
        caster:GetOwner(),
        caster:GetTeamNumber()
    )
    nelya:SetControllableByPlayer(caster:GetPlayerID(), false)
    nelya:SetOwner(caster)
    nelya:AddNewModifier(caster, self, "modifier_stint_q_trigger", {duration = duration})
    local p = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_game_spawn_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, nelya)
    ParticleManager:SetParticleControl(p, 0, nelya:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    EmitSoundOn("stint_q", caster)
end

modifier_stint_q_barrier = class({})

function modifier_stint_q_barrier:IsPurgable() return true end

function modifier_stint_q_barrier:OnCreated()
    if not IsServer() then return end
    self.dispel = self:GetAbility():GetSpecialValueFor("dispel")
    if self.dispel > 0 then
        self:StartIntervalThink(self.dispel)
        self:OnIntervalThink()
    end
    local effect = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_golden_staff_lvlup_globe_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(effect, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect, 5, Vector(1, 1, 1))
    ParticleManager:ReleaseParticleIndex(effect)
    self.barrier_max = self:GetAbility():GetSpecialValueFor("shield") * self:GetParent():GetMaxHealth() / 100
    self.barrier_block = self:GetAbility():GetSpecialValueFor("shield") * self:GetParent():GetMaxHealth() / 100
    self:SetHasCustomTransmitterData( true )
    self:SendBuffRefreshToClients()
end

function modifier_stint_q_barrier:AddCustomTransmitterData()
    return {
        barrier_max = self.barrier_max,
        barrier_block = self.barrier_block,
    }
end

function modifier_stint_q_barrier:HandleCustomTransmitterData( data )
    self.barrier_max = data.barrier_max
    self.barrier_block = data.barrier_block
end

function modifier_stint_q_barrier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_stint_q_barrier:OnIntervalThink()
    self:GetParent():Purge(false, true, false, true, false)
end


function modifier_stint_q_barrier:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_stint_q_barrier:GetModifierIncomingDamageConstant(params)
    if IsClient() then
		if params.report_max then
			return self.barrier_max
		else
			return self.barrier_block
		end
	end
    if params.damage >= self.barrier_block then
		self:Destroy()
        return self.barrier_block * (-1)
	else
		self.barrier_block = self.barrier_block - params.damage
        self:SendBuffRefreshToClients()
		return params.damage * (-1)
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
function modifier_stint_q_trigger:IsPurgable()  return false end

function modifier_stint_q_trigger:OnCreated()
    if not IsServer() then return end
    local ab = self:GetAbility()
    self.radius    = ab:GetSpecialValueFor("radius")
    self.cd_single = ab:GetSpecialValueFor("cooldown_single")
    self.hits      = ab:GetSpecialValueFor("hits")
    self.speed     = 1000
    self.busy      = false
    self.hitCount  = 0
    self.nextScan  = 0
    self.currentTarget = nil
    self.base_damage = ab:GetSpecialValueFor("base_damage")
    self.level_damage = ab:GetSpecialValueFor("level_damage")
    self.damage = self.base_damage + self.level_damage * self:GetCaster():GetLevel()
    self.attack_rate = 0.9 / self.hits
    self:StartIntervalThink(0.1)
end

function modifier_stint_q_trigger:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_stint_q_trigger:GetModifierFixedAttackRate()
    return self.attack_rate
end

function modifier_stint_q_trigger:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_ATTACK_LANDED,  
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_stint_q_trigger:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetAbility() then
        self:Destroy()
        return
    end
    local nelya  = self:GetParent()
    local caster = self:GetCaster()
    local now = GameRules:GetGameTime()
    if not self.busy and (nelya:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 2000 then
        FindClearSpaceForUnit( nelya, caster:GetAbsOrigin() + RandomVector(150), false )
    end
    if not self.busy and (nelya:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() >= 200 then
        nelya:MoveToPosition(caster:GetAbsOrigin() + RandomVector(150))
    end
    if self.busy and self.currentTarget then
         if (not self.currentTarget:IsAlive())
         or not caster:CanEntityBeSeenByMyTeam( self.currentTarget ) or self.currentTarget:IsAttackImmune()
         or not self.currentTarget:IsPositionInRange(caster:GetAbsOrigin(), self.radius + 500) then
             self.hitCount = 0
             self:FinishRun()
             return
         end
     end
    if self.busy or now < self.nextScan then
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
    self.hitCount = self.hits
    self.currentTarget = target
    nelya:AddNewModifier(caster, self:GetAbility(), "modifier_stint_q_nelya", {duration = 1.0})
    nelya:MoveToTargetToAttack(target)
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, nelya)
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn("stint_q_appear", nelya)
end

function modifier_stint_q_trigger:FinishRun()
    if not IsServer() then return end
    local nelya  = self:GetParent()
    local caster = self:GetCaster()
    self.busy        = false
    self.currentTarget = nil
    self.nextScan    = GameRules:GetGameTime() + self.cd_single
    nelya:Stop()
    nelya:MoveToPosition(caster:GetAbsOrigin())
    nelya:AddNewModifier(caster, self:GetAbility(), "modifier_stint_q_nelya", {duration = 0.5})
end

function modifier_stint_q_trigger:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    self.hitCount = self.hitCount - 1
    if self.hitCount <= 0 then
        self:FinishRun()
    end
end

function modifier_stint_q_trigger:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
    local effect_cast = ParticleManager:CreateParticle(
        "particles/econ/items/drow/drow_arcana/drow_arcana_shard_hypothermia_death_v2.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    UTIL_Remove(self:GetParent())
end

function modifier_stint_q_trigger:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

modifier_stint_q_nelya = class({})

function modifier_stint_q_nelya:IsHidden()   return true end
function modifier_stint_q_nelya:IsPurgable() return false end

function modifier_stint_q_nelya:OnCreated(kv)
    if not IsServer() then return end
end

function modifier_stint_q_nelya:DeclareFunctions()
    return {
      MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
end

function modifier_stint_q_nelya:GetModifierMoveSpeed_AbsoluteMin()
    return 1000
end