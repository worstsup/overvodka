function Cooldowns(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = caster:FindAbilityByName("eldzhey_w"):GetCooldownTimeRemaining()
	caster:FindAbilityByName("eldzhey_w"):StartCooldown(cooldown + 6)
end