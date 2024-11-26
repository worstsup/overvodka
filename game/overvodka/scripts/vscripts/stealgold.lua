function StealGold(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Gold = 0
	local gold_damage = math.floor(target:GetGold() / 100 * 15) + 250
	
	if target:TriggerSpellAbsorb(ability) then return end
	target:TriggerSpellReflect(ability)
	
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	target:EmitSound("segasuka")
	
		Gold = gold_damage
		
		local Steal = gold_damage * (-1)
		
		target:ModifyGold(Steal, false, 0)
		caster:ModifyGold(Gold, false, 0)
end