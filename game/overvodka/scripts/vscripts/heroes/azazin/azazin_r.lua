LinkLuaModifier( "modifier_azazin_r", "heroes/azazin/azazin_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azazin_r_debuff", "heroes/azazin/azazin_r", LUA_MODIFIER_MOTION_NONE )

azazin_r = class({})
k = 0
function azazin_r:Precache(context)
    PrecacheResource( "particle", "particles/azazin_r_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/azazin_r_radius.vpcf", context )
    PrecacheResource( "particle", "particles/azazin_r_debuff.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/azazin_r_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/azazin_r_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/azazin_r.vsndevts", context )
    PrecacheResource( "model", "models/azazin/azazin_girl.vmdl", context )
end

function azazin_r:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end
function azazin_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function azazin_r:GetCastRange(location, target)
    return self:GetSpecialValueFor( "radius" )
end

function azazin_r:OnToggle()
	local caster = self:GetCaster()
	local toggle = self:GetToggleState()

	if toggle then
		self.modifier = caster:AddNewModifier( caster, self, "modifier_azazin_r", {})
		self:EndCooldown()
	else
		if self.modifier and not self.modifier:IsNull() then
			self.modifier:Destroy()
		end
		self.modifier = nil
		self:UseResources(false, false, false, true)
	end
end

modifier_azazin_r = class({})

function modifier_azazin_r:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_azazin_r:IsPurgable()
	return false
end

function modifier_azazin_r:IsAura() return true end
function modifier_azazin_r:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_azazin_r:GetModifierAura() return "modifier_azazin_r_debuff" end
function modifier_azazin_r:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_azazin_r:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_azazin_r:OnCreated( kv )
	if not IsServer() then return end
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_second" )
    self.gold_per_second = self:GetAbility():GetSpecialValueFor( "gold_per_second" )
    local particle = ParticleManager:CreateParticle("particles/azazin_r_radius.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
    self:AddParticle(particle, false, false, -1, false, false)
	self.damageTable = 
	{
		attacker = self:GetParent(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	local interval = 1
	self.parent = self:GetParent()
	self:Burn()
	self:StartIntervalThink( interval )
	if k == 0 then
        EmitSoundOnLocationWithCaster(self.parent:GetAbsOrigin(),"azazin_r_1", self.parent)
        k = 1
    else
        EmitSoundOnLocationWithCaster(self.parent:GetAbsOrigin(),"azazin_r_2", self.parent)
        k = 0
    end
    EmitSoundOn("azazin_r", self.parent)
end

function modifier_azazin_r:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
    return funcs
end

function modifier_azazin_r:GetModifierProjectileName()
    return "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf"
end

function modifier_azazin_r:GetModifierModelChange()
    return "models/azazin/azazin_girl.vmdl"
end

function modifier_azazin_r:GetAttackSound()
	return "Hero_DarkWillow.Attack"
end

function modifier_azazin_r:OnDestroy()
	if not IsServer() then return end
	StopSoundOn("azazin_r", self.parent)
end

function modifier_azazin_r:OnIntervalThink()
	local mana = self.parent:GetMana()
	if mana < self.manacost then
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
		return
	end
	self:Burn()
end

function modifier_azazin_r:Burn()
	self.parent:SpendMana( self.manacost, self:GetAbility() )

	local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		if enemy:IsRealHero() and not enemy:IsIllusion() then
			PlayerResource:SpendGold(enemy:GetPlayerID(), self.gold_per_second, 4)
			self.parent:ModifyGold(self.gold_per_second, false, 0)
		end
	end
end

function modifier_azazin_r:GetEffectName()
	return "particles/azazin_r_ambient.vpcf"
end

function modifier_azazin_r:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_azazin_r_debuff = class({})

function modifier_azazin_r_debuff:IsPurgable()
    return false
end

function modifier_azazin_r_debuff:OnCreated()
    if not IsServer() then return end
end

function modifier_azazin_r_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_azazin_r_debuff:GetEffectName()
    return "particles/azazin_r_debuff.vpcf"
end

function modifier_azazin_r_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_azazin_r_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_azazin_r_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_slow")
end