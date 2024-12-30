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
	k = 0
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
	k = k + 1
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
	local ALL_TEAMS = {
    	DOTA_TEAM_CUSTOM_1,
    	DOTA_TEAM_CUSTOM_2,
    	DOTA_TEAM_CUSTOM_3,
    	DOTA_TEAM_CUSTOM_4,
    	DOTA_TEAM_CUSTOM_5,
    	DOTA_TEAM_CUSTOM_6,
    	DOTA_TEAM_CUSTOM_7,
    	DOTA_TEAM_CUSTOM_8,
    	DOTA_TEAM_GOODGUYS,
    	DOTA_TEAM_BADGUYS
	}
	local caster = self:GetParent()
    local caster_position = caster:GetAbsOrigin()
    if (k % 15 == 0) then
    	for _, team in ipairs(ALL_TEAMS) do
        	MinimapEvent(
            	team,                -- The team to broadcast the ping to
            	caster,              -- The entity causing the event
            	caster_position.x,   -- X-coordinate of the event
            	caster_position.y,   -- Y-coordinate of the event
            	DOTA_MINIMAP_EVENT_HINT_LOCATION, -- Mimics Alt + Right Click ping type
            	3                    -- Event duration in seconds
        	)
    	end
    end
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

function modifier_hamster:GetEffectName()
	return "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1_shard.vpcf"
end
function modifier_hamster:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end