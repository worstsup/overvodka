item_chapman_red = class({})

function item_chapman_red:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_haste", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_green = class({})

function item_chapman_green:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_pink = class({})

function item_chapman_pink:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_arcane", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_yellow = class({})

function item_chapman_yellow:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_illusion", {duration = 0.1})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_indigo = class({})

function item_chapman_indigo:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_shield", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_violet = class({})

function item_chapman_violet:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_invis", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_chapman_blue = class({})

function item_chapman_blue:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_doubledamage", {duration = self:GetSpecialValueFor("duration")})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end

item_cubin = class({})

function item_cubin:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn("chapman", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_haste", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_arcane", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_shield", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_invis", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_doubledamage", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rune_illusion", {duration = 0.1})
    local effect_cast = ParticleManager:CreateParticle("particles/chapman.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:SpendCharge(1)
end