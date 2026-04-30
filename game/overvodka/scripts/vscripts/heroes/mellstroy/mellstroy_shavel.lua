mellstroy_shavel = class({})
LinkLuaModifier( "modifier_mellstroy_shavel", "heroes/mellstroy/mellstroy_shavel", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mellstroy_shavel_debuff", "heroes/mellstroy/mellstroy_shavel", LUA_MODIFIER_MOTION_BOTH )

function mellstroy_shavel:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/shavel.vsndevts", context )
end

function mellstroy_shavel:GetAbilityTextureName()
    if self:GetCaster():HasMellstroyArcanaSkin() then
        return "shavel_arcana"
    end
    return "shavel"
end

function mellstroy_shavel:GetGoldCost(iLevel)
    local base = self:GetSpecialValueFor( "gold_cost" )

    local low = tonumber( self:GetCaster()._low_gold ) or 0
    if low == 1 then
        return math.floor( base * 0.75 + 0.5 )
    end

    return base
end

function mellstroy_shavel:Spawn()
	if not IsServer() then return end
end

function mellstroy_shavel:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

mellstroy_shavel.modifiers = {}
function mellstroy_shavel:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then
		caster:Interrupt()
		return
	end
	local duration = self:GetSpecialValueFor( "channel_time" )
	target:RemoveModifierByName( "modifier_generic_motion" )
	target:RemoveModifierByName( "modifier_knockback" )
	target:RemoveModifierByName( "modifier_generic_knockback_lua" )
	local mod = target:AddNewModifier( caster, self, "modifier_mellstroy_shavel_debuff", { duration = duration } )
	self.modifiers[mod] = true

	caster:AddNewModifier( caster, self, "modifier_mellstroy_shavel", { duration = duration } )
	if target:IsCreep() then
		EmitSoundOn( "shavel", caster )
	else
		EmitSoundOn( "shavel", caster )
	end
end

function mellstroy_shavel:GetChannelTime()
	return self:GetSpecialValueFor( "channel_time" )
end

function mellstroy_shavel:OnChannelFinish( bInterrupted )
	for mod,_ in pairs( self.modifiers ) do
		if not mod:IsNull() then
			mod:Destroy()
		end
	end
	self.modifiers = {}

	local self_mod = self:GetCaster():FindModifierByName( "modifier_mellstroy_shavel" )
	if self_mod then
		self_mod:Destroy()
	end
end

function mellstroy_shavel:RemoveModifier( mod )
	self.modifiers[mod] = nil
	local has_enemies = false
	for _,mod in pairs( self.modifiers ) do
		has_enemies = true
	end

	if not has_enemies then
		self:EndChannel( true )
	end
end

modifier_mellstroy_shavel = class({})

function modifier_mellstroy_shavel:IsHidden() return false end
function modifier_mellstroy_shavel:IsDebuff() return false end
function modifier_mellstroy_shavel:IsPurgable() return false end

function modifier_mellstroy_shavel:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}
end

function modifier_mellstroy_shavel:GetModifierDisableTurning()
	return 1
end

modifier_mellstroy_shavel_debuff = class({})

function modifier_mellstroy_shavel_debuff:IsHidden() return false end
function modifier_mellstroy_shavel_debuff:IsDebuff() return true end
function modifier_mellstroy_shavel_debuff:IsPurgable() return true end
function modifier_mellstroy_shavel_debuff:IsStunDebuff() return true end

function modifier_mellstroy_shavel_debuff:OnCreated( kv )
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.isRoshan = self.parent:GetUnitName()=="npc_dota_roshan"

    self.interval   = self:GetAbility():GetSpecialValueFor( "interval" )
    self.radius     = self:GetAbility():GetSpecialValueFor( "splash_radius" )
    self.ministun   = self:GetAbility():GetSpecialValueFor( "ministun" )
    self.damage     = self:GetAbility():GetSpecialValueFor( "ministun" )
    self.animrate   = self:GetAbility():GetSpecialValueFor( "animation_rate" )
    self.lift_height = 250
    self.elapsed_motion = 0
    self.total_hits = math.max( 1, math.floor( ( self:GetDuration() / self.interval ) + 0.001 ) )
    self.motion_duration = self.total_hits * self.interval

    if not IsServer() then return end
    self.damage = self:GetAbility():GetAbilityDamage()
    self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
    self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
    self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
    self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()

    self.interrupt_pos = self.caster:GetOrigin() + self.caster:GetForwardVector() * 200
    self.cast_pos = self.caster:GetOrigin()
    self.pos_threshold = 100

    local attach_rollback = { "attach_attack1","attach_attack","attach_hitloc" }
    for _,name in ipairs(attach_rollback) do
        self.attach_name = name
        if self.caster:ScriptLookupAttachment( name )~=0 then break end
    end

    local hitloc_enum = self.parent:ScriptLookupAttachment( "attach_hitloc" )
    local hitloc_pos = self.parent:GetAttachmentOrigin( hitloc_enum )
    self.deltapos = self.parent:GetOrigin() - hitloc_pos

    if not self:ApplyHorizontalMotionController() then
        if not self.isRoshan then self:Destroy(); return end
    end
    if not self:ApplyVerticalMotionController() then
        if not self.isRoshan then self:Destroy(); return end
    end

    self:SetPriority( DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST )

    self:StartIntervalThink( self.interval )
end

function modifier_mellstroy_shavel_debuff:OnDestroy()
    if not IsServer() then return end

    self.parent:RemoveHorizontalMotionController( self )
    self.parent:RemoveVerticalMotionController( self )

    self.ability:RemoveModifier( self )
end

function modifier_mellstroy_shavel_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
end

function modifier_mellstroy_shavel_debuff:GetOverrideAnimation()
	if self.isRoshan then
		return ACT_DOTA_DISABLED
	end
	return ACT_DOTA_FLAIL
end

function modifier_mellstroy_shavel_debuff:GetOverrideAnimationRate()
	return self.animrate
end

function modifier_mellstroy_shavel_debuff:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}
end

function modifier_mellstroy_shavel_debuff:OnIntervalThink()
    local origin = self.parent:GetOrigin()
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        origin, nil, self.radius,
        self.abilityTargetTeam, self.abilityTargetType,
        self.abilityTargetFlags, 0, false
    )

    local damageTable = {
        attacker = self.caster,
        damage = self.damage,
        damage_type = self.abilityDamageType,
        ability = self.ability,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
    }

    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        enemy:AddNewModifier( self.caster, self, "modifier_generic_stunned_lua", { duration = self.ministun } )
        ApplyDamage(damageTable)
        EmitSoundOn( "Hero_PrimalBeast.Pulverize.Stun", self.caster )
    end

    self:PlayEffects( origin, self.radius )

    if (self.caster:GetOrigin()-self.cast_pos):Length2D()>self.pos_threshold then
        self:Destroy()
        return
    end
end

function modifier_mellstroy_shavel_debuff:UpdateVerticalMotion( me, dt )
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    self.elapsed_motion = math.min( self.elapsed_motion + dt, self.motion_duration )

    local height = 0
    if self.interval > 0 and self.elapsed_motion < self.motion_duration then
        local cycle_elapsed = self.elapsed_motion % self.interval
        local phase = cycle_elapsed / self.interval
        height = math.sin( phase * math.pi ) * self.lift_height
    end

    local pos = self.parent:GetAbsOrigin()
    local ground = GetGroundPosition( pos, self.parent )
    pos.x = ground.x
    pos.y = ground.y
    pos.z = ground.z + height

    self.parent:SetAbsOrigin( pos )
end

function modifier_mellstroy_shavel_debuff:OnVerticalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_mellstroy_shavel_debuff:GetPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

function modifier_mellstroy_shavel_debuff:GetMotionPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

function modifier_mellstroy_shavel_debuff:PlayEffects( origin, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, radius, radius) )
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( self.parent:GetOrigin(), "Hero_PrimalBeast.Pulverize.Impact", self.caster )
end