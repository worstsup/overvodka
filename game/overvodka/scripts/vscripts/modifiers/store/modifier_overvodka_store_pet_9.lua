modifier_overvodka_store_pet_9 = class({})

function modifier_overvodka_store_pet_9:IsHidden() return true end
function modifier_overvodka_store_pet_9:IsPurgable() return false end

function modifier_overvodka_store_pet_9:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_9:GetModifierModelChange()
    return "models/kotost/kot.vmdl"
end
