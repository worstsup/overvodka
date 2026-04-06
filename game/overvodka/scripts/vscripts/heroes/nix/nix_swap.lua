LinkLuaModifier("modifier_nix_swap_levin", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_swap_pravin", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_swap_levin_updater", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_swap_pravin_updater", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_swap_levin_bonus", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nix_swap_pravin_bonus", "heroes/nix/nix_swap", LUA_MODIFIER_MOTION_NONE)

local NIX_DYNAMIC_SPECIALS = {
    ejovik = {
        bonus_mag = "levin",
        bonus_mp = "levin",
        bonus_resist = "levin",
        evasion = "pravin",
        bonus_as = "pravin",
    },
    nix_semya = {
        damage_steal = "pravin",
        dps = "levin",
        magresist = "levin",
    },
    gunnar_bash = {
        damage = "both",
        armor = "pravin",
        armor_duration = "pravin",
    },
    nix_rus = {
        dps = "levin",
        as_loss = "pravin",
    },
}

local function PlayLevinSwapParticle(caster)
    local particle = ParticleManager:CreateParticle("particles/ui/ui_slark_goalburst_relic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:ReleaseParticleIndex(particle)
end

local function PlayPravinSwapParticle(caster)
    local origin = caster:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle("particles/nix_pravin_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 1, Vector(100, 0, 0))
    ParticleManager:SetParticleControl(particle, 3, origin)
    ParticleManager:ReleaseParticleIndex(particle)
end

local function PlayNixSwapClientSound(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local player = caster:GetPlayerOwner()
    if not player then return end

    EmitSoundOnClient("ui.pick_repick", player)
end

local function ApplyNixPrimaryAttribute(caster, is_pravin)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end
    if not caster.SetPrimaryAttribute then return end

    local primary_attribute = is_pravin and DOTA_ATTRIBUTE_AGILITY or DOTA_ATTRIBUTE_INTELLECT
    caster:SetPrimaryAttribute(primary_attribute)
    caster:CalculateStatBonus(true)
end

local function RefreshNixAbilityButtons(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local abilities = {
        "nix_levin",
        "nix_pravin",
        "ejovik",
        "nix_semya",
        "gunnar_bash",
        "nix_rus",
    }

    for _, ability_name in ipairs(abilities) do
        local ability = caster:FindAbilityByName(ability_name)
        if ability and not ability:IsNull() then
            ability:MarkAbilityButtonDirty()
        end
    end
end

local function GetNixDynamicSpecialMode(ability_name, value_name)
    local ability_values = NIX_DYNAMIC_SPECIALS[ability_name]
    if not ability_values then return nil end

    return ability_values[value_name]
end

local function GetNixDynamicSpecialValue(parent, ability, value_name, special_level)
    if not ability or ability:IsNull() then return nil end

    local ability_name = ability:GetAbilityName()
    local mode = GetNixDynamicSpecialMode(ability_name, value_name)
    if not mode then return nil end

    local is_pravin = parent and not parent:IsNull() and parent:HasModifier("modifier_nix_swap_pravin")

    if mode == "levin" and is_pravin then
        return 0
    end

    if mode == "pravin" and not is_pravin then
        return 0
    end

    local resolved_level = tonumber(special_level)
    if resolved_level == nil or resolved_level < 0 then
        resolved_level = math.max((ability:GetLevel() or 1) - 1, 0)
    end

    local value = tonumber(ability:GetLevelSpecialValueNoOverride(value_name, resolved_level)) or 0

    if ability_name == "gunnar_bash" and value_name == "damage" and not is_pravin then
        local multiplier = tonumber(ability:GetLevelSpecialValueNoOverride("magic_damage_multiplier", resolved_level)) or 1
        if multiplier <= 0 then
            multiplier = 1
        end
        value = value * multiplier
    end

    return value
end

local function ShouldOverrideNixSpecial(parent, params)
    if not parent or parent:IsNull() then return 0 end
    if not params or not params.ability or params.ability:IsNull() then return 0 end

    local ability_name = params.ability:GetAbilityName()
    local value_name = params.ability_special_value
    if not ability_name or not value_name then return 0 end

    return GetNixDynamicSpecialMode(ability_name, value_name) and 1 or 0
end

local function EnsureStanceAbilityLevels(caster)
    if not caster or caster:IsNull() then return end

    local levin = caster:FindAbilityByName("nix_levin")
    local pravin = caster:FindAbilityByName("nix_pravin")

    return levin, pravin
end

local function SyncStanceAbilities(caster)
    if not IsServer() then return end

    local levin, pravin = EnsureStanceAbilityLevels(caster)
    if not levin or not pravin then return end

    if not caster:HasModifier("modifier_nix_swap_levin") and not caster:HasModifier("modifier_nix_swap_pravin") then
        caster:AddNewModifier(caster, levin, "modifier_nix_swap_levin", {})
        ApplyNixPrimaryAttribute(caster, false)
        return
    end

    if caster:HasModifier("modifier_nix_swap_pravin") then
        if pravin:IsHidden() then
            caster:SwapAbilities("nix_levin", "nix_pravin", false, true)
        end
        ApplyNixPrimaryAttribute(caster, true)
        return
    end

    if levin:IsHidden() then
        caster:SwapAbilities("nix_pravin", "nix_levin", false, true)
    end
    ApplyNixPrimaryAttribute(caster, false)
end

nix_levin = class({})
nix_pravin = class({})

function nix_levin:IsStealable() return false end
function nix_pravin:IsStealable() return false end

function nix_levin:Precache(context)
    PrecacheResource("particle", "particles/ui/ui_slark_goalburst_relic.vpcf", context)
    PrecacheResource("particle", "particles/nix_pravin_swap.vpcf", context)
    PrecacheResource("particle", "particles/custom_hud/nix_levin.vpcf", context)
    PrecacheResource("particle", "particles/custom_hud/nix_pravin.vpcf", context)
    PrecacheResource("particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context)
    PrecacheResource("particle", "particles/generic_gameplay/generic_lifesteal.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", context)
end

function nix_levin:Spawn()
    if not IsServer() then return end
    if not self:IsTrained() then
        self:SetLevel(1)
    end
    local pravin = self:GetCaster():FindAbilityByName("nix_pravin")
    if pravin and not pravin:IsTrained() then
        pravin:SetLevel(1)
    end
    SyncStanceAbilities(self:GetCaster())
end

function nix_pravin:Spawn()
    if not IsServer() then return end
    if not self:IsTrained() then
        self:SetLevel(1)
    end
    local levin = self:GetCaster():FindAbilityByName("nix_levin")
    if levin and not levin:IsTrained() then
        levin:SetLevel(1)
    end
    SyncStanceAbilities(self:GetCaster())
end

function nix_levin:OnOwnerSpawned()
    if not IsServer() then return end
    SyncStanceAbilities(self:GetCaster())
end

function nix_pravin:OnOwnerSpawned()
    if not IsServer() then return end
    SyncStanceAbilities(self:GetCaster())
end

function nix_levin:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local _, pravin = EnsureStanceAbilityLevels(caster)
    local bonus_duration = self:GetSpecialValueFor("bonus_duration")

    caster:RemoveModifierByName("modifier_nix_swap_levin")
    caster:RemoveModifierByName("modifier_nix_swap_levin_updater")
    caster:RemoveModifierByName("modifier_nix_swap_pravin_updater")
    caster:AddNewModifier(caster, self, "modifier_nix_swap_pravin", {})
    caster:AddNewModifier(caster, self, "modifier_nix_swap_pravin_updater", { duration = 3.25 })
    caster:AddNewModifier(caster, self, "modifier_nix_swap_pravin_bonus", { duration = bonus_duration })
    if pravin and not pravin:IsNull() then
        pravin:UseResources(false, false, false, true)
    end
    PlayPravinSwapParticle(caster)
    PlayNixSwapClientSound(caster)
    RefreshNixAbilityButtons(caster)
    EmitSoundOn("nix_pravin", caster)
end

function nix_pravin:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local levin = EnsureStanceAbilityLevels(caster)
    local bonus_duration = self:GetSpecialValueFor("bonus_duration")

    caster:RemoveModifierByName("modifier_nix_swap_pravin")
    caster:RemoveModifierByName("modifier_nix_swap_levin_updater")
    caster:RemoveModifierByName("modifier_nix_swap_pravin_updater")
    caster:AddNewModifier(caster, self, "modifier_nix_swap_levin", {})
    caster:AddNewModifier(caster, self, "modifier_nix_swap_levin_updater", { duration = 3.25 })
    caster:AddNewModifier(caster, self, "modifier_nix_swap_levin_bonus", { duration = bonus_duration })
    if levin and not levin:IsNull() then
        levin:UseResources(false, false, false, true)
    end
    PlayLevinSwapParticle(caster)
    PlayNixSwapClientSound(caster)
    RefreshNixAbilityButtons(caster)
    EmitSoundOn("nix_levin", caster)
end

modifier_nix_swap_levin = class({})
modifier_nix_swap_pravin = class({})

function modifier_nix_swap_levin:IsHidden() return true end
function modifier_nix_swap_levin:IsPurgable() return false end
function modifier_nix_swap_levin:RemoveOnDeath() return false end

function modifier_nix_swap_levin:OnCreated()
    if not IsServer() then return end
    SyncStanceAbilities(self:GetParent())
    ApplyNixPrimaryAttribute(self:GetParent(), false)
    RefreshNixAbilityButtons(self:GetParent())
end

function modifier_nix_swap_levin:GetTexture()
    return "nix_levin"
end

function modifier_nix_swap_levin:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_nix_swap_levin:GetModifierOverrideAbilitySpecial(params)
    return ShouldOverrideNixSpecial(self:GetParent(), params)
end

function modifier_nix_swap_levin:GetModifierOverrideAbilitySpecialValue(params)
    return GetNixDynamicSpecialValue(self:GetParent(), params.ability, params.ability_special_value, params.ability_special_level)
end

function modifier_nix_swap_pravin:IsHidden() return true end
function modifier_nix_swap_pravin:IsPurgable() return false end
function modifier_nix_swap_pravin:RemoveOnDeath() return false end

function modifier_nix_swap_pravin:OnCreated()
    if not IsServer() then return end
    SyncStanceAbilities(self:GetParent())
    ApplyNixPrimaryAttribute(self:GetParent(), true)
    RefreshNixAbilityButtons(self:GetParent())
end

function modifier_nix_swap_pravin:GetTexture()
    return "nix_pravin"
end

function modifier_nix_swap_pravin:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    }
end

function modifier_nix_swap_pravin:GetModifierOverrideAbilitySpecial(params)
    return ShouldOverrideNixSpecial(self:GetParent(), params)
end

function modifier_nix_swap_pravin:GetModifierOverrideAbilitySpecialValue(params)
    return GetNixDynamicSpecialValue(self:GetParent(), params.ability, params.ability_special_value, params.ability_special_level)
end

modifier_nix_swap_levin_updater = class({})
modifier_nix_swap_pravin_updater = class({})
modifier_nix_swap_levin_bonus = class({})
modifier_nix_swap_pravin_bonus = class({})

function modifier_nix_swap_levin_updater:IsHidden() return true end
function modifier_nix_swap_levin_updater:IsPurgable() return false end

function modifier_nix_swap_pravin_updater:IsHidden() return true end
function modifier_nix_swap_pravin_updater:IsPurgable() return false end

function modifier_nix_swap_levin_bonus:IsHidden() return false end
function modifier_nix_swap_levin_bonus:IsPurgable() return true end

function modifier_nix_swap_levin_bonus:OnCreated()
    self.spell_lifesteal = 0

    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        self.spell_lifesteal = ability:GetSpecialValueFor("spell_lifesteal")
    end
end

function modifier_nix_swap_levin_bonus:OnRefresh()
    self:OnCreated()
end

function modifier_nix_swap_levin_bonus:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_nix_swap_levin_bonus:OnTakeDamage(params)
    if not IsServer() then return end
    if not self.spell_lifesteal or self.spell_lifesteal <= 0 then return end

    local parent = self:GetParent()
    if params.attacker ~= parent then return end
    if parent == params.unit then return end
    if not params.inflictor then return end
    if parent:IsIllusion() then return end
    if not params.unit or params.unit:IsNull() then return end
    if params.unit:IsBuilding() or params.unit:IsWard() or params.unit:IsOther() then return end
    if params.damage <= 0 then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
    if bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then return end

    local bonus_percentage = 0
    for _, mod in pairs(parent:FindAllModifiers()) do
        if mod ~= self and mod.GetModifierSpellLifestealRegenAmplify_Percentage and mod:GetModifierSpellLifestealRegenAmplify_Percentage() then
            bonus_percentage = bonus_percentage + mod:GetModifierSpellLifestealRegenAmplify_Percentage()
        end
    end

    local heal = self.spell_lifesteal * 0.01 * params.damage
    heal = heal * (bonus_percentage * 0.01 + 1)
    if heal <= 0 then return end

    parent:HealWithParams(heal, self:GetAbility(), false, true, parent, true)
    local particle = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_nix_swap_levin_bonus:OnTooltip()
    return self.spell_lifesteal or 0
end

function modifier_nix_swap_levin_bonus:GetTexture()
    return "nix_levin"
end

function modifier_nix_swap_pravin_bonus:IsHidden() return false end
function modifier_nix_swap_pravin_bonus:IsPurgable() return true end
function modifier_nix_swap_pravin_bonus:ShouldUseOverheadOffset() return true end

function modifier_nix_swap_pravin_bonus:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.lifesteal = 0

    if self.ability and not self.ability:IsNull() then
        self.lifesteal = self.ability:GetSpecialValueFor("lifesteal_pct") * 0.01
    end

    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(particle, 1, self.parent:GetOrigin())
    self:AddParticle(particle, false, false, 1, false, true)
end

function modifier_nix_swap_pravin_bonus:OnRefresh()
    self.ability = self:GetAbility()
    self.lifesteal = 0

    if self.ability and not self.ability:IsNull() then
        self.lifesteal = self.ability:GetSpecialValueFor("lifesteal_pct") * 0.01
    end
end

function modifier_nix_swap_pravin_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_nix_swap_pravin_bonus:GetModifierProcAttack_Feedback(params)
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if params.attacker ~= self.parent then return end
    if not params.target or params.target:IsNull() then return end
    if params.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if params.target:IsBuilding() or params.target:IsOther() then return end

    self.attack_record = params.record
end

function modifier_nix_swap_pravin_bonus:OnTakeDamage(params)
    if not IsServer() then return end
    if self.attack_record ~= params.record then return end
    if not self.lifesteal or self.lifesteal <= 0 then return end
    if params.attacker ~= self.parent then return end
    if not params.unit or params.unit:IsNull() then return end

    local heal = params.damage * self.lifesteal
    if params.unit:IsCreep() then
        heal = heal * 0.6
    end
    if heal <= 0 then return end

    self.parent:HealWithParams(heal, self.ability, true, true, self.parent, false)
    local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_nix_swap_pravin_bonus:OnTooltip()
    if not self.ability or self.ability:IsNull() then return 0 end
    return self.ability:GetSpecialValueFor("lifesteal_pct")
end

function modifier_nix_swap_pravin_bonus:GetTexture()
    return "nix_pravin"
end