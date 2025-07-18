dave_peashooter = class({})

function dave_peashooter:Precache(context)
    PrecacheResource("soundfile", "soundevents/gribochki.vsndevts", context )
    PrecacheResource("model", "pvz/peashooter.vmdl", context )
end

function dave_peashooter:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_dave_8" )
end

function dave_peashooter:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_damage = self:GetSpecialValueFor("base_damage")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local peashooter = CreateUnitByName("npc_peashooter_1", point, true, caster, caster, caster:GetTeamNumber())
    peashooter:SetControllableByPlayer(caster:GetPlayerID(), false)
    peashooter:SetOwner(caster)
    peashooter:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    peashooter:AddNewModifier(caster, self, "modifier_phased", {duration = duration})
    peashooter:SetBaseMaxHealth(base_hp)
    peashooter:SetMaxHealth(base_hp)
    peashooter:SetHealth(base_hp)
    peashooter:SetBaseDamageMin(base_damage)
    peashooter:SetBaseDamageMax(base_damage)
    peashooter:SetMaximumGoldBounty(gold)
    peashooter:SetMinimumGoldBounty(gold)
    peashooter:SetDeathXP(xp)
    EmitSoundOn("gribochki", peashooter)
end
