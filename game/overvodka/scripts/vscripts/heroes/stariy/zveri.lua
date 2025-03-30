function Sound (keys)
	local caster = keys.caster
	local ability = keys.ability
	Chance = RandomInt(1,4)
	if Chance == 1 then
		EmitSoundOn( "borsh", caster )
	elseif Chance == 2 then
		EmitSoundOn( "veter", caster )
	elseif Chance == 3 then
		EmitSoundOn( "kitaec", caster )	
	elseif Chance == 4 then
		EmitSoundOn( "ptichki", caster )
	end
end

function Tricks (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:TriggerSpellAbsorb(ability) then return end
	local damage = ability:GetSpecialValueFor("damage")
	local disarm_duration = ability:GetSpecialValueFor("disarm_duration")
	local hex_duration = ability:GetSpecialValueFor("hex_duration")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local silence_duration = ability:GetSpecialValueFor("disarm_duration")

	if Chance == 1 then
		ability:ApplyDataDrivenModifier( target, target, "modifier_stariy_disarmed", { Duration = disarm_duration * (1 - target:GetStatusResistance()) })
	elseif Chance == 2 then
		ability:ApplyDataDrivenModifier( target, target, "modifier_stariy_silenced", { Duration = silence_duration * (1 - target:GetStatusResistance()) })
	elseif Chance == 3 then
		target:AddNewModifier( target, self, "modifier_stunned", { duration = stun_duration * (1 - target:GetStatusResistance()) } )	
	elseif Chance == 4 then
		target:AddNewModifier( target, self, "modifier_shadow_shaman_voodoo", { duration = hex_duration * (1 - target:GetStatusResistance()) } )
	end
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = ability})
end

