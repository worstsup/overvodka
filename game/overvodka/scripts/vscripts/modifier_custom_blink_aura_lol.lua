modifier_custom_blink_aura_lol = class({})

function modifier_custom_blink_aura_lol:IsHidden() return true end
function modifier_custom_blink_aura_lol:IsDebuff() return false end
function modifier_custom_blink_aura_lol:IsPurgable() return false end

function modifier_custom_blink_aura_lol:OnCreated()
    if not IsServer() then return end
end