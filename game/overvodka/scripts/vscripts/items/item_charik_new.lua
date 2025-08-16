LinkLuaModifier("modifier_item_charik_new", "items/item_charik_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen", "items/item_charik_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen_effect", "items/item_charik_new", LUA_MODIFIER_MOTION_NONE)
item_charik_new = class({})

function item_charik_new:GetIntrinsicModifierName()
    return "modifier_item_charik_new"
end

modifier_item_charik_new = class({})

function modifier_item_charik_new:IsHidden() return true end
function modifier_item_charik_new:IsPurgable() return false end
function modifier_item_charik_new:IsPurgeException() return false end
function modifier_item_charik_new:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_charik_new:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_charik_new_regen") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_charik_new_regen", {})
	end
end

function modifier_item_charik_new:OnDestroy()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_item_charik_new_regen") then
		self:GetCaster():RemoveModifierByName("modifier_item_charik_new_regen")
	end
end

function modifier_item_charik_new:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_item_charik_new:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_strength')
end

function modifier_item_charik_new:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agility')
end

function modifier_item_charik_new:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_charik_new:GetModifierMagicalResistanceBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_magresist')
end

function modifier_item_charik_new:GetModifierMoveSpeedBonus_Percentage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_ms')
end


modifier_item_charik_new_regen = class({})

function modifier_item_charik_new_regen:IsHidden() 
    return true 
end

function modifier_item_charik_new_regen:IsPurgable() 
    return false 
end

function modifier_item_charik_new_regen:RemoveOnDeath() 
    return false 
end

function modifier_item_charik_new_regen:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_charik_new_regen:OnCreated()
    if not IsServer() then return end
    self.standing_time = 0
    self.k = false
    self.t = false
    self:StartIntervalThink(0.1)
end

function modifier_item_charik_new_regen:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetAbility() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if parent:IsIllusion() then return end
    if not parent:IsAlive() then 
        self.standing_time = 0 
        return 
    end
    if not ability or ability:IsNull() then return end
    if ability:IsCooldownReady() then
        local percent_min = ability:GetSpecialValueFor("percent_min") / 100
        local percent_heal = ability:GetSpecialValueFor("percent_heal") / 100
        if parent:GetHealth() >= parent:GetMaxHealth() * percent_min and parent:GetMana() >= parent:GetMaxMana() * percent_min then
            self.standing_time = 0
            return
        end

        if not parent:IsMoving() then
            self.standing_time = self.standing_time + 0.1
            if self.standing_time >= 1.0 and not self.k then
                EmitSoundOn("smok2", parent)
                parent:AddNewModifier(parent, ability, "modifier_item_charik_new_regen_effect", { duration = 2 })
                self.k = true
            end
            if self.standing_time >= 3.0 then
                local healAmount = parent:GetMaxHealth() * percent_heal
                parent:Heal(healAmount, ability)
                local manaRestore = parent:GetMaxMana() * percent_heal
                parent:GiveMana(manaRestore)
                local playerID = parent:GetPlayerOwnerID()
                if playerID and PlayerResource:IsValidPlayerID(playerID) then
                    if Quests and Quests.IncrementQuest then
                        Quests:IncrementQuest(playerID, "charonHeal", healAmount)
                    end
                end
                local particle = ParticleManager:CreateParticle("particles/econ/events/compendium_2024/compendium_2024_teleport_endcap_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                ParticleManager:ReleaseParticleIndex(particle)
                ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
                self.t = true
                self.standing_time = 0
                self.k = false
            end
        else
            if not self.t then
                StopSoundOn("smok2", parent)
                parent:RemoveModifierByName("modifier_item_charik_new_regen_effect")
            end 
            self.standing_time = 0
            self.k = false
        end
    else
        self.t = false
        self.standing_time = 0
        self.k = false
    end
end

function modifier_item_charik_new_regen:OnTakeDamage(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        self.standing_time = 0
    end
end


modifier_item_charik_new_regen_effect = class({})

function modifier_item_charik_new_regen_effect:GetTexture()
    return "charik"
end

function modifier_item_charik_new_regen_effect:IsHidden() 
    return false 
end

function modifier_item_charik_new_regen_effect:IsPurgable() 
    return false 
end

function modifier_item_charik_new_regen_effect:RemoveOnDeath() 
    return false 
end
