macan_innate = class({})
LinkLuaModifier( "modifier_macan_innate", "heroes/macan/macan_innate", LUA_MODIFIER_MOTION_NONE )

function macan_innate:GetIntrinsicModifierName()
	return "modifier_macan_innate"
end

macan_innate.music_heroes = {
	npc_dota_hero_invoker = true,
	npc_dota_hero_ogre_magi = true,
	npc_dota_hero_terrorblade = true,
	npc_dota_hero_ursa = true,
	npc_dota_hero_rattletrap = true,
	npc_dota_hero_kunkka = true,
	npc_dota_hero_necrolyte = true,
	npc_dota_hero_antimage = true,
	npc_dota_hero_weaver = true,
	npc_dota_hero_omniknight = true,
	npc_dota_hero_ringmaster = true,
}


modifier_macan_innate = class({})

function modifier_macan_innate:IsHidden() return true end
function modifier_macan_innate:IsPurgable() return false end

function modifier_macan_innate:OnCreated( kv )
	self.crit_bonus = self:GetAbility():GetSpecialValueFor( "crit_bonus" )
end

function modifier_macan_innate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_macan_innate:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		if macan_innate.music_heroes[params.target:GetUnitName()] then
			self.record = params.record
			return self.crit_bonus
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

function modifier_macan_innate:PlayEffects( target )
	local particle_cast = "particles/macan_innate.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetAbsOrigin(),
		true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetParent():GetAbsOrigin()-target:GetAbsOrigin()):Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end