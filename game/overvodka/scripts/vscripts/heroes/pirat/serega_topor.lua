LinkLuaModifier( "modifier_serega_topor", "heroes/pirat/serega_topor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_ring_lua", "modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_topor", "heroes/pirat/serega_topor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_lifesteal_lua", "modifier_generic_lifesteal_lua", LUA_MODIFIER_MOTION_NONE )

serega_topor = class({})

function serega_topor:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/serega_topor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_start.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_marci_sidekick.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_axe.vpcf", context )
	PrecacheResource( "particle", "particles/pirat_r_attack.vpcf", context )
	PrecacheResource( "particle", "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf", context )
end

function serega_topor:Spawn()
	if not IsServer() then return end
end

function serega_topor:OnSpellStart()
	local caster = self:GetCaster()
	local topor_duration = self:GetSpecialValueFor( "topor_duration" )
	caster:AddNewModifier( caster, self, "modifier_topor", { duration = topor_duration } )
	local radius = self:GetSpecialValueFor( "radius" )
	local speed = self:GetSpecialValueFor( "speed" )
	local buff_duration = self:GetSpecialValueFor( "buff_duration" )
	local effect = self:PlayEffects( radius, speed )
	local effect_new = self:PlayEffectsNew()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_lifesteal_lua",
		{ duration = buff_duration }
	)
	local pulse = caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_ring_lua",
		{
			end_radius = radius,
			speed = speed,
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY,
			target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}
	)
	pulse:SetCallback( function( enemy )
		self:OnHit( enemy )
	end)
end

function serega_topor:OnHit( enemy )
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor( "radius" )
	local damage_min = self:GetSpecialValueFor( "damage_min" )
	local damage_max = self:GetSpecialValueFor( "damage_max" )
	local slow_min = self:GetSpecialValueFor( "slow_min" )
	local slow_max = self:GetSpecialValueFor( "slow_max" )
	local duration = self:GetSpecialValueFor( "slow_duration" )
	local distance = (enemy:GetOrigin()-caster:GetOrigin()):Length2D()
	local pct = distance/radius
	pct = math.min(pct,1)
	local damage = damage_min + (damage_max-damage_min)*pct
	local slow = slow_min + (slow_max-slow_min)*pct
	EmitSoundOn( "Ability.PlasmaFieldImpact", enemy )
	local damageTable = {
		victim = enemy,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	ApplyDamage(damageTable)
	if enemy and not enemy:IsNull() then
		enemy:AddNewModifier(caster, self, "modifier_dark_willow_debuff_fear", {duration = duration})
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_serega_topor",
			{
				duration = duration,
				slow = slow,
			}
		)
	end
end

function serega_topor:PlayEffects( radius, speed )
	local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_scepter_ground_proj.vpcf"
	local sound_cast = "serega_topor"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( speed, radius, 1 ) )
	EmitSoundOn( sound_cast, self:GetCaster() )
	return effect_cast
end

function serega_topor:PlayEffectsNew()
	local particle_cast = "particles/pirat_r_start.vpcf"
	local effect_cast_new = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast_new )
end


modifier_topor = class({})

function modifier_topor:IsPurgable()
	return false
end

function modifier_topor:OnCreated( kv )
	if not IsServer() then return end
	self.as = 1000
	self.bat = self:GetAbility():GetSpecialValueFor( "bat" )
	self.speed = self:GetAbility():GetSpecialValueFor( "bonus_speed" )
	self.projectile = 900
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.range = self:GetAbility():GetSpecialValueFor( "range" )
	if self:GetParent():GetUnitName() == "npc_dota_hero_rubick" then
		self.range = 0
		self.projectile = 0
	end
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_max" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
	self:StartIntervalThink( 0.4 )
	self:OnIntervalThink()
end

function modifier_topor:OnIntervalThink()
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not parent or parent:IsNull() or not ability then return end

    self:PlayEffects()

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetOrigin(),
        nil,
        self.slow_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _,enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() then
            enemy:AddNewModifier(
                parent,
                ability,
                "modifier_razor_plasma_field_lua",
                { duration = 1, slow = self.slow }
            )
        end
    end

    local origin    = parent:GetAbsOrigin()
    local baseDir   = parent:GetForwardVector(); baseDir.z = 0
    if baseDir:Length2D() < 0.01 then baseDir = Vector(1,0,0) end

    local speed     = 1500
    local distance  = 600
    local startR    = 115
    local endR      = 120

    local baseAngle = math.atan2(baseDir.y, baseDir.x)
    local step      = math.pi / 4

    local infoBase = {
        Ability            = ability,
        EffectName         = "particles/pirat_r_axe.vpcf",
        vSpawnOrigin       = origin,
        fDistance          = distance,
        fStartRadius       = startR,
        fEndRadius         = endR,
        Source             = parent,
        bHasFrontalCone    = false,
        bReplaceExisting   = false,
        iUnitTargetTeam    = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType    = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags   = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit       = true,
        bProvidesVision    = true,
        iVisionRadius      = 200,
        iVisionTeamNumber  = parent:GetTeamNumber(),
    }

    for i = 0, 7 do
        local ang = baseAngle + i * step
        local dir = Vector(math.cos(ang), math.sin(ang), 0)
        local info = table.shallow_copy and table.shallow_copy(infoBase) or {}
        if not info.Ability then
            for k,v in pairs(infoBase) do info[k] = v end
        end
        info.vVelocity = dir * speed
        ProjectileManager:CreateLinearProjectile(info)
    end
end


function modifier_topor:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_topor:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() ~= "npc_dota_hero_rubick" then
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
	end
end

function modifier_topor:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end
function modifier_topor:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end
function modifier_topor:GetModifierTotalDamageOutgoing_Percentage()
    return self.bonus_dmg
end
function modifier_topor:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_topor:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

function modifier_topor:GetModifierProjectileSpeedBonus()
	return self.projectile
end

function modifier_topor:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_topor:GetModifierModelChange()
	return "models/heroes/troll_warlord/troll_warlord.vmdl"
end

function modifier_topor:GetModifierModelScale()
	return 30
end

function modifier_topor:GetModifierProjectileName()
	return "particles/pirat_r_attack.vpcf"
end

function modifier_topor:GetAttackSound()
	return "Hero_TrollWarlord.Attack"
end

function modifier_topor:GetModifierAttackSpeedBonus_Constant( params )
	return self.as
end
function modifier_topor:PlayEffects()
	local particle_cast = "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


modifier_serega_topor = class({})

function modifier_serega_topor:IsHidden()
	return false
end
function modifier_serega_topor:IsDebuff()
	return true
end
function modifier_serega_topor:IsPurgable()
	return true
end

function modifier_serega_topor:OnCreated( kv )
	if not IsServer() then return end
	self:SetHasCustomTransmitterData( true )
	self.slow = kv.slow
	self:SetStackCount( self.slow )
end

function modifier_serega_topor:OnRefresh( kv )
	if not IsServer() then return end
	self.slow = math.max(kv.slow,self.slow)
	self:SetStackCount( self.slow )
end


function modifier_serega_topor:AddCustomTransmitterData()
	local data = {
		slow = self.slow
	}

	return data
end

function modifier_serega_topor:HandleCustomTransmitterData( data )
	self.slow = data.slow
end

function modifier_serega_topor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_serega_topor:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end