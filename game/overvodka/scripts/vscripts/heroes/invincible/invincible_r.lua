LinkLuaModifier( "modifier_invincible_r_slow", "heroes/invincible/invincible_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invincible_r_buff", "heroes/invincible/invincible_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invincible_r_debuff", "heroes/invincible/invincible_r", LUA_MODIFIER_MOTION_NONE)
invincible_r = class({})

function invincible_r:Precache(context)
    PrecacheResource("soundfile", "soundevents/invincible_r.vsndevts", context)
    PrecacheResource("particle", "particles/invincible_r_cast.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_cast_arcana.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_cast_self.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_cast_chain.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_cast_chain_arcana.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_marker.vpcf", context)
    PrecacheResource("particle", "particles/grimstroke_soulchain_rope_new.vpcf", context)
    PrecacheResource("particle", "particles/grimstroke_soulchain_rope_new_arcana.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_debuff.vpcf", context)
    PrecacheResource("particle", "particles/invincible_r_debuff_arcana.vpcf", context)
    PrecacheResource("particle", "particles/whatsapp.vpcf", context)
end

function invincible_r:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "invincible_r_arcana"
    end
    return "invincible_r"
end

function invincible_r:OnSpellStart()
    local caster = self:GetCaster()
    local sound = "invincible_r"
    local self_particle = "particles/invincible_r_cast_self.vpcf"
    local cast_particle = "particles/invincible_r_cast.vpcf"
    local cast_chain = "particles/invincible_r_cast_chain.vpcf"
    if caster:HasArcana() then
        sound = "invincible_r_arcana"
        self_particle = "particles/whatsapp.vpcf"
        cast_particle = "particles/invincible_r_cast_arcana.vpcf"
        cast_chain = "particles/invincible_r_cast_chain_arcana.vpcf"
    end
    EmitSoundOn(sound, caster)
    local effect_cast = ParticleManager:CreateParticle( self_particle, PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 2, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 5, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 12, caster:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local effect_cast_caster = ParticleManager:CreateParticle( cast_particle, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast_caster, 0, caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast_caster )
    caster:AddNewModifier(caster, self, "modifier_invincible_r_buff", {duration = self:GetSpecialValueFor("duration")})
    local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		self:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_CLOSEST,
		false
	)
    local found = false
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(
            caster, 
            self, 
            "modifier_invincible_r_slow", 
            {duration = self:GetSpecialValueFor("slow_dur") * ( 1 - enemy:GetStatusResistance() )}
        )
        if not found and enemy:IsHero() then
            enemy:AddNewModifier(caster, self, "modifier_invincible_r_debuff", { duration = self:GetSpecialValueFor("chain_dur") * ( 1 - enemy:GetStatusResistance() ) })
            local effect_cast_target = ParticleManager:CreateParticle( cast_chain, PATTACH_ABSORIGIN_FOLLOW, caster )
            ParticleManager:SetParticleControlEnt( effect_cast_target, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
            ParticleManager:SetParticleControlEnt( effect_cast_target, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
            ParticleManager:ReleaseParticleIndex( effect_cast_target )	
            found = true
        else
            enemy:AddNewModifier(
                caster, 
                self,
                "modifier_knockback",
                {
                    center_x = caster:GetAbsOrigin().x,
                    center_y = caster:GetAbsOrigin().y,
                    center_z = caster:GetAbsOrigin().z,
                    duration = 0.5,
                    knockback_duration = 0.5,
                    knockback_distance = 500,
                    knockback_height = 100
                }
            )
        end
    end
end

modifier_invincible_r_slow = class({})
function modifier_invincible_r_slow:IsHidden() return false end
function modifier_invincible_r_slow:IsDebuff() return true end
function modifier_invincible_r_slow:IsPurgable() return false end

function modifier_invincible_r_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_invincible_r_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

modifier_invincible_r_buff = class({})
function modifier_invincible_r_buff:IsHidden() return false end
function modifier_invincible_r_buff:IsDebuff() return false end
function modifier_invincible_r_buff:IsPurgable() return false end

function modifier_invincible_r_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_invincible_r_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_invincible_r_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_invincible_r_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end

modifier_invincible_r_debuff = class({})

function modifier_invincible_r_debuff:IsPurgable()
	return false
end

function modifier_invincible_r_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.limit = 550
	self:PlayEffects1()
	self:PlayEffects2(true)
    self.effect_lifesteal = 0
	self:StartIntervalThink(0.1)
end

function modifier_invincible_r_debuff:OnDestroy( kv )
	if not IsServer() then return end
	self:PlayEffects2(false)
end

function modifier_invincible_r_debuff:OnIntervalThink()
	local range = self:GetAbility():GetSpecialValueFor( "range" )
	local vector_distance = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local facingAngle = self:GetParent():GetAnglesAsVector().y
	local angleToPair = VectorToAngles(vector_distance).y
	local angleDifference = math.abs(AngleDiff( angleToPair, facingAngle ))
	if angleDifference > 90 then
		if distance >= range then
			self.limit = 0.01
		end
	else
		self.limit = 550
	end
end

function modifier_invincible_r_debuff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_invincible_r_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_TETHERED] = true,
	}
	return state
end

function modifier_invincible_r_debuff:GetModifierMoveSpeed_Limit()
	return self.limit
end

function modifier_invincible_r_debuff:PlayEffects1()
    local debuff = "particles/invincible_r_debuff.vpcf"
    if self:GetCaster():HasArcana() then
        debuff = "particles/invincible_r_debuff_arcana.vpcf"
    end
	local effect_cast1 = ParticleManager:CreateParticle( debuff, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast1, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	self:AddParticle( effect_cast1, false, false, -1, false, false )
    if not self:GetCaster():HasArcana() then
        local effect_cast2 = ParticleManager:CreateParticle( "particles/invincible_r_marker.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        self:AddParticle( effect_cast2, false, false, -1, false, true )
    end
end

function modifier_invincible_r_debuff:PlayEffects2(connect)
    local rope = "particles/grimstroke_soulchain_rope_new.vpcf"
    if self:GetCaster():HasArcana() then
        rope = "particles/grimstroke_soulchain_rope_new_arcana.vpcf"
    end
	if connect then
		self.effect_cast = ParticleManager:CreateParticle( rope, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
		ParticleManager:SetParticleControlEnt( self.effect_cast, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	else
		if self.effect_cast then
			ParticleManager:DestroyParticle( self.effect_cast, false )
			ParticleManager:ReleaseParticleIndex( self.effect_cast )
		end
	end
end