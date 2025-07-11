modifier_overvodka_store_pet_4 = class({})

function modifier_overvodka_store_pet_4:IsHidden() return true end
function modifier_overvodka_store_pet_4:IsPurgable() return false end

function modifier_overvodka_store_pet_4:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_4:GetModifierModelChange()
    return "models/amogus/source/mcqueen.vmdl"
end