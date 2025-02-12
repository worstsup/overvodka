dvoreckov_innate = class({})

LinkLuaModifier("modifier_dvoreckov_innate", "heroes/dvoreckov/dvoreckov_innate.lua", LUA_MODIFIER_MOTION_NONE)

function dvoreckov_innate:GetIntrinsicModifierName()
    return "modifier_dvoreckov_innate"
end

modifier_dvoreckov_innate = class({})

function modifier_dvoreckov_innate:IsHidden() return true end
function modifier_dvoreckov_innate:IsPurgable() return false end

function modifier_dvoreckov_innate:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.5)
        self:OnIntervalThink()
    end
end

function modifier_dvoreckov_innate:OnIntervalThink()
    if IsServer() then
        self.spell_amp = math.random(-2000, 2500) / 100.0
        self:SetStackCount(math.floor(self.spell_amp * 100))
    end
end

function modifier_dvoreckov_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_dvoreckov_innate:GetModifierSpellAmplify_Percentage()
    return self.spell_amp or 0
end

function modifier_dvoreckov_innate:OnTooltip()
    return self.spell_amp
end

function modifier_dvoreckov_innate:GetTexture()
    return "kipil"
end