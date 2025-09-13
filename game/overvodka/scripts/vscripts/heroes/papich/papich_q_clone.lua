LinkLuaModifier( "modifier_papich_q_clone", 		"heroes/papich/papich_q_clone", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_papich_q_clone_debuff", 	"heroes/papich/papich_q_clone", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_arc_lua", 		"modifier_generic_arc_lua", 	LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_leashed_lua", 	"modifier_generic_leashed_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_papich_q_clone_blood", 	"heroes/papich/papich_q_clone", LUA_MODIFIER_MOTION_NONE )

papich_q_clone = class({})

function papich_q_clone:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf", context )
	PrecacheResource( "particle", "particles/slark_ti6_pounce_trail_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_start_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_ground_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_leash_new.vpcf", context)
	PrecacheResource( "particle", "particles/pa_persona_shard_fan_of_knives_blades_new.vpcf", context)
end

function papich_q_clone:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_papich_q_clone",
		{}
	)
	local sound_cast = "papich_q_clone"
	EmitSoundOn( sound_cast, caster )
end

modifier_papich_q_clone_blood = class({})
function modifier_papich_q_clone_blood:IsDebuff() return true end
function modifier_papich_q_clone_blood:IsHidden() return false end
function modifier_papich_q_clone_blood:IsPurgable() return true end
function modifier_papich_q_clone_blood:IsPurgeException() return false end
function modifier_papich_q_clone_blood:IsStunDebuff() return false end
function modifier_papich_q_clone_blood:RemoveOnDeath() return true end

function modifier_papich_q_clone_blood:OnCreated(params)
	self.blood_damage = self:GetAbility():GetSpecialValueFor("blood_damage")
	self:StartIntervalThink(1)
end
function modifier_papich_q_clone_blood:OnIntervalThink()
	if not IsServer() then return end
	self.dmg = self:GetParent():GetHealth() * self.blood_damage * 0.01
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.dmg, damage_type = DAMAGE_TYPE_PURE })
end

function modifier_papich_q_clone_blood:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_papich_q_clone_blood:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf"
end

function modifier_papich_q_clone_blood:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_papich_q_clone = class({})

function modifier_papich_q_clone:IsHidden()
	return true
end
function modifier_papich_q_clone:IsDebuff()
	return false
end
function modifier_papich_q_clone:IsStunDebuff()
	return false
end
function modifier_papich_q_clone:IsPurgable()
	return true
end

function modifier_papich_q_clone:OnCreated( kv )
	self.parent = self:GetParent()
	local speed = self:GetAbility():GetSpecialValueFor( "pounce_speed" )
	local distance = self:GetAbility():GetSpecialValueFor( "pounce_distance" )
	self.radius = self:GetAbility():GetSpecialValueFor( "pounce_radius" )
	self.leash_radius = self:GetAbility():GetSpecialValueFor( "leash_radius" )
	self.leash_duration = self:GetAbility():GetSpecialValueFor( "leash_duration" )
	self.blood_duration = self:GetAbility():GetSpecialValueFor( "blood_duration" )
	self.damage = self:GetAbility():GetSpecialValueFor( "end_damage" )
	self.end_damage_radius = self:GetAbility():GetSpecialValueFor( "end_radius" )
	local duration = distance/speed
	local height = 160
	if not IsServer() then return end
	self.arc = self.parent:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_generic_arc_lua",
		{
			speed = speed,
			duration = duration,
			distance = distance,
			height = height,
		}
	)
	self.arc:SetEndCallback(function( interrupted )
		if self:IsNull() then return end
		self.arc = nil
		self:Destroy()
	end)
	self:SetDuration( duration, true )
	self:GetAbility():SetActivated( false )
	self:StartIntervalThink( 0.1 )
	self:OnIntervalThink()
	self:PlayEffects()
end

function modifier_papich_q_clone:OnDestroy()
	if not IsServer() then return end
	self:GetAbility():SetActivated( true )
	GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), 100, false )
	if self.arc and not self.arc:IsNull() then
		self.arc:Destroy()
	end
end

function modifier_papich_q_clone:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_papich_q_clone:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		0,
		FIND_CLOSEST,
		false
	)
	local target
	for _,enemy in pairs(enemies) do
		if not enemy:IsIllusion() then
			target = enemy
			break
		end
	end
	if not target then return end
	target:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_papich_q_clone_debuff",
		{
			duration = self.leash_duration,
			radius = self.leash_radius,
			purgable = false,
		}
	)
	self:PlayEffects1()
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self.end_damage_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false) 

	for _,unit in pairs(targets) do
		ApplyDamage({victim = unit, attacker = self:GetParent(), damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})
		if unit and not unit:IsNull() then
			unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_papich_q_clone_blood", {duration = self.blood_duration})
		end
	end
	local sound_cast = "Hero_Slark.Pounce.Impact"
	EmitSoundOn( sound_cast, target )
	self:Destroy()
end

function modifier_papich_q_clone:GetEffectName()
	return "particles/slark_ti6_pounce_trail_new.vpcf"
end

function modifier_papich_q_clone:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_papich_q_clone:PlayEffects()
	local particle_cast = "particles/slark_ti6_pounce_start_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_papich_q_clone:PlayEffects1()
	local particle_cast = "particles/pa_persona_shard_fan_of_knives_blades_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


modifier_papich_q_clone_debuff = class({})

function modifier_papich_q_clone_debuff:IsHidden()
	return false
end
function modifier_papich_q_clone_debuff:IsDebuff()
	return true
end
function modifier_papich_q_clone_debuff:IsStunDebuff()
	return false
end
function modifier_papich_q_clone_debuff:IsPurgable()
	return false
end
function modifier_papich_q_clone_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_papich_q_clone_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.radius = kv.radius
	self.leash = self:GetParent():AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"modifier_generic_leashed_lua",
		kv
	)
	self.leash:SetEndCallback(function()
		if self:IsNull() then return end
		self.leash = nil
		self:Destroy()
	end)
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_papich_q_clone_debuff:OnDestroy()
	if not IsServer() then return end
	if self.leash and not self.leash:IsNull() then
		self.leash:Destroy()
	end
	local sound_cast = "papich_q_clone_success"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_papich_q_clone_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_papich_q_clone_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_papich_q_clone_debuff:PlayEffects1()
	local particle_cast = "particles/slark_ti6_pounce_ground_new.vpcf"
	local sound_cast = "papich_q_clone_success"
	local caster = self:GetCaster()
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		caster,
		PATTACH_WORLDORIGIN,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_papich_q_clone_debuff:PlayEffects2()
	local particle_cast = "particles/slark_ti6_pounce_leash_new.vpcf"
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 3, self:GetParent():GetOrigin() )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end