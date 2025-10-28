LinkLuaModifier("modifier_prince_e", "heroes/prince/prince_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_e_zombie", "heroes/prince/prince_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_e_shard", "heroes/prince/prince_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_e_inside", "heroes/prince/prince_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_prince_w", "heroes/prince/prince_w", LUA_MODIFIER_MOTION_NONE)

prince_e = class({})

function prince_e:Precache(ctx)
    PrecacheUnitByNameSync("npc_dota_prince_throne", ctx)
    PrecacheUnitByNameSync("npc_dota_prince_zombie", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_undying/undying_tombstone.vpcf", ctx)
    PrecacheResource("particle", "particles/neutral_fx/skeleton_spawn.vpcf", ctx)
    PrecacheResource("model", "models/prince/tron_shard.vmdl", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/prince_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/prince_e.vpcf", ctx)
end

function prince_e:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function prince_e:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function prince_e:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function prince_e:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function prince_e:OnSpellStart()
    if not IsServer() then return end
    local cursor_point = self:GetCursorPosition()
    EmitSoundOnLocationWithCaster(cursor_point, "prince_e", self:GetCaster())
    local effect_cast = ParticleManager:CreateParticle("particles/prince_e_ping.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 0, cursor_point)
    ParticleManager:SetParticleControl(effect_cast, 7, Vector(255, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    Timers:CreateTimer(self:GetSpecialValueFor("spawn_delay"), function()
        if not self or self:IsNull() then return end
        if not self:GetCaster() or self:GetCaster():IsNull() then return end
        GridNav:DestroyTreesAroundPoint(cursor_point, 250, false)
        local Throne = CreateUnitByName( "npc_dota_prince_throne", cursor_point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
        if Throne ~= nil then
            Throne:SetMinimumGoldBounty(200)
            local duration = self:GetSpecialValueFor("duration")
            Throne:AddNewModifier( self:GetCaster(), self, "modifier_prince_e", { duration = duration } )
            Throne:AddNewModifier( self:GetCaster(), self, "modifier_kill", { duration = duration } )
            local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_undying/undying_tombstone.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( particle, 0, cursor_point ) 
            ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), duration, "attach_attack1", self:GetCaster():GetOrigin(), true )
            ParticleManager:SetParticleControl( particle, 2, Vector( duration, duration, duration ) )
            ParticleManager:ReleaseParticleIndex( particle )
            Throne:EmitSound("Hero_Undying.Tombstone")
            if self:GetCaster():HasShard() then
                self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_prince_e_shard", {duration = duration})
            end
        end
    end)
end

modifier_prince_e_shard = class({})

function modifier_prince_e_shard:IsHidden() return true end
function modifier_prince_e_shard:IsPurgable() return false end
function modifier_prince_e_shard:RemoveOnDeath() return false end

function modifier_prince_e_shard:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ORDER }
end

function modifier_prince_e_shard:OnOrder(params)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if params.unit ~= caster then return end
    if params.order_type ~= DOTA_UNIT_ORDER_MOVE_TO_TARGET 
    and params.order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET
    and params.order_type ~= DOTA_UNIT_ORDER_MOVE_TO_POSITION then return end

    local target = params.target
    if not target or target:IsIllusion() or target:GetTeamNumber() ~= caster:GetTeamNumber() or target:GetUnitName() ~= "npc_dota_prince_throne" then return end

    if target._inside and IsValidEntity(target._inside) and target._inside:IsAlive() then
        return
    end

    local now = GameRules:GetGameTime()
    local cd_until = caster._prince_e_enter_cd_until or 0
    if now < cd_until then
        return
    end

    local range = self:GetAbility():GetSpecialValueFor("shard_range")
    if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= range then
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_prince_e_inside", {duration = self:GetRemainingTime(), throne = target:entindex()})
    end
end

modifier_prince_e_inside = class({})

function modifier_prince_e_inside:IsHidden() return false end
function modifier_prince_e_inside:IsPurgable() return false end
function modifier_prince_e_inside:RemoveOnDeath() return false end

function modifier_prince_e_inside:OnCreated(kv)
    if not IsServer() then return end

    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    self.throne  = EntIndexToHScript(kv.throne)
    self.time_passed = 0

    if self.throne and not self.throne:IsNull() then
        self.throne._inside = self.parent
    end

    self.bonus_hp = 0
    if self.throne and not self.throne:IsNull() and self.throne:IsAlive() and self.ability and not self.ability:IsNull() then
        self.bonus_hp = tonumber(self.ability:GetSpecialValueFor("shard_bonus_hp")) or 0
        if self.bonus_hp > 0 then
            local mod = self.throne:FindModifierByName("modifier_prince_e")
            local per_pip = (mod and mod.hits_per_pip) or 2

            self.throne:SetBaseMaxHealth(self.throne:GetBaseMaxHealth() + self.bonus_hp * per_pip)
            self.throne:SetMaxHealth(self.throne:GetMaxHealth() + self.bonus_hp * per_pip)
            self.throne:SetHealth(self.throne:GetHealth() + self.bonus_hp * per_pip)

            if mod then
                mod.pips_display = (mod.pips_display or 0) + self.bonus_hp
                mod:_UpdatePips()
            end

            self.throne:SetModel("models/prince/tron_shard.vmdl")
        end
    end

    self.parent:AddNoDraw()
    self:StartIntervalThink(FrameTime())
end

function modifier_prince_e_inside:OnIntervalThink()
    if not IsServer() then return end
    self.time_passed = self.time_passed + FrameTime()
    if not self.throne or self.throne:IsNull() then
        self:Destroy()
        return
    end
    if not self.throne:IsAlive() then
        self:Destroy()
        return
    end
    self:GetParent():SetAbsOrigin(self.throne:GetAbsOrigin())
end

function modifier_prince_e_inside:OnDestroy()
    if not IsServer() then return end
    if self.throne and not self.throne:IsNull() and self.throne._inside == self.parent then
        self.throne._inside = nil
    end

    if self.throne and not self.throne:IsNull() and self.throne:IsAlive() and self.bonus_hp and self.bonus_hp > 0 then
        local mod = self.throne:FindModifierByName("modifier_prince_e")
        local per_pip = (mod and mod.hits_per_pip) or 2

        local new_base = math.max(1, self.throne:GetBaseMaxHealth() - self.bonus_hp * per_pip)
        local new_max  = math.max(1, self.throne:GetMaxHealth()  - self.bonus_hp * per_pip)
        self.throne:SetBaseMaxHealth(new_base)
        self.throne:SetMaxHealth(new_max)
        self.throne:SetHealth(math.min(self.throne:GetHealth(), new_max))

        self.throne:SetModel("models/prince/throne/tron.vmdl")
        self.throne:StartGesture(ACT_DOTA_IDLE)

        if mod then
            mod.pips_display = math.max(1, (mod.pips_display or 1) - self.bonus_hp)
            mod:_UpdatePips()
        end
    end

    if self.ability and not self.ability:IsNull() then
        local reenter_cd = tonumber(self.ability:GetSpecialValueFor("min_inside_time")) or 0
        if reenter_cd > 0 then
            self.parent._prince_e_enter_cd_until = GameRules:GetGameTime() + reenter_cd
        end
    end

    self:GetParent():RemoveNoDraw()
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin() + RandomVector(120), true)
end


function modifier_prince_e_inside:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ORDER }
end

function modifier_prince_e_inside:OnOrder(params)
    if not IsServer() then return end
    if self.time_passed < self:GetAbility():GetSpecialValueFor("min_inside_time") then return end
    if params.unit ~= self:GetParent() then return end
    if params.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or params.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
        self:Destroy()
    end
end

function modifier_prince_e_inside:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED]    = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

modifier_prince_e = class({})

function modifier_prince_e:IsHidden() return true end
function modifier_prince_e:IsPurgable() return false end

function modifier_prince_e:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_prince_e:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
end

function modifier_prince_e:GetDisableHealing()
    return 1
end

function modifier_prince_e:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_prince_e:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_prince_e:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_prince_e:GetModifierHealthBarPips()
    return self._pips or self.pips_display or 1
end

function modifier_prince_e:OnAttackLanded(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    if keys.target ~= parent then return end

    local attacker = keys.attacker
    if not attacker or attacker:IsNull() then return end

    local hp_loss = (attacker:IsHero() and not attacker:IsIllusion()) and 2 or 1

    local cur = math.max(0, parent:GetHealth())
    local new = math.max(0, cur - hp_loss)

    if new <= 0 then
        if attacker:IsHero() then
            parent:Kill(nil, attacker)
        else
            parent:ForceKill(false)
        end
    else
        parent:SetHealth(new)
    end
end


function modifier_prince_e:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.zombie_interval = self:GetAbility():GetSpecialValueFor("zombie_interval")

    self.pips_display = self:GetAbility():GetSpecialValueFor("tombstone_health")
    self.hits_per_pip = 2
    local max_hp_internal = self.pips_display * self.hits_per_pip

    local parent = self:GetParent()
    parent:SetBaseMaxHealth(max_hp_internal)
    parent:SetMaxHealth(max_hp_internal)
    parent:SetHealth(max_hp_internal)

    self:SetHasCustomTransmitterData(true)
    self:_UpdatePips()
    self:StartIntervalThink(self.zombie_interval)
end

function modifier_prince_e:_UpdatePips()
    if not IsServer() then return end
    self._pips = self.pips_display or 1
    self:SendBuffRefreshToClients()
end

function modifier_prince_e:AddCustomTransmitterData()
    return { pips = self._pips or 1 }
end

function modifier_prince_e:HandleCustomTransmitterData(data)
    self._pips = data.pips or 1
end

function modifier_prince_e:OnDestroy()
    if not IsServer() then return end
    local zombies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,zombie in pairs( zombies ) do
        if zombie:GetUnitName() == "npc_dota_prince_zombie" then
            zombie:ForceKill(false)
        end
    end
end

function modifier_prince_e:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetAbility() or self:GetAbility():IsNull() then
        self:GetParent():ForceKill(false)
        self:Destroy()
        return
    end
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    local base_damage = self:GetAbility():GetSpecialValueFor("damage")
    for _,enemy in pairs( enemies ) do
        if enemy ~= nil and enemy:IsAlive() then
            local Zombie = CreateUnitByName( "npc_dota_prince_zombie", enemy:GetOrigin() + RandomVector( 50 ), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )
            ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticle( "particles/neutral_fx/skeleton_spawn.vpcf", PATTACH_ABSORIGIN, Zombie ) )
            Zombie:FindAbilityByName( "undying_tombstone_zombie_deathstrike" ):SetLevel(self:GetAbility():GetLevel())
            Zombie:SetAggroTarget(enemy)
            Zombie:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_prince_e_zombie", {enemy_entindex = enemy:entindex()})
            Zombie:SetBaseDamageMin(base_damage)
            Zombie:SetBaseDamageMax(base_damage)
            local prince = self:GetCaster()
            if prince and prince:HasTalent("special_bonus_unique_prince_7") then
                local ab = prince:FindAbilityByName("prince_w")
                if ab and ab:GetLevel() > 0 then
                    Zombie:AddNewModifier(Zombie, ab, "modifier_prince_w", {})
                end
            end
        end
    end
end

function modifier_prince_e:GetEffectName()
    return "particles/prince_e.vpcf"
end

function modifier_prince_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_prince_e_zombie = class({})

function modifier_prince_e_zombie:IsPurgable() return false end
function modifier_prince_e_zombie:IsHidden() return true end

function modifier_prince_e_zombie:OnCreated(keys)
    if not IsServer() then return end
    self.aggro_target = EntIndexToHScript(keys.enemy_entindex)
    self:StartIntervalThink(FrameTime())
end

function modifier_prince_e_zombie:OnIntervalThink()
    if IsServer() then
        if not self.aggro_target or self.aggro_target:IsNull() then
            self:GetParent():ForceKill(false)
            return
        end
        if not self.aggro_target:IsAlive() or self.aggro_target == nil then
            self:GetParent():ForceKill(false)
        end
        if not self:GetParent():CanEntityBeSeenByMyTeam(self.aggro_target) then
            ExecuteOrderFromTable({
                UnitIndex   = self:GetParent():entindex(),
                OrderType   = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position    = self.aggro_target:GetAbsOrigin()
            })
        elseif self:GetParent():GetAggroTarget() ~= self.aggro_target then
            ExecuteOrderFromTable({
                UnitIndex   = self:GetParent():entindex(),
                OrderType   = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = self.aggro_target
            })
        end
    end
end

function modifier_prince_e_zombie:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_prince_e_zombie:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }
end

function modifier_prince_e_zombie:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_prince_e_zombie:GetAbsoluteNoDamagePure()
    return 1
end
