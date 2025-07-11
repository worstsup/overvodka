modifier_overvodka_store_pet_6 = class({})

function modifier_overvodka_store_pet_6:IsHidden() return true end
function modifier_overvodka_store_pet_6:IsPurgable() return false end

function modifier_overvodka_store_pet_6:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetModelScale(0.2)
end

function modifier_overvodka_store_pet_6:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModelScale(1)
end

function modifier_overvodka_store_pet_6:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_6:GetModifierModelChange()
    return "models/amogus/source/skebob.vmdl"
end