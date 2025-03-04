macan_r = class({})
macan_r_release = class({})
LinkLuaModifier( "modifier_macan_r_charge", "heroes/macan/macan_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_macan_r", "heroes/macan/macan_r", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function macan_r:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_charge_active.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_chargeup.vpcf", context )
	PrecacheResource( "particle", "particles/primal_beast_onslaught_range_finder_new.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/zavod.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/ezda.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/macan_r.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/macan_r_gay.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/glox.vsndevts", context )
end

function macan_r:Spawn()
	if not IsServer() then return end
end

function macan_r:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor( "chargeup_time" )
	local mod = caster:AddNewModifier(
		caster,
		self,
		"modifier_macan_r_charge",
		{ duration = duration }
	)
	self.sub = caster:FindAbilityByName( "macan_r_release" )
	if not self.sub or self.sub:IsNull() then
		self.sub = caster:AddAbility( "macan_r_release" )
	end
	self.sub.main = self
	self.sub:SetLevel( self:GetLevel() )

	caster:SwapAbilities(
		self:GetAbilityName(),
		self.sub:GetAbilityName(),
		false,
		true
	)
	self.sub:UseResources( false, false, false, true )
end

function macan_r:OnChargeFinish( interrupt )
	local caster = self:GetCaster()
	caster:SwapAbilities(
		self:GetAbilityName(),
		self.sub:GetAbilityName(),
		true,
		false
	)
	local max_duration = self:GetSpecialValueFor( "chargeup_time" )
	local max_distance = self:GetSpecialValueFor( "max_distance" )
	local speed = self:GetSpecialValueFor( "charge_speed" )
	local charge_duration = max_duration
	local mod = caster:FindModifierByName( "modifier_macan_r_charge" )
	if mod then
		charge_duration = mod:GetElapsedTime()

		mod.charge_finish = true
		mod:Destroy()
	end

	local distance = max_distance * charge_duration/max_duration
	local duration = distance/speed
	if interrupt then return end
	caster:AddNewModifier(
		caster,
		self,
		"modifier_macan_r",
		{ duration = duration }
	)
end

function macan_r_release:OnSpellStart()
	self.main:OnChargeFinish( false )
end

modifier_macan_r = class({})

function modifier_macan_r:IsHidden()
	return false
end

function modifier_macan_r:IsDebuff()
	return false
end

function modifier_macan_r:IsPurgable()
	return false
end

function modifier_macan_r:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )

	self.radius = self:GetAbility():GetSpecialValueFor( "knockback_radius" )
	self.distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )
	self.duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )
	self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	local damage = self:GetAbility():GetSpecialValueFor( "knockback_damage" )

	self.tree_radius = 120
	self.height = 50
	self.duration = 0.3

	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	self.knockback_units = {}
	self.knockback_units[self.parent] = true
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end
	EmitSoundOn( "ezda", self:GetCaster() )
	EmitSoundOn( "macan_r_gay", self:GetCaster() )
	self.damageTable = {
		attacker = self.parent,
		damage = damage,
		damage_type = self.abilityDamageType,
		ability = self.ability,
	}
end

function modifier_macan_r:OnRefresh( kv )
end

function modifier_macan_r:OnRemoved()
end

function modifier_macan_r:OnDestroy()
	if not IsServer() then return end
	StopSoundOn( "ezda", self:GetCaster() )
	StopSoundOn( "macan_r_gay", self:GetCaster() )
	EmitSoundOn( "glox", self:GetCaster() )
	self.parent:RemoveHorizontalMotionController(self)
	FindClearSpaceForUnit( self.parent, self.parent:GetOrigin(), false )
end

function modifier_macan_r:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

function modifier_macan_r:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		ExecuteOrderFromTable({
			UnitIndex = self.parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION,
			Position = params.new_pos,
		})
	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( params.target:GetOrigin() )
	end	
end
function modifier_macan_r:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end
function modifier_macan_r:GetModifierDisableTurning()
	return 1
end

function modifier_macan_r:SetDirection( location )
	local dir = ((location-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_macan_r:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_macan_r:GetActivityTranslationModifiers()
	return "onslaught_movement"
end

function modifier_macan_r:GetModifierModelChange()
	return "bmw/models/heroes/bm/bmwe90.vmdl"
end

function modifier_macan_r:GetModifierModelScale()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_axe" then
		local Talent = self:GetCaster():FindAbilityByName("special_bonus_unique_axe")
		if Talent:GetLevel() == 1 then
			return -25
		end
	end
	return -50
end

function modifier_macan_r:OnIntervalThink()
end

function modifier_macan_r:TurnLogic( dt )
	if self.face_target then return end
	local angle_diff = AngleDiff( self.current_angle, self.target_angle )
	local turn_speed = self.turn_speed*dt
	local sign = -1
	if angle_diff<0 then sign = 1 end
	if math.abs( angle_diff )<1.1*turn_speed then
		self.current_angle = self.target_angle
		self.face_target = true
	else
		self.current_angle = self.current_angle + sign*turn_speed
	end
	local angles = self.parent:GetAnglesAsVector()
	self.parent:SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_macan_r:HitLogic()
	GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), self.tree_radius, false )
	local units = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		self.abilityTargetType,
		self.abilityTargetFlags,
		0,
		false
	)

	for _,unit in pairs(units) do
		self.knockback_units[unit] = true
		local is_enemy = unit:GetTeamNumber()~=self.parent:GetTeamNumber()
		if is_enemy then
			local enemy = unit
			self.damageTable.victim = enemy
			ApplyDamage(self.damageTable)
			enemy:AddNewModifier(
				self.parent,
				self.ability,
				"modifier_generic_stunned_lua",
				{ duration = self.stun }
			)
		end
		if is_enemy or not (unit:IsCurrentlyHorizontalMotionControlled() or unit:IsCurrentlyVerticalMotionControlled()) then
			local direction = unit:GetOrigin()-self.parent:GetOrigin()
			direction.z = 0
			direction = direction:Normalized()
			unit:AddNewModifier(
				self.parent,
				self.ability,
				"modifier_generic_arc_lua",
				{
					dir_x = direction.x,
					dir_y = direction.y,
					duration = self.duration,
					distance = self.distance,
					height = self.height,
					activity = ACT_DOTA_FLAIL,
				}
			)
		end
		self:PlayEffects( unit, self.radius )
	end
end

function modifier_macan_r:UpdateHorizontalMotion( me, dt )
	if self.parent:IsRooted() then
		self:Destroy()
		return
	end
	self:HitLogic()
	self:TurnLogic( dt )
	local nextpos = me:GetOrigin() + me:GetForwardVector() * self.speed * dt
	me:SetOrigin(nextpos)
end

function modifier_macan_r:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_macan_r:GetEffectName()
	return "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_charge_active.vpcf"
end

function modifier_macan_r:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_macan_r:PlayEffects( target, radius )
	local particle_cast = "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_macan_r_charge = class({})

function modifier_macan_r_charge:IsHidden()
	return false
end

function modifier_macan_r_charge:IsDebuff()
	return false
end

function modifier_macan_r_charge:IsPurgable()
	return false
end

function modifier_macan_r_charge:OnCreated( kv )
	self.parent = self:GetParent()
	self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
	self.ability = self:GetAbility()
	local sound_cast = "zavod"
	EmitSoundOn( sound_cast, self.parent )
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	if not IsServer() then return end
	self.origin = self.parent:GetOrigin()
	self.charge_finish = false
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	self:StartIntervalThink( FrameTime() )
	self.filter = FilterManager:AddExecuteOrderFilter( self.OrderFilter, self )
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_macan_r_charge:OnRefresh( kv )
end

function modifier_macan_r_charge:OnRemoved()
	if not IsServer() then return end
	if not self.charge_finish then
		self.ability:OnChargeFinish( false )
	end
	FilterManager:RemoveExecuteOrderFilter( self.filter )
end

function modifier_macan_r_charge:OnDestroy()
end

function modifier_macan_r_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_macan_r_charge:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( params.target:GetOrigin() )
	end	
end

function modifier_macan_r_charge:SetDirection( location )
	local dir = ((location-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_macan_r_charge:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_macan_r_charge:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
function modifier_macan_r_charge:OrderFilter( data )
	if data.order_type~=DOTA_UNIT_ORDER_MOVE_TO_POSITION and
		data.order_type~=DOTA_UNIT_ORDER_MOVE_TO_TARGET and
		data.order_type~=DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		return true
	end
	local found = false
	for _,entindex in pairs(data.units) do
		local entunit = EntIndexToHScript( entindex )
		if entunit==self.parent then
			found = true
		end
	end
	if not found then return true end
	data.order_type = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	if data.entindex_target~=0 then
		local pos = EntIndexToHScript( data.entindex_target ):GetOrigin()
		data.position_x = pos.x
		data.position_y = pos.y
		data.position_z = pos.z
	end

	return true
end

function modifier_macan_r_charge:OnIntervalThink()
	if self.parent:IsRooted() or self.parent:IsStunned() or self.parent:IsSilenced() or
		self.parent:IsCurrentlyHorizontalMotionControlled() or self.parent:IsCurrentlyVerticalMotionControlled()
	then
		self.ability:OnChargeFinish( true )
	end
	self:TurnLogic( FrameTime() )
	self:SetEffects()
end

function modifier_macan_r_charge:TurnLogic( dt )
	if self.face_target then return end

	local angle_diff = AngleDiff( self.current_angle, self.target_angle )
	local turn_speed = self.turn_speed*dt

	local sign = -1
	if angle_diff<0 then sign = 1 end

	if math.abs( angle_diff )<1.1*turn_speed then
		self.current_angle = self.target_angle
		self.face_target = true
	else
		self.current_angle = self.current_angle + sign*turn_speed
	end

	local angles = self.parent:GetAnglesAsVector()
	self.parent:SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_macan_r_charge:PlayEffects1()
	local particle_cast = "particles/primal_beast_onslaught_range_finder_new.vpcf"
	local effect_cast = ParticleManager:CreateParticleForPlayer( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetPlayerOwner() )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	self.effect_cast = effect_cast
	self:SetEffects()
end

function modifier_macan_r_charge:SetEffects()
	local target_pos = self.origin + self.parent:GetForwardVector() * self.speed * self:GetElapsedTime()
	ParticleManager:SetParticleControl( self.effect_cast, 1, target_pos )
end

function modifier_macan_r_charge:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_chargeup.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end