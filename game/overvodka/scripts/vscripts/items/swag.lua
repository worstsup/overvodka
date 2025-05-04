LinkLuaModifier( "modifier_item_swag_active", "items/swag", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_swag_invis", "items/swag", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_swag", "items/swag", LUA_MODIFIER_MOTION_NONE )
item_swag = class({})

function item_swag:GetIntrinsicModifierName()
    return "modifier_item_swag"
end

function item_swag:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local delay = self:GetSpecialValueFor("initial_fade_delay")
    local duration = self:GetSpecialValueFor("duration")
    Timers:CreateTimer(delay, function()
        target:AddNewModifier(caster, self, "modifier_item_swag_active", {duration = duration})
    end)
    local effect_cast = ParticleManager:CreateParticle("particles/swag_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_cast, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self.effect_cast = ParticleManager:CreateParticle( "particles/swag_start.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, target:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
    EmitSoundOn("Item.GlimmerCape.Activate", target)
    EmitSoundOn("swag", target)
end

modifier_item_swag = class({})

function modifier_item_swag:IsHidden() return true end
function modifier_item_swag:IsPurgable() return false end
function modifier_item_swag:IsPurgeException() return false end
function modifier_item_swag:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_swag:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_item_swag:GetModifierMagicalResistanceBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_magical_armor')
    end
end

function modifier_item_swag:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_armor')
    end
end

function modifier_item_swag:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
    end
end

function modifier_item_swag:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
    end
end

function modifier_item_swag:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_all_stats')
    end
end

function modifier_item_swag:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_mana')
    end
end

function modifier_item_swag:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_health')
    end
end

function modifier_item_swag:GetModifierMoveSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('self_movement_speed')
    end
end

modifier_item_swag_active = class({})

function modifier_item_swag_active:IsHidden() return false end
function modifier_item_swag_active:IsPurgable() return true  end

function modifier_item_swag_active:OnCreated()
    if not IsServer() then return end
    self.max_shield = self:GetAbility():GetSpecialValueFor("barrier_block")
    self:SetStackCount(self.max_shield)
    self.sec_delay = self:GetAbility():GetSpecialValueFor("secondary_fade_delay")
    local parent = self:GetParent()
    parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_swag_invis", {duration = self:GetDuration()})
    local particle = ParticleManager:CreateParticle("particles/swag_head.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, parent:GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
    self.shield = ParticleManager:CreateParticle("particles/swag_shield.vpcf", PATTACH_POINT_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.shield, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.shield, 1, Vector(150, 150, 0))
    ParticleManager:SetParticleControl(self.shield, 4, parent:GetAbsOrigin())
    self:AddParticle(self.shield, false, false, -1, false, false)
end

function modifier_item_swag_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_swag_active:GetModifierIncomingDamageConstant( params )
    if IsClient() then 
        if params.report_max then 
            return self.max_shield or self:GetStackCount()
        else 
            return self:GetStackCount()
        end 
    end
    if params.damage>=self:GetStackCount() then
        ParticleManager:DestroyParticle(self.shield, false)
        ParticleManager:ReleaseParticleIndex(self.shield)
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end


function modifier_item_swag_active:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("active_movement_speed")
end

function modifier_item_swag_active:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("target_attack_speed")
end

function modifier_item_swag_active:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("target_armor")
end

function modifier_item_swag_active:OnAttack(params)
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		self:BreakInvis()
	end
end

function modifier_item_swag_active:OnAbilityExecuted(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    self:BreakInvis()
end

function modifier_item_swag_active:BreakInvis()
    if not self:GetParent():HasModifier("modifier_item_swag_invis") then return end
    self:GetParent():RemoveModifierByName("modifier_item_swag_invis")
    Timers:CreateTimer(self.sec_delay, function()
        if self:IsNull() then return end
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_swag_invis", {duration = self:GetRemainingTime()})
    end)
end

modifier_item_swag_invis = class({})
function modifier_item_swag_invis:IsHidden() return false end
function modifier_item_swag_invis:IsPurgable() return true end
function modifier_item_swag_invis:CheckState()
    return {[MODIFIER_STATE_INVISIBLE] = true}
end
function modifier_item_swag_invis:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end
function modifier_item_swag_invis:GetModifierInvisibilityLevel()
    return 1
end