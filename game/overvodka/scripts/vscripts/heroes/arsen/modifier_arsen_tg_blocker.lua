modifier_arsen_tg_blocker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_arsen_tg_blocker:IsHidden()
	return true
end

function modifier_arsen_tg_blocker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_arsen_tg_blocker:OnCreated( kv )
	if not IsServer() then return end

	if kv.model==1 then
		-- references
		self.fade_min = self:GetAbility():GetSpecialValueFor( "warrior_fade_min_dist" )
		self.fade_max = self:GetAbility():GetSpecialValueFor( "warrior_fade_max_dist" )
		self.gold = self:GetAbility():GetSpecialValueFor( "golt" )
		self.fade_range = self.fade_max-self.fade_min
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.origin = self.parent:GetOrigin()

		-- replace model for even soldiers
		self:GetParent():SetOriginalModel( "models/heroes/mars/mars_soldier.vmdl" )
		self:GetParent():SetRenderAlpha( 0 )
		self:GetParent().model = 1

		-- Start interval
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_arsen_tg_blocker:OnRefresh( kv )
end

function modifier_arsen_tg_blocker:OnRemoved()
end

function modifier_arsen_tg_blocker:OnDestroy()
	if not IsServer() then return end
	self:GetParent():ForceKill( false )
	-- UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_arsen_tg_blocker:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_arsen_tg_blocker:OnIntervalThink()
	local alpha = 0

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.origin,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.fade_max,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.origin,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.fade_max,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)
 	for i,unit in ipairs(units) do
 		k = 0
 		if not unit:IsIllusion() then
 			k = k + 1
 			if k % 3 ~= 0 then
        		self.caster:ModifyGold(self.gold, false, 0)
        	end
        end
    end
	-- find out distance between closest enemy
	if #enemies>0 then
		local enemy = enemies[1]
		local range = math.max( self.parent:GetRangeToUnit( enemy ), self.fade_min )
		range = math.min( range, self.fade_max )-self.fade_min
		alpha = self:Interpolate( range/self.fade_range, 255, 0 )
	end

	-- set alpha based on distance
	self.parent:SetRenderAlpha( alpha )
end

function modifier_arsen_tg_blocker:Interpolate( value, min, max )
	return value*(max-min) + min
end