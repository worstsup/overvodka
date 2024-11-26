-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_snapfire_lil_shredder_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_snapfire_lil_shredder_lua:IsHidden()
	return false
end

function modifier_snapfire_lil_shredder_lua:IsDebuff()
	return false
end

function modifier_snapfire_lil_shredder_lua:IsStunDebuff()
	return false
end

function modifier_snapfire_lil_shredder_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_snapfire_lil_shredder_lua:OnCreated( kv )
	-- references
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.attacks = self:GetAbility():GetOrbSpecialValueFor( "buffed_attacks", "e" )
		self.damage = self:GetAbility():GetOrbSpecialValueFor( "damage", "e" )
		self.range_bonus = self:GetAbility():GetOrbSpecialValueFor( "attack_range_bonus", "e" )
	else
		self.attacks = 6
		self.damage = 105
		self.range_bonus = 275
	end
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		self.damage = self:GetCaster():GetAttackDamage() + self.damage + 50
	end
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	self.records = {}

	-- play Effects & Sound
	self:PlayEffects()
	local sound_cast = "dimon"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_snapfire_lil_shredder_lua:OnRefresh( kv )
	-- references
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.attacks = self:GetAbility():GetOrbSpecialValueFor( "buffed_attacks", "e" )
		self.damage = self:GetAbility():GetOrbSpecialValueFor( "damage", "e" )
		self.range_bonus = self:GetAbility():GetOrbSpecialValueFor( "attack_range_bonus", "e" )
	else
		self.attacks = 6
		self.damage = 105
		self.range_bonus = 275
	end
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		self.damage = self:GetCaster():GetAttackDamage() + self.damage + 70
	end
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	-- play sound
	local sound_cast = "dimon"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_snapfire_lil_shredder_lua:OnRemoved()
end

function modifier_snapfire_lil_shredder_lua:OnDestroy()
	if not IsServer() then return end

	-- stop sound
	local sound_cast = "dimon"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_snapfire_lil_shredder_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_snapfire_lil_shredder_lua:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=0 then return end

	-- record attack
	self.records[params.record] = true

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
	EmitSoundOn( sound_cast, self:GetParent() )

	-- decrement stack
	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end

function modifier_snapfire_lil_shredder_lua:OnAttackLanded( params )
	if self.records[params.record] then
		-- add modifier
		params.target:AddNewModifier(
			self:GetParent(), -- player source
			self:GetAbility(), -- ability source
			"modifier_snapfire_lil_shredder_lua_debuff", -- modifier name
			{ duration = self.slow } -- kv
		)

	end

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Target"
	EmitSoundOn( sound_cast, params.target )
end

function modifier_snapfire_lil_shredder_lua:OnAttackRecordDestroy( params )
	if self.records[params.record] then
		self.records[params.record] = nil

		-- if table is empty and no stack left, destroy
		if next(self.records)==nil and self:GetStackCount()<=0 then
			self:Destroy()
		end
	end
end

function modifier_snapfire_lil_shredder_lua:GetModifierProjectileName()
	if self:GetStackCount()<=0 then return end
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
end

function modifier_snapfire_lil_shredder_lua:GetModifierOverrideAttackDamage()
	if self:GetStackCount()<=0 then return end
	return self.damage
end

function modifier_snapfire_lil_shredder_lua:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function modifier_snapfire_lil_shredder_lua:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return self.as_bonus
end

function modifier_snapfire_lil_shredder_lua:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount()<=0 then return end
	return self.bat
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_snapfire_lil_shredder_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end