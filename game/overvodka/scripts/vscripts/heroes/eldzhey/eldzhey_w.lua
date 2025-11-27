LinkLuaModifier( "modifier_eldzhey_w_heal", "heroes/eldzhey/eldzhey_w", LUA_MODIFIER_MOTION_NONE )

eldzhey_w = class({})

function eldzhey_w:Precache( context )
	PrecacheResource( "particle", "particles/eldzhey_w_cast.vpcf", context )
	PrecacheResource( "particle", "particles/eldzhey_w_heal.vpcf", context )
	PrecacheResource( "particle", "particles/eldzhey_w_damage.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/nepar.vsndevts", context )
end

function eldzhey_w:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function eldzhey_w:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCaster()
	if caster:HasModifier("modifier_eldzhey_e") then
		caster:RemoveModifierByName("modifier_eldzhey_e")
	end
	caster:Purge( false, true, false, false, false )
	caster:EmitSound( "nepar" )
	self:PlayEffects1( target, self:GetSpecialValueFor( "radius" ) )
	caster:AddNewModifier(caster, self, "modifier_eldzhey_w_heal", { duration = self:GetSpecialValueFor("heal_duration") } )
end

modifier_eldzhey_w_heal = class({})

function modifier_eldzhey_w_heal:IsHidden()         return true end
function modifier_eldzhey_w_heal:IsPurgable()       return false end

function modifier_eldzhey_w_heal:OnCreated()
	if not IsServer() then return end
	self.heal = self:GetAbility():GetSpecialValueFor("heal")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.duration = self:GetAbility():GetSpecialValueFor("heal_duration")
	self.interval = 0.25
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_eldzhey_w_heal:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local heal_per_interval = self.heal * self.interval / (self.duration + self.interval)
	local friends = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,friend in pairs(friends) do
		friend:HealWithParams( heal_per_interval, self:GetAbility(), false, true, caster, false )
		SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, friend, heal_per_interval, caster and caster:GetPlayerOwner() )
	end
	if self:GetAbility():GetSpecialValueFor("damagebyfacet") == 1 then
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), caster:GetOrigin(), nil,
			self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0, 0, false
		)
		local damage_per_interval = (self.heal/2) * self.interval / (self.duration + self.interval)
		local damageTable = {
			attacker = caster,
			damage = damage_per_interval,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}
		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			self:GetAbility():PlayEffects2( caster, enemy )
			ApplyDamage(damageTable)
		end
	end
end


function eldzhey_w:PlayEffects1( target, radius )
	local effect_target = ParticleManager:CreateParticle( "particles/eldzhey_w_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_target, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_target )
	local effect_cast = ParticleManager:CreateParticle( "particles/eldzhey_w_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		self:GetCaster():GetAbsOrigin(), 
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function eldzhey_w:PlayEffects2( origin, target )
	local particle_target = "particles/eldzhey_w_damage.vpcf"
	local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_target,
		0,
		origin,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		origin:GetAbsOrigin(),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_target,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetAbsOrigin(),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_target )
end