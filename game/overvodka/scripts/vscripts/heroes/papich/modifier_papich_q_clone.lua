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

function modifier_papich_q_clone:OnRefresh( kv )
end
function modifier_papich_q_clone:OnRemoved()
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
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
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
		unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_papich_q_clone_blood", {duration = self.blood_duration})
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
