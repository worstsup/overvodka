modifier_overvodka_store_pet_8 = class({})

function modifier_overvodka_store_pet_8:IsHidden() return true end
function modifier_overvodka_store_pet_8:IsPurgable() return false end

function modifier_overvodka_store_pet_8:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetModelScale(2)
end

function modifier_overvodka_store_pet_8:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModelScale(1)
end

function modifier_overvodka_store_pet_8:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_8:GetModifierModelChange()
    return "models/amogus/source/skipper.vmdl"
end