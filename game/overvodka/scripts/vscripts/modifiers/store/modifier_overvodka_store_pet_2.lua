modifier_overvodka_store_pet_2 = class({})

function modifier_overvodka_store_pet_2:IsHidden() return true end
function modifier_overvodka_store_pet_2:IsPurgable() return false end

function modifier_overvodka_store_pet_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_2:GetModifierModelChange()
    return "models/items/courier/hamster_courier/hamster_courier_lv1.vmdl"
end