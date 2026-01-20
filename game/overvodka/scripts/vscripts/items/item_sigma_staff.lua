LinkLuaModifier("modifier_item_sigma_staff_passive", "items/item_sigma_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sigma_staff_active",  "items/item_sigma_staff", LUA_MODIFIER_MOTION_NONE)

item_sigma_staff = class({})

function item_sigma_staff:GetIntrinsicModifierName()
    return "modifier_item_sigma_staff_passive"
end

function item_sigma_staff:GetAbilityTextureName()
    local caster = self:GetCaster()
    if caster and caster:HasModifier("modifier_item_sigma_staff_active") then
        return "sigma_staff_active"
    end
    return "sigma_staff"
end

function item_sigma_staff:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    if caster:HasModifier("modifier_item_sigma_staff_active") then
        caster:RemoveModifierByName("modifier_item_sigma_staff_active")
        caster:EmitSound("DOTA_Item.Armlet.DeActivate")
    else
        caster:AddNewModifier(caster, self, "modifier_item_sigma_staff_active", {})
        caster:EmitSound("DOTA_Item.Armlet.Activate")
    end
end


modifier_item_sigma_staff_passive = class({})

function modifier_item_sigma_staff_passive:IsHidden()      return true end
function modifier_item_sigma_staff_passive:IsPurgable()    return false end
function modifier_item_sigma_staff_passive:RemoveOnDeath() return false end
function modifier_item_sigma_staff_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_sigma_staff_passive:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability then return end

    self.bonus_int    = self.ability:GetSpecialValueFor("int")
    self.bonus_armor  = self.ability:GetSpecialValueFor("armor")
    self.bonus_damage = self.ability:GetSpecialValueFor("dmg")
    self.bonus_mp_reg = self.ability:GetSpecialValueFor("mp")
end

function modifier_item_sigma_staff_passive:OnRefresh()
    self:OnCreated()
end

function modifier_item_sigma_staff_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_item_sigma_staff_passive:GetModifierBonusStats_Intellect()
	if not self:GetAbility() then return end
    return self.bonus_int or 0
end

function modifier_item_sigma_staff_passive:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
    return self.bonus_armor or 0
end

function modifier_item_sigma_staff_passive:GetModifierPreAttack_BonusDamage()
	if not self:GetAbility() then return end
    return self.bonus_damage or 0
end

function modifier_item_sigma_staff_passive:GetModifierConstantManaRegen()
	if not self:GetAbility() then return end
    return self.bonus_mp_reg or 0
end


modifier_item_sigma_staff_active = class({})

function modifier_item_sigma_staff_active:IsHidden()      return true end
function modifier_item_sigma_staff_active:IsPurgable()    return false end
function modifier_item_sigma_staff_active:RemoveOnDeath() return true end
function modifier_item_sigma_staff_active:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_sigma_staff_active:GetEffectName()
    return "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_v2_debuff.vpcf"
end

function modifier_item_sigma_staff_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_sigma_staff_active:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()

    if not self.ability then return end
    self.bonus_armor_active   = self.ability:GetSpecialValueFor("bonus_armor")
    self.spell_amp            = self.ability:GetSpecialValueFor("unholy_bonus_damage")

    self.total_bonus_str      = self.ability:GetSpecialValueFor("unholy_bonus_strength")
    self.ticks_to_full        = self.ability:GetSpecialValueFor("unholy_ticks_to_full_effect")
    self.tick_interval_str    = self.ability:GetSpecialValueFor("unholy_tick_interval")

    self.drain_pct_per_sec    = self.ability:GetSpecialValueFor("unholy_health_drain_per_second")
    self.drain_interval       = self.ability:GetSpecialValueFor("unholy_health_drain_interval")

	self.hp_per_str           = 22

    self.current_bonus_str    = 0
    self.ticks_done           = 0
    self.str_tick_accum       = 0

	self.ticks_active         = 0

    if not IsServer() then return end
    self.parent:EmitSound("sigmastaff")
    self:StartIntervalThink(self.drain_interval)
end

function modifier_item_sigma_staff_active:OnRefresh()
    self:OnCreated()
end

function modifier_item_sigma_staff_active:OnDestroy()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    self.parent:StopSound("sigmastaff")

    if self.ticks_active and self.ticks_active > 0 then
        self.current_bonus_str = 0
        self.parent:CalculateStatBonus(true)

        local health_bonus_interval_ratio =
            (self.total_bonus_str / self.ticks_to_full) * self.hp_per_str

        for i = 1, self.ticks_active do
            local currentHP = self.parent:GetHealth()
            local maxHP     = self.parent:GetMaxHealth()

            local amount_to_damage =
                ((currentHP + health_bonus_interval_ratio) / (maxHP + health_bonus_interval_ratio)) * maxHP
                - currentHP

            local new_hp = currentHP - amount_to_damage
            if new_hp < 1 then new_hp = 1 end
            self.parent:SetHealth(new_hp)
        end
    end

    self.ticks_active      = 0
    self.ticks_done        = 0
    self.current_bonus_str = 0
end

function modifier_item_sigma_staff_active:OnIntervalThink()
    if not IsServer() then return end
	if not self:GetAbility() then
		self:Destroy()
		return
	end
    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end
    if not self.parent:IsAlive() then
        self.parent:RemoveModifierByName("modifier_item_sigma_staff_active")
        return
    end
    if not self.parent:HasItemInInventory("item_sigma_staff") then
        self.parent:RemoveModifierByName("modifier_item_sigma_staff_active")
        return
    end

    local parent = self.parent

    local mana     = parent:GetMana()
    local max_mana = parent:GetMaxMana()
    local drain    = self.drain_pct_per_sec * 0.01 * max_mana * self.drain_interval

    local new_mana = mana - drain
    if new_mana < 1 then new_mana = 1 end
    parent:SetMana(new_mana)

    if self.ticks_done < self.ticks_to_full and self.total_bonus_str > 0 then
        self.str_tick_accum = self.str_tick_accum + self.drain_interval

        while self.str_tick_accum >= self.tick_interval_str and self.ticks_done < self.ticks_to_full do
            self.str_tick_accum = self.str_tick_accum - self.tick_interval_str
            self.ticks_done     = self.ticks_done + 1

            local health_bonus_interval_ratio =
                (self.total_bonus_str / self.ticks_to_full) * self.hp_per_str

            local per_tick_str = self.total_bonus_str / self.ticks_to_full
            self.current_bonus_str = self.current_bonus_str + per_tick_str
            parent:CalculateStatBonus(true)

            local currentHP = parent:GetHealth()
            local maxHP     = parent:GetMaxHealth()

            local amount_to_heal =
                ((currentHP + health_bonus_interval_ratio) / (maxHP + health_bonus_interval_ratio)) * maxHP
                - currentHP

            parent:SetHealth(math.max(1, currentHP + amount_to_heal))

            self.ticks_active = self.ticks_active + 1
        end
    end
end

function modifier_item_sigma_staff_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_item_sigma_staff_active:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return end
    return self.bonus_armor_active or 0
end

function modifier_item_sigma_staff_active:GetModifierSpellAmplify_Percentage()
	if not self:GetAbility() then return end
    return self.spell_amp or 0
end

function modifier_item_sigma_staff_active:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
    return self.current_bonus_str or 0
end
