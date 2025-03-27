function modifier_item_mask_of_madness_datadriven_on_orb_impact(keys)
	if keys.target.GetInvulnCount == nil then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_mask_of_madness_datadriven_lifesteal", {duration = 0.03})
	end
end