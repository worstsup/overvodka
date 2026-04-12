LinkLuaModifier( "modifier_golovach_q", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_q_buff", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_hidden", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_golovach_slow", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golovach_q_crit_next", "heroes/golovach/golovach_q", LUA_MODIFIER_MOTION_NONE )

golovach_q = class({})

function golovach_q:Precache(ctx)
	PrecacheResource( "particle", "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf", ctx )
	PrecacheResource( "particle", "particles/dark_seer_punch_glove_attack_new.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_target.vpcf", ctx )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", ctx )
end

function golovach_q:GetIntrinsicModifierName()
	return "modifier_golovach_q"
end

modifier_golovach_q = class({})

function modifier_golovach_q:IsHidden() return true end
function modifier_golovach_q:IsDebuff() return false end
function modifier_golovach_q:IsPurgable() return false end

function modifier_golovach_q:OnCreated()
	self.chance = self:GetAbility():GetSpecialValueFor( "percent" )
	self.cast_range = self:GetAbility():GetSpecialValueFor( "cast_range" )
	self.kick_distance = self:GetAbility():GetSpecialValueFor( "unit_distance" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.angle_back = self:GetAbility():GetSpecialValueFor( "back_angle" )
end

function modifier_golovach_q:OnRefresh()
	self.chance = self:GetAbility():GetSpecialValueFor( "percent" )
	self.cast_range = self:GetAbility():GetSpecialValueFor( "cast_range" )
	self.kick_distance = self:GetAbility():GetSpecialValueFor( "unit_distance" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.angle_back = self:GetAbility():GetSpecialValueFor( "back_angle" )
end

function modifier_golovach_q:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_golovach_q:OnAttackLanded( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) and params.attacker then
		if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
		if params.attacker:IsBuilding() or params.attacker:IsOther() then return end
		if params.attacker == self:GetParent() then return end
		if params.target ~= self:GetParent() then return end
		if params.target:IsIllusion() or not params.target:IsAlive() then return end
		local parent = self:GetParent()
		local attacker = params.attacker
		local facing_direction = parent:GetAnglesAsVector().y
		local vec = attacker:GetAbsOrigin() - parent:GetAbsOrigin()
		local attacker_vector = vec:Normalized()
		local attacker_direction = VectorToAngles( attacker_vector ).y
		local angle_diff = AngleDiff( facing_direction, attacker_direction )
		angle_diff = math.abs(angle_diff)
		if angle_diff > (180-self.angle_back) and vec:Length2D() <= self.cast_range then
			self:ThresholdLogic( params.damage, params.attacker )
			self:PlayEffects( true, attacker_vector )
		end
	end
end

function modifier_golovach_q:ThresholdLogic( damage, target )
	local random_chance = RandomInt(1, 100)
	if damage > 0 and random_chance <= self.chance then
		self:GetAbility():UseResources( false, false, false, true )
		EmitSoundOn( "golovach_q", self:GetCaster() )
		self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_golovach_q_crit_next", { duration = 0.1, mult = self.damage } )
		self:GetCaster():PerformAttack( target, true, true, true, true, false, false, true )
		self:Kick( target, target:GetAbsOrigin().x-self:GetParent():GetAbsOrigin().x, target:GetAbsOrigin().y-self:GetParent():GetAbsOrigin().y )
		self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_golovach_q_buff", { duration = self.slow_duration } )
	end
end

function modifier_golovach_q:Kick( target, x, y )
	self:PlayEffects1( target )
	target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_golovach_hidden", { x = x, y = y, r = self.kick_distance } )
	target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_golovach_slow", { duration = self.slow_duration } )
	self:PlayEffects2( target, Vector(x,y,0):Normalized(), self.kick_distance/self:GetAbility():GetSpecialValueFor("speed") )
end

function modifier_golovach_q:PlayEffects( bBack, direction )
	local effect_cast = nil
	if bBack then
		effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		EmitSoundOn( "Hero_Bristleback.Bristleback", self:GetParent() )
	else
		effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
	end
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_golovach_q:PlayEffects1( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/dark_seer_punch_glove_attack_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "golovach_punch", self:GetCaster() )
end

function modifier_golovach_q:PlayEffects2( target, direction, duration )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Target", target )
end


modifier_golovach_hidden = class({})

function modifier_golovach_hidden:IsHidden() return true end
function modifier_golovach_hidden:IsDebuff() return true end
function modifier_golovach_hidden:IsStunDebuff() return false end
function modifier_golovach_hidden:IsPurgable() return false end

function modifier_golovach_hidden:OnCreated( kv )
	if IsServer() then
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
		self.origin = self:GetParent():GetAbsOrigin()
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_golovach_hidden:OnDestroy( kv )
	if IsServer() then
		if not self:GetParent() or self:GetParent():IsNull() then return end
		self:GetParent():InterruptMotionControllers( true )
		if self:GetParent():IsAlive() and not self:GetParent():IsOutOfGame() then
			FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		end
	end
end

function modifier_golovach_hidden:UpdateHorizontalMotion( me, dt )
	local pos = self:GetParent():GetAbsOrigin()
	if (pos-self.origin):Length2D()>=self.distance then
		self:Destroy()
		return
	end
	local target = pos + self.direction * (self.speed*dt)
	self:GetParent():SetAbsOrigin( target )
end

function modifier_golovach_hidden:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_golovach_hidden:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_golovach_hidden:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end


modifier_golovach_q_buff = class({})

function modifier_golovach_q_buff:OnCreated()
	self.reduction = self:GetAbility():GetSpecialValueFor( "damage_reduction_pct" )
end

function modifier_golovach_q_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_golovach_q_buff:GetModifierIncomingDamage_Percentage()
	return -self.reduction
end


modifier_golovach_slow = class({})

function modifier_golovach_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_golovach_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_golovach_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end


modifier_golovach_q_crit_next = class({})

function modifier_golovach_q_crit_next:IsHidden() return true end
function modifier_golovach_q_crit_next:IsPurgable() return false end

function modifier_golovach_q_crit_next:OnCreated( kv )
    self.mult = tonumber(kv and kv.mult) or 100
end

function modifier_golovach_q_crit_next:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_CANCELLED,
    }
end

function modifier_golovach_q_crit_next:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return end
    if not params or params.attacker ~= self:GetParent() then return end
    return self.mult
end

function modifier_golovach_q_crit_next:TryConsume(params)
    if not IsServer() then return end
    if params and params.attacker == self:GetParent() then
        self:Destroy()
    end
end

function modifier_golovach_q_crit_next:OnAttackLanded(params)    self:TryConsume(params) end
function modifier_golovach_q_crit_next:OnAttackFail(params)      self:TryConsume(params) end
function modifier_golovach_q_crit_next:OnAttackCancelled(params) self:TryConsume(params) end