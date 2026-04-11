if not HeroBossEvent then
    HeroBossEvent = class({})
end

HeroBossEvent.ALL_TEAMS = {
    DOTA_TEAM_CUSTOM_1,
    DOTA_TEAM_CUSTOM_2,
    DOTA_TEAM_CUSTOM_3,
    DOTA_TEAM_CUSTOM_4,
    DOTA_TEAM_CUSTOM_5,
    DOTA_TEAM_CUSTOM_6,
    DOTA_TEAM_CUSTOM_7,
    DOTA_TEAM_CUSTOM_8,
    DOTA_TEAM_GOODGUYS,
    DOTA_TEAM_BADGUYS,
}

function HeroBossEvent:ShowBossUI(data)
    if not IsServer() or type(data) ~= "table" then
        return
    end

    CustomGameEventManager:Send_ServerToAllClients("hero_boss_event_spawned", data)
end

function HeroBossEvent:ClearBossUI(data)
    if not IsServer() then
        return
    end

    CustomGameEventManager:Send_ServerToAllClients("hero_boss_event_cleared", data or {})
end

function HeroBossEvent:RevealToAllTeams(position, radius, duration)
    if not IsServer() then
        return
    end

    for _, team in ipairs(self.ALL_TEAMS) do
        AddFOWViewer(team, position, radius or 500, duration or 0.2, false)
    end
end

function HeroBossEvent:CanCastAbility(ability)
    if not IsValid(ability) then
        return false
    end

    if ability:GetLevel() <= 0 then
        return false
    end

    if not ability:IsActivated() then
        return false
    end

    if ability.IsPassive and ability:IsPassive() then
        return false
    end

    local behavior = ability:GetBehaviorInt()
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_TOGGLE) ~= 0 then
        return false
    end

    return ability:IsFullyCastable()
end

function HeroBossEvent:FindClosestEnemy(unit, radius, heroes_only)
    if not IsValid(unit) then
        return nil
    end

    local unit_type = DOTA_UNIT_TARGET_HERO
    if not heroes_only then
        unit_type = unit_type + DOTA_UNIT_TARGET_BASIC
    end

    local enemies = FindUnitsInRadius(
        unit:GetTeamNumber(),
        unit:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        unit_type,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    for _, enemy in ipairs(enemies) do
        if IsValid(enemy) and enemy:IsAlive() and not enemy:IsBuilding() and not enemy:IsOther() and not enemy:IsInvulnerable() and not enemy:IsOutOfGame() then
            return enemy
        end
    end
end

modifier_hero_boss_running = class({})

function modifier_hero_boss_running:IsHidden() return true end
function modifier_hero_boss_running:IsPurgable() return false end
function modifier_hero_boss_running:IsPurgeException() return false end
function modifier_hero_boss_running:RemoveOnDeath() return false end

function modifier_hero_boss_running:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

function modifier_hero_boss_running:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    }
end

function modifier_hero_boss_running:GetModifierMoveSpeed_Limit()
    return 600
end

function modifier_hero_boss_running:GetModifierMoveSpeed_Absolute()
    return 600
end

function modifier_hero_boss_running:GetModifierMoveSpeedOverride()
    return 600
end

modifier_hero_boss_simple_ai = class({})

function modifier_hero_boss_simple_ai:IsHidden() return true end
function modifier_hero_boss_simple_ai:IsPurgable() return false end
function modifier_hero_boss_simple_ai:RemoveOnDeath() return false end

function modifier_hero_boss_simple_ai:OnCreated(kv)
    self.search_radius = tonumber(kv.search_radius) or 1200
    self.cast_interval = tonumber(kv.cast_interval) or 4.0
    self.cast_lock_duration = tonumber(kv.cast_lock_duration) or 0.4
    self.heroes_only = tonumber(kv.heroes_only) == 1
    self.next_cast_time = 0

    if not IsServer() then
        return
    end

    self.next_cast_time = GameRules:GetGameTime() + RandomFloat(0.15, 0.45)
    self:StartIntervalThink(0.2)
end

function modifier_hero_boss_simple_ai:OnIntervalThink()
    if not IsServer() then
        return
    end

    local parent = self:GetParent()
    if not IsValid(parent) or not parent:IsAlive() then
        self:Destroy()
        return
    end

    local target = HeroBossEvent:FindClosestEnemy(parent, self.search_radius, self.heroes_only)
    if not IsValid(target) then
        return
    end

    if not parent:IsStunned() and not parent:IsHexed() and not parent:IsChanneling() and GameRules:GetGameTime() >= self.next_cast_time then
        if self:TryCastAbility(target) then
            self.next_cast_time = GameRules:GetGameTime() + self.cast_interval
            return
        end

        self.next_cast_time = GameRules:GetGameTime() + 0.5
    end

    parent:MoveToTargetToAttack(target)
end

function modifier_hero_boss_simple_ai:TryCastAbility(target)
    local parent = self:GetParent()
    if not IsValid(parent, target) then
        return false
    end

    for i = 0, 15 do
        local ability = parent:GetAbilityByIndex(i)
        if HeroBossEvent:CanCastAbility(ability) then
            local behavior = ability:GetBehaviorInt()
            local cast_range = ability:GetCastRange(parent:GetAbsOrigin(), target)
            local distance = (target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()

            if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                if cast_range <= 0 or distance <= cast_range + 150 then
                    parent:CastAbilityOnTarget(target, ability, -1)
                    return true
                end
            elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                if cast_range <= 0 or distance <= math.max(cast_range, self.search_radius) then
                    parent:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
                    return true
                end
            elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                parent:CastAbilityNoTarget(ability, -1)
                return true
            end
        end
    end

    return false
end
