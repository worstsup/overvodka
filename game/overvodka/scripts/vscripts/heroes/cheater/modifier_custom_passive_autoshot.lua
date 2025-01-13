modifier_custom_passive_autoshot = class({})

function modifier_custom_passive_autoshot:IsHidden() return true end
function modifier_custom_passive_autoshot:IsPurgable() return false end
function modifier_custom_passive_autoshot:IsPermanent() return true end

function modifier_custom_passive_autoshot:OnCreated()
    if not IsServer() then return end

    self:StartIntervalThink(0.03)
end

function modifier_custom_passive_autoshot:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent:IsAlive() then return end

    local attack_interval = parent:GetSecondsPerAttack(true)
    local attack_range = parent:Script_GetAttackRange()
    if parent:IsStunned() or parent:IsDisarmed() or parent:IsCommandRestricted() then return end
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        attack_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,    
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )

    if #enemies > 0 then
        local target = enemies[1]
        if not self.last_attack_time or GameRules:GetGameTime() >= self.last_attack_time + attack_interval then
            parent:PerformAttack(target, true, true, false, false, true, false, false)
            self.last_attack_time = GameRules:GetGameTime()
        end
    end
end