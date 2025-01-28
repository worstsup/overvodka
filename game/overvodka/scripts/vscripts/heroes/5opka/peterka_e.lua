LinkLuaModifier("modifier_peterka_e_cast", "heroes/5opka/peterka_e", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_peterka_e_charge", "heroes/5opka/peterka_e", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_peterka_e_debuff", "heroes/5opka/peterka_e", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

peterka_e = class({})
function peterka_e:Precache(context)
	PrecacheResource("particle", "particles/peterka_chargeup.vpcf", context)
	PrecacheResource("particle", "particles/peterka_charge.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_range_finder.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/5opka_e.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/5opka_e_cast.vsndevts", context)
	PrecacheResource("model", "peterka/emelya.vmdl", context)
end
function peterka_e:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor( "chargeup_time" )
	local point = self:GetCursorPosition()
	
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_peterka_e_cast", { duration = duration } )
	
	local release_ability = self:GetCaster():FindAbilityByName( "peterka_e_release" )
	
	if release_ability then
		release_ability:UseResources( false, false, false, true )
	end

	EmitSoundOn("5opka_e", self:GetCaster())
end

function peterka_e:OnChargeFinish( interrupt, target )
	if not IsServer() then return end

	local caster = self:GetCaster()

	local max_duration = self:GetSpecialValueFor( "chargeup_time" )
	local max_distance = self:GetSpecialValueFor( "max_distance" )
	local speed = self:GetSpecialValueFor( "charge_speed" )

	local charge_duration = max_duration

	local mod = caster:FindModifierByName( "modifier_peterka_e_cast" )
	if mod then
		charge_duration = mod:GetElapsedTime()
		mod.charge_finish = true
		mod:Destroy()
	end
	local distance = max_distance * charge_duration/max_duration

	local duration = distance/speed

	if interrupt then
		return
	end

	caster:AddNewModifier( caster, self, "modifier_peterka_e_charge", { duration = duration } )
end

peterka_e_release = class({})

function peterka_e_release:IsStealable()
	return false
end

function peterka_e_release:OnSpellStart()
	local ability = self:GetCaster():FindAbilityByName("peterka_e")
	if ability then
		ability:OnChargeFinish( false )
	end
end

modifier_peterka_e_cast = class({})

function modifier_peterka_e_cast:IsPurgable()
	return false
end

function modifier_peterka_e_cast:OnCreated( kv )
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.max_time = self:GetAbility():GetSpecialValueFor( "chargeup_time" ) 

	if not IsServer() then return end
	self.anim_return = 0
	self.origin = self:GetParent():GetOrigin()
	self.charge_finish = false
	self.target_angle = self:GetParent():GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true

	self.time = (self:GetAbility():GetSpecialValueFor("max_distance") / self:GetAbility():GetSpecialValueFor( "charge_speed" ))

	self:StartIntervalThink( FrameTime() )
	
	self:PlayEffects1()
	self:PlayEffects2()

	self:GetCaster():SwapAbilities( "peterka_e", "peterka_e_release", false, true )
end

function modifier_peterka_e_cast:OnRemoved()
	if not IsServer() then return end

	self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	self:GetCaster():SwapAbilities( "peterka_e_release", "peterka_e", false, true )

	if not self.charge_finish then
		self:GetAbility():OnChargeFinish( false, self.target )
	end
end

function modifier_peterka_e_cast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function modifier_peterka_e_cast:GetModifierModelChange()
	return "peterka/emelya.vmdl"
end

function modifier_peterka_e_cast:OnOrder( params )
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
	elseif
		params.order_type==DOTA_UNIT_ORDER_STOP or 
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:GetAbility():OnChargeFinish( false, self.target )
	end	
end

function modifier_peterka_e_cast:SetDirection( location )
	local dir = ((location-self:GetParent():GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_peterka_e_cast:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_peterka_e_cast:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

function modifier_peterka_e_cast:OnIntervalThink()
	if IsServer() then
		self.anim_return = self.anim_return + FrameTime()
		if self.anim_return >= 1 then
			self.anim_return = 0
			self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
		end
	end

	if self.target and self.target:IsAlive() then 
		self:SetDirection(self.target:GetAbsOrigin())
	end

	if self:GetParent():IsRooted() or self:GetParent():IsStunned() or self:GetParent():IsSilenced() or
		self:GetParent():IsCurrentlyHorizontalMotionControlled() or self:GetParent():IsCurrentlyVerticalMotionControlled()
	then
		self:GetAbility():OnChargeFinish( true, self.target )
	end

	self:TurnLogic( FrameTime() )
	self:SetEffects()
end

function modifier_peterka_e_cast:TurnLogic( dt )
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

	local angles = self:GetParent():GetAnglesAsVector()
	self:GetParent():SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_peterka_e_cast:PlayEffects1()
	self.effect_cast = ParticleManager:CreateParticleForPlayer( "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_range_finder.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner() )
	
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	
	self:AddParticle( self.effect_cast, false, false, -1, false, false )
	
	self:SetEffects()
end

function modifier_peterka_e_cast:SetEffects()
	local time = self:GetElapsedTime()

	local k =  time/self.max_time

	local speed_time = k*self.time
	
	local target_pos = self.origin + self:GetParent():GetForwardVector() * self.speed * speed_time

	ParticleManager:SetParticleControl( self.effect_cast, 1, target_pos )
end

function modifier_peterka_e_cast:PlayEffects2()
	local effect_cast = ParticleManager:CreateParticle( "particles/peterka_chargeup.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false )
end

modifier_peterka_e_charge = class({})

function modifier_peterka_e_charge:IsPurgable()
	return false
end

function modifier_peterka_e_charge:CheckState()
	local state = 
	{
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_DEBUFF_IMMUNE] = self.debuff_immune
	}
	return state
end

function modifier_peterka_e_charge:OnCreated( kv )

	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )

	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )

	self.radius = self:GetAbility():GetSpecialValueFor( "knockback_radius" )

	self.distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )

	self.duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )

	self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.debuff_immune = false
	if self:GetAbility():GetSpecialValueFor("debuff_immune") == 1 then
		self.debuff_immune = true
	end
	local damage = self:GetAbility():GetSpecialValueFor( "knockback_damage" )
	EmitSoundOn("5opka_e_cast", self:GetParent())
	self.tree_radius = 100
	self.height = 50
	self.duration = 0.3

	if not IsServer() then return end

	self.damage = damage

	self.target_angle = self:GetParent():GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	self.knockback_units = {}
	self.knockback_units[self:GetParent()] = true

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

	self.distance_pass = 0

	self.damageTable = { attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() }
end

function modifier_peterka_e_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

function modifier_peterka_e_charge:GetModifierModelChange()
	return "peterka/emelya.vmdl"
end

function modifier_peterka_e_charge:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		self:SetDirection( params.new_pos )
	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( params.target:GetOrigin() )
	elseif
		params.order_type==DOTA_UNIT_ORDER_STOP or 
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET or
		params.order_type==DOTA_UNIT_ORDER_CAST_POSITION or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
	end	
end

function modifier_peterka_e_charge:GetModifierDisableTurning()
	return 1
end

function modifier_peterka_e_charge:SetDirection( location )
	local dir = ((location-self:GetParent():GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_peterka_e_charge:TurnLogic( dt )
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

	local angles = self:GetParent():GetAnglesAsVector()
	self:GetParent():SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_peterka_e_charge:HitLogic()
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree_radius, false )
	
	local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )

	for _,unit in pairs(units) do
		if not self.knockback_units[unit] then
			self.knockback_units[unit] = true
			self:PlayEffects( unit, self.radius )
		end
	end
end

function modifier_peterka_e_charge:UpdateHorizontalMotion( me, dt )
	if self:GetParent():IsRooted() or self:GetParent():IsStunned() or self:GetParent():IsHexed() or self:GetParent():IsFeared() then
		self:Destroy()
	end

	self:HitLogic()
	self:TurnLogic( dt )
	local nextpos = me:GetOrigin() + me:GetForwardVector() * self.speed * dt
	me:SetOrigin(nextpos)
end

function modifier_peterka_e_charge:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_peterka_e_charge:GetEffectName()
	return "particles/peterka_charge.vpcf"
end

function modifier_peterka_e_charge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_peterka_e_charge:PlayEffects( target, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	target:EmitSound("Hero_PrimalBeast.Onslaught.Hit")
end

function modifier_peterka_e_charge:OnDestroy()
	if not IsServer() then return end

	self:GetParent():RemoveHorizontalMotionController(self)
	FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetOrigin(), false )
end

function modifier_peterka_e_charge:IsAura()
	return true
end

function modifier_peterka_e_charge:GetModifierAura()
	return "modifier_peterka_e_debuff"
end

function modifier_peterka_e_charge:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("knockback_radius")
end

function modifier_peterka_e_charge:GetAuraDuration()
	return 0.1
end

function modifier_peterka_e_charge:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_peterka_e_charge:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_peterka_e_charge:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES 
end

function modifier_peterka_e_charge:GetAuraEntityReject(target)
	return false
end

modifier_peterka_e_debuff = class({})

function modifier_peterka_e_debuff:IsPurgable()
	return false
end

function modifier_peterka_e_debuff:OnCreated( kv )
	if not IsServer() then return end
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end
end

function modifier_peterka_e_debuff:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	if self:GetParent():IsDebuffImmune() or self:GetParent():IsMagicImmune() then return end
	local damage = self:GetAbility():GetSpecialValueFor("knockback_damage")
	ApplyDamage({ attacker = self:GetCaster(), victim = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
	self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_generic_stunned_lua", { duration = self:GetAbility():GetSpecialValueFor("stun_duration") } )
end

function modifier_peterka_e_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_peterka_e_debuff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_peterka_e_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_peterka_e_debuff:UpdateHorizontalMotion( me, dt )
	local caster = self:GetCaster()
	local target = caster:GetOrigin() + caster:GetForwardVector() * 190

	me:SetOrigin( target )
end

function modifier_peterka_e_debuff:OnHorizontalMotionInterrupted()
	self:Destroy()
end
