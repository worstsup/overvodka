LinkLuaModifier("modifier_item_chips_base",  "items/chips", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_red_chips",   "items/chips", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_green_chips", "items/chips", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blue_chips",  "items/chips", LUA_MODIFIER_MOTION_NONE)

item_red_chips = class({})

function item_red_chips:OnAbilityPhaseStart()
    return self:GetCaster():IsHero()
end

function item_red_chips:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local charges = self:GetCurrentCharges()
    if charges <= 0 then
        caster:ConsumeItem(self)
        return
    end

    local mod = caster:FindModifierByName("modifier_item_red_chips")
    if not mod then
        mod = caster:AddNewModifier(caster, nil, "modifier_item_red_chips", {
            bonus_str = self:GetSpecialValueFor("bonus_str"),
            resist    = self:GetSpecialValueFor("resist"),
        })
    end

    mod:SetStackCount((mod:GetStackCount() or 0) + charges)
	mod:SendBuffRefreshToClients()

    caster:CalculateStatBonus(true)

    caster:ConsumeItem(self)
end

--------------------------------------------------------------------------------

item_green_chips = class({})

function item_green_chips:OnAbilityPhaseStart()
    return self:GetCaster():IsHero()
end

function item_green_chips:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local charges = self:GetCurrentCharges()
    if charges <= 0 then
        caster:ConsumeItem(self)
        return
    end

    local mod = caster:FindModifierByName("modifier_item_green_chips")
    if not mod then
        mod = caster:AddNewModifier(caster, nil, "modifier_item_green_chips", {
            bonus_agi = self:GetSpecialValueFor("bonus_agi"),
            movespeed = self:GetSpecialValueFor("movespeed"),
        })
    end

    mod:SetStackCount((mod:GetStackCount() or 0) + charges)
	mod:SendBuffRefreshToClients()

    caster:CalculateStatBonus(true)

    caster:ConsumeItem(self)
end

--------------------------------------------------------------------------------

item_blue_chips = class({})

function item_blue_chips:OnAbilityPhaseStart()
    return self:GetCaster():IsHero()
end

function item_blue_chips:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local charges = self:GetCurrentCharges()
    if charges <= 0 then
        caster:ConsumeItem(self)
        return
    end

    local mod = caster:FindModifierByName("modifier_item_blue_chips")
    if not mod then
        mod = caster:AddNewModifier(caster, nil, "modifier_item_blue_chips", {
            bonus_int = self:GetSpecialValueFor("bonus_int"),
            amp       = self:GetSpecialValueFor("spell_amplify"),
        })
    end

    mod:SetStackCount((mod:GetStackCount() or 0) + charges)
	mod:SendBuffRefreshToClients()

    caster:CalculateStatBonus(true)

    caster:ConsumeItem(self)
end

modifier_item_chips_base = class({})

function modifier_item_chips_base:IsPurgable() return false end
function modifier_item_chips_base:RemoveOnDeath() return false end

function modifier_item_chips_base:OnCreated(kv)
    self._v = self._v or {}
    self:SetHasCustomTransmitterData(true)

    if not IsServer() then return end

    self:_LoadValues(kv)

    if kv and kv.stacks ~= nil then
        self:SetStackCount(math.max(0, math.floor(tonumber(kv.stacks) or 0)))
    end

    self:SendBuffRefreshToClients()
end

function modifier_item_chips_base:OnRefresh(kv)
    self._v = self._v or {}
    self:SetHasCustomTransmitterData(true)

    if not IsServer() then return end

    self:_LoadValues(kv)
    self:SendBuffRefreshToClients()
end

function modifier_item_chips_base:AddCustomTransmitterData()
    self._txData = self._txData or {}
    local t = self._txData

    t.bonus_str = self._v.bonus_str or 0
    t.resist    = self._v.resist    or 0

    t.bonus_agi = self._v.bonus_agi or 0
    t.movespeed = self._v.movespeed or 0

    t.bonus_int = self._v.bonus_int or 0
    t.amp       = self._v.amp       or 0

    return t
end

function modifier_item_chips_base:HandleCustomTransmitterData(data)
    if not data then return end
    self._v = self._v or {}

    self._v.bonus_str = tonumber(data.bonus_str) or 0
    self._v.resist    = tonumber(data.resist)    or 0

    self._v.bonus_agi = tonumber(data.bonus_agi) or 0
    self._v.movespeed = tonumber(data.movespeed) or 0

    self._v.bonus_int = tonumber(data.bonus_int) or 0
    self._v.amp       = tonumber(data.amp)       or 0
end

function modifier_item_chips_base:_LoadValues(kv)
    self._v = self._v or {}

    local ability = self:GetAbility()
    if ability and (not ability:IsNull()) then
        self:_LoadFromAbility(ability)
        return
    end

    self:_LoadFromKV(kv)
end

function modifier_item_chips_base:_LoadFromAbility(ability) end
function modifier_item_chips_base:_LoadFromKV(kv) end

--------------------------------------------------------------------------------
-- RED
modifier_item_red_chips = class(modifier_item_chips_base)

function modifier_item_red_chips:GetTexture() return "red_chips" end

function modifier_item_red_chips:_LoadFromAbility(ability)
    self._v.bonus_str = ability:GetSpecialValueFor("bonus_str") or 0
    self._v.resist    = ability:GetSpecialValueFor("resist") or 0
end

function modifier_item_red_chips:_LoadFromKV(kv)
    self._v.bonus_str = tonumber(kv and kv.bonus_str) or 0
    self._v.resist    = tonumber(kv and kv.resist) or 0
end

function modifier_item_red_chips:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
end

function modifier_item_red_chips:GetModifierBonusStats_Strength()
    return (self:GetStackCount() or 0) * (self._v.bonus_str or 0)
end

function modifier_item_red_chips:GetModifierStatusResistanceStacking()
    return (self:GetStackCount() or 0) * (self._v.resist or 0)
end

--------------------------------------------------------------------------------
-- GREEN
modifier_item_green_chips = class(modifier_item_chips_base)

function modifier_item_green_chips:GetTexture() return "green_chips" end

function modifier_item_green_chips:_LoadFromAbility(ability)
    self._v.bonus_agi  = ability:GetSpecialValueFor("bonus_agi") or 0
    self._v.movespeed  = ability:GetSpecialValueFor("movespeed") or 0
end

function modifier_item_green_chips:_LoadFromKV(kv)
    self._v.bonus_agi = tonumber(kv and kv.bonus_agi) or 0
    self._v.movespeed = tonumber(kv and kv.movespeed) or 0
end

function modifier_item_green_chips:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_green_chips:GetModifierBonusStats_Agility()
    return (self:GetStackCount() or 0) * (self._v.bonus_agi or 0)
end

function modifier_item_green_chips:GetModifierMoveSpeedBonus_Percentage()
    return (self:GetStackCount() or 0) * (self._v.movespeed or 0)
end

--------------------------------------------------------------------------------
-- BLUE
modifier_item_blue_chips = class(modifier_item_chips_base)

function modifier_item_blue_chips:GetTexture() return "blue_chips" end

function modifier_item_blue_chips:_LoadFromAbility(ability)
    self._v.bonus_int  = ability:GetSpecialValueFor("bonus_int") or 0
    self._v.amp        = ability:GetSpecialValueFor("spell_amplify") or 0
end

function modifier_item_blue_chips:_LoadFromKV(kv)
    self._v.bonus_int = tonumber(kv and kv.bonus_int) or 0
    self._v.amp       = tonumber(kv and kv.amp) or 0
end

function modifier_item_blue_chips:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_blue_chips:GetModifierBonusStats_Intellect()
    return (self:GetStackCount() or 0) * (self._v.bonus_int or 0)
end

function modifier_item_blue_chips:GetModifierSpellAmplify_Percentage()
    return (self:GetStackCount() or 0) * (self._v.amp or 0)
end