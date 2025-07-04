LinkLuaModifier("modifier_item_oboyudno", "items/oboyudno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_overvodka_blade_mail", "items/oboyudno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_overvodka_blade_mail_active", "items/oboyudno", LUA_MODIFIER_MOTION_NONE)

item_oboyudno = class({})

function item_oboyudno:GetIntrinsicModifierName()
    return "modifier_item_oboyudno"
end

function item_oboyudno:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
	local target = self:GetCursorTarget()
    target:Purge( false, true, false, false, false)
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_overvodka_blade_mail_active", {duration = duration} )
    target:AddNewModifier( self:GetCaster(), self, "modifier_item_lotus_orb_active", {duration = duration} )
    target:EmitSound("oboyudno")
    target:EmitSound("DOTA_Item.BladeMail.Activate")
end

modifier_item_oboyudno = class({})

function modifier_item_oboyudno:IsHidden() return true end
function modifier_item_oboyudno:IsPurgable() return false end
function modifier_item_oboyudno:IsPurgeException() return false end
function modifier_item_oboyudno:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_oboyudno:OnCreated()
	if not IsServer() then return end
end

function modifier_item_oboyudno:OnDestroy()
end

function modifier_item_oboyudno:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED	
	}
end

function modifier_item_oboyudno:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor_stats')
end

function modifier_item_oboyudno:GetModifierConstantHealthRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_hpregen')
end

function modifier_item_oboyudno:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed_stats')
end

function modifier_item_oboyudno:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage_stats')
end

function modifier_item_oboyudno:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int_stats')
end

function modifier_item_oboyudno:OnAttackLanded(params)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if params.attacker:IsBuilding() then return end
	if params.attacker ~= self:GetParent() and params.target == self:GetParent() then
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		if self:GetParent():FindAllModifiersByName("modifier_item_oboyudno")[1] ~= self then return end
		if self:GetParent():HasModifier("modifier_item_overvodka_blade_mail") then return end
		if self:GetAbility():GetName() == "item_overvodka_blade_mail" then
			if params.attacker:IsMagicImmune() then return end
		end
		local damage_return = self:GetAbility():GetSpecialValueFor("return_damage_passive_percentage") * params.original_damage / 100 + self:GetAbility():GetSpecialValueFor("return_damage_passive")
		ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
		local playerID = self:GetParent():GetPlayerOwnerID()
		if playerID and PlayerResource:IsValidPlayerID(playerID) then
			local dmg_quest = math.floor(damage_return)
			if Quests and Quests.IncrementQuest then
				Quests:IncrementQuest(playerID, "oboyudnoDamage", dmg_quest)
			end
		end
	end
end

item_overvodka_blade_mail = class({})

function item_overvodka_blade_mail:GetIntrinsicModifierName()
    return "modifier_item_overvodka_blade_mail"
end

function item_overvodka_blade_mail:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_overvodka_blade_mail_active", {duration = duration} )
    self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
end

modifier_item_overvodka_blade_mail = class({})

function modifier_item_overvodka_blade_mail:IsHidden() return true end
function modifier_item_overvodka_blade_mail:IsPurgable() return false end
function modifier_item_overvodka_blade_mail:IsPurgeException() return false end
function modifier_item_overvodka_blade_mail:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_overvodka_blade_mail:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_overvodka_blade_mail:GetModifierPhysicalArmorBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_item_overvodka_blade_mail:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_intellect')
end

function modifier_item_overvodka_blade_mail:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_damage')
end

function modifier_item_overvodka_blade_mail:OnAttackLanded(params)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if params.attacker ~= self:GetParent() and params.target == self:GetParent() then
		if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		if self:GetParent():FindAllModifiersByName("modifier_item_overvodka_blade_mail")[1] ~= self then return end
		if self:GetAbility():GetName() == "item_overvodka_blade_mail" then
			if params.attacker:IsMagicImmune() then return end
		end
		local damage_return = self:GetAbility():GetSpecialValueFor("return_damage_passive_percentage") * params.original_damage / 100 + self:GetAbility():GetSpecialValueFor("return_damage_passive")
		ApplyDamage({victim = params.attacker, attacker = self:GetParent(), damage = damage_return, damage_type = params.damage_type,  damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, ability = self:GetAbility()})
	end
end

modifier_item_overvodka_blade_mail_active = class({})

function modifier_item_overvodka_blade_mail_active:IsPurgable()
	return false
end

function modifier_item_overvodka_blade_mail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_item_overvodka_blade_mail_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_item_overvodka_blade_mail_active:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end

function modifier_item_overvodka_blade_mail_active:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_item_overvodka_blade_mail_active:OnTakeDamage(keys)
	if not IsServer() then return end
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags
	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if self:GetAbility():GetName() == "item_overvodka_blade_mail" then
			if keys.attacker:IsMagicImmune() then return end
		end
		EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
		local damage_return = keys.original_damage / 100 * self:GetAbility():GetSpecialValueFor("return_damage")
		ApplyDamage({ victim = keys.attacker, damage = damage_return, damage_type = keys.damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = self:GetParent(), ability = self:GetAbility() })
		local playerID = self:GetCaster():GetPlayerOwnerID()
		if playerID and PlayerResource:IsValidPlayerID(playerID) then
			if Quests and Quests.IncrementQuest then
				local dmg_quest = math.floor(damage_return)
				Quests:IncrementQuest(playerID, "oboyudnoDamage", dmg_quest)
			end
		end
	end
end