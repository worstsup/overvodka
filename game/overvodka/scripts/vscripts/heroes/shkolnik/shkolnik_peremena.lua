shkolnik_peremena = class({})

function shkolnik_peremena:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function shkolnik_peremena:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function shkolnik_peremena:Precache( context )
    PrecacheResource( "soundfile", "soundevents/peremena.vsndevts", context )
    PrecacheResource( "model", "models/heroes/ursa/ursa.vmdl", context )
end

function shkolnik_peremena:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local level = self:GetLevel()
    local count = self:GetSpecialValueFor("schoolboys_number")
    if self:GetCaster():HasTalent("special_bonus_unique_shkolnik_7") then level = 6 end
    caster:EmitSound("peremena")
    for i = 1, count do
        self.schoolboy = CreateUnitByName("npc_schoolboy_"..level, caster:GetAbsOrigin() + RandomVector(300), true, caster, nil, caster:GetTeamNumber())
        self.schoolboy:SetOwner(caster)
        self.schoolboy:SetControllableByPlayer(caster:GetPlayerID(), true)
        FindClearSpaceForUnit(self.schoolboy, self.schoolboy:GetAbsOrigin(), true)
        self.schoolboy:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("schoolboys_duration")})
        if caster:HasTalent("special_bonus_unique_shkolnik_3") then
            self.schoolboy:AddNewModifier(caster, self, "modifier_phased", {})
        end
    end
end