modifier_nix_rus = class({})
--------------------------------------------------------------------------------
function modifier_nix_rus:IsPurgable()
	return false
end

function modifier_nix_rus:OnCreated( kv )
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.dps = self:GetAbility():GetSpecialValueFor( "dps" )
	if IsServer() then
		self:StartIntervalThink( 0.25 )
	end
	k = 0
end

--------------------------------------------------------------------------------

function modifier_nix_rus:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_nix_rus:OnIntervalThink()
	if IsServer() then
		k = k + 1
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,unit in pairs(enemies) do
			unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_axe_berserkers_call_lol_debuff", {duration = 0.5})
			if k % 4 == 0 then
				ApplyDamage({ victim = unit, attacker = self:GetParent(), damage = self.dps, damage_type = DAMAGE_TYPE_MAGICAL })
			end
			if self:GetParent():HasScepter() then
				unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_generic_disarmed_lua", {duration = 0.5})
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_nix_rus:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end


--------------------------------------------------------------------------------

function modifier_nix_rus:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_nix_rus:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end
function modifier_nix_rus:GetEffectName()
	return "particles/centaur_ti6_warstomp_gold_new.vpcf"
end

function modifier_nix_rus:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end