function Jinada( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local level = ability:GetLevel() - 1
	local cooldown = ability:GetCooldown(level)
	local gold_cost  = ability:GetLevelSpecialValueFor("gold_cost", level)
	local player_id = caster:GetPlayerID()
	local gold = PlayerResource:GetGold(player_id)
	local duration = ability:GetLevelSpecialValueFor("duration", level)
	local percent = ability:GetLevelSpecialValueFor("percent", level)
	local modifierName = "modifier_jinada_datadriven"
	local damage = gold_cost + percent * 0.01 * gold
	if ability:GetCooldownTimeRemaining() == 0 then
		if PlayerResource:GetGold(player_id) < damage  then
			ability:EndCooldown()
			return
		end
		caster:EmitSound("biznes")
		PlayerResource:SpendGold(player_id, damage, 4)
		ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_PURE})
		ability:ApplyDataDrivenModifier( caster, target, "modifier_jinada_slow_datadriven", { Duration = duration } )
		ability:StartCooldown(cooldown)
		local particleName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf"
        local effect = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
        if target then
            ParticleManager:SetParticleControlEnt(effect, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
        else
            ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin()) -- Attach to the caster if no target
        end

        -- Optionally, destroy the particle after a certain duration
        ParticleManager:ReleaseParticleIndex(effect)
	end
end