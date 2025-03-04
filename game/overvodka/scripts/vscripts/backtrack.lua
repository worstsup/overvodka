function BacktrackHealth( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

function BacktrackHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	if ability:GetCooldownTimeRemaining() > 0 then
		return
	end
	caster:SetHealth(ability.caster_hp_old)
	ability:StartCooldown( ability:GetCooldown(ability:GetLevel()) )
end