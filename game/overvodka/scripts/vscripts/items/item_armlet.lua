function swap_to_item(keys, ItemName)
	for i=0, 8, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item == nil then
			keys.caster:AddItem(CreateItem("item_dummy_datadriven", keys.caster, keys.caster))
		end
	end
	keys.caster:RemoveItem(keys.ability)
	keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster))
	for i=0, 8, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy_datadriven" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end
end

function item_armlet_active_datadriven_on_spell_start(keys)
	keys.caster:StopSound("sigmastaff")
	swap_to_item(keys, "item_armlet_datadriven")
end


function item_armlet_datadriven_on_spell_start(keys)
	while keys.caster:HasAnyAvailableInventorySpace() do
		keys.caster:AddItem(CreateItem("item_dummy_datadriven", keys.caster, keys.caster))
	end
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_armlet_active_datadriven" then
				keys.caster:RemoveItem(current_item)
				keys.caster:AddItem(CreateItem("item_armlet_datadriven", keys.caster, keys.caster))
			end
		end
	end
	
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy_datadriven" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end

	keys.caster:EmitSound("sigmastaff")
	swap_to_item(keys, "item_armlet_active_datadriven")
end

function modifier_item_armlet_active_datadriven_on_interval_think_damage(keys)
	local new_hp = keys.caster:GetMana() - (keys.UnholyHealthDrainPerSecond * keys.caster:GetMaxMana() * 0.01 * keys.UnholyHealthDrainInterval)
	
	if new_hp < 1 then
		new_hp = 1
	end
	
	keys.caster:SetMana(new_hp)
end

function modifier_item_armlet_active_datadriven_apply_tick_strength_on_interval_think(keys)
	if keys.ability.ArmletTicksActive == nil or keys.ability.ArmletTicksActive < keys.UnholyTicksToFullEffect then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_armlet_active_datadriven_tick", {duration = -1})
		if keys.ability.ArmletTicksActive == nil then
			keys.ability.ArmletTicksActive = 1
		else
			keys.ability.ArmletTicksActive = keys.ability.ArmletTicksActive + 1
		end
		local currentHP = keys.caster:GetHealth()
		local maxHP = keys.caster:GetMaxHealth()
		local health_bonus_interval_ratio = (keys.UnholyBonusStrength / keys.UnholyTicksToFullEffect) * 19
		
		local amount_to_heal = ((currentHP + health_bonus_interval_ratio) / (maxHP + health_bonus_interval_ratio)) * maxHP - currentHP
		
		keys.caster:SetHealth(currentHP + amount_to_heal)
	end
end

function item_armlet_active_datadriven_on_unequip(keys)
	if keys.ability.ArmletTicksActive ~= nil then
		
		for i=1, keys.ability.ArmletTicksActive, 1 do
			keys.caster:RemoveModifierByName("modifier_item_armlet_active_datadriven_tick")
		end
		for i=1, keys.ability.ArmletTicksActive, 1 do
			local currentHP = keys.caster:GetHealth()
			local maxHP = keys.caster:GetMaxHealth()
			local health_bonus_interval_ratio = (keys.UnholyBonusStrength / keys.UnholyTicksToFullEffect) * 19
			local amount_to_damage = ((currentHP + health_bonus_interval_ratio) / (maxHP + health_bonus_interval_ratio)) * maxHP - currentHP
			local new_hp = currentHP - amount_to_damage
			if new_hp < 1 then
				new_hp = 1
			end
			keys.caster:SetHealth(new_hp)
		end
		keys.ability.ArmletTicksActive = nil
	end
end