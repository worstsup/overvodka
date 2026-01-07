LinkLuaModifier("modifier_pistol_innate", "heroes/pistol/pistol_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_innate_shield", "heroes/pistol/pistol_innate", LUA_MODIFIER_MOTION_NONE)

pistol_innate = class({})

function pistol_innate:GetIntrinsicModifierName()
    return "modifier_pistol_innate"
end

local function GetMainHero(unit)
    if not unit or unit:IsNull() then return nil end

    local pid = unit:GetPlayerOwnerID()
    if pid ~= nil and pid ~= -1 then
        local hero = PlayerResource:GetSelectedHeroEntity(pid)
        if hero and not hero:IsNull() then
            return hero
        end
    end

    return nil
end

local function GetControllingEnemyHero(attacker)
    if not attacker or attacker:IsNull() then return nil end

    if attacker:IsRealHero() then
        return attacker
    end

    return GetMainHero(attacker)
end

modifier_pistol_innate = class({})

function modifier_pistol_innate:IsHidden() return self:GetStackCount() == 0 end
function modifier_pistol_innate:IsPurgable() return false end
function modifier_pistol_innate:RemoveOnDeath() return false end

function modifier_pistol_innate:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self.damage_per_charge = self.ability:GetSpecialValueFor("damage_per_charge")
    self.armor_per_charge  = self.ability:GetSpecialValueFor("armor_per_charge")
    self.regen_per_charge  = self.ability:GetSpecialValueFor("regen_per_charge")

    if not IsServer() then return end

    self._damage_accum = self._damage_accum or 0

    if self.parent:IsIllusion() then
        self:StartIntervalThink(0.5)
        self:SyncFromOwner()
    end
end

function modifier_pistol_innate:OnRefresh()
    self:OnCreated()
end

function modifier_pistol_innate:OnIntervalThink()
    if not IsServer() then return end
    self:SyncFromOwner()
end

function modifier_pistol_innate:SyncFromOwner()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsIllusion() then return end

    local hero = GetMainHero(self.parent)
    if not hero or hero:IsNull() then return end

    local mod = hero:FindModifierByName("modifier_pistol_innate")
    if mod and not mod:IsNull() then
        self:SetStackCount(mod:GetStackCount())
    else
        self:SetStackCount(0)
    end
end

function modifier_pistol_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_pistol_innate:GetModifierPhysicalArmorBonus()
    if self:GetParent():PassivesDisabled() then return 0 end
    return (self:GetStackCount() or 0) * (self.armor_per_charge or 0)
end

function modifier_pistol_innate:GetModifierConstantHealthRegen()
    if self:GetParent():PassivesDisabled() then return 0 end
    return (self:GetStackCount() or 0) * (self.regen_per_charge or 0)
end

function modifier_pistol_innate:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self.parent
    if not parent or parent:IsNull() then return end
    if parent:PassivesDisabled() then return end
    if parent:IsIllusion() then return end
    if params.unit ~= parent then return end
    local attacker = params.attacker
    if not attacker or attacker:IsNull() then return end
    if attacker.IsBuilding and attacker:IsBuilding() then return end
    if attacker:GetTeamNumber() == DOTA_TEAM_NEUTRALS then return end

    local flags = params.damage_flags or 0
    if bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
    if bit.band(flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end

    local controlling_hero = GetControllingEnemyHero(attacker)
    if not controlling_hero or controlling_hero:IsNull() then return end

    if controlling_hero:GetTeamNumber() == parent:GetTeamNumber() then return end

    local dmg = params.damage or 0
    if dmg <= 0 then return end

    self._damage_accum = (self._damage_accum or 0) + dmg

    local step = math.max(1, self.damage_per_charge or 1000)

    if self._damage_accum >= step then
        local add = math.floor(self._damage_accum / step)
        self._damage_accum = self._damage_accum - add * step
        self:SetStackCount((self:GetStackCount() or 0) + add)
        parent:EmitSound("pistol_innate")
        local duration = self:GetAbility():GetSpecialValueFor("shield_duration")
        if duration > 0 then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_pistol_innate_shield", {duration = duration})
        end
    end
end


modifier_pistol_innate_shield = class({})

function modifier_pistol_innate_shield:IsHidden() return false end
function modifier_pistol_innate_shield:IsPurgable() return true end

function modifier_pistol_innate_shield:OnCreated()
    if not IsServer() then return end
    self.p = ParticleManager:CreateParticle("particles/pistol_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_pistol_innate_shield:OnDestroy()
    if self.p then
        ParticleManager:DestroyParticle(self.p, false)
        ParticleManager:ReleaseParticleIndex(self.p)
    end
end

function modifier_pistol_innate_shield:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_pistol_innate_shield:GetModifierIncomingDamage_Percentage()
	return -self:GetAbility():GetSpecialValueFor("shield_pct")
end