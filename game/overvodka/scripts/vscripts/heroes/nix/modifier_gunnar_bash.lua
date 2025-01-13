modifier_gunnar_bash = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_gunnar_bash:IsHidden()
	return true
end

function modifier_gunnar_bash:IsDebuff()
	return false
end

function modifier_gunnar_bash:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_gunnar_bash:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.pseudoseed = RandomInt( 1, 100 )

	-- references
	self.chance = self:GetAbility():GetSpecialValueFor( "chance_pct" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor" )
	self.armor_duration = self:GetAbility():GetSpecialValueFor( "armor_duration" )
	self.knockback_duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" )
	self.knockback_distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" )
	self.knockback_height = self:GetAbility():GetSpecialValueFor( "knockback_height" )


	if not IsServer() then return end
end

function modifier_gunnar_bash:OnRefresh( kv )
	self:OnCreated( kv )	
end

function modifier_gunnar_bash:OnRemoved()
end

function modifier_gunnar_bash:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_gunnar_bash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function modifier_gunnar_bash:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if self.parent:PassivesDisabled() then return end
	if not self.ability:IsFullyCastable() then return end
	if self.parent:IsIllusion() then return end
	if params.target:IsMagicImmune() then return end

	-- unit filter
	local filter = UnitFilter(
		params.target,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.parent:GetTeamNumber()
	)
	if filter~=UF_SUCCESS then return end

	-- roll pseudo random
	if not RollPseudoRandomPercentage( self.chance, self.pseudoseed, self.parent ) then return end

	-- set cooldown
	self.ability:UseResources( false, false, false, true )

	-- proc
	self:Bash( params.target, false )
end

--------------------------------------------------------------------------------
-- Helper
function modifier_gunnar_bash:Bash( target, double )
	local direction = target:GetOrigin()-self.parent:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local dist = self.knockback_distance
	if double then
		dist = dist*2
	end

	-- create arc
	target:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			dir_x = direction.x,
			dir_y = direction.y,
			duration = self.knockback_duration,
			distance = dist,
			height = self.knockback_height,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)

	-- stun
	target:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = self.duration } -- kv
	)
	target:AddNewModifier(
		self.parent, -- player source
		self.ability, -- ability source
		"modifier_generic_armor", -- modifier name
		{ duration = self.armor_duration } -- kv
	)
	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self.parent,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability, --Optional.
	}
	ApplyDamage(damageTable)

	-- apply bonus damage
	damageTable.damage = damage
	ApplyDamage( damageTable )

	-- play effects
	self:PlayEffects( target, target:IsCreep() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_gunnar_bash:PlayEffects( target, isCreep )
	-- Get Resources
	local particle_cast = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf"
	local sound_cast = "gunnar"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end