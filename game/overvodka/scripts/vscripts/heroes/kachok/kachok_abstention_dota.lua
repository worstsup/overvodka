LinkLuaModifier("modifier_kachok_abstention_dota", "heroes/kachok/kachok_abstention_dota", LUA_MODIFIER_MOTION_NONE)

kachok_abstention_dota = class({})

function kachok_abstention_dota:GetIntrinsicModifierName()
  return "modifier_kachok_abstention_dota"
end

modifier_kachok_abstention_dota = class({})

function modifier_kachok_abstention_dota:IsHidden()    return false  end
function modifier_kachok_abstention_dota:IsPurgable()  return false end
function modifier_kachok_abstention_dota:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_kachok_abstention_dota:OnCreated()
  if not IsServer() then return end
  self.caster     = self:GetCaster()
  self.ability    = self:GetAbility()
  self.stackCount = 0
  self.modelScale = self.caster:GetModelScale()
end

function modifier_kachok_abstention_dota:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH,
  }
end

function modifier_kachok_abstention_dota:OnDeath(params)
  if not IsServer() then return end

  local victim   = params.unit
  local attacker = params.attacker
  if attacker ~= self.caster then return end
  if victim:GetTeamNumber() == self.caster:GetTeamNumber() then return end
  if self.caster:IsIllusion() or  self.caster:PassivesDisabled() or not self.caster:IsAlive() then return end
  if not self.ability:IsCooldownReady() then return end
  local bonusAttr = self.ability:GetSpecialValueFor("bonus_attribute")
  local mult = victim:IsRealHero() and 3 or 1
  local totalBonus = bonusAttr * mult
  self.caster:ModifyStrength(totalBonus)
  if self.caster:HasScepter() then
    self.caster:ModifyAgility(totalBonus)
    self.caster:ModifyIntellect(totalBonus)
  end
  self.modelScale = self.modelScale + 0.01 * mult
  if not self.caster:HasModifier("modifier_kachok_trenbolone") then
    self.caster:SetModelScale(self.modelScale)
  end
  self.stackCount = self.stackCount + mult
  self:SetStackCount(self.stackCount)
  self.ability:UseResources(false, false, false, true)
end
