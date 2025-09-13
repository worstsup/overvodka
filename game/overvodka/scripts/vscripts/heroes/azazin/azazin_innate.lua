azazin_innate = class({})
LinkLuaModifier( "modifier_azazin_innate", "heroes/azazin/azazin_innate", LUA_MODIFIER_MOTION_NONE )

function azazin_innate:Precache( context )
    PrecacheResource( "particle", "particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", context )
end

function azazin_innate:GetIntrinsicModifierName()
	return "modifier_azazin_innate"
end

modifier_azazin_innate = class({})

function modifier_azazin_innate:IsHidden() return true end
function modifier_azazin_innate:IsPurgable() return false end

function modifier_azazin_innate:OnCreated( kv )
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" )
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" )
end

function modifier_azazin_innate:OnRefresh( kv )
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" )
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" )
end

function modifier_azazin_innate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end

function modifier_azazin_innate:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		local target = params.target
		local result = UnitFilter(
			target,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,
			self:GetParent():GetTeamNumber()
		)
		if result == UF_SUCCESS then
			local mana_burn =  math.min( target:GetMana(), self.mana_break )
			target:Script_ReduceMana( mana_burn, self:GetAbility() )
			self:PlayEffects( target )
			return mana_burn * self.mana_damage_pct
		end

	end
end

function modifier_azazin_innate:PlayEffects( target )
	local particle_cast = "particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end