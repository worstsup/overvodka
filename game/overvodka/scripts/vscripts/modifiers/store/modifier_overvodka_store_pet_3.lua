modifier_overvodka_store_pet_3 = class({})

function modifier_overvodka_store_pet_3:IsHidden() return true end
function modifier_overvodka_store_pet_3:IsPurgable() return false end

function modifier_overvodka_store_pet_3:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetModelScale(0.25)
end

function modifier_overvodka_store_pet_3:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModelScale(1)
end

function modifier_overvodka_store_pet_3:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_3:GetModifierModelChange()
    return "models/amogus/source/amongus.vmdl"
end