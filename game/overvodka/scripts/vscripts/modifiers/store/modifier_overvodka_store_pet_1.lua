modifier_overvodka_store_pet_1 = class({})

function modifier_overvodka_store_pet_1:IsHidden() return true end
function modifier_overvodka_store_pet_1:IsPurgable() return false end

function modifier_overvodka_store_pet_1:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_1:GetModifierModelChange()
    return "models/items/courier/butch_pudge_dog/butch_pudge_dog.vmdl"
end