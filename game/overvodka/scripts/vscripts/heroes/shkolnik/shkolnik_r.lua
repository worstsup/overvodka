LinkLuaModifier("modifier_shkolnik_r", "heroes/shkolnik/shkolnik_r", LUA_MODIFIER_MOTION_NONE)

shkolnik_r = class({})

function shkolnik_r:Precache( context )
    PrecacheResource( "particle", "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf", context )
end

function shkolnik_r:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function shkolnik_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function shkolnik_r:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT
end

function shkolnik_r:OnSpellStart()
    if not IsServer() then return end
    self.point = self:GetCursorPosition()
    local caster = self:GetCaster()
    EmitSoundOn("ivn", caster)
    self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_shkolnik_r", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_shkolnik_r = class ({})

function modifier_shkolnik_r:IsPurgable()
    return false
end

function modifier_shkolnik_r:OnCreated()
    if not IsServer() then return end
    self.parent = self:GetParent()
    self.turn_rate = 120
    self:SetDirection( Vector(self:GetAbility().point.x, self:GetAbility().point.y, 0) ) 
    self.current_dir = self.target_dir
    self.turn_speed = FrameTime()*self.turn_rate
    self.proj_time = 0
    self.not_scepter = not self:GetCaster():HasScepter()
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()
end

function modifier_shkolnik_r:OnDestroy()
    if not IsServer() then return end
end

function modifier_shkolnik_r:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
    return funcs
end

function modifier_shkolnik_r:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_shkolnik_r:GetModifierDisableTurning()
    return 1
end

function modifier_shkolnik_r:OnOrder( params )
    if params.unit~=self:GetParent() then return end

    if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or params.order_type == DOTA_UNIT_ORDER_CONTINUE then
        StopSoundOn("ivn", self:GetCaster())
        self:Destroy()
        self:GetParent():Stop()
        return
    end

    if  params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
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

function modifier_shkolnik_r:SetDirection( vec )
    if vec.x == self:GetCaster():GetAbsOrigin().x and vec.y == self:GetCaster():GetAbsOrigin().y then 
        vec = self:GetCaster():GetAbsOrigin() + 100*self:GetCaster():GetForwardVector()
    end
    self.target_dir = ((vec-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
    self.face_target = false
end

function modifier_shkolnik_r:TurnLogic()
    if self.face_target then return end
    local current_angle = VectorToAngles( self.current_dir ).y
    local target_angle = VectorToAngles( self.target_dir ).y
    local angle_diff = AngleDiff( current_angle, target_angle )
    local sign = -1
    if angle_diff<0 then sign = 1 end
    if math.abs( angle_diff )<1.1*self.turn_speed then
        self.current_dir = self.target_dir
        self.face_target = true
    else
        self.current_dir = RotatePosition( Vector(0,0,0), QAngle(0, sign*self.turn_speed, 0), self.current_dir )
    end
    local a = self.parent:IsCurrentlyHorizontalMotionControlled()
    local b = self.parent:IsCurrentlyVerticalMotionControlled()
    if not (a or b) then
        self.parent:SetForwardVector( self.current_dir )
    end
end

function modifier_shkolnik_r:OnIntervalThink()
    if not IsServer() then return end
    local projectile_name = "particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf"
    local projectile_distance = self:GetAbility():GetSpecialValueFor("distance")
    local projectile_speed = self:GetAbility():GetSpecialValueFor("speed")
    local projectile_start_radius = self:GetAbility():GetSpecialValueFor("starting_aoe")
    local projectile_end_radius = self:GetAbility():GetSpecialValueFor("final_aoe")
    local projectile_direction = self:GetParent():GetForwardVector()
    if self:GetCaster():HasScepter() then
        self:TurnLogic()
    end

    local info = 
    {
        Source = self:GetCaster(),
        Ability = self:GetAbility(),
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = projectile_distance,
        fStartRadius = projectile_start_radius,
        fEndRadius = projectile_end_radius,
        bHasFrontalCone = false,
        vVelocity = projectile_direction * projectile_speed,
        bDeleteOnHit = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bProvidesVision = false,
    }

    self.proj_time = self.proj_time + FrameTime()

    if self.proj_time >= 0.25 then
        self.proj_time = 0
        self:GetAbility():PlayProjectile( info )
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function modifier_shkolnik_r:CheckState()
    return{[MODIFIER_STATE_DISARMED] = true,
    [MODIFIER_STATE_ROOTED] = true,
    [MODIFIER_STATE_SILENCED] = self.not_scepter,
    [MODIFIER_STATE_MUTED] = self.not_scepter}
end

function shkolnik_r:PlayProjectile( info )
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
    ParticleManager:SetParticleControl( effect_cast, 1, info.vVelocity )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function shkolnik_r:OnProjectileHit( target, location )
    if not IsServer() then return end
    local damage = self:GetSpecialValueFor("damage")
    if not target then return end
    if target:HasModifier("modifier_black_king_bar_immune") or target:IsMagicImmune() or target:IsDebuffImmune() then damage = damage * 0.2 end
    local damageTable = 
    {
        victim          = target,
        damage          = damage,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        attacker        = self:GetCaster(),
        ability         = self
    }
    
    ApplyDamage(damageTable)
end