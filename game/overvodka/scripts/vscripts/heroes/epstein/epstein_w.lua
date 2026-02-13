LinkLuaModifier("modifier_epstein_w_debuff", "heroes/epstein/epstein_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE)

epstein_w = class({})

function epstein_w:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    target:AddNewModifier(self:GetCaster(), self, "modifier_epstein_w_debuff", { duration = self:GetSpecialValueFor("duration") })
    target:EmitSound("epstein_w")
end


modifier_epstein_w_debuff = class({})

function modifier_epstein_w_debuff:IsHidden() return false end
function modifier_epstein_w_debuff:IsDebuff() return true end
function modifier_epstein_w_debuff:IsPurgable() return (not self:GetCaster():HasTalent("special_bonus_unique_epstein_5")) end

function modifier_epstein_w_debuff:OnCreated()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    if not self.ability then
        self:Destroy()
        return
    end

    self.armor = self.ability:GetSpecialValueFor("armor")
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.damage_interval = self.ability:GetSpecialValueFor("damage_interval")
    self.add_duration = self.ability:GetSpecialValueFor("add_duration")
    self.add_armor = self.ability:GetSpecialValueFor("add_armor")
    self.silence_duration = self.ability:GetSpecialValueFor("silence_duration")

    self:SetStackCount(0)
    if not IsServer() then return end
    CustomGameEventManager:Send_ServerToAllClients("epstein_w_square_start", {entindex = self:GetParent():entindex()})
    self:StartIntervalThink(self.damage_interval)
end

function modifier_epstein_w_debuff:OnRefresh()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    if not self.ability then return end

    self.armor = self.ability:GetSpecialValueFor("armor")
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.add_duration = self.ability:GetSpecialValueFor("add_duration")
    self.add_armor = self.ability:GetSpecialValueFor("add_armor")
    self.silence_duration = self.ability:GetSpecialValueFor("silence_duration")
end

function modifier_epstein_w_debuff:OnDestroy()
    if not IsServer() then return end
    CustomGameEventManager:Send_ServerToAllClients("epstein_w_square_end", {entindex = self:GetParent():entindex()})
end

function modifier_epstein_w_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

function modifier_epstein_w_debuff:GetModifierPhysicalArmorBonus()
    local stacks = self:GetStackCount() or 0
    return -( (self.armor or 0) + stacks * (self.add_armor or 0) )
end

function modifier_epstein_w_debuff:OnIntervalThink()
    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) or not parent:IsAlive() then
        self:Destroy()
        return
    end

    local caster = self.caster
    if not caster or caster:IsNull() or not IsValidEntity(caster) then
        caster = parent
    end
    ApplyDamage({victim = parent, attacker = caster, ability = self.ability, damage = self.damage * self.damage_interval, damage_type = DAMAGE_TYPE_PHYSICAL})
end

function modifier_epstein_w_debuff:OnAbilityFullyCast(params)
    if not IsServer() then return end
    if not params or not params.ability then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end

    if params.unit ~= parent then return end
    if params.ability:IsItem() then return end

    self:SetStackCount((self:GetStackCount() or 0) + 1)

    local add = self.add_duration or 0
    if add > 0 then
        local new_remaining = math.max(0.0, self:GetRemainingTime()) + add
        self:SetDuration(new_remaining, true)
    end

    local silence = self.silence_duration or 0
    if silence > 0 then
        local caster = self.caster
        if not caster or caster:IsNull() or not IsValidEntity(caster) then
            caster = self:GetCaster()
        end
        if not caster or caster:IsNull() or not IsValidEntity(caster) then
            caster = parent
        end

        parent:AddNewModifier(caster, self.ability, "modifier_generic_silenced_lua", { duration = silence })
    end
end