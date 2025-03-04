evelone_e = class({})
LinkLuaModifier( "modifier_evelone_e", "heroes/evelone/evelone_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_evelone_e_illusions", "heroes/evelone/evelone_e", LUA_MODIFIER_MOTION_NONE )

function evelone_e:Precache(context)
    PrecacheResource("particle", "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf", context)
    PrecacheResource("particle", "particles/evelone_e_ulti.vpcf", context)
    PrecacheResource("particle", "particles/evelone_e_ulti_2.vpcf", context)
	PrecacheResource("soundfile", "soundevents/evelone_e_1.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/evelone_e_2.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/evelone_e_tamaev.vsndevts", context)
end

function evelone_e:GetIntrinsicModifierName()
	return "modifier_evelone_e"
end

modifier_evelone_e = class({})

function modifier_evelone_e:IsHidden()
	return true
end
function modifier_evelone_e:IsDebuff()
	return false
end
function modifier_evelone_e:IsPurgable()
	return false
end

function modifier_evelone_e:OnCreated( kv )
    if not IsServer() then return end
	self.k = 0
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.outgoing = self:GetAbility():GetSpecialValueFor("illusion_outgoing_damage")
	self.incoming = self:GetAbility():GetSpecialValueFor("illusion_incoming_damage")
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_evelone_e:OnRefresh( kv )
    if not IsServer() then return end
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.outgoing = self:GetAbility():GetSpecialValueFor("illusion_outgoing_damage")
	self.incoming = self:GetAbility():GetSpecialValueFor("illusion_incoming_damage")
end

function modifier_evelone_e:OnDestroy( kv )
end

function modifier_evelone_e:OnIntervalThink()
	if self:GetParent():IsIllusion() then return end
	if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():HasModifier("modifier_silver_edge_debuff") then return end
	if self:GetParent():HasModifier("modifier_break") then return end
	if self:GetParent():IsInvisible() then return end
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		FIND_CLOSEST,
		false
	)
	for _,enemy in pairs(enemies) do
		self.illusions = CreateIllusions(
		    self:GetParent(),
		    enemy,
		    {
		    	outgoing_damage = self.outgoing,
		    	incoming_damage = self.incoming,
		    	duration = self.duration,
		    },
		    1,
		    150,
		    false,
		    true
	    )
        illusion = self.illusions[1]
		illusion:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_evelone_e_illusions", {duration = -1})
		if self:GetAbility():GetSpecialValueFor("hasfacet") == 0 then
        	illusion:SetAbsOrigin(self:GetParent():GetAbsOrigin())
        	FindClearSpaceForUnit(illusion, self:GetParent():GetAbsOrigin(), true)
		end
		self:PlayEffectsNew( illusion )
		self:PlayEffects( enemy )
		self:GetAbility():UseResources(false, false, false, true)
		break
	end
end

function modifier_evelone_e:PlayEffects( target )
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
    if self:GetParent():HasModifier("modifier_evelone_r") then
        particle_cast = "particles/evelone_e_ulti_2.vpcf"
    end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	if target:GetUnitName() == "npc_dota_hero_tidehunter" then
		EmitSoundOn( "evelone_e_tamaev", self:GetParent() )
	else
		if self.k == 0 then
			EmitSoundOn( "evelone_e_1", self:GetParent() )
			self.k = 1
		else
			EmitSoundOn( "evelone_e_2", self:GetParent() )
			self.k = 0
		end
	end
end

function modifier_evelone_e:PlayEffectsNew( target )
	local particle_cast = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf"
    if self:GetParent():HasModifier("modifier_evelone_r") then
        particle_cast = "particles/evelone_e_ulti.vpcf"
    end
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:SetParticleControl( effect_cast, 3, self:GetParent():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_evelone_e_illusions = class({})

function modifier_evelone_e_illusions:IsHidden()
	return true
end
function modifier_evelone_e_illusions:IsDebuff()
	return false
end
function modifier_evelone_e_illusions:IsPurgable()
	return false
end

function modifier_evelone_e_illusions:OnCreated()
	if not IsServer() then return end
end

function modifier_evelone_e_illusions:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end


function modifier_evelone_e_illusions:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ms_illusion")
end