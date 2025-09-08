LinkLuaModifier( "modifier_gunnar_bash", "heroes/nix/gunnar_bash", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_armor", "modifier_generic_armor", LUA_MODIFIER_MOTION_NONE )

gunnar_bash = class({})

function gunnar_bash:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/gunnar.vsndevts", context )
end

function gunnar_bash:Spawn()
	if not IsServer() then return end
end

function gunnar_bash:GetIntrinsicModifierName()
	return "modifier_gunnar_bash"
end


modifier_gunnar_bash = class({})

function modifier_gunnar_bash:IsHidden()
	return true
end
function modifier_gunnar_bash:IsDebuff()
	return false
end
function modifier_gunnar_bash:IsPurgable()
	return false
end

function modifier_gunnar_bash:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.pseudoseed = RandomInt( 1, 100 )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance_pct" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	self.armor_duration = self:GetAbility():GetSpecialValueFor( "armor_duration" )
	self.knockback_duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )
	self.knockback_height = self:GetAbility():GetSpecialValueFor( "knockback_height" )
	if not IsServer() then return end
end

function modifier_gunnar_bash:OnRefresh( kv )
	self:OnCreated( kv )	
end

function modifier_gunnar_bash:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_gunnar_bash:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if self.parent:PassivesDisabled() then return end
	if not self.ability:IsFullyCastable() then return end
	if self.parent:IsIllusion() then return end
	if params.target:IsMagicImmune() then return end
	local filter = UnitFilter(
		params.target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.parent:GetTeamNumber()
	)
	if filter~=UF_SUCCESS then return end
	if not RollPseudoRandomPercentage( self.chance, self.pseudoseed, self.parent ) then return end
	self.ability:UseResources( false, false, false, true )
	self:Bash( params.target )
end

function modifier_gunnar_bash:Bash( target )

	target:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_knockback",
		{
			center_x = target:GetAbsOrigin().x,
			center_y = target:GetAbsOrigin().y,
			center_z = target:GetAbsOrigin().z,
			duration = self.knockback_duration,
			knockback_duration = self.knockback_duration,
			knockback_distance = 0,
			knockback_height = self.knockback_height,
		}
	)
	target:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_generic_stunned_lua",
		{ duration = self.duration }
	)
	target:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_generic_armor",
		{ duration = self.armor_duration }
	)
	self:PlayEffects( target, target:IsCreep() )
	local damageTable = {
		victim = target,
		attacker = self.parent,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability,
	}
	ApplyDamage(damageTable)
end

function modifier_gunnar_bash:PlayEffects( target, isCreep )
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf", PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "gunnar", target )
end