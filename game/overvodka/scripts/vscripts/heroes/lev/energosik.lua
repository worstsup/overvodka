energosik = class({})

function energosik:Precache(context)
    PrecacheResource("soundfile", "soundevents/redbull.vsndevts", context)
end

function energosik:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    EmitSoundOn("redbull", caster)
    caster:AddNewModifier(caster, self, "modifier_rune_haste", {
        duration = self:GetSpecialValueFor("duration"),
    })
end
