modifier_overvodka_store_pet_5 = class({})

function modifier_overvodka_store_pet_5:IsHidden() return true end
function modifier_overvodka_store_pet_5:IsPurgable() return false end

function modifier_overvodka_store_pet_5:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_5:GetModifierModelChange()
    return "models/amogus/source/choucatm.vmdl"
end