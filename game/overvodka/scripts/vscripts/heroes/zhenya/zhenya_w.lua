LinkLuaModifier( "modifier_zhenya_w", "heroes/zhenya/zhenya_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_buff", "heroes/zhenya/zhenya_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_enemy_aura", "heroes/zhenya/zhenya_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_w_enemy_debuff", "heroes/zhenya/zhenya_w", LUA_MODIFIER_MOTION_NONE )

zhenya_w = class({})

function zhenya_w:Precache(context)
    PrecacheResource("model", "models/burgers/burgers.vmdl", context)
    PrecacheResource("particle", "particles/zhenya_w.vpcf", context)
    PrecacheResource("soundfile", "soundevents/zhenya_w.vsndevts", context)
end

function zhenya_w:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function zhenya_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local burger = CreateUnitByName("npc_burger", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    burger:SetControllableByPlayer(caster:GetPlayerID(), false)
    burger:SetOwner(caster)
    burger:AddNewModifier(caster, self, "modifier_zhenya_w", {})
    burger:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    if caster:HasTalent("special_bonus_unique_zhenya_7") then
        burger:AddNewModifier(caster, self, "modifier_zhenya_w_enemy_aura", {})
    end
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "zhenya_w_start", caster)
end

modifier_zhenya_w = class({})

function modifier_zhenya_w:IsHidden() return true end
function modifier_zhenya_w:IsPurgable() return false end

function modifier_zhenya_w:OnCreated()
    if not IsServer() then return end
    EmitSoundOn("zhenya_w_loop", self:GetParent())
    local fx = ParticleManager:CreateParticle("particles/zhenya_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(fx, false, false, -1, false, false)
end

function modifier_zhenya_w:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("zhenya_w_loop", self:GetParent())
    UTIL_Remove(self:GetParent())
end

function modifier_zhenya_w:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE]      = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
    }
end

function modifier_zhenya_w:IsAura() return true end
function modifier_zhenya_w:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_zhenya_w:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_zhenya_w:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_zhenya_w:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_zhenya_w:GetModifierAura() return "modifier_zhenya_w_buff" end
function modifier_zhenya_w:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_duration") end

modifier_zhenya_w_buff = class({})

function modifier_zhenya_w_buff:IsHidden() return false end
function modifier_zhenya_w_buff:IsPurgable() return false end
function modifier_zhenya_w_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_zhenya_w_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_zhenya_w_buff:OnIntervalThink()
    local parent = self:GetParent()
    local auraCaster = self:GetAuraOwner()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    if (parent:GetAbsOrigin() - auraCaster:GetAbsOrigin()):Length2D() <= radius then
        self:IncrementStackCount()
        parent:CalculateStatBonus(true)
    end
end

function modifier_zhenya_w_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_zhenya_w_buff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("strength") * self:GetStackCount()
end

modifier_zhenya_w_enemy_aura = class({})

function modifier_zhenya_w_enemy_aura:IsHidden() return true end
function modifier_zhenya_w_enemy_aura:IsPurgable() return false end

function modifier_zhenya_w_enemy_aura:IsAura() return true end
function modifier_zhenya_w_enemy_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_zhenya_w_enemy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_zhenya_w_enemy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_zhenya_w_enemy_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_zhenya_w_enemy_aura:GetModifierAura() return "modifier_zhenya_w_enemy_debuff" end
function modifier_zhenya_w_enemy_aura:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_duration") end

modifier_zhenya_w_enemy_debuff = class({})

function modifier_zhenya_w_enemy_debuff:IsHidden() return false end
function modifier_zhenya_w_enemy_debuff:IsDebuff() return true end
function modifier_zhenya_w_enemy_debuff:IsPurgable() return false end
function modifier_zhenya_w_enemy_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_zhenya_w_enemy_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_zhenya_w_enemy_debuff:OnIntervalThink()
    local parent = self:GetParent()
    local auraCaster = self:GetAuraOwner()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    if (parent:GetAbsOrigin() - auraCaster:GetAbsOrigin()):Length2D() <= radius then
        self:IncrementStackCount()
        parent:CalculateStatBonus(true)
    end
end

function modifier_zhenya_w_enemy_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_zhenya_w_enemy_debuff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("strength_loss") * self:GetStackCount()
end
