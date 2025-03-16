modifier_nix_rus = class({})

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
    local particle = ParticleManager:CreateParticle("particles/nix_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_nix_rus:OnRemoved()
end

function modifier_nix_rus:OnIntervalThink()
	if IsServer() then
		k = k + 1
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			0,
			false
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

function modifier_nix_rus:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

function modifier_nix_rus:GetModifierModelScale( params )
	return self.model_scale
end

function modifier_nix_rus:GetModifierBonusStats_Strength( params )
	return self.bonus_strength
end

function modifier_nix_rus:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end