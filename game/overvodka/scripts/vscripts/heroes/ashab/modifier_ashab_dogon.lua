modifier_ashab_dogon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ashab_dogon:IsHidden()
	return false
end

function modifier_ashab_dogon:IsDebuff()
	return false
end

function modifier_ashab_dogon:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ashab_dogon:OnCreated( kv )
	self.parent = self:GetParent()

	-- references
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed" )
	self.radius = self:GetAbility():GetSpecialValueFor( "bash_radius" )
	self.duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.magresist_duration = self:GetAbility():GetSpecialValueFor( "magresist_duration" )

	if not IsServer() then return end

	self.target = EntIndexToHScript( kv.target )
	self.direction = self:GetParent():GetForwardVector()
	self.targets = {}

	self.search_radius = 4000
	self.tree_radius = 150
	self.min_dist = 150
	self.offset = 20
	self.interrupted = false

	-- check ability
	self.mod = self.parent:FindModifierByName( "modifier_spirit_breaker_greater_bash_lua" )
	if self.mod and self.mod:GetAbility():GetLevel()<1 then
		self.mod = nil
	end

	if not self:ApplyHorizontalMotionController() then
		self.interrupted = true
		self:Destroy()
	end

	-- set target
	self:SetTarget( self.target )

	-- set ability as inactive
	self:GetAbility():SetActivated( false )

	-- play effects
	local sound_cast = "dogon"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function modifier_ashab_dogon:OnRefresh( kv )
	
end

function modifier_ashab_dogon:OnRemoved()
end

function modifier_ashab_dogon:OnDestroy()
	if not IsServer() then return end

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree_radius, true )

	self:GetParent():RemoveHorizontalMotionController( self )

	-- remove debuff
	if self.debuff and (not self.debuff:IsNull()) then
		self.debuff:Destroy()
	end

	-- set ability as inactive
	self:GetAbility():SetActivated( true )

	-- start cooldown
	self:GetAbility():UseResources( false, false, false, true )


	if self.interrupted then return end
	
	-- bash
	if self.mod and (not self.mod:IsNull()) then
		self.mod:Bash( self.target, false )
	end
	self.parent:AddNewModifier(
		self.parent, -- player source
		self:GetAbility(), -- ability source
		"modifier_magresist", -- modifier name
		{ duration = self.magresist_duration } -- kv
	)
	-- stun enemy
	self.target:AddNewModifier(
		self.parent, -- player source
		self:GetAbility(), -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = self.duration } -- kv
	)
	ApplyDamage({attacker = self:GetParent(), victim = self.target, ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
	-- set attack target
	if self.target:IsAlive() then
		-- command to attack target
		local order = {
			UnitIndex = self.parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self.target:entindex(),
		}
		ExecuteOrderFromTable( order )
		-- self.parent:SetAttacking( self.target )
	end

	-- play effects
	local sound_cast = "razgrom"
	local particle_cast = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.target )
	EmitSoundOn( sound_cast, self.target )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ashab_dogon:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_ashab_dogon:GetOverrideAnimation()
	return ACT_DOTA_POOF_END
end 

function modifier_ashab_dogon:OnOrder( params )
	if params.unit~=self.parent then return end

	-- TODO: check more orders

	if
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET or
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION or
		params.order_type==DOTA_UNIT_ORDER_CAST_POSITION or
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET or
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET_TREE or
		params.order_type==DOTA_UNIT_ORDER_CAST_RUNE or
		params.order_type==DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION
	then
		self.interrupted = true
		EmitSoundOn( "ashab_oi", self.parent)
		self:Destroy()
	end
end

function modifier_ashab_dogon:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_ashab_dogon:GetModifierIgnoreMovespeedLimit()
	return 1
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_ashab_dogon:UpdateHorizontalMotion( me, dt )
	-- bash logic
	self:BashLogic()

	-- cancel logic
	self:CancelLogic()

	-- get direction
	local direction = self.target:GetOrigin()-me:GetOrigin()
	local dist = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- check if near
	if dist<self.min_dist then
		self:Destroy()
		return
	end

	-- set target pos
	local pos = me:GetOrigin() + direction * me:GetIdealSpeed() * dt
	pos = GetGroundPosition( pos, me )

	me:SetOrigin( pos )
	self.direction = direction

	-- face towards
	self.parent:FaceTowards( self.target:GetOrigin() )
end

function modifier_ashab_dogon:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Helper
function modifier_ashab_dogon:BashLogic()
	-- check modifier
	if (not self.mod) or self.mod:IsNull() then return end

	local loc = self.parent:GetOrigin() + self.direction * self.offset

	-- find units
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		loc,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		if not self.targets[enemy] then
			self.targets[enemy] = true

			-- apply bash
			self.mod:Bash( enemy, 0, false )
		end
	end
end

function modifier_ashab_dogon:CancelLogic()
	-- check stun
	local check = self.parent:IsHexed() or self.parent:IsStunned() or self.parent:IsRooted()
	if check then
		EmitSoundOn( "ashab_oi", self.parent)
		self.interrupted = true
		self:Destroy()
	end

	-- check if target is dead
	if not self.target:IsAlive() then
		-- find another valid target
		local enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(),	-- int, your team number
			self.target:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.search_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
			FIND_CLOSEST,	-- int, order filter
			false	-- bool, can grow cache
		)

		if #enemies<1 then
			self.interrupted = true
			self:Destroy()
			return
		else
			self:SetTarget( enemies[1] )
		end
	end
end

function modifier_ashab_dogon:SetTarget( target )
	-- reset previous
	if self.debuff and (not self.debuff:IsNull()) then
		self.debuff:Destroy()
	end

	-- add charge indicator
	self.debuff = target:AddNewModifier(
		self.parent, -- player source
		self:GetAbility(), -- ability source
		"modifier_ashab_dogon_debuff", -- modifier name
		{} -- kv
	)

	self.target = target

	-- target gets bashed last
	self.targets[target] = true
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ashab_dogon:GetEffectName()
	return "particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_mesh.vpcf"
end



function modifier_ashab_dogon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end