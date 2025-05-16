LinkLuaModifier("modifier_invincible_w", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_invincible_w_debuff", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_w_end", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_w_start", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_invincible_w_visual", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_generic_knockback_invincible_knockback_cooldown", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_invincible_w_buff_attack_speed", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_w_buff_attack", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invincible_w_creep_damage", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_invincible", "heroes/invincible/invincible_w", LUA_MODIFIER_MOTION_BOTH)

invincible_w = class({})

function invincible_w:Precache(context)
    PrecacheResource( "particle", 'particles/sxssss/drow_banshee_wail_parent.vpcf', context )
    PrecacheResource( "particle", 'particles/sxssss/drow_banshee_wail_explosion.vpcf', context )
    PrecacheResource( "soundfile", "soundevents/invincible_w.vsndevts", context)
end

function invincible_w:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():StartGesture(ACT_DOTA_POOF_END)
    EmitSoundOn("invincible_w_start", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invincible_w_start", {duration = 0.8})

    local direction = self:GetCaster():GetForwardVector() * -1
    local knockback = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_invincible", { direction_x = direction.x, direction_y = direction.y, distance = 150, height = 20, duration = 0.35 })

    local callback = function( bInterrupted )
        Timers:CreateTimer(FrameTime(), function()
            self:GetCaster():StartGesture(ACT_DOTA_POOF_END)
            local direction_f = self:GetCaster():GetForwardVector()
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_invincible", { direction_x = direction_f.x, direction_y = direction_f.y, distance = 380, height = 50, duration = 0.35, check_target = 1 })
        end)
    end

    knockback:SetEndCallback( callback )
end

modifier_invincible_w_start = class({})
function modifier_invincible_w_start:IsPurgable() return false end
function modifier_invincible_w_start:IsHidden() return true end
function modifier_invincible_w_start:OnCreated()
    if not IsServer() then return end
    local invincible_q = self:GetCaster():FindAbilityByName("invincible_q")
    if invincible_q then
        invincible_q:SetActivated(false)
    end
    local invincible_w = self:GetCaster():FindAbilityByName("invincible_w")
    if invincible_w then
        invincible_w:SetActivated(false)
    end
    local invincible_e = self:GetCaster():FindAbilityByName("invincible_e")
    if invincible_e then
        invincible_e:SetActivated(false)
    end
    local invincible_r = self:GetCaster():FindAbilityByName("invincible_r")
    if invincible_r then
        invincible_r:SetActivated(false)
    end
    self.interrupt = false
end

function modifier_invincible_w_start:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
end

function modifier_invincible_w_start:GetModifierDisableTurning( params )
	return 1
end

function modifier_invincible_w_start:OnDestroy()
    if not IsServer() then return end
    local invincible_q = self:GetCaster():FindAbilityByName("invincible_q")
    if invincible_q then
        invincible_q:SetActivated(true)
    end
    local invincible_w = self:GetCaster():FindAbilityByName("invincible_w")
    if invincible_w then
        invincible_w:SetActivated(true)
    end
    local invincible_e = self:GetCaster():FindAbilityByName("invincible_e")
    if invincible_e then
        invincible_e:SetActivated(true)
    end
    local invincible_r = self:GetCaster():FindAbilityByName("invincible_r")
    if invincible_r then
        invincible_r:SetActivated(true)
    end
    if self.interrupt then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w", {duration = self:GetAbility():GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_visual", {})
end

function modifier_invincible_w_start:CheckState()
    return
    {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_DISARMED] = true,
        --[MODIFIER_STATE_SILENCED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

modifier_invincible_w = class({})

function modifier_invincible_w:IsPurgable() return false end
function modifier_invincible_w:IsPurgeException() return false end

function modifier_invincible_w:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_EVENT_ON_ORDER,
    }
end

function modifier_invincible_w:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_DISARMED] = true,
        --[MODIFIER_STATE_SILENCED] = true,
        --[MODIFIER_STATE_MUTED] = true,
    }
end

function modifier_invincible_w:GetModifierDisableTurning( params )
	return 1
end

function modifier_invincible_w:OnCreated( kv )
	if not IsServer() then return end

    local invincible_q = self:GetCaster():FindAbilityByName("invincible_q")
    if invincible_q then
        invincible_q:SetActivated(false)
    end
    local invincible_w = self:GetCaster():FindAbilityByName("invincible_w")
    if invincible_w then
        invincible_w:SetActivated(false)
    end
    local invincible_e = self:GetCaster():FindAbilityByName("invincible_e")
    if invincible_e then
        invincible_e:SetActivated(false)
    end
    local invincible_r = self:GetCaster():FindAbilityByName("invincible_r")
    if invincible_r then
        invincible_r:SetActivated(false)
    end
    self:GetCaster():RemoveGesture(ACT_DOTA_POOF_END)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	self.flCreationTime = GameRules:GetDOTATime( false, true )
	local hAbility = self:GetAbility()
	self.max_speed = self:GetAbility():GetSpecialValueFor("speed")
	self.creep_damage = self:GetAbility():GetSpecialValueFor("creep_damage")
    if self.creep_damage == 100 then
        self.max_speed = self.max_speed + self:GetCaster():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), true) * 2.0
    end
	self.acceleration = 350
	self.deceleration = 500
	self.turn_rate_min = 360
	self.turn_rate_max = 360
	self.impact_radius = 150
	self.impact_stun = 0
	self.base_damage = 0
	self.damage_per_level = 0
	self.knockback_distance = 150
	self.knockback_duration = 0
	self.flCurrentSpeed = self.max_speed
	self.flDespawnTime = 0.5
	self.nTreeDestroyRadius = 75
	self.bMaxSpeedNotified = false
	self.bCrashScheduled = false
	self.hCrashScheduledUnit = nil
    local obs = self:GetParent():GetAbsOrigin() +  self:GetParent():GetForwardVector() * 100
    local vDir = obs - self:GetParent():GetAbsOrigin()
	vDir.z = 0
	vDir = vDir:Normalized()
	local angles = VectorAngles( vDir )
	self:GetParent().flDesiredYaw = angles.y
	if self:ApplyHorizontalMotionController() == false then 
		self:Destroy()
		return
	end
	self:StartIntervalThink( FrameTime() )
end

function modifier_invincible_w:OnIntervalThink()
    if not IsServer() then return end

    local friendlys = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	for _, friendly in pairs(friendlys) do
        if not friendly:HasModifier("modifier_generic_knockback_invincible_knockback_cooldown") then
            local direction = friendly:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
            local length = direction:Length2D()
            direction.z = 0
            direction = direction:Normalized()
            friendly:AddNewModifier(
                self:GetCaster(),
                self,
                "modifier_generic_knockback_lua",
                {
                    direction_x = direction.x,
                    direction_y = direction.y,
                    distance = 70,
                    duration = 0.1,
                }
            )
            friendly:AddNewModifier(friendly, nil, "modifier_generic_knockback_invincible_knockback_cooldown", {duration = 0.4})
        end
    end

    self:CheckEnemies(100)
end

function modifier_invincible_w:CheckEnemies(radius)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	for _, target in pairs(enemies) do
        target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_slow")})
        local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invincible_w_buff_attack", {} )
        self:GetCaster():PerformAttack ( target, true, true, true, false, false, false, true )
        EmitSoundOn("invincible_w_hit", self:GetCaster())
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invincible_w_buff_attack_speed", {duration = self:GetRemainingTime() + 0.3} )
        self.enemy = true
        self:Destroy()
        local victim_angle = target:GetAnglesAsVector()
        local victim_forward_vector = target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
        victim_forward_vector.z = 0
        victim_forward_vector = victim_forward_vector:Normalized()
        local attacker_new = target:GetAbsOrigin() + (victim_forward_vector) * 175
        attacker_new = GetGroundPosition(attacker_new, self:GetParent())
        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        self:GetCaster():SetForwardVector(victim_forward_vector)
        self:GetCaster():MoveToTargetToAttack(target)
        return
    end

    if self.creep_damage == 100 then
        local creeps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
        for _, target in pairs(creeps) do
            if not target:HasModifier("modifier_invincible_w_creep_damage") then
                target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_slow")})
                target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_creep_damage", {duration = 0.25})
                self:GetCaster():PerformAttack ( target, true, true, true, false, false, false, true )
            end
        end
    else
        local creeps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
        for _, target in pairs(creeps) do
            if not target:HasModifier("modifier_invincible_w_creep_damage") then
                target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_slow")})
                target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_creep_damage", {duration = 0.25})
                local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invincible_w_buff_attack", {} )
                self:GetCaster():PerformAttack ( target, true, true, true, false, false, false, true )
                if modifier and not modifier:IsNull() then
                    modifier:Destroy()
                end
            end
        end
    end
end

function modifier_invincible_w:OnOrder( params )
	if not IsServer() then return end
	if params.unit == self:GetParent() then
		local validMoveOrders =
		{
			[DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
			[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
			[DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
			[DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
			[DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
			[DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
		}
		if validMoveOrders[params.order_type] then
			local vTargetPos = params.new_pos
			if params.target ~= nil and params.target:IsNull() == false then
				vTargetPos = params.target:GetAbsOrigin()
			end
			local vMountOrigin = self:GetParent():GetOrigin()
			if self.angle_correction ~= nil and self.angle_correction > 0 then
				local flOrderDist = (vMountOrigin - vTargetPos):Length2D()
				vMountOrigin = vMountOrigin + self:GetParent():GetForwardVector() * math.min(self.angle_correction, flOrderDist * 0.75)
			end
			local vDir = vTargetPos - vMountOrigin
			vDir.z = 0
			vDir = vDir:Normalized()
			local angles = VectorAngles( vDir )
			self:GetParent().flDesiredYaw = angles.y
		end
	end
end

function modifier_invincible_w:OnDestroy()
	if not IsServer() then return end
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
    self:GetCaster():StartGesture(ACT_DOTA_SPAWN)
	self:GetParent():RemoveHorizontalMotionController( self )
    if self.enemy == nil then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_invincible_w_end", {duration = self:GetAbility():GetSpecialValueFor("end_delay")})
    else
        local modifier_invincible_w_visual = self:GetParent():FindModifierByName("modifier_invincible_w_visual")
        if modifier_invincible_w_visual then
            modifier_invincible_w_visual:Destroy()
        end
    end
    local invincible_q = self:GetCaster():FindAbilityByName("invincible_q")
    if invincible_q then
        invincible_q:SetActivated(true)
    end
    local invincible_w = self:GetCaster():FindAbilityByName("invincible_w")
    if invincible_w then
        invincible_w:SetActivated(true)
    end
    local invincible_e = self:GetCaster():FindAbilityByName("invincible_e")
    if invincible_e then
        invincible_e:SetActivated(true)
    end
    local invincible_r = self:GetCaster():FindAbilityByName("invincible_r")
    if invincible_r then
        invincible_r:SetActivated(true)
    end
end

function modifier_invincible_w:UpdateHorizontalMotion( me, dt )
	if not IsServer() or not self:GetParent() then return end
	local curAngles = self:GetParent():GetAnglesAsVector()
	local flAngleDiff = AngleDiff( self:GetParent().flDesiredYaw, curAngles.y ) or 0
	local flTurnAmount = dt * ( self.turn_rate_min + self:GetSpeedMultiplier() * ( self.turn_rate_max - self.turn_rate_min ) )
	if self.flLastCrashTime ~= nil and GameRules:GetDOTATime(false, true) - self.flLastCrashTime <= 2.0 then
		flTurnAmount = flTurnAmount * 1.5
	end
	flTurnAmount = math.min( flTurnAmount, math.abs( flAngleDiff ) )
	if flAngleDiff < 0.0 then
		flTurnAmount = flTurnAmount * -1
	end
	if flAngleDiff ~= 0.0 then
		curAngles.y = curAngles.y + flTurnAmount
		me:SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
	end
	local flMaxSpeed = self.max_speed
	local flAcceleration = self.acceleration or -self.deceleration
	self.flCurrentSpeed = math.max( math.min( self.flCurrentSpeed + ( dt * flAcceleration ), flMaxSpeed ), 0 )
	local vNewPos = self:GetParent():GetOrigin() + self:GetParent():GetForwardVector() * ( dt * self.flCurrentSpeed )
	me:SetOrigin( vNewPos )
end

function modifier_invincible_w:OnHorizontalMotionInterrupted()
	if not IsServer() then return end
	self:Destroy()
end

function modifier_invincible_w:GetSpeedMultiplier()
	return 0.5 + 0.5 * (self.flCurrentSpeed / self.max_speed)
end

modifier_invincible_w_debuff = class({})

function modifier_invincible_w_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_invincible_w_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_enemy")
end

modifier_invincible_w_end = class({})
function modifier_invincible_w_end:IsHidden() return true end
function modifier_invincible_w_end:IsPurgeException() return false end
function modifier_invincible_w_end:IsPurgable() return false end
function modifier_invincible_w_end:CheckState()
    return
    {
        [MODIFIER_STATE_STUNNED] = true
    }
end

function modifier_invincible_w_end:OnCreated()
    if not IsServer() then return end
    self:GetParent():RemoveModifierByName("modifier_invincible_w_visual")
    self:GetCaster():RemoveGesture(ACT_DOTA_POOF_END)
    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1.0)
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
    self.creep_damage = self:GetAbility():GetSpecialValueFor("creep_damage")
    if self.creep_damage == 100 then
        self.speed = self.speed + self:GetCaster():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), true) * 2
    end
    self:StartIntervalThink(0.01)
end

function modifier_invincible_w_end:OnIntervalThink()
    if not IsServer() then return end
    self.speed = self.speed - (self.speed / self:GetAbility():GetSpecialValueFor("end_delay") * 0.01)
    if self.speed <= 0 then self:Destroy() return end
    local origin = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * self.speed * 0.01
    origin = GetGroundPosition(origin, self:GetParent())
    self:GetParent():SetAbsOrigin(origin)
end

function modifier_invincible_w_end:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end

modifier_invincible_w_visual = class({})
function modifier_invincible_w_visual:IsHidden() return true end
function modifier_invincible_w_visual:IsPurgable() return false end
function modifier_invincible_w_visual:IsPurgeException() return false end
function modifier_invincible_w_visual:OnCreated()
    if not IsServer() then return end
    --self:GetParent():AddNoDraw()
    Timers:CreateTimer(FrameTime(), function()
        self.particle = ParticleManager:CreateParticle("particles/sxssss/drow_banshee_wail_parent.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self:AddParticle(self.particle, false, false, -1, false, false)

        local particle = ParticleManager:CreateParticle("particles/sxssss/drow_banshee_wail_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt( particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetParent():EmitSound("invincible_w_fly")
    end)
end
function modifier_invincible_w_visual:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("invincible_w_fly")
    local particle = ParticleManager:CreateParticle("particles/sxssss/drow_banshee_wail_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt( particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
    ParticleManager:ReleaseParticleIndex(particle)
    --self:GetParent():RemoveNoDraw()
end
function modifier_invincible_w_visual:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true,
    }
end

modifier_generic_knockback_invincible_knockback_cooldown = class({})
function modifier_generic_knockback_invincible_knockback_cooldown:IsHidden() return true end
function modifier_generic_knockback_invincible_knockback_cooldown:IsPurgable() return false end
function modifier_generic_knockback_invincible_knockback_cooldown:IsPurgeException() return false end

modifier_invincible_w_buff_attack = class({})
function modifier_invincible_w_buff_attack:IsHidden()
	return true
end
function modifier_invincible_w_buff_attack:IsPurgable()
	return false
end
function modifier_invincible_w_buff_attack:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end
function modifier_invincible_w_buff_attack:GetModifierDamageOutgoing_Percentage( params )
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor( "damage_from_attack" ) - 100
	end
end

modifier_invincible_w_buff_attack_speed = class({})

function modifier_invincible_w_buff_attack_speed:IsPurgable() return false end

function modifier_invincible_w_buff_attack_speed:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_invincible_w_buff_attack_speed:OnIntervalThink()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end

function modifier_invincible_w_buff_attack_speed:OnDestroy()
    if not IsServer() then return end
end

function modifier_invincible_w_buff_attack_speed:CheckState()
    return
    {
        [MODIFIER_STATE_UNTARGETABLE_ENEMY] = true,
        -- [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

function modifier_invincible_w_buff_attack_speed:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end
function modifier_invincible_w_buff_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("buff_attack_speed")
end

modifier_invincible_w_creep_damage = class({})
function modifier_invincible_w_creep_damage:IsHidden() return true end

modifier_generic_knockback_invincible = class({})

function modifier_generic_knockback_invincible:IsHidden()
	return true
end

function modifier_generic_knockback_invincible:IsPurgable()
	return false
end

function modifier_generic_knockback_invincible:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_knockback_invincible:OnCreated( kv )
	if IsServer() then
		self.distance = kv.distance or 0
        self.check_target = kv.check_target
		self.height = kv.height or -1
		self.duration = kv.duration or 0
		if kv.direction_x and kv.direction_y then
			self.direction = Vector(kv.direction_x,kv.direction_y,0):Normalized()
		else
			self.direction = -(self:GetParent():GetForwardVector())
		end
		self.tree = kv.tree_destroy_radius or self:GetParent():GetHullRadius()

		if kv.IsStun then self.stun = kv.IsStun==1 else self.stun = false end
		if kv.IsFlail then self.flail = kv.IsFlail==1 else self.flail = true end
		if self.duration == 0 then
			self:Destroy()
			return
		end
		self.parent = self:GetParent()
		self.origin = self.parent:GetOrigin()
		self.hVelocity = self.distance/self.duration
		local half_duration = self.duration/2
		self.gravity = 2*self.height/(half_duration*half_duration)
		self.vVelocity = self.gravity*half_duration
		if self.distance>0 then
			if self:ApplyHorizontalMotionController() == false then 
				self:Destroy()
				return
			end
		end
		if self.height>=0 then
			if self:ApplyVerticalMotionController() == false then 
				self:Destroy()
				return
			end
		end
		if self.flail then
			self:SetStackCount( 1 )
		elseif self.stun then
			self:SetStackCount( 2 )
		end
	else
		self.anim = self:GetStackCount()
		self:SetStackCount( 0 )
	end
end

function modifier_generic_knockback_invincible:OnRefresh( kv )
	if not IsServer() then return end
end

function modifier_generic_knockback_invincible:OnDestroy( kv )
	if not IsServer() then return end

	if not self.interrupted then
		if self.tree>0 then
			GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree, true )
		end
	end

    if self.interrupted then
        local modifier_invincible_w_start = self:GetParent():FindModifierByName("modifier_invincible_w_start")
        if modifier_invincible_w_start then
            modifier_invincible_w_start.interrupt = true
        end
    end

	if self.EndCallback then
		self.EndCallback( self.interrupted )
	end

	self:GetParent():InterruptMotionControllers( true )
end

function modifier_generic_knockback_invincible:SetEndCallback( func ) 
	self.EndCallback = func
end

function modifier_generic_knockback_invincible:CheckState()
	local state = 
    {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_generic_knockback_invincible:UpdateHorizontalMotion( me, dt )
	local parent = self:GetParent()
	local target = self.direction*self.distance*(dt/self.duration)
    if self:GetRemainingTime() <= 0.3 then
        if self.check_target and self.check_target == 1 then
            self:CheckEnemies(100)
        end
    end
    if self:CheckStun(self:GetParent()) or self:GetParent():IsSilenced() then
        self.interrupted = true
        self:Destroy()
        local invincible_w = self:GetCaster():FindAbilityByName("invincible_w")
        if invincible_w then
            invincible_w:EndCooldown()
        end
    end

	parent:SetOrigin( parent:GetOrigin() + target )
end

function modifier_generic_knockback_invincible:CheckStun(parent)
    local exclusive = 
    {
        ["modifier_invincible_w"] = true,
        ["modifier_invincible_w_end"] = true,
        ["modifier_invincible_w_start"] = true,
        ["modifier_generic_knockback_invincible"] = true,
        
    }
    for _, mod in pairs(parent:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        for state_name, mod_table in pairs(tables) do
            if tostring(state_name) == tostring(MODIFIER_STATE_STUNNED) and exclusive[mod:GetName()] == nil then
                return true
            end
        end
    end
    return false
end

function modifier_generic_knockback_invincible:CheckEnemies(radius)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	for _, target in pairs(enemies) do
        target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invincible_w_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration_slow")})
        local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invincible_w_buff_attack", {} )
        self:GetCaster():PerformAttack ( target, true, true, true, false, false, false, true )
        if modifier and not modifier:IsNull() then
            modifier:Destroy()
        end
        self.interrupted = true
        self:Destroy()
        local victim_angle = target:GetAnglesAsVector()
        local victim_forward_vector = target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
        victim_forward_vector.z = 0
        victim_forward_vector = victim_forward_vector:Normalized()
        local attacker_new = target:GetAbsOrigin() + (victim_forward_vector) * 175
        attacker_new = GetGroundPosition(attacker_new, self:GetParent())
        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        self:GetCaster():SetForwardVector(victim_forward_vector)
        self:GetCaster():MoveToTargetToAttack(target)
        self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invincible_w_buff_attack_speed", {duration = self:GetAbility():GetSpecialValueFor("duration")+0.3} )
        return
    end
end

function modifier_generic_knockback_invincible:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end

function modifier_generic_knockback_invincible:UpdateVerticalMotion( me, dt )
	local time = dt/self.duration
	self.parent:SetOrigin( self.parent:GetOrigin() + Vector( 0, 0, self.vVelocity*dt ) )
	self.vVelocity = self.vVelocity - self.gravity*dt
end

function modifier_generic_knockback_invincible:OnVerticalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end

function modifier_generic_knockback_invincible:GetEffectName()
	if not IsServer() then return end
	if self.stun then
		return "particles/generic_gameplay/generic_stunned.vpcf"
	end
end

function modifier_generic_knockback_invincible:GetEffectAttachType()
	if not IsServer() then return end
	return PATTACH_OVERHEAD_FOLLOW
end