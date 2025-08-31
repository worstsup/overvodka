zolo_stopapupa = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_stopapupa", "heroes/zolo/zolo_stopapupa", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zolo_slow", "heroes/zolo/zolo_stopapupa", LUA_MODIFIER_MOTION_NONE )

function zolo_stopapupa:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

function zolo_stopapupa:OnSpellStart()
end

function zolo_stopapupa:OnOrbImpact( params )
	local duration = self:GetSpecialValueFor( "armor_duration" )
	local bash = self:GetSpecialValueFor( "ministun_duration" )
	local chance = self:GetSpecialValueFor( "chance" )
	local str = self:GetCaster():GetStrength()
	local damage = self:GetSpecialValueFor( "str_damage" ) * str * 0.01
	local random_chance = RandomInt(1, 100)
	if random_chance <= chance then
		self:GetCaster():ModifyGold(300, false, 0)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self:GetCaster(), 300, nil)
	end
	self:PlayEffects(params.target)
	ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
	if params.target and not params.target:IsNull() then
		params.target:AddNewModifier(
			self:GetCaster(), 
			self, 
			"modifier_zolo_stopapupa", 
			{ duration = duration }
		)
		params.target:AddNewModifier(
			self:GetCaster(), 
			self, 
			"modifier_dark_willow_debuff_fear", 
			{ duration = bash }
		)
		params.target:AddNewModifier(
			self:GetCaster(), 
			self, 
			"modifier_zolo_slow", 
			{ duration = bash }
		)
	end
end

function zolo_stopapupa:PlayEffects(target)
	local particle_cast = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf"
	local Chance = RandomInt(1,5)
	if Chance == 1 then
		EmitSoundOn( "mayas", self:GetCaster() )
	elseif Chance == 2 then
		EmitSoundOn( "stopapupa", self:GetCaster() )
	elseif Chance == 3 then
		EmitSoundOn( "nizkaya", self:GetCaster() )	
	elseif Chance == 4 then
		EmitSoundOn( "raif", self:GetCaster() )
	elseif Chance == 5 then
		EmitSoundOn( "snadom", self:GetCaster() )	
	end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_zolo_slow = class({})

function modifier_zolo_slow:IsHidden() return true end
function modifier_zolo_slow:IsDebuff() return true end
function modifier_zolo_slow:IsStunDebuff() return false end
function modifier_zolo_slow:IsPurgable() return true end

function modifier_zolo_slow:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_zolo_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_zolo_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end


modifier_zolo_stopapupa = class({})

function modifier_zolo_stopapupa:IsHidden() return false end
function modifier_zolo_stopapupa:IsDebuff() return true end
function modifier_zolo_stopapupa:IsStunDebuff() return false end
function modifier_zolo_stopapupa:IsPurgable() return true end

function modifier_zolo_stopapupa:OnCreated( kv )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_zolo_stopapupa:OnRefresh( kv )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
end

function modifier_zolo_stopapupa:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_zolo_stopapupa:GetModifierPhysicalArmorBonus()
	return -self.armor
end