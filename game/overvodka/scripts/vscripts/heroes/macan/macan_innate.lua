macan_innate = class({})
LinkLuaModifier( "modifier_macan_innate", "heroes/macan/macan_innate", LUA_MODIFIER_MOTION_NONE )

function macan_innate:GetIntrinsicModifierName()
	return "modifier_macan_innate"
end

modifier_macan_innate = class({})

function modifier_macan_innate:IsHidden()
	return true
end
function modifier_macan_innate:IsPurgable()
	return false
end

function modifier_macan_innate:OnCreated( kv )
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self:GetAbility():GetSpecialValueFor( "crit_bonus" )
end

function modifier_macan_innate:OnRefresh( kv )
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self:GetAbility():GetSpecialValueFor( "crit_bonus" )
end

function modifier_macan_innate:OnDestroy( kv )
end

function modifier_macan_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function modifier_macan_innate:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if self:RollChance( self.crit_chance ) then
			if params.target:GetUnitName() == "npc_dota_hero_invoker" or params.target:GetUnitName() == "npc_dota_hero_ogre_magi" or params.target:GetUnitName() == "npc_dota_hero_terrorblade" or params.target:GetUnitName() == "npc_dota_hero_ursa" or params.target:GetUnitName() == "npc_dota_hero_rattletrap" or params.target:GetUnitName() == "npc_dota_hero_kunkka" or params.target:GetUnitName() == "npc_dota_hero_necrolyte" or params.target:GetUnitName() == "npc_dota_hero_antimage" then
				self.record = params.record
				return self.crit_bonus
			end
		end
	end
end

function modifier_macan_innate:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record then
			self.record = nil
			self:PlayEffects( params.target )
		end
	end
end

function modifier_macan_innate:RollChance( chance )
	local rand = math.random()
	if rand<chance/100 then
		return true
	end
	return false
end

function modifier_macan_innate:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetParent():GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end