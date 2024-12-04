modifier_chillguy_w_debuff = class({})

function modifier_chillguy_w_debuff:IsHidden() return true end
function modifier_chillguy_w_debuff:IsDebuff() return false end
function modifier_chillguy_w_debuff:IsPurgable() return false end

function modifier_chillguy_w_debuff:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_chillguy_w_debuff:OnRefresh()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_chillguy_w_debuff:IsAura() return true end
function modifier_chillguy_w_debuff:GetAuraRadius() return self.radius end
function modifier_chillguy_w_debuff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_chillguy_w_debuff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_chillguy_w_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_chillguy_w_debuff:GetModifierAura() return "modifier_chillguy_w_shard" end
