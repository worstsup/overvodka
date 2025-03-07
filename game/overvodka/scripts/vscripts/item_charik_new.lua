LinkLuaModifier("modifier_item_charik_new", "item_charik_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen", "item_charik_new", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_charik_new_regen_effect", "item_charik_new", LUA_MODIFIER_MOTION_NONE)
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

function modifier_item_charik_new_regen:IsHidden() return true end
function modifier_item_charik_new_regen:IsPurgable() return false end
function modifier_item_charik_new_regen:RemoveOnDeath() return false end
function modifier_item_charik_new_regen:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_item_charik_new_regen:OnCreated()
    if not IsServer() then return end
    self.standing_time = 0
    k = 0
    t = 0
    self:StartIntervalThink(0.1)
end

function modifier_item_charik_new_regen:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if parent:IsIllusion() then return end
    if ability:IsCooldownReady() and parent:IsAlive() then
        if not parent:IsMoving() then
        	if parent:GetHealth() >= parent:GetMaxHealth() * 0.4 and parent:GetMana() >= parent:GetMaxMana() * 0.4 then
                self.standing_time = 0
                return
            end
            self.standing_time = self.standing_time + 0.1
            if self.standing_time >= 1.0 and k == 0 then
            	EmitSoundOn( "smok2", self:GetParent())
            	parent:AddNewModifier(parent, ability, "modifier_item_charik_new_regen_effect", {duration = 2})
            	k = 1
            end
            if self.standing_time >= 3.0 then
                local healAmount = parent:GetMaxHealth() * 0.3
                parent:Heal(healAmount, ability)
                local manaRestore = parent:GetMaxMana() * 0.3
                parent:GiveMana(manaRestore)

                local particle = ParticleManager:CreateParticle("particles/econ/events/compendium_2024/compendium_2024_teleport_endcap_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                ParticleManager:ReleaseParticleIndex(particle)

                ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
                t = 1
                self.standing_time = 0
                k = 0
            end
        else
        	if t == 0 then
        		StopSoundOn("smok2", self:GetParent())
        		parent:RemoveModifierByName("modifier_item_charik_new_regen_effect")
        	end
            self.standing_time = 0
        end
    else
    	t = 0
        self.standing_time = 0 
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
  	return "items/charik"
end

function modifier_item_charik_new_regen_effect:IsHidden() return false end
function modifier_item_charik_new_regen_effect:IsPurgable() return false end
function modifier_item_charik_new_regen_effect:RemoveOnDeath() return false end