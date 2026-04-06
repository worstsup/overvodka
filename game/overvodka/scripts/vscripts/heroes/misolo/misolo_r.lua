LinkLuaModifier("modifier_misolo_r_hidden", "heroes/misolo/misolo_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_r_warrior", "heroes/misolo/misolo_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_visage_silent_as_the_grave", "heroes/misolo/misolo_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_arc_flux", "heroes/misolo/misolo_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_arc_spark_wraith", "heroes/misolo/misolo_r", LUA_MODIFIER_MOTION_NONE)

misolo_r = class({})
misolo_visage_soul_assumption = class({})
misolo_visage_silent_as_the_grave = class({})
misolo_arc_flux = class({})
misolo_arc_spark_wraith = class({})

modifier_misolo_r_hidden = class({})
modifier_misolo_r_warrior = class({})
modifier_misolo_visage_silent_as_the_grave = class({})
modifier_misolo_arc_flux = class({})
modifier_misolo_arc_spark_wraith = class({})

function misolo_r:Precache(context)
    PrecacheUnitByNameSync("npc_dota_misolo_beast_warrior", context)
    PrecacheUnitByNameSync("npc_dota_misolo_visage_warrior", context)
    PrecacheUnitByNameSync("npc_dota_misolo_arc_warrior", context)

    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_primal_split.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_wraith.vpcf", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_beastmaster", context)
    PrecacheResource("particle", "particles/broodskoe_hatsapp.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_arc_warden.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", context)
end

function misolo_r:OnAbilityPhaseInterrupted()
	StopSoundOn( "misolo_r_start", self:GetCaster() )
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
end

function misolo_r:OnAbilityPhaseStart()
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_primal_split.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
	EmitSoundOn( "misolo_r_start", self:GetCaster() )
	return true
end

function misolo_r:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not IsValid(caster) or self._split_active then return end

    local p = ParticleManager:CreateParticle("particles/broodskoe_hatsapp.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)

    -- misolo_r follows the Primal Split flow: hide the real hero, spawn 3 controllable warriors, then either return the hero or kill him.
    self._split_active = true
    self._split_finished = false
    self._hidden_position = caster:GetAbsOrigin()
    self._warriors = {}
    self._split_killer = nil

    caster:Interrupt()
    caster:Stop()
    caster:AddNewModifier(caster, self, "modifier_misolo_r_hidden", {})

    EmitSoundOn("Hero_Brewmaster.PrimalSplit.Cast", caster)

    self:SpawnWarriors()

    local duration = self:GetSpecialValueFor("split_duration")
    EmitSoundOn("misolo_r", caster)
    Timers:CreateTimer(duration, function()
        if not self or self:IsNull() or self._split_finished then
            return
        end

        self:FinishSplit(self:GetPriorityWarrior() ~= nil)
    end)
end

function misolo_r:GetPriorityWarrior()
    for _, role in ipairs({"beast", "visage", "arc"}) do
        local warrior = self._warriors and self._warriors[role] or nil
        if IsValid(warrior) and warrior:IsAlive() then
            return warrior
        end
    end
end

function misolo_r:SendSplitSelectionEvent()
    local caster = self:GetCaster()
    if not IsValid(caster) then return end

    local player = caster:GetPlayerOwner()
    if not IsValid(player) then return end

    local payload = {
        caster = caster:entindex(),
    }
    local primary = self:GetPriorityWarrior()
    if IsValid(primary) then
        payload.primary = primary:entindex()
    end

    for _, role in ipairs({"beast", "visage", "arc"}) do
        local warrior = self._warriors and self._warriors[role] or nil
        if IsValid(warrior) then
            payload[role] = warrior:entindex()
        end
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "misolo_r_select_split_units", payload)
end

function misolo_r:SendReturnSelectionEvent()
    local caster = self:GetCaster()
    if not IsValid(caster) then return end

    local player = caster:GetPlayerOwner()
    if not IsValid(player) then return end

    CustomGameEventManager:Send_ServerToPlayer(player, "misolo_r_select_return_unit", {
        unit_entindex = caster:entindex(),
    })
end

function misolo_r:SpawnWarriors()
    local caster = self:GetCaster()
    if not IsValid(caster) then return end

    local origin = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()
    forward.z = 0
    if forward:Length2D() <= 0 then
        forward = Vector(1, 0, 0)
    else
        forward = forward:Normalized()
    end

    local right = Vector(-forward.y, forward.x, 0)
    local spawns = {
        {"beast", "npc_dota_misolo_beast_warrior", origin + forward * 100},
        {"visage", "npc_dota_misolo_visage_warrior", origin - forward * 50 - right * 86.6},
        {"arc", "npc_dota_misolo_arc_warrior", origin - forward * 50 + right * 86.6},
    }

    for _, data in ipairs(spawns) do
        local warrior = CreateUnitByName(data[2], data[3], true, caster, caster, caster:GetTeamNumber())
        if IsValid(warrior) then
            warrior:SetOwner(caster)
            warrior:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
            warrior:SetForwardVector(forward)
            warrior:SetDeathXP(0)
            warrior:SetMinimumGoldBounty(0)
            warrior:SetMaximumGoldBounty(0)
            warrior._misolo_split_role = data[1]

            FindClearSpaceForUnit(warrior, data[3], true)
            self:SetupWarrior(warrior)
            self._warriors[data[1]] = warrior
        end
    end

    ResolveNPCPositions(origin, 128)
    self:SendSplitSelectionEvent()
end

function misolo_r:SetupWarrior(warrior)
    local health = self:GetSpecialValueFor("units_health")
    local damage = self:GetSpecialValueFor("units_damage")
    local level = self:GetLevel()

    warrior:AddNewModifier(self:GetCaster(), self, "modifier_misolo_r_warrior", {})
    warrior:SetBaseMaxHealth(health)
    warrior:SetMaxHealth(health)
    warrior:SetHealth(health)
    warrior:SetBaseDamageMin(damage)
    warrior:SetBaseDamageMax(damage)
    warrior:SetMana(warrior:GetMaxMana())

    for i = 0, 5 do
        local ability = warrior:GetAbilityByIndex(i)
        if ability then
            local max_level = 1
            if ability.GetMaxLevel then
                max_level = math.max(ability:GetMaxLevel() or 1, 1)
            end

            local target_level = math.min(level, max_level)
            if target_level > 0 then
                ability:SetLevel(target_level)
            end

            ability:EndCooldown()
            if ability.RefreshCharges then
                ability:RefreshCharges()
            end
        end
    end
end

function misolo_r:RemoveWarriors()
    for _, role in ipairs({"beast", "visage", "arc"}) do
        local warrior = self._warriors and self._warriors[role] or nil
        if IsValid(warrior) then
            warrior:AddNoDraw()
            UTIL_Remove(warrior)
        end
    end

    self._warriors = {}
end

function misolo_r:FinishSplit(success, killer)
    local caster = self:GetCaster()
    if not IsValid(caster) or self._split_finished then return end

    self._split_finished = true
    self._split_active = false

    local warrior = self:GetPriorityWarrior()
    local return_position = self._hidden_position or caster:GetAbsOrigin()
    local return_forward = caster:GetForwardVector()

    if success and IsValid(warrior) and warrior:IsAlive() then
        return_position = warrior:GetAbsOrigin()
        return_forward = warrior:GetForwardVector()
    end

    self:RemoveWarriors()

    if caster:HasModifier("modifier_misolo_r_hidden") then
        caster:RemoveModifierByName("modifier_misolo_r_hidden")
    else
        caster:RemoveNoDraw()
    end

    FindClearSpaceForUnit(caster, return_position, true)
    ResolveNPCPositions(return_position, 128)
    caster:SetForwardVector(return_forward)
    self:SendReturnSelectionEvent()

    if success then
        caster:Stop()
    else
        if not IsValid(killer) then
            killer = self._split_killer
        end

        if not IsValid(killer) then
            killer = caster
        end

        caster:Kill(self, killer)
    end

    self._hidden_position = nil
    self._split_killer = nil
end

function modifier_misolo_r_hidden:IsHidden() return true end
function modifier_misolo_r_hidden:IsPurgable() return false end
function modifier_misolo_r_hidden:RemoveOnDeath() return false end

function modifier_misolo_r_hidden:OnCreated()
    if not IsServer() then return end

    self:GetParent():AddNoDraw()
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("hidden_position_update_interval"))
end

function modifier_misolo_r_hidden:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsValid(parent, ability) then
        self:Destroy()
        return
    end

    if ability._split_finished then
        self:Destroy()
        return
    end

    local warrior = ability:GetPriorityWarrior()
    if not IsValid(warrior) then
        ability:FinishSplit(false)
        return
    end

    ability._hidden_position = warrior:GetAbsOrigin()
    parent:SetAbsOrigin(ability._hidden_position)
    parent:SetForwardVector(warrior:GetForwardVector())
end

function modifier_misolo_r_hidden:OnDestroy()
    if not IsServer() then return end
    if IsValid(self:GetParent()) then
        self:GetParent():RemoveNoDraw()
    end
end

function modifier_misolo_r_hidden:CheckState()
    return {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_misolo_r_warrior:IsHidden() return true end
function modifier_misolo_r_warrior:IsPurgable() return false end
function modifier_misolo_r_warrior:RemoveOnDeath() return false end

function modifier_misolo_r_warrior:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_misolo_r_warrior:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end

    local ability = self:GetAbility()
    if not IsValid(ability) or ability._split_finished then return end

    if IsValid(params.attacker) then
        ability._split_killer = params.attacker
    end

    Timers:CreateTimer(FrameTime(), function()
        if not IsValid(ability) or ability._split_finished then
            return
        end

        if ability:GetPriorityWarrior() then
            return
        end

        ability:FinishSplit(false, ability._split_killer)
    end)
end

function misolo_visage_soul_assumption:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not IsValid(caster, target) then return end
    if target:TriggerSpellAbsorb(self) then return end

    ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf",
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
    })

    EmitSoundOn("Hero_Visage.SoulAssumption.Cast", caster)
end

function misolo_visage_soul_assumption:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not IsValid(target) then return end

    ApplyDamage({
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetSpecialValueFor("damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    })

    EmitSoundOn("Hero_Visage.SoulAssumption.Target", target)
end

function misolo_visage_silent_as_the_grave:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not IsValid(caster) then return end

    caster:AddNewModifier(caster, self, "modifier_misolo_visage_silent_as_the_grave", {duration = self:GetSpecialValueFor("duration")})
    EmitSoundOn("Hero_Visage.BecomeInvis", caster)
end

function modifier_misolo_visage_silent_as_the_grave:IsHidden() return false end
function modifier_misolo_visage_silent_as_the_grave:IsPurgable() return true end

function modifier_misolo_visage_silent_as_the_grave:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_misolo_visage_silent_as_the_grave:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_misolo_visage_silent_as_the_grave:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_misolo_visage_silent_as_the_grave:GetModifierMoveSpeedBonus_Constant()
    return 550
end

function modifier_misolo_visage_silent_as_the_grave:GetTexture()
    return "visage_silent_as_the_grave"
end

function misolo_arc_flux:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not IsValid(caster, target) then return end
    if target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(caster, self, "modifier_misolo_arc_flux", {duration = self:GetSpecialValueFor("duration")})
    EmitSoundOn("Hero_ArcWarden.Flux.Cast", caster)
    EmitSoundOn("Hero_ArcWarden.Flux.Target", target)
end

function modifier_misolo_arc_flux:IsHidden() return false end
function modifier_misolo_arc_flux:IsDebuff() return true end
function modifier_misolo_arc_flux:IsPurgable() return true end

function modifier_misolo_arc_flux:OnCreated()
    self.damage_per_second = self:GetAbility():GetSpecialValueFor("damage_per_second")
    self.slow_pct = self:GetAbility():GetSpecialValueFor("slow_pct")

    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_misolo_arc_flux:OnRefresh()
    self.damage_per_second = self:GetAbility():GetSpecialValueFor("damage_per_second")
    self.slow_pct = self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_misolo_arc_flux:OnIntervalThink()
    if not IsServer() then return end

    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_second,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    })
end

function modifier_misolo_arc_flux:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_misolo_arc_flux:GetModifierMoveSpeedBonus_Percentage()
    return -(self.slow_pct or 0)
end

function modifier_misolo_arc_flux:GetEffectName()
    return "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function modifier_misolo_arc_flux:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_misolo_arc_flux:GetTexture()
    return "arc_warden_flux"
end

function misolo_arc_spark_wraith:OnSpellStart()
    if not IsServer() then return end

    local point = self:GetCursorPosition()
    CreateModifierThinker(self:GetCaster(), self, "modifier_misolo_arc_spark_wraith", {duration = self:GetSpecialValueFor("activation_time") + self:GetSpecialValueFor("watch_duration")}, point, self:GetCaster():GetTeamNumber(), false)
    EmitSoundOn("Hero_ArcWarden.SparkWraith.Cast", self:GetCaster())
end

function misolo_arc_spark_wraith:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not IsValid(target) then return end

    ApplyDamage({
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetSpecialValueFor("damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    })

    EmitSoundOn("Hero_ArcWarden.SparkWraith.Damage", target)
end

function modifier_misolo_arc_spark_wraith:IsHidden() return true end
function modifier_misolo_arc_spark_wraith:IsPurgable() return false end

function modifier_misolo_arc_spark_wraith:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.activation_time = self:GetAbility():GetSpecialValueFor("activation_time")

    if not IsServer() then return end

    self.armed = false
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_wraith.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(self.activation_time)
end

function modifier_misolo_arc_spark_wraith:OnIntervalThink()
    if not IsServer() then return end

    if not self.armed then
        self.armed = true
        self:StartIntervalThink(0.1)
        return
    end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if not IsValid(parent, caster, ability) then
        self:Destroy()
        return
    end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    for _, enemy in ipairs(enemies) do
        if IsValid(enemy) and enemy:IsAlive() and not enemy:IsInvulnerable() and not enemy:IsOutOfGame() then
            ProjectileManager:CreateTrackingProjectile({
                Target = enemy,
                Source = parent,
                Ability = ability,
                EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
                iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"),
                bDodgeable = true,
                bVisibleToEnemies = true,
                bProvidesVision = false,
            })

            EmitSoundOn("Hero_ArcWarden.SparkWraith.Activate", enemy)
            self:Destroy()
            return
        end
    end
end

function modifier_misolo_arc_spark_wraith:OnDestroy()
    if not IsServer() then return end
    if IsValid(self:GetParent()) then
        UTIL_Remove(self:GetParent())
    end
end
