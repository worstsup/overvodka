modifier_overvodka_creep = class({})

function modifier_overvodka_creep:IsHidden()      return true end
function modifier_overvodka_creep:IsPurgable()    return false  end

function modifier_overvodka_creep:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_overvodka_creep:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.attacker == self:GetParent() and params.target:IsBuilding() then
        return -50
    end
    return 0
end