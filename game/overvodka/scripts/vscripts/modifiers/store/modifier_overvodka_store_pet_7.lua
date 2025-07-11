modifier_overvodka_store_pet_7 = class({})

function modifier_overvodka_store_pet_7:IsHidden() return true end
function modifier_overvodka_store_pet_7:IsPurgable() return false end

function modifier_overvodka_store_pet_7:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetModelScale(0.12)
end

function modifier_overvodka_store_pet_7:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModelScale(1)
end

function modifier_overvodka_store_pet_7:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_overvodka_store_pet_7:GetModifierModelChange()
    return "models/amogus/source/spike.vmdl"
end