LinkLuaModifier("modifier_item_oboyudno_2", "items/oboyudno_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_overvodka_blade_mail", "items/oboyudno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_overvodka_blade_mail_active", "items/oboyudno", LUA_MODIFIER_MOTION_NONE)

item_oboyudno_2 = class({})

function item_oboyudno_2:GetIntrinsicModifierName()
    return "modifier_item_oboyudno_2"
end

function item_oboyudno_2:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
	local target = self:GetCursorTarget()
    target:Purge( false, true, false, false, false)
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_overvodka_blade_mail_active", {duration = duration} )
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_lotus_orb_active", {duration = duration} )
    target:EmitSound("oboyudno_2")
    target:EmitSound("DOTA_Item.BladeMail.Activate")
end

modifier_item_oboyudno_2 = class({})

function modifier_item_oboyudno_2:IsHidden() return true end
function modifier_item_oboyudno_2:IsPurgable() return false end
function modifier_item_oboyudno_2:IsPurgeException() return false end
function modifier_item_oboyudno_2:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_oboyudno_2:OnCreated()
	if not IsServer() then return end
end

function modifier_item_oboyudno_2:OnDestroy()
	if not IsServer() then return end
end

function modifier_item_oboyudno_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED	
	}
end

function modifier_item_oboyudno_2:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor_stats')
end

function modifier_item_oboyudno_2:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_hpregen')
end

function modifier_item_oboyudno_2:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_oboyudno_2:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage_stats')
end

function modifier_item_oboyudno_2:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int_stats')
end

function modifier_item_oboyudno_2:OnAttackLanded(params)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if params.attacker:IsBuilding() then return end
	if params.attacker ~= self:GetParent() and params.target == self:GetParent() then
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		if self:GetParent():FindAllModifiersByName("modifier_item_oboyudno_2")[1] ~= self then return end
		if self:GetParent():HasModifier("modifier_item_overvodka_blade_mail") then return end
		if self:GetAbility():GetName() == "item_overvodka_blade_mail" then
			if params.attacker:IsMagicImmune() then return end
		end
		local damage_return = self:GetAbility():GetSpecialValueFor("return_damage_passive_percentage") * params.original_damage / 100 + self:GetAbility():GetSpecialValueFor("return_damage_passive")
		ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
	end
end