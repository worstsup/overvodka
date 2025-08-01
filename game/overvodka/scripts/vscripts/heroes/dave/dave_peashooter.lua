LinkLuaModifier("modifier_peashooter_pure_attack", "heroes/dave/dave_peashooter", LUA_MODIFIER_MOTION_NONE)

dave_peashooter = class({})

function dave_peashooter:Precache(context)
    PrecacheResource("soundfile", "soundevents/gribochki.vsndevts", context )
    PrecacheResource("model", "pvz/peashooter.vmdl", context )
end

function dave_peashooter:GetAbilityDamageType()
    if self:GetSpecialValueFor("pure_damage") > 0 then
        return DAMAGE_TYPE_PURE
    end
    return DAMAGE_TYPE_PHYSICAL
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
    if self:GetSpecialValueFor("pure_damage") > 0 then
        peashooter:AddNewModifier(caster, self, "modifier_peashooter_pure_attack", {})
    end
    EmitSoundOn("gribochki", peashooter)
end

modifier_peashooter_pure_attack = class({})

function modifier_peashooter_pure_attack:IsHidden()    return true end
function modifier_peashooter_pure_attack:IsPurgable()  return false end

function modifier_peashooter_pure_attack:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_peashooter_pure_attack:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    self:GetParent():SetBaseDamageMin(0)
    self:GetParent():SetBaseDamageMax(0)
    local target = params.target
    local damage = self:GetAbility():GetSpecialValueFor("base_damage")
    ApplyDamage({
        victim      = target,
        attacker    = params.attacker,
        damage      = damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability     = self:GetAbility(),
    })
end