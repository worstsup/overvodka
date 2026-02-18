LinkLuaModifier("modifier_govno",           "items/govno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_govno_backtrack", "items/govno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen", "items/item_charik_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen_effect", "items/item_charik_new", LUA_MODIFIER_MOTION_NONE)

item_govno = class({})

function item_govno:GetIntrinsicModifierName()
	return "modifier_govno"
end

modifier_govno = class({})

function modifier_govno:IsHidden() return true end
function modifier_govno:IsPurgable() return false end
function modifier_govno:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_govno:OnCreated()
	self.ability = self:GetAbility()
	if not self.ability or self.ability:IsNull() then return end

	self.bonus_movement_speed = self.ability:GetSpecialValueFor("bonus_movement_speed")
	self.bonus_strength       = self.ability:GetSpecialValueFor("bonus_strength")
	self.bonus_agility        = self.ability:GetSpecialValueFor("bonus_agility")
	self.bonus_health         = self.ability:GetSpecialValueFor("bonus_health")
	self.bonus_hpregen        = self.ability:GetSpecialValueFor("bonus_hpregen")
	self.bonus_magic_resist   = self.ability:GetSpecialValueFor("bonus_magic_resist")
	self.bonus_as             = self.ability:GetSpecialValueFor("bonus_as")

	if not IsServer() then return end

	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	local regen = parent:FindModifierByName("modifier_item_charik_new_regen")
	if regen and not regen:IsNull() then
		local regen_ability = regen:GetAbility()
		if not regen_ability or regen_ability:IsNull() then
			regen:Destroy()
			regen = nil
		end
	end

	if not regen then
		parent:AddNewModifier(parent, self.ability, "modifier_item_charik_new_regen", {})
	end

	parent:AddNewModifier(parent, self.ability, "modifier_govno_backtrack", {})
end

function modifier_govno:OnDestroy()
	if not IsServer() then return end

	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	if not parent:HasItemInInventory("item_charik_new") and not parent:HasItemInInventory("item_govno") then
		parent:RemoveModifierByName("modifier_item_charik_new_regen")
	end

	local mod = parent:FindModifierByName("modifier_govno_backtrack")
	if mod and not mod:IsNull() then
		mod:Destroy()
	end
end

function modifier_govno:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_govno:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self.bonus_movement_speed
    end
end

function modifier_govno:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self.bonus_strength
    end
end

function modifier_govno:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self.bonus_agility
    end
end

function modifier_govno:GetModifierHealthBonus()
    if self:GetAbility() then
        return self.bonus_health
    end
end

function modifier_govno:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self.bonus_hpregen
    end
end

function modifier_govno:GetModifierMagicalResistanceBonus()
    if self:GetAbility() then
        return self.bonus_magic_resist
    end
end

function modifier_govno:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self.bonus_as
    end
end

modifier_govno_backtrack = class({})

function modifier_govno_backtrack:IsHidden() return true end
function modifier_govno_backtrack:IsPurgable() return false end

function modifier_govno_backtrack:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not self.ability or self.ability:IsNull() then return end

    self.block_chance_pct = self.ability:GetSpecialValueFor("dodge_chance_pct") or 0
    self.block_pct        = self.ability:GetSpecialValueFor("block_pct") or 0
end

function modifier_govno_backtrack:OnRefresh()
    self:OnCreated()
end

function modifier_govno_backtrack:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end

function modifier_govno_backtrack:GetModifierTotal_ConstantBlock(params)
    if not IsServer() then return 0 end
    if not params or params.target ~= self.parent then return 0 end

    local ability = self.ability
    if not ability or ability:IsNull() then return 0 end

    if ability:GetCooldownTimeRemaining() > 0 then return 0 end

    if self.parent:FindAllModifiersByName("modifier_govno_backtrack")[1] ~= self then return 0 end
	if not self.parent:HasItemInInventory("item_govno") then return 0 end

    local chance = self.block_chance_pct or 0
    local pct    = self.block_pct or 0
    if chance <= 0 or pct <= 0 then return 0 end

    if not RollPercentage(chance) then return 0 end

    local dmg = params.damage or 0
    if dmg <= 0 then return 0 end

    local block = dmg * pct / 100
    if block <= 0 then return 0 end

    local p = ParticleManager:CreateParticle("particles/kaska.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:ReleaseParticleIndex(p)

    ability:UseResources(false, false, false, true)

    local playerID = self.parent:GetPlayerOwnerID()
    if playerID and PlayerResource:IsValidPlayerID(playerID) then
        if Quests and Quests.IncrementQuest then
            Quests:IncrementQuest(playerID, "kaskaAmount")
        end
    end

    return block
end
