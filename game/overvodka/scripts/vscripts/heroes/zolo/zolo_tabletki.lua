LinkLuaModifier("modifier_zolo_tabletki", "heroes/zolo/zolo_tabletki", LUA_MODIFIER_MOTION_NONE)

zolo_tabletki = class({})

if ZoloTabletkiData == nil then
    ZoloTabletkiData = { totalBonus = 0 }
end

function zolo_tabletki:Precache(context)
    PrecacheResource("soundfile", "soundevents/zolo_tabletki.vsndevts", context)
end

function zolo_tabletki:GetIntrinsicModifierName()
    return "modifier_zolo_tabletki"
end

function zolo_tabletki:OnSpellStart()
    local caster = self:GetCaster()
    local bonus_strength = self:GetSpecialValueFor("bonus_strength")

    if not caster:HasModifier("modifier_zolo_tabletki") then
        caster:AddNewModifier(caster, self, "modifier_zolo_tabletki", {})
    end

    local modifier = caster:FindModifierByName("modifier_zolo_tabletki")
    if modifier then
        modifier:AddBonusStrength(bonus_strength)
    end

    caster:EmitSound("zolo_tabletki")
end

function zolo_tabletki:GetCooldown(level)

    if GetMapName() == "overvodka_5x5" then
        return self.BaseClass.GetCooldown(self, level) + self:GetSpecialValueFor("dota_bonus_cooldown")
    end

    return self.BaseClass.GetCooldown(self, level)

end

modifier_zolo_tabletki = class({})

function modifier_zolo_tabletki:IsHidden() return (self:GetStackCount() == 0) end
function modifier_zolo_tabletki:IsPurgable() return false end
function modifier_zolo_tabletki:RemoveOnDeath() return false end
function modifier_zolo_tabletki:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_zolo_tabletki:AllowIllusionDuplicate() return true end

function modifier_zolo_tabletki:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(ZoloTabletkiData.totalBonus)
end

function modifier_zolo_tabletki:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_zolo_tabletki:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end

function modifier_zolo_tabletki:AddBonusStrength(amount)
    if not IsServer() then return end
    ZoloTabletkiData.totalBonus = ZoloTabletkiData.totalBonus + amount
    self:SetStackCount(ZoloTabletkiData.totalBonus)
    self:GetParent():CalculateStatBonus(true)
end
