ebanko_w = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_w", "heroes/ebanko/ebanko_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ebanko_w_slow", "heroes/ebanko/ebanko_w", LUA_MODIFIER_MOTION_NONE )

function ebanko_w:GetIntrinsicModifierName()
	return "modifier_ebanko_w"
end

function ebanko_w:Precache( context )
	PrecacheResource( "soundfile", "soundevents/fof.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/ya_tebya.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", context )
end

function ebanko_w:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then
		return
	end
	local duration = self:GetSpecialValueFor( "dur" )
	local slow_duration = self:GetSpecialValueFor( "slow_duration" )
	local damage = self:GetSpecialValueFor( "damage" )
	local stack = self:GetSpecialValueFor("stack")
	local kills = caster:GetKills()
	damage = damage + kills * stack
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, 
	}
	if not target:IsDebuffImmune() and not target:IsMagicImmune() then
		local knockback = target:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_knockback",
			{
				center_x = 0,
				center_y = 0,
				center_z = 0,
				duration = duration,
				knockback_duration = duration,
				knockback_distance = 0,
				knockback_height = 300
			}
		)
		target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = duration * (1 - target:GetStatusResistance()) })
		target:AddNewModifier(caster, self, "modifier_ebanko_w_slow", { duration = slow_duration * (1 - target:GetStatusResistance()) })
	end
	ApplyDamage( damageTable )
	self:PlayEffects( target )
	self:PlayEffects1( target )

end

function ebanko_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	EmitSoundOn( "fof", target )
	EmitSoundOn( "ya_tebya", target )
end

function ebanko_w:PlayEffects1( target )
	local particle_cast = "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
end

modifier_ebanko_w_slow = class({})

function modifier_ebanko_w_slow:IsHidden()
	return false
end
function modifier_ebanko_w_slow:IsDebuff()
	return true
end
function modifier_ebanko_w_slow:IsPurgable()
	return true
end
function modifier_ebanko_w_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
end
function modifier_ebanko_w_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end
function modifier_ebanko_w_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end

modifier_ebanko_w = class({})
function modifier_ebanko_w:IsHidden()
	return true
end

function modifier_ebanko_w:IsDebuff()
	return false
end

function modifier_ebanko_w:IsPurgable()
	return false
end

function modifier_ebanko_w:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.pseudoseed = RandomInt( 1, 100 )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	if not IsServer() then return end
end

function modifier_ebanko_w:OnRefresh( kv )
	self:OnCreated( kv )	
end

function modifier_ebanko_w:OnRemoved()
end

function modifier_ebanko_w:OnDestroy()
end

function modifier_ebanko_w:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
	return funcs
end

function modifier_ebanko_w:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:IsIllusion() then return end
	local filter = UnitFilter(
		params.target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.parent:GetTeamNumber()
	)
	if filter~=UF_SUCCESS then return end
	if not RollPseudoRandomPercentage( self.chance, self.pseudoseed, self.parent ) then return end
	self:Bash( params.target)
end

function modifier_ebanko_w:Bash(target)
	if target:TriggerSpellAbsorb( self:GetAbility() ) then
		return
	end
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "dur" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.stack = self:GetAbility():GetSpecialValueFor( "stack" )
	self.kills = self:GetParent():GetKills()
	self.dmg = self.damage + self.kills * self.stack
	local damageTable = {
		victim = target,
		attacker = self:GetParent(),
		damage = self.dmg,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), 
	}
	if not target:IsDebuffImmune() and not target:IsMagicImmune() then
		local knockback = target:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_knockback",
			{
				center_x = 0,
				center_y = 0,
				center_z = 0,
				duration = self.duration,
				knockback_duration = self.duration,
				knockback_distance = 0,
				knockback_height = 300
			}
		)
		target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_generic_stunned_lua", { duration = self.duration })
		target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ebanko_w_slow", { duration = self.slow_duration * (1 - target:GetStatusResistance()) })
	end
	ApplyDamage( damageTable )
	self:PlayEffects( target )
	self:PlayEffects1( target )
end

function modifier_ebanko_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	EmitSoundOn( "fof", target )
	EmitSoundOn( "ya_tebya", target )
end

function modifier_ebanko_w:PlayEffects1( target )
	local particle_cast = "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
end