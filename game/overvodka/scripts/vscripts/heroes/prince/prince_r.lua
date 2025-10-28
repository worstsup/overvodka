LinkLuaModifier( "modifier_prince_r", "heroes/prince/prince_r", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_prince_r_thinker", "heroes/prince/prince_r", LUA_MODIFIER_MOTION_BOTH  )
LinkLuaModifier( "modifier_prince_r_slow", "heroes/prince/prince_r", LUA_MODIFIER_MOTION_NONE  )

prince_r = class({})

function prince_r:IsStealable()
    return false
end

function prince_r:Precache( context )
	PrecacheResource( "particle", "amir4an/particles/heroes/queen_of_pain/amir4an_queen_of_pain_god/amir4an_queen_of_pain_god_ultimate_precast_ambient.vpcf", context )
	PrecacheResource( "particle", "amir4an/particles/heroes/queen_of_pain/amir4an_queen_of_pain_god/amir4an_queen_of_pain_god_scream_v2_ambient.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/prince_sounds.vsndevts", context )
end

function prince_r:OnAbilityPhaseStart()
	EmitSoundOn("prince_r_cast", self:GetCaster())
	self.pcf = ParticleManager:CreateParticle("amir4an/particles/heroes/queen_of_pain/amir4an_queen_of_pain_god/amir4an_queen_of_pain_god_ultimate_precast_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(self.pcf, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pcf, 1, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pcf, 26, Vector(250,0,0))
	ParticleManager:SetParticleControl(self.pcf, 27, Vector(255,63,0))
	return true
end

function prince_r:OnAbilityPhaseInterrupted()
	StopSoundOn("prince_r_cast", self:GetCaster())
	ParticleManager:DestroyParticle(self.pcf, false)
	ParticleManager:ReleaseParticleIndex(self.pcf)
end

function prince_r:Spawn()
	if not IsServer() then return end
	if IsInToolsMode() then
		self:SetLevel(1)
	end
end

function prince_r:OnSpellStart()
	if self.pcf then
		ParticleManager:DestroyParticle(self.pcf, false)
		ParticleManager:ReleaseParticleIndex(self.pcf)
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_prince_r", {duration = self:GetSpecialValueFor("duration")})
end

modifier_prince_r = class({})
function modifier_prince_r:IsHidden() return false end
function modifier_prince_r:IsDebuff() return false end
function modifier_prince_r:IsPurgable() return false end
function modifier_prince_r:IsPurgeException() return false end
function modifier_prince_r:IsStunDebuff() return false end
function modifier_prince_r:RemoveOnDeath() return true end
function modifier_prince_r:DestroyOnExpire() return true end

function modifier_prince_r:OnCreated()
	self.parent = self:GetParent()
	EmitSoundOn("prince_r_loop", self.parent)
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.starting_aoe = self:GetAbility():GetSpecialValueFor( "starting_aoe" )
	self.final_aoe = self:GetAbility():GetSpecialValueFor( "final_aoe" )
	self.distance = self:GetAbility():GetSpecialValueFor( "distance" )
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )
	self.incoming_damage_reduction = self:GetAbility():GetSpecialValueFor( "incoming_damage_reduction" )

	if not IsServer() then return end
    local prince_q = self:GetCaster():FindAbilityByName("prince_q")
    if prince_q then
        prince_q:SetActivated(false)
    end
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true

	OvervodkaGameMode:UpdateMute("npc_dota_hero_abaddon", _, _, false, self:GetAbility():GetAbilityName())

	self.start_delay = 0.2
	self.timer = 0
	self.origin = self.parent:GetAbsOrigin()
	self.charge_finish = false
	self:StartIntervalThink( FrameTime() )
end

function modifier_prince_r:OnDestroy()
	if not IsServer() then return end
    local prince_q = self:GetCaster():FindAbilityByName("prince_q")
    if prince_q then
        prince_q:SetActivated(true)
    end
	StopSoundOn("prince_r_loop", self.parent)
	OvervodkaGameMode:UpdateMute("npc_dota_hero_abaddon", _, _, true, self:GetAbility():GetAbilityName())
	self:GetParent():Stop()
end

function modifier_prince_r:OnIntervalThink()
	if self.start_delay > 0 then
		self.start_delay = self.start_delay - FrameTime()
		return
	end

	self.timer = self.timer + FrameTime()
	if self.timer >= self.interval and self:GetParent().voice_level > 0.08 then
		self.timer = 0

		local unit = CreateUnitByName("npc_dota_companion", Vector(), false, nil, nil, self:GetCaster():GetTeamNumber())
		unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_prince_r_thinker", {
			direction_x = self:GetParent():GetForwardVector().x,
			direction_y = self:GetParent():GetForwardVector().y,
			direction_z = self:GetParent():GetForwardVector().z
		})
	end
	self:TurnLogic( FrameTime() )
end

function modifier_prince_r:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_DEBUFF_IMMUNE] = true,
	}
end

function modifier_prince_r:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
	}
end

function modifier_prince_r:GetOverrideAnimation()
	return ACT_DOTA_CAST_GHOST_SHIP
end

function modifier_prince_r:GetOverrideAnimationRate()
	return 0.2
end

function modifier_prince_r:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_prince_r:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_prince_r:GetModifierIncomingDamage_Percentage()
	return self.incoming_damage_reduction 
end

function modifier_prince_r:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		ExecuteOrderFromTable({
			UnitIndex = self:GetParent():entindex(),
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
		self:SetDirection( params.target:GetAbsOrigin() )
	
	elseif
		params.order_type==DOTA_UNIT_ORDER_STOP or 
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
	end	
end

function modifier_prince_r:GetModifierDisableTurning()
	return 1
end

function modifier_prince_r:SetDirection( location )
	local dir = ((location-self.parent:GetAbsOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_prince_r:TurnLogic( dt )
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

modifier_prince_r_thinker = class({})
function modifier_prince_r_thinker:IsHidden() return true end
function modifier_prince_r_thinker:IsDebuff() return false end
function modifier_prince_r_thinker:IsPurgable() return false end
function modifier_prince_r_thinker:IsPurgeException() return false end
function modifier_prince_r_thinker:IsStunDebuff() return false end
function modifier_prince_r_thinker:RemoveOnDeath() return false end
function modifier_prince_r_thinker:DestroyOnExpire() return false end

function modifier_prince_r_thinker:OnCreated(data)
    if not IsServer() then return end
    self.voice_level = self:GetCaster().voice_level or 0

    local v = math.max(0, math.min(1, self.voice_level))
    local min_v, max_v = 1, 30
    self.voice_exp = min_v * math.pow(max_v / min_v, v)

    self.voice_level_raw = self.voice_level
    self.voice_level = self.voice_exp / 50

    self.color = gradient_rgb(self:GetCaster().voice_level)
    print(self.color)
    self.direction = self:GetCaster():GetForwardVector()
    self:GetParent():SetAbsOrigin(self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("mouth")))
    self.start_pos = self:GetParent():GetAbsOrigin()
    self.z = self:GetParent():GetAbsOrigin().z
    self.direction_left = self:GetCaster():GetRightVector()
    self.direction_right = self:GetCaster():GetRightVector() * -1
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
    self.aoe_max = self:GetAbility():GetSpecialValueFor("final_aoe")
    self.max_range = self:GetAbility():GetSpecialValueFor("distance")
    self.pcf = ParticleManager:CreateParticle("amir4an/particles/heroes/queen_of_pain/amir4an_queen_of_pain_god/amir4an_queen_of_pain_god_scream_v2_ambient.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.pcf, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlForward(self.pcf, 0, self.direction)
    ParticleManager:SetParticleControl(self.pcf, 26, Vector(300, 0, self.voice_exp))
    ParticleManager:SetParticleControl(self.pcf, 27, self.color)
    ParticleManager:SetParticleShouldCheckFoW(self.pcf, false)
    self:ApplyHorizontalMotionController()
    self:ApplyVerticalMotionController()
end

function modifier_prince_r_thinker:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local frame_movement = self.direction * self.speed * dt
    local new_pos = self:GetParent():GetOrigin() + frame_movement
    if (self.start_pos - new_pos):Length2D() > self.max_range then
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
        self:Destroy()
        return
    end
    local aoe1 = math.sin(math.min(self:GetElapsedTime() / 2, math.pi/2))  * self.aoe_max + 50
    local aoe2 = self:GetElapsedTime() / FrameTime()
    local aoe = aoe1 + aoe2
    local pont_left = self.direction_left * aoe / 2 + self:GetParent():GetOrigin()
    local direction_right = self.direction_right * aoe / 2 + self:GetParent():GetOrigin()
    local enemies = FindUnitsInLine(self:GetParent():GetTeamNumber(), pont_left, direction_right, nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)
    for _,enemy in pairs(enemies) do
	    enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_prince_r_slow", {
            duration = self:GetAbility():GetSpecialValueFor("wave_knockback_duration"),
            direction_x = self.direction.x,
            direction_y = self.direction.y,
        })
    end
    ParticleManager:SetParticleControl(self.pcf, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlForward(self.pcf, 0, self.direction)
    ParticleManager:SetParticleControl(self.pcf, 26, Vector(aoe / 2, 0, self.voice_level * 50))


    self:GetParent():SetOrigin(Vector(new_pos.x, new_pos.y, 0))
end

function modifier_prince_r_thinker:UpdateVerticalMotion( me, dt )
    self:GetParent():SetOrigin(Vector(0, 0, self.z))
end

function modifier_prince_r_thinker:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
    }
end

function modifier_prince_r_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

local function clamp01(x) return math.max(0, math.min(1, x)) end

local function hex_to_rgb(hex)
    hex = hex:gsub("#","")
    return tonumber(hex:sub(1,2),16),
           tonumber(hex:sub(3,4),16),
           tonumber(hex:sub(5,6),16)
end

local function lerp(a,b,t) return a + (b - a) * t end

function gradient_rgb(t)
    t = clamp01(t)
    local stops = {
        {0.00, "b91f74"},
        {0.25, "932F73"},
        {0.45, "E44757"},
        {0.70, "FF8B5A"},
        {0.90, "FFD196"},
        {1.00, "FFF2DE"},
    }

    if t <= stops[1][1] then
        return hex_to_rgb(stops[1][2])
    end
    if t >= stops[#stops][1] then
        return hex_to_rgb(stops[#stops][2])
    end

    for i = 1, #stops-1 do
        local p0, c0 = stops[i][1], stops[i][2]
        local p1, c1 = stops[i+1][1], stops[i+1][2]
        if t >= p0 and t <= p1 then
            local local_t = (t - p0) / (p1 - p0)
            local r0,g0,b0 = hex_to_rgb(c0)
            local r1,g1,b1 = hex_to_rgb(c1)
            local r = math.floor(lerp(r0, r1, local_t) + 0.5)
            local g = math.floor(lerp(g0, g1, local_t) + 0.5)
            local b = math.floor(lerp(b0, b1, local_t) + 0.5)
            return Vector(r,g,b)
        end
    end

    return hex_to_rgb(stops[#stops][2])
end

modifier_prince_r_slow = class({})
function modifier_prince_r_slow:IsHidden() return true end
function modifier_prince_r_slow:IsDebuff() return true end
function modifier_prince_r_slow:IsPurgable() return false end
function modifier_prince_r_slow:IsPurgeException() return false end
function modifier_prince_r_slow:IsStunDebuff() return false end
function modifier_prince_r_slow:RemoveOnDeath() return true end
function modifier_prince_r_slow:DestroyOnExpire() return true end

function modifier_prince_r_slow:OnCreated(data)
    self.direction = Vector(data.direction_x, data.direction_y, 0)
    if not IsServer() then return end
    self.damage_instant = self:GetAbility():GetSpecialValueFor("damage_instant")
    self.damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier")
    self.damage = self:GetAbility():GetSpecialValueFor("damage") * FrameTime()
    self.knockback_speed = self:GetAbility():GetSpecialValueFor("knockback_speed")
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_instant * self.damage_multiplier * self:GetCaster().voice_level,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility()
    })
    self:StartIntervalThink(FrameTime())
end

function modifier_prince_r_slow:OnIntervalThink()
    if math.abs(AngleDiff(VectorAngles(self.direction).y, self:GetParent():GetAngles().y)) < 70 then return end

    local frame_movement = self.direction * self.knockback_speed * FrameTime()

    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin() + frame_movement, false)
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility()
    })
end