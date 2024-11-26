scale = 0.6
function TricksMaster(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local cooldown = ability:GetCooldown(level)
	local bonus_strength = 1
	
	if caster:IsIllusion() == false then
		if ability:GetCooldownTimeRemaining() == 0 then
			ability:StartCooldown(cooldown)
			scale = scale + 0.015
			if caster:HasScepter() then
				caster:ModifyStrength(bonus_strength)
				caster:ModifyAgility(bonus_strength)
				caster:ModifyIntellect(bonus_strength)
			else
				caster:ModifyStrength(bonus_strength)
			end
			caster:SetModelScale(scale)
			caster:CalculateStatBonus()
		end
	end
end