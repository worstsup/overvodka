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
                "item_refresher"
            }
	if caster:GetHealth() < hp and ability:GetCooldownTimeRemaining() == 0 then
		if strong == 1 then
			BorrowedTimePurge( event )
		end
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_silvername_secret", { duration = dur })
		ability:UseResources( false, false, false, true )
		caster:Stop()
		caster:EmitSound("secret")
		if caster:HasScepter() then
        	for i = 0, caster:GetAbilityCount() - 1 do
            	local abil = caster:GetAbilityByIndex( i )
            	if abil and abil ~= event.ability then
                	abil:EndCooldown()
            	end
        	end
        	for i = 0, 8 do
            	local current_item = caster:GetItemInSlot(i)
            	local should_refresh = true
            	for _,forbidden_item in pairs(forbidden_items) do
                	if current_item and (current_item:GetName() == forbidden_item or current_item:GetPurchaser() ~= caster) then
                    	should_refresh = false
                	end
            	end
            	if current_item and should_refresh then
                	current_item:EndCooldown()
            	end
    		end
    	end
	end
end

function BorrowedTimeHeal( event )
	local damage = event.DamageTaken
	local caster = event.caster
	local ability = event.ability
	if caster:HasModifier("modifier_item_nullifier_mute") then return end
	caster:Heal(damage*2, caster)
end

function BorrowedTimePurge( event )
	local caster = event.caster
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end
