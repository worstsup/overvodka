LinkLuaModifier("modifier_peterka_w_dota", "heroes/5opka/peterka_w_dota", LUA_MODIFIER_MOTION_NONE)

peterka_w_dota = class({})

function peterka_w_dota:GetIntrinsicModifierName()
    return "modifier_peterka_w_dota"
end

function peterka_w_dota:Precache(context)
    PrecacheResource("soundfile", "soundevents/peterka_w.vsndevts", context)
    PrecacheResource("particle", "particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", context)
end

modifier_peterka_w_dota = class({})

function modifier_peterka_w_dota:IsHidden()   return true end
function modifier_peterka_w_dota:IsPurgable() return false end

function modifier_peterka_w_dota:OnCreated()
    if not IsServer() then return end
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    self.radius  = self.ability:GetSpecialValueFor("radius")
end

function modifier_peterka_w_dota:OnRefresh()
    if not IsServer() then return end
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_peterka_w_dota:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_peterka_w_dota:OnDeath(params)
    if not IsServer() then return end
    local victim = params.unit
    local attacker = params.attacker
    if victim:IsRealHero() then return end
    if victim:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end
    if not attacker:IsRealHero() then return end
    if attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if (victim:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() > self.radius then
        return
    end
    if not self.parent:IsAlive() or self.parent:PassivesDisabled() then return end
    if self.ability:GetCooldownTimeRemaining() > 0 then return end
    local bounty = victim:GetGoldBounty() * self:GetAbility():GetSpecialValueFor("gold_mult")
    self.parent:ModifyGold(bounty, true, DOTA_ModifyGold_Unspecified)
    SendOverheadEventMessage(self.parent, OVERHEAD_ALERT_GOLD, self.parent, bounty, nil)
    local damage_pct = self.ability:GetSpecialValueFor("damage")
    local damage_amount = bounty * damage_pct * 0.01
    ApplyDamage({
        victim = attacker,
        attacker = self.parent,
        damage = damage_amount,
        damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability,
    })
    ParticleManager:CreateParticle("particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
    local heal_pct = self.ability:GetSpecialValueFor("heal")
    local heal_amount = bounty * heal_pct * 0.01
    self.parent:Heal(heal_amount, self.ability)
    self.ability:UseResources(false, false, false, true)
    EmitSoundOn("peterka_w", self.parent)
end
