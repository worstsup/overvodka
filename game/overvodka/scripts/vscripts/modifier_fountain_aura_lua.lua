modifier_fountain_aura_lua = class({})

function modifier_fountain_aura_lua:IsHidden()
	return true
end

function modifier_fountain_aura_lua:IsAura()
	return true
end

function modifier_fountain_aura_lua:GetModifierAura()
	return "modifier_fountain_aura_effect_lua"
end

function modifier_fountain_aura_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_fountain_aura_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_fountain_aura_lua:GetAuraDuration()
	return 0.1
end

function modifier_fountain_aura_lua:GetAuraRadius()
	return 1275
end

function modifier_fountain_aura_lua:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.05)
	end
end

function modifier_fountain_aura_lua:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
		if #enemies == 0 then
			return
		end
		for _, enemy in pairs(enemies) do
			if enemy:IsAlive() and enemy:HasModifier("modifier_mazellov_r") and not enemy:HasModifier("modifier_knockback") then
				local direction = (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
				local distance = (self:GetParent():GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
				local new_pos = enemy:GetAbsOrigin() + direction * (1600 - distance)
				FindClearSpaceForUnit(enemy, new_pos, true)
			end
		end
	end
end