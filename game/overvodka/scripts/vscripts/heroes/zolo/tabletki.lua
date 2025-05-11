function Tabletki(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local bonus_strength = ability:GetSpecialValueFor("bonus_strength")
	caster:EmitSound("zolo_tabletki")
	caster:ModifyStrength(bonus_strength)
	caster:CalculateStatBonus(true)
	if GetMapName() == "overvodka_5x5" then
		ability:StartCooldown(50)
	end
end