function BorrowedTimeActivate( event )
	local caster = event.caster
	local ability = event.ability
	if caster:PassivesDisabled() then return end
	if caster:HasModifier("modifier_item_nullifier_mute") then return end
	if not caster:IsAlive() then return end
	local threshold = ability:GetLevelSpecialValueFor( "hp_threshold" , ability:GetLevel() - 1  )
	local hp = threshold * caster:GetMaxHealth() / 100
	local dur = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  )
	local strong = ability:GetLevelSpecialValueFor( "strong" , ability:GetLevel() - 1  )
	local forbidden_items = 
            {
                "item_aeon_disk",
                "item_lesh",
                "item_refresher",
				"item_onehp"
            }
	if caster:GetHealth() < hp and ability:GetCooldownTimeRemaining() == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_silvername_secret", { duration = dur })
		ability:UseResources( false, false, false, true )
		caster:EmitSound("secret")
	end
end

function BorrowedTimeHeal( event )
	local damage = event.DamageTaken
	local caster = event.caster
	local ability = event.ability
	if caster:HasModifier("modifier_item_nullifier_mute") then return end
	caster:Heal(damage * 2, caster)
end