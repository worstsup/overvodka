LinkLuaModifier("modifier_visitor_ability_facet_1", "heroes/pale_visitor/visitor_ability_facet_1", LUA_MODIFIER_MOTION_NONE)

visitor_ability_facet_1 = class({})

function visitor_ability_facet_1:GetIntrinsicModifierName()
    return "modifier_visitor_ability_facet_1"
end


modifier_visitor_ability_facet_1 = class({})

function modifier_visitor_ability_facet_1:IsHidden()   return true end
function modifier_visitor_ability_facet_1:IsPurgable() return false end

function modifier_visitor_ability_facet_1:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()

    self:UpdateValues()

    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_visitor_ability_facet_1:OnRefresh()
    self:UpdateValues()
end

function modifier_visitor_ability_facet_1:UpdateValues()
    if not self.ability or self.ability:IsNull() then
        self.gold_per_enemy = 0
        self.exp_per_enemy  = 0
        return
    end

    self.gold_per_enemy = self.ability:GetSpecialValueFor("gold") or 0
    self.exp_per_enemy  = self.ability:GetSpecialValueFor("exp")  or 0
end

function modifier_visitor_ability_facet_1:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end
    if not self.parent:IsRealHero() then return end
    if self.parent:PassivesDisabled() then return end

    local d_ability = self.parent:FindAbilityByName("visitor_d")
    if not d_ability or d_ability:IsNull() then return end

    local radius = d_ability:GetSpecialValueFor("vision_radius") or 0
    if radius <= 0 then return end

    local team   = self.parent:GetTeamNumber()
    local origin = self.parent:GetAbsOrigin()

    local enemies = FindUnitsInRadius(
        team,
        origin,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER,
        false
    )

    local unseen_count = 0

    for _,enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsRealHero() and enemy:IsAlive() then
            if not enemy:CanEntityBeSeenByMyTeam(self.parent) then
                unseen_count = unseen_count + 1
            end
        end
    end

    if unseen_count <= 0 then return end

    local gold_gain = (self.gold_per_enemy or 0) * unseen_count
    local exp_gain  = (self.exp_per_enemy  or 0) * unseen_count

    if gold_gain <= 0 and exp_gain <= 0 then return end

    self.parent:ModifyGold(gold_gain, false, DOTA_ModifyGold_GameTick)
    self.parent:AddExperience(exp_gain, DOTA_ModifyXP_Unspecified, false, false)
end

function modifier_visitor_ability_facet_1:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_visitor_ability_facet_1:OnDeath(params)
    if not IsServer() then return end

    local parent = self.parent
    if not parent or parent:IsNull() then return end

    local victim   = params.unit
    local attacker = params.attacker

    if attacker ~= parent then return end
    if not victim or victim:IsNull() then return end
    if victim:GetTeamNumber() == parent:GetTeamNumber() then return end

    local bounty = victim:GetGoldBounty() or 0
    if bounty <= 0 then return end

    local playerID = parent:GetPlayerOwnerID()
    if playerID == nil or playerID == -1 then return end

    local current_gold = PlayerResource:GetGold(playerID)
    local remove = math.min(bounty, current_gold)

    if remove > 0 then
        PlayerResource:SpendGold(playerID, remove, 4)
    end
end