LinkLuaModifier( "modifier_pistol_w", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_cooldown", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_active", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_lifesteal", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_active_fury", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_active_animation", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pistol_w_active_recovery", "heroes/pistol/pistol_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

pistol_w = class({})

function pistol_w:OnAbilityPhaseStart()
	if not self:GetCaster():HasModifier("modifier_pistol_mute") then
        self:GetCaster():EmitSound("pistol_w")
    end
    return true
end

function pistol_w:OnAbilityPhaseInterrupted()
    self:GetCaster():StopSound("pistol_w")
end

function pistol_w:Precache( ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", ctx )
	PrecacheResource( "soundfile", "soundevents/pistol_sounds.vsndevts", ctx )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_largo/largo_croak_genius_buff.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_largo/largo_amphibian_rhapsody_fightsong_buff.vpcf", ctx )
	PrecacheResource( "particle", "particles/marci_unleash_stack_golovach.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", ctx )
	PrecacheResource( "particle", "particles/pistol_w_pulse.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_pulse_debuff.vpcf", ctx )
end

function pistol_w:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_pistol_w_active", { duration = self:GetSpecialValueFor( "duration" ) } )
end

function pistol_w:GetIntrinsicModifierName()
	return "modifier_pistol_w"
end


modifier_pistol_w = class({})

function modifier_pistol_w:IsHidden() return true end
function modifier_pistol_w:IsPurgable() return false end

function modifier_pistol_w:OnCreated()
    self.counter_cooldown = self:GetAbility():GetSpecialValueFor( "counter_cooldown" )
end

function modifier_pistol_w:OnRefresh()
    self:OnCreated()
end

function modifier_pistol_w:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_pistol_w:OnAttackLanded( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.attacker == parent then return end
    if params.target ~= parent then return end
    if params.target:IsWard() then return end
    if params.target:PassivesDisabled() then return end
    if parent:HasModifier( "modifier_pistol_w_cooldown" ) then return end

    if RollPercentage( self:GetAbility():GetSpecialValueFor( "chance" ) ) then
        parent:AddNewModifier( parent, self:GetAbility(), "modifier_pistol_w_lifesteal", { duration = 1.5 } )
        parent:AddNewModifier( parent, self:GetAbility(), "modifier_pistol_w_cooldown", { duration = self.counter_cooldown } )
    end
end


modifier_pistol_w_lifesteal = class({})

function modifier_pistol_w_lifesteal:IsPurgable() return false end
function modifier_pistol_w_lifesteal:IsHidden() return true end

function modifier_pistol_w_lifesteal:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_pistol_w_lifesteal:GetModifierAttackSpeed_Limit()
	return 1
end

function modifier_pistol_w_lifesteal:GetModifierAttackSpeedBonus_Constant()
    return 15000
end

function modifier_pistol_w_lifesteal:OnTakeDamage( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent ~= params.attacker then return end
    if parent == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.unit:IsWard() then return end
    if params.inflictor == nil and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        
        local lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" ) * 0.01

        if params.unit:IsCreep() then
            lifesteal = lifesteal * 0.6
        end

        local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_CUSTOMORIGIN, parent )
        ParticleManager:SetParticleControlEnt( p, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
        ParticleManager:ReleaseParticleIndex( p )
        
        local heal = params.damage * lifesteal
        parent:HealWithParams( heal, self:GetAbility(), true, true, parent, false )
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, parent:GetPlayerOwner())
        local effect_cast = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:Destroy()
    end
end


modifier_pistol_w_active = class({})

function modifier_pistol_w_active:IsHidden() return false end
function modifier_pistol_w_active:IsPurgable() return true end

function modifier_pistol_w_active:OnCreated()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.attack_damage = self.ability:GetSpecialValueFor( "attack_damage" )
    self.attack_damage_pct = self.ability:GetSpecialValueFor( "attack_damage_pct" )

    if not IsServer() then return end

	local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_largo/largo_croak_genius_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	self:AddParticle( p, false, false, -1, false, false )

	local p2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_largo/largo_amphibian_rhapsody_fightsong_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	self:AddParticle( p2, false, false, -1, false, false )

    self.damage = self.attack_damage + self.parent:GetAverageTrueAttackDamage( nil ) * self.attack_damage_pct * 0.01
	self:SetHasCustomTransmitterData( true )
    self.parent:AddNewModifier(self.parent, self.ability, "modifier_pistol_w_active_fury", {})
    self:PlayEffects()
	self:StartIntervalThink(0.1)
end

function modifier_pistol_w_active:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.damage = self.damage
    return self._txData
end

function modifier_pistol_w_active:HandleCustomTransmitterData( data )
    self.damage = data.damage
end

function modifier_pistol_w_active:OnIntervalThink()
	if not IsServer() then return end
	self.damage = self.attack_damage + self.parent:GetAverageTrueAttackDamage( nil ) * self.attack_damage_pct * 0.01
	self:SendBuffRefreshToClients()
end

function modifier_pistol_w_active:OnDestroy()
	if not IsServer() then return end

	local fury = self.parent:FindModifierByNameAndCaster( "modifier_pistol_w_active_fury", self.parent )
	if fury then
		fury:ForceDestroy()
	end

	local recovery = self.parent:FindModifierByNameAndCaster( "modifier_pistol_w_active_recovery", self.parent )
	if recovery then
		recovery:ForceDestroy()
	end
end

function modifier_pistol_w_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
end

function modifier_pistol_w_active:GetAttackSound()
	return "Hero_Marci.Flurry.Attack"
end

function modifier_pistol_w_active:GetModifierOverrideAttackDamage()
	return self.damage
end

function modifier_pistol_w_active:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


modifier_pistol_w_active_fury = class({})

function modifier_pistol_w_active_fury:IsHidden() return false end
function modifier_pistol_w_active_fury:IsDebuff() return false end
function modifier_pistol_w_active_fury:IsPurgable() return false end

function modifier_pistol_w_active_fury:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "flurry_bonus_attack_speed" )
	self.recovery = self:GetAbility():GetSpecialValueFor( "time_between_flurries" )
	self.charges = self:GetAbility():GetSpecialValueFor( "charges_per_flurry" )
	self.timer = self:GetAbility():GetSpecialValueFor( "max_time_window_per_hit" )
	self.damage = self:GetAbility():GetSpecialValueFor( "pulse_damage" )
    self.kick = self:GetAbility():GetSpecialValueFor( "pulse_attack_kick" )
	if not IsServer() then return end
	self.counter = self.charges
	self:SetStackCount( self.counter )
	self.success = 0
	self.animation = self.parent:AddNewModifier( self.parent, self.ability, "modifier_pistol_w_active_animation", {} )
	self:PlayEffects1()
	self:PlayEffects2( self.parent, self.counter )
end

function modifier_pistol_w_active_fury:OnDestroy()
	if not IsServer() then return end
	if not self.animation:IsNull() then
		self.animation:Destroy()
	end
	local main = self.parent:FindModifierByNameAndCaster( "modifier_pistol_w_active", self.parent )
	if not main then return end
	if self.forced then return end
	self.parent:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_pistol_w_active_recovery",
		{
			duration = self.recovery,
			success = self.success,
		}
	)
	if self.success~=1 then return end
end

function modifier_pistol_w_active_fury:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end

function modifier_pistol_w_active_fury:GetActivityTranslationModifiers()
	if self:GetStackCount()%2==0 then
		return "flurry_attack_b"
	end

	return "flurry_attack_a"
end

function modifier_pistol_w_active_fury:GetModifierAttackSpeed_Limit()
	return 1
end

function modifier_pistol_w_active_fury:GetModifierProcAttack_Feedback( params )
	self:StartIntervalThink( self.timer )
	self.counter = self.counter - 1
	self:SetStackCount( self.counter )
	self:EditEffects2( self.counter )
	self:PlayEffects3( self.parent, params.target )
	if self.counter<=0 then
		self.success = 1
		self:Pulse( params.target )
		self:Destroy()
	end
end

function modifier_pistol_w_active_fury:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_pistol_w_active_fury:OnIntervalThink()
	self:Destroy()
end

function modifier_pistol_w_active_fury:Pulse( target )
    self:PlayEffects4( target, 100 )
    local direction = target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()
	target:AddNewModifier(
		self.parent, self.ability,
		"modifier_generic_arc_lua",
		{
			dir_x = direction.x,
			dir_y = direction.y,
			duration = 0.2,
			distance = self.kick,
			height = 25,
			activity = ACT_DOTA_FLAIL,
		}
	)
	ApplyDamage( { victim = target, attacker = self.parent, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self.ability } )
end

function modifier_pistol_w_active_fury:ForceDestroy()
	self.forced = true
	self:Destroy()
end

function modifier_pistol_w_active_fury:ShouldUseOverheadOffset() return true end

function modifier_pistol_w_active_fury:PlayEffects1()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "eye_l", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "eye_r", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( effect_cast, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false )
	EmitSoundOn( "Hero_Marci.Unleash.Charged", self:GetParent() )
	EmitSoundOnClient( "Hero_Marci.Unleash.Charged.2D", self:GetParent():GetPlayerOwner() )
end

function modifier_pistol_w_active_fury:PlayEffects2( caster, counter )
	local effect_cast = ParticleManager:CreateParticle( "particles/marci_unleash_stack_golovach.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 0, counter, 0 ) )
	self:AddParticle( effect_cast, false, false, 1, false, true )
	self.effect_cast = effect_cast
end

function modifier_pistol_w_active_fury:EditEffects2( counter )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 0, counter, 0 ) )
end

function modifier_pistol_w_active_fury:PlayEffects3( caster, target )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_pistol_w_active_fury:PlayEffects4( target, radius )
	local effect_cast = ParticleManager:CreateParticle( "particles/pistol_w_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius,radius,radius) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	--EmitSoundOnLocationWithCaster( point, "golovach_r_hit", self:GetParent() )
end

modifier_pistol_w_active_recovery = class({})

function modifier_pistol_w_active_recovery:IsHidden() return false end
function modifier_pistol_w_active_recovery:IsDebuff() return true end
function modifier_pistol_w_active_recovery:IsPurgable() return false end

function modifier_pistol_w_active_recovery:OnCreated( kv )
	self.parent = self:GetParent()
	self.rate = self:GetAbility():GetSpecialValueFor( "recovery_fixed_attack_rate" )
	if not IsServer() then return end
	self.success = kv.success==1
end

function modifier_pistol_w_active_recovery:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_pistol_w_active_recovery:OnDestroy()
	if not IsServer() then return end
	local main = self.parent:FindModifierByNameAndCaster( "modifier_pistol_w_active", self.parent )
	if not main then return end
	if self.forced then return end
	self.parent:AddNewModifier( self.parent, self:GetAbility(), "modifier_pistol_w_active_fury", {})
end

function modifier_pistol_w_active_recovery:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
	}
end

function modifier_pistol_w_active_recovery:GetModifierFixedAttackRate()
	return self.rate
end

function modifier_pistol_w_active_recovery:ForceDestroy()
	self.forced = true
	self:Destroy()
end


modifier_pistol_w_cooldown = class({})

function modifier_pistol_w_cooldown:IsHidden() return false end
function modifier_pistol_w_cooldown:IsPurgable() return false end


modifier_pistol_w_active_animation = class({})

function modifier_pistol_w_active_animation:IsHidden() return true end
function modifier_pistol_w_active_animation:IsDebuff() return false end
function modifier_pistol_w_active_animation:IsPurgable() return false end

function modifier_pistol_w_active_animation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end

function modifier_pistol_w_active_animation:GetActivityTranslationModifiers()
	return "unleash"
end