LinkLuaModifier("modifier_frisk_w", "heroes/frisk/frisk_w", LUA_MODIFIER_MOTION_NONE)

frisk_w = class({})

function frisk_w:IsStealable() return false end

local ALT_PAIRS = {
    {"frisk_q",        "frisk_q_alt"},
    {"frisk_e",        "frisk_e_alt"},
    {"frisk_ultimate", "frisk_r_alt"},
}

function frisk_w:Precache(context)
    PrecacheResource("particle", "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction_form.vpcf", context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
end

function frisk_w:GetAbilityTextureName()
    local caster = self:GetCaster()
    if caster and caster:HasModifier("modifier_frisk_w") then
        return "vihor_w"
    end
    return "vihor_q"
end

function frisk_w:SyncAltLevels()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    local lvl = self:GetLevel()
    for _, pair in ipairs(ALT_PAIRS) do
        local alt = caster:FindAbilityByName(pair[2])
        if alt then
            local max = (alt.GetMaxLevel and alt:GetMaxLevel()) or 4
            alt:SetLevel(math.min(lvl, max))
        end
    end
end

function frisk_w:OnUpgrade()
    if not IsServer() then return end
    self:SyncAltLevels()
end

function frisk_w:OnOwnerSpawned()
    if not IsServer() then return end
    self:SyncAltLevels()
end

function frisk_w:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()

    local m = c:FindModifierByName("modifier_frisk_w")
    if m then
        m:Destroy()
    else
        c:AddNewModifier(c, self, "modifier_frisk_w", {})
    end

    c:EmitSound("frisk_w")
    local p = ParticleManager:CreateParticle(
        "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction_form.vpcf",
        PATTACH_WORLDORIGIN, nil
    )
    ParticleManager:SetParticleControl(p, 1, c:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
end

modifier_frisk_w = class({})
function modifier_frisk_w:IsHidden() return true end
function modifier_frisk_w:IsPurgable() return false end
function modifier_frisk_w:RemoveOnDeath() return false end

function modifier_frisk_w:OnCreated()
    if not IsServer() then return end
    self.pairs = ALT_PAIRS

    for _, info in ipairs(self.pairs) do
        local a = self:GetCaster():FindAbilityByName(info[1])
        local b = self:GetCaster():FindAbilityByName(info[2])
        if a and b then
            self:GetCaster():SwapAbilities(info[1], info[2], false, true)
            b:SetHidden(false)
        end
    end

    local w = self:GetAbility()
    if w and not w:IsNull() then
        w:SyncAltLevels()
    end
end

function modifier_frisk_w:OnDestroy()
    if not IsServer() then return end
    for _, info in ipairs(self.pairs) do
        local a = self:GetCaster():FindAbilityByName(info[1])
        local b = self:GetCaster():FindAbilityByName(info[2])
        if a and b then
            self:GetCaster():SwapAbilities(info[2], info[1], false, true)
            b:SetHidden(true)
        end
    end
end
