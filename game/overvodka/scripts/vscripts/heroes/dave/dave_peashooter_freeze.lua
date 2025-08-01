LinkLuaModifier("modifier_peashooter_pure_attack", "heroes/dave/dave_peashooter", LUA_MODIFIER_MOTION_NONE)

dave_peashooter_freeze = class({})

function dave_peashooter_freeze:Precache(context)
    PrecacheResource( "soundfile", "soundevents/gribochki.vsndevts", context )
    PrecacheResource("model", "pvz/peashooter_freeze.vmdl", context )
end

function dave_peashooter_freeze:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_damage = self:GetSpecialValueFor("base_damage")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local peashooter = CreateUnitByName("npc_peashooter_freeze", point, true, caster, caster, caster:GetTeamNumber())
    peashooter:SetControllableByPlayer(caster:GetPlayerID(), false)
    peashooter:SetOwner(caster)
    peashooter:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    peashooter:AddNewModifier(caster, self, "modifier_phased", {duration = duration})
    peashooter:SetMaxHealth(base_hp)
    peashooter:SetHealth(base_hp)
    peashooter:SetBaseDamageMin(base_damage)
    peashooter:SetBaseDamageMax(base_damage)
    peashooter:SetMaximumGoldBounty(gold)
    peashooter:SetMinimumGoldBounty(gold)
    peashooter:SetDeathXP(xp)
    if self:GetSpecialValueFor("pure_damage") > 0 then
        peashooter:AddNewModifier(caster, self, "modifier_peashooter_pure_attack", {})
    end
    EmitSoundOn("gribochki", peashooter)
end
