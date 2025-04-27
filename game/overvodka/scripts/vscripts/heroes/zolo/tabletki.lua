function Tabletki(keys)
	local caster = keys.caster	
	local ability = keys.ability
	local bonus_strength = ability:GetSpecialValueFor("bonus_strength")
	caster:EmitSound("zolo_tabletki")
	caster:ModifyStrength(bonus_strength)
	caster:CalculateStatBonus(true)
	if GetMapName() == "dota" then
		ability:StartCooldown(60)
	end
end