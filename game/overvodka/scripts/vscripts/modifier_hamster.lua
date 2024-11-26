modifier_hamster = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_hamster:IsHidden()
	return true
end

function modifier_hamster:IsDebuff()
	return false
end

function modifier_hamster:IsStunDebuff()
	return false
end

function modifier_hamster:IsPurgable()
	return false
end

-- Initializations
function modifier_hamster:OnCreated( kv )
	-- load data
	self.gold = 100
	self:StartIntervalThink( 0.2 )
end

function modifier_hamster:OnRefresh( kv )
	-- references
	self.gold = 100
end
function modifier_hamster:OnRemoved()
end

function modifier_hamster:OnDestroy()
end

function modifier_hamster:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		AddFOWViewer( enemy:GetTeamNumber(), self:GetParent():GetOrigin(), 400, 1, false )
	end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_hamster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_hamster:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_hamster:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end
	if params.attacker:IsRealHero() and params.attacker:IsIllusion() == false then
		params.attacker:ModifyGold( self.gold, true, 0 )
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, params.attacker, self.gold, nil)
	end
end