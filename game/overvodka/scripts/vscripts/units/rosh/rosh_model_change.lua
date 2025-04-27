rosh_model_change = class({})
LinkLuaModifier("modifier_rosh_model_change", "units/rosh/rosh_model_change.lua", LUA_MODIFIER_MOTION_NONE)

function rosh_model_change:GetIntrinsicModifierName()
    return "modifier_rosh_model_change"
end

modifier_rosh_model_change = class({})
function modifier_rosh_model_change:IsHidden() return true end
function modifier_rosh_model_change:IsPurgable() return false end
function modifier_rosh_model_change:IsPurgeException() return false end
function modifier_rosh_model_change:RemoveOnDeath() return false end
function modifier_rosh_model_change:IsPermanent() return true end

function modifier_rosh_model_change:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function modifier_rosh_model_change:GetModifierModelChange()
    return "models/shrek/shrek.vmdl"
end