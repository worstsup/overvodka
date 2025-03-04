LinkLuaModifier("modifier_item_aegis_hero", "aegis_hero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aegis_hero_slow", "aegis_hero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
item_aegis_hero = class({})

function item_aegis_hero:GetIntrinsicModifierName()
	return "modifier_item_aegis_hero"
end

modifier_item_aegis_hero = class({})

function modifier_item_aegis_hero:IsHidden() return true end
function modifier_item_aegis_hero:IsPurgable() return false end
function modifier_item_aegis_hero:IsPurgeException() return false end
function modifier_item_aegis_hero:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_aegis_hero:OnCreated()
	if not IsServer() then return end
	self.critProc = false
end

function modifier_item_aegis_hero:CheckState()
	local state = {}
	if IsServer() then
		state = {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
	end
	return state
end

function modifier_item_aegis_hero:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START
	}
end

function modifier_item_aegis_hero:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
    	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

function modifier_item_aegis_hero:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_aegis_hero")[1] ~= self then return end
	if RollPercentage( self:GetAbility():GetSpecialValueFor("minibash_chance") ) then
		self.critProc = true
	else
		self.critProc = false
	end
end

function modifier_item_aegis_hero:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_aegis_hero")[1] ~= self then return end
	if not params.attacker:IsIllusion() and self.critProc then
		local duration = self:GetAbility():GetSpecialValueFor("slow_duration")
        local damage_pct = self:GetAbility():GetSpecialValueFor("bash_damage")
        local cleave_damage = self:GetAbility():GetSpecialValueFor("cleave_percent")
        local cleave_radius = self:GetAbility():GetSpecialValueFor("cleave_radius")
		local caster = self:GetCaster()
	    if not self:GetCaster():IsHero() then
	        caster = caster:GetOwner()
	    end
		local damage = self:GetParent():GetAverageTrueAttackDamage(nil) * damage_pct * 0.01
		print(damage)
        ApplyDamage({victim = params.target, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        if not params.attacker:IsRangedAttacker() then
        	local cleaveDamage = ( cleave_damage * params.damage ) / 100.0
			DoCleaveAttack( self:GetParent(), params.target, self:GetAbility(), cleaveDamage, cleave_radius, cleave_radius, cleave_radius, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf" )
			params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_aegis_hero_slow", {duration = duration})
		end
        params.target:EmitSound("DOTA_Item.MKB.melee")
        params.target:EmitSound("DOTA_Item.MKB.Minibash")
    end
end

modifier_item_aegis_hero_slow = class({})

function modifier_item_aegis_hero_slow:IsHidden() return false end
function modifier_item_aegis_hero_slow:IsPurgable() return false end

function modifier_item_aegis_hero_slow:GetTexture()
    return "items/aegis_hero"
end

function modifier_item_aegis_hero_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_aegis_hero_slow:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("movement_speed_slow")
end

function modifier_item_aegis_hero_slow:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("attack_speed_slow")
end