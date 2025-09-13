LinkLuaModifier( "modifier_papich_e_passive",   "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_custom_min_health",  "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_papich_e_charge",    "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e",           "heroes/papich/papich_e", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_papich_e_command",   "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e_heal",      "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_bkb",         "heroes/papich/papich_e", LUA_MODIFIER_MOTION_NONE )

papich_e = class({})

function papich_e:IsRefreshable() return false end

function papich_e:Precache(context)
    PrecacheResource( "soundfile", "soundevents/papich_e_fly.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_plane.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_start.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_end.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_plane_start.vsndevts", context )
    PrecacheResource( "particle", "particles/primal_beast_onslaught_range_finder_new.vpcf", context )
end

function papich_e:GetIntrinsicModifierName()
    return "modifier_papich_e_passive"
end

function papich_e:OnChargeFinish( interrupt )
    local caster = self:GetCaster()
    local max_duration = self:GetSpecialValueFor( "chargeup_time" )
    local max_distance = self:GetSpecialValueFor( "max_distance" )
    local speed = self:GetSpecialValueFor( "charge_speed" )
    if GetMapName() == "overvodka_5x5" then
        speed = speed + 500
    end
    local charge_duration = max_duration
    local mod = caster:FindModifierByName( "modifier_papich_e_charge" )
    if mod then
        charge_duration = mod:GetElapsedTime()
        mod.charge_finish = true
        mod:Destroy()
    end

    if interrupted then return end
    caster:AddNewModifier(
        caster,
        self,
        "modifier_papich_e",
        { duration = -1 }
    )
end

modifier_papich_e_passive = class({})

function modifier_papich_e_passive:IsHidden() return true end
function modifier_papich_e_passive:IsPurgable() return false end
function modifier_papich_e_passive:RemoveOnDeath() return false end

function modifier_papich_e_passive:OnCreated()
    if not self:GetParent():IsRealHero() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.check_interval = 0.1

    if IsServer() then
        self:StartIntervalThink(self.check_interval)
    end
end

function modifier_papich_e_passive:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsTempestDouble() then return end
    if self:GetParent():PassivesDisabled() or self:GetParent():HasModifier("modifier_mazellov_r") then
        if self:GetParent():HasModifier("modifier_custom_min_health") then
            self:GetParent():RemoveModifierByName("modifier_custom_min_health")
        end
        return
    end
    if not self:GetParent():IsAlive() then return end
    if not self.ability or not self.parent or self.parent:IsIllusion() then return end
    if not self.ability:IsCooldownReady() then
        self.parent:RemoveModifierByName("modifier_custom_min_health")
        return
    end

    local current_health = self.parent:GetHealth()
    local max_health = self.parent:GetMaxHealth()
    local health_threshold = max_health * 0.05

    if current_health > health_threshold then
        if not self.parent:HasModifier("modifier_custom_min_health") then
            self.parent:AddNewModifier(self.parent, self.ability, "modifier_custom_min_health", {})
        end
    else
        if self.parent:HasModifier("modifier_brb_test") then
            self.parent:RemoveModifierByName("modifier_brb_test")
            self.parent:RemoveModifierByName("modifier_brb_test_attack_target")
        end
        if self.parent:HasModifier("modifier_axe_berserkers_call_lua_debuff") then
            self.parent:RemoveModifierByName("modifier_axe_berserkers_call_lua_debuff")
        end
        if self.parent:HasModifier("modifier_generic_stunned_lua") then
            self.parent:RemoveModifierByName("modifier_generic_stunned_lua")
        end
        if self.parent:HasModifier("modifier_golovach_e") then
            self.parent:RemoveModifierByName("modifier_golovach_e")
        end
        if self.parent:HasModifier("modifier_dark_willow_debuff_fear") then
            self.parent:RemoveModifierByName("modifier_dark_willow_debuff_fear")
        end
        if self.parent:HasModifier("modifier_generic_arc_lua") then
            self.parent:RemoveModifierByName("modifier_generic_arc_lua")
        end
        if self.parent:HasModifier("modifier_generic_knockback_lua") then
            self.parent:RemoveModifierByName("modifier_generic_knockback_lua")
        end
        if self.parent:HasModifier("modifier_serega_sven") then
            self.parent:RemoveModifierByName("modifier_serega_sven")
        end
        if self.parent:HasModifier("modifier_knockback") then
            self.parent:RemoveModifierByName("modifier_knockback")
        end
        self.parent:Stop()
        local caster = self:GetParent()
        local team = caster:GetTeam()
        local point = 0
        local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
        for _,fountainEnt in pairs( fountainEntities ) do
            if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
               point = fountainEnt:GetAbsOrigin()
               break
            end
        end
        self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        self.parent:Purge( true, true, false, true, true )
        caster:FaceTowards(point)
        local duration = self:GetAbility():GetSpecialValueFor( "chargeup_time" )
        local mod = caster:AddNewModifier(
           caster,
           self.ability,
           "modifier_papich_e_command",
           { duration = duration+0.1 }
        )
        self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel() - 1))
        local mod = caster:AddNewModifier(
           caster,
            self.ability,
           "modifier_papich_e_charge",
           { duration = duration }
        )
        if self.parent:HasModifier("modifier_custom_min_health") then
            self.parent:RemoveModifierByName("modifier_custom_min_health")
        end
        caster:FaceTowards(point)
    end
end


modifier_custom_min_health = class({})

function modifier_custom_min_health:IsHidden() return true end
function modifier_custom_min_health:IsPurgable() return false end
function modifier_custom_min_health:RemoveOnDeath() return false end

function modifier_custom_min_health:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_custom_min_health:GetMinHealth()
    return 1
end


modifier_papich_e_command = class({})

function modifier_papich_e_command:IsHidden() return true end
function modifier_papich_e_command:IsDebuff() return false end
function modifier_papich_e_command:IsPurgable() return false end

function modifier_papich_e_command:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end


modifier_papich_e_heal = class({})

function modifier_papich_e_heal:IsHidden() return true end
function modifier_papich_e_heal:IsPurgable() return false end

function modifier_papich_e_heal:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
end

function modifier_papich_e_heal:GetModifierHealthRegenPercentage()
    return 25
end

function modifier_papich_e_heal:GetModifierTotalPercentageManaRegen()
    return 25
end


modifier_papich_bkb = class({})

function modifier_papich_bkb:IsHidden() return false end
function modifier_papich_bkb:IsPurgable() return false end

function modifier_papich_bkb:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
end

function modifier_papich_bkb:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end


modifier_papich_e_charge = class({})

function modifier_papich_e_charge:IsHidden() return false end
function modifier_papich_e_charge:IsDebuff() return false end
function modifier_papich_e_charge:IsPurgable() return false end

function modifier_papich_e_charge:OnCreated( kv )
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	EmitSoundOn( "papich_e_start", self.parent )
	local sound_cast = "papich_e_plane_start"
	EmitSoundOn( sound_cast, self.parent )
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	if not IsServer() then return end
	self.origin = self.parent:GetOrigin()
	self.charge_finish = false
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	local caster = self:GetParent()
    local team = caster:GetTeam()
    self.point = 0
    local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
    for _,fountainEnt in pairs( fountainEntities ) do
        if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
            self.point = fountainEnt:GetAbsOrigin()
            break
        end
    end
    caster:FaceTowards(self.point)
	self:StartIntervalThink( FrameTime() )
	self.filter = FilterManager:AddExecuteOrderFilter( self.OrderFilter, self )
	self:SetDirection( self.point )
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_papich_e_charge:OnRemoved()
	if not IsServer() then return end
	if not self.charge_finish then
		self.ability:OnChargeFinish( false )
	end
	FilterManager:RemoveExecuteOrderFilter( self.filter )
end

function modifier_papich_e_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end

function modifier_papich_e_charge:GetMinHealth()
    return 1
end

function modifier_papich_e_charge:OnOrder( params )
	if params.unit~=self:GetParent() then return end
end

function modifier_papich_e_charge:SetDirection( location )
	local dir = ((location-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_papich_e_charge:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_papich_e_charge:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}
end

function modifier_papich_e_charge:OrderFilter( data )
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

function modifier_papich_e_charge:OnIntervalThink()
	self:TurnLogic( FrameTime() )
	self:SetEffects()
end

function modifier_papich_e_charge:TurnLogic( dt )
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

function modifier_papich_e_charge:PlayEffects1()
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

function modifier_papich_e_charge:SetEffects()
	local target_pos = self.origin + self.parent:GetForwardVector() * self.speed * self:GetElapsedTime()
	ParticleManager:SetParticleControl( self.effect_cast, 1, target_pos )
end

function modifier_papich_e_charge:PlayEffects2()
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
	self:AddParticle(effect_cast, false, false, -1, false, false)
end


modifier_papich_e = class({})

function modifier_papich_e:IsHidden() return false end
function modifier_papich_e:IsDebuff() return false end
function modifier_papich_e:IsPurgable() return false end

function modifier_papich_e:OnCreated()
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.gold = self:GetAbility():GetSpecialValueFor( "gold" )
	self.bkb = self:GetAbility():GetSpecialValueFor( "bkb_duration" )
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
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end
	EmitSoundOn( "papich_e_plane", self:GetCaster() )
	EmitSoundOn( "papich_e_fly", self:GetCaster() )
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
	return {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
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
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
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
		if GetMapName() == "overvodka_5x5" then
			self.speed = 2000
		end
	end
	if distance < 500 or (GetMapName() ~= "overvodka_5x5" and distance > 11000) or (GetMapName() == "overvodka_5x5" and distance > 20000) then
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