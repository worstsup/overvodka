chef_r = class({})
LinkLuaModifier( "modifier_chef_r", "heroes/lev/chef_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chef_r_slow", "heroes/lev/chef_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE )

function chef_r:Precache(context)
    PrecacheResource( "soundfile", "soundevents/chef_r.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/chef_r_start.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/chef_r_hit_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/chef_r_hit_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/chef_r_throw.vsndevts", context )
    PrecacheResource( "particle", "particles/chef_r_proj_1.vpcf", context )
    PrecacheResource( "particle", "particles/chef_r_proj_2.vpcf", context )
    PrecacheResource( "particle", "particles/chef_r_proj_3.vpcf", context )
    PrecacheResource( "particle", "particles/chef_r_proj_4.vpcf", context )
    PrecacheResource( "particle", "particles/chef_r.vpcf", context )
    PrecacheResource( "particle", "particles/chef_r_aoe.vpcf", context )
end

function chef_r:OnAbilityPhaseStart()
    EmitSoundOn( "chef_r_start", self:GetCaster() )
    return true
end

function chef_r:OnAbilityPhaseInterrupted()
    StopSoundOn( "chef_r_start", self:GetCaster() )
end

function chef_r:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn( "chef_r", self:GetCaster() )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_chef_r", { duration = self:GetSpecialValueFor( "duration" ) } )
end

function chef_r:OnProjectileHitHandle(target, location, projectileHandle)
    if not target and not location then return end
    local caster = self:GetCaster()
    local impact_point = location or target:GetAbsOrigin()
    local damage = self:GetSpecialValueFor("damage")
    local disarm_duration = self:GetSpecialValueFor("disarm_duration")
    local slow_duration = self:GetSpecialValueFor("slow_duration")
    local aoe_radius = self:GetSpecialValueFor("aoe_radius")
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        impact_point,
        nil,
        aoe_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    local effect_cast = ParticleManager:CreateParticle("particles/chef_r_aoe.vpcf", PATTACH_WORLDORIGIN, target)
    ParticleManager:SetParticleControl(effect_cast, 0, impact_point)
    ParticleManager:ReleaseParticleIndex(effect_cast)
    EmitSoundOn("chef_r_hit_" .. RandomInt(1,2), target)
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, self, "modifier_generic_disarmed_lua", {
            duration = disarm_duration
        })
        enemy:AddNewModifier(caster, self, "modifier_chef_r_slow", {
            duration = slow_duration
        })
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        })
    end
end

modifier_chef_r = class({})

function modifier_chef_r:IsPurgable() return false end

function modifier_chef_r:OnCreated(kv)
    if not IsServer() then return end
    self.radius     = self:GetAbility():GetSpecialValueFor("radius")
    self.interval   = self:GetAbility():GetSpecialValueFor("interval")
    local effect_cast = ParticleManager:CreateParticle( "particles/chef_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetParent():GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		self:GetParent():GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetParent(),
		PATTACH_CENTER_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(),
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
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_chef_r:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetParent()
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )
    if #enemies == 0 then return end
    local max_enemies = self:GetAbility():GetSpecialValueFor("max_enemies")
    for num,enemy in pairs(enemies) do
        if num > max_enemies then break end
        local proj_info = {
            Target               = enemy,
            Source               = caster,
            Ability              = self:GetAbility(),
            iMoveSpeed           = 1000,
            bDodgeable           = true,
            bProvidesVision      = true,
            iVisionRadius        = 200,
            iVisionTeamNumber    = caster:GetTeamNumber(),
        }
        local effects = {
            "particles/chef_r_proj_1.vpcf",
            "particles/chef_r_proj_2.vpcf",
            "particles/chef_r_proj_3.vpcf",
            "particles/chef_r_proj_4.vpcf"
        }
        proj_info.EffectName = effects[RandomInt(1, 4)]
        ProjectileManager:CreateTrackingProjectile(proj_info)
        EmitSoundOn( "chef_r_throw", caster )
    end
end

function modifier_chef_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_chef_r:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("move_speed")
end

function modifier_chef_r:GetModifierModelScale()
    return 25
end

modifier_chef_r_slow = class({})

function modifier_chef_r_slow:IsPurgable() return true end
function modifier_chef_r_slow:IsDebuff() return true end
function modifier_chef_r_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_chef_r_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end