modifier_papich_e = class({})

function modifier_papich_e:IsHidden()
	return false
end

function modifier_papich_e:IsDebuff()
	return false
end

function modifier_papich_e:IsPurgable()
	return false
end

function modifier_papich_e:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.dir = self.parent:GetForwardVector():Normalized()
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.gold = self:GetAbility():GetSpecialValueFor( "gold" )
	self.radius = self:GetAbility():GetSpecialValueFor( "knockback_radius" )
	self.distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )
	self.duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )
	self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.bkb = self:GetAbility():GetSpecialValueFor( "bkb_duration" )
	local damage = self:GetAbility():GetSpecialValueFor( "knockback_damage" )
	self.point = 0
	self.poss = self:GetParent():GetAbsOrigin()
	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == self.parent:GetTeamNumber() then
			self.point = fountainEnt:GetAbsOrigin()
			break
		end
    end
	self:SetDirection( self.point )
    self.k = 0
	self.tree_radius = 240
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
	EmitSoundOn( "papich_e_plane", self:GetCaster() )
	EmitSoundOn( "papich_e_fly", self:GetCaster() )
	self.damageTable = {
		attacker = self.parent,
		damage = damage,
		damage_type = self.abilityDamageType,
		ability = self.ability,
	}
end

function modifier_papich_e:OnRefresh( kv )
end

function modifier_papich_e:OnRemoved()
end

function modifier_papich_e:OnDestroy()
	if not IsServer() then return end
	StopSoundOn( "papich_e_plane", self:GetCaster() )
	StopSoundOn( "papich_e_fly", self:GetCaster() )
	self.parent:RemoveHorizontalMotionController(self)
	self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_3_END)
	FindClearSpaceForUnit( self.parent, self.parent:GetOrigin(), false )
end

function modifier_papich_e:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end
function modifier_papich_e:GetMinHealth()
    return 1
end
function modifier_papich_e:OnOrder( params )
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
function modifier_papich_e:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end
function modifier_papich_e:GetModifierDisableTurning()
	return 1
end

function modifier_papich_e:SetDirection( location )
	local dir = ((location-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_papich_e:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_papich_e:GetActivityTranslationModifiers()
	return "onslaught_movement"
end

function modifier_papich_e:GetModifierModelChange()
	return "arthas/jet.vmdl"
end

function modifier_papich_e:GetModifierModelScale()
	return 0
end

function modifier_papich_e:OnIntervalThink()
end

function modifier_papich_e:TurnLogic( dt )
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

function modifier_papich_e:HitLogic()
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
	end
end

function modifier_papich_e:UpdateHorizontalMotion( me, dt )
	if self.parent:IsRooted() then
		self:Destroy()
		return
	end
	local distance = (self.point - self:GetParent():GetAbsOrigin()):Length2D()
	if distance < 750 then
		self.speed = 100
	else
		self.speed = 1600
		if GetMapName() == "dota" then
			self.speed = 2000
		end
	end
	if distance < 500 or (GetMapName() ~= "dota" and distance > 11000) or (GetMapName() == "dota" and distance > 20000) then
		if self.k == 0 then
			self:GetCaster():ModifyGold(self.gold, false, 0)
			EmitSoundOn( "papich_e_plane_start", self:GetCaster() )
			self:GetCaster():AddNewModifier(
				self.parent,
				self.ability,
				"modifier_papich_e_heal",
				{ duration = 4 }
			)
		end
		self:SetDirection( self.poss )
		self.k = self.k + 1
		self.speed = 70
	end
	local distance2 = (self.poss - self:GetParent():GetAbsOrigin()):Length2D()
	if distance2 < 300 and self.k >= 1 then
		EmitSoundOn( "papich_e_end", self:GetCaster() )
		self:GetCaster():AddNewModifier(
			self.parent,
			self.ability,
			"modifier_papich_bkb",
			{ duration = self.bkb }
		)
		self:Destroy()
	end
	self:HitLogic()
	self:TurnLogic( dt )
	local nextpos = me:GetOrigin() + me:GetForwardVector() * self.speed * dt
	me:SetOrigin(nextpos)
end

function modifier_papich_e:OnHorizontalMotionInterrupted()
	self:Destroy()
end
