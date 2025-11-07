LinkLuaModifier("modifier_visitor_innate", "heroes/pale_visitor/visitor_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_screamer", "heroes/pale_visitor/visitor_innate", LUA_MODIFIER_MOTION_NONE)

visitor_innate = class({})

function visitor_innate:GetIntrinsicModifierName()
    return "modifier_visitor_innate"
end


modifier_visitor_innate = class({})

function modifier_visitor_innate:IsHidden() return true end
function modifier_visitor_innate:IsPurgable() return false end
function modifier_visitor_innate:RemoveOnDeath() return false end

function modifier_visitor_innate:OnCreated()
	if not IsServer() then return end
	GameRules:GetGameModeEntity():SetDaynightCycleAdvanceRate( 2.0 )
end

function modifier_visitor_innate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_visitor_innate:GetModifierPreAttack_BonusDamage()
	if not self:GetParent() or self:GetParent():PassivesDisabled() then
		return 0
	end

	local parent = self:GetParent()
	local str = parent:GetStrength()
	local agi = parent:GetAgility()
	local int = parent:GetIntellect(false)
	local total = str + agi + int

	return math.floor(total * self:GetAbility():GetSpecialValueFor("dmg_per_attr"))
end

function modifier_visitor_innate:OnDeath(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
	if not params.attacker or params.attacker:IsNull() then return end
	if params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
	local parent = self:GetParent()
	local killer = params.attacker
	if not killer:IsRealHero() then
		killer = killer:GetOwner()
	end
	killer:AddNewModifier(parent, self:GetAbility(), "modifier_visitor_screamer", {duration = 1})
end

modifier_visitor_screamer = class({})

function modifier_visitor_screamer:IsPurgable() return false end
function modifier_visitor_screamer:IsHidden() return true end

function modifier_visitor_screamer:OnCreated()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerOwnerID()
    if playerID ~= nil and playerID ~= -1 then
        local player = PlayerResource:GetPlayer(playerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "VisitorScreamerTrue", {})
		end
    end
end

function modifier_visitor_screamer:OnDestroy()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerOwnerID()
    if playerID ~= nil and playerID ~= -1 then
        local player = PlayerResource:GetPlayer(playerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "VisitorScreamerFalse", {})
        end
    end
end