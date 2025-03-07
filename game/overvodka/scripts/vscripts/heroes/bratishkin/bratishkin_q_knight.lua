LinkLuaModifier("modifier_bratishkin_q_knight", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_knight_upgrade", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)

bratishkin_q_knight = class({})

function bratishkin_q_knight:Precache( context )
    PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", context )
    PrecacheResource( "model", "models/bratishkin/knight/base.vmdl", context )
	PrecacheResource( "model", "models/items/sven/weapon_ruling_sword.vmdl", context )
end

function bratishkin_q_knight:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function bratishkin_q_knight:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight_upgrade", {})
    local modifier_bratishkin_q_knight = self:GetCaster():FindModifierByName("modifier_bratishkin_q_knight")
    if modifier_bratishkin_q_knight then
        modifier_bratishkin_q_knight:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight", {})
    end
    self:GetCaster():EmitSound("gennadiy_start")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_bratishkin_q_knight = class({})
function modifier_bratishkin_q_knight:IsHidden() return false end
function modifier_bratishkin_q_knight:IsPurgable() return false end
function modifier_bratishkin_q_knight:IsPurgeException() return false end
function modifier_bratishkin_q_knight:RemoveOnDeath() return false end

function modifier_bratishkin_q_knight:OnCreated()
    if not IsServer() then return end
    self.abilities_list = 
    {
        {"bratishkin_q_knight", "bratishkin_q_base"}
    }
    self.model = self:GetParent():GetModelName()
    self:GetParent():SetModel("models/bratishkin/knight/base.vmdl")
    self:GetParent():SetOriginalModel("models/bratishkin/knight/base.vmdl")
    self:GetParent():SetModelScale(1.3)
    self:GetParent().weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sven/weapon_ruling_sword.vmdl"})
	self:GetParent().weapon:FollowEntityMerge(self:GetParent(), "attach_sword")
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[1], info[2], false, true)
    end
end

function modifier_bratishkin_q_knight:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_bratishkin_q_knight:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor_knight")
end

function modifier_bratishkin_q_knight:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("bat_knight")
end

function modifier_bratishkin_q_knight:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range_knight")
end

function modifier_bratishkin_q_knight:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_knight")
end

function modifier_bratishkin_q_knight:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModel(self.model)
    self:GetParent():SetOriginalModel(self.model)
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
    self:GetParent():SetModelScale(1)
    self:GetParent().weapon:RemoveSelf()
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[2], info[1], false, true)
    end
end

modifier_bratishkin_q_knight_upgrade = class({})
function modifier_bratishkin_q_knight_upgrade:IsHidden() return true end
function modifier_bratishkin_q_knight_upgrade:IsPurgable() return false end
function modifier_bratishkin_q_knight_upgrade:IsPurgeException() return false end
function modifier_bratishkin_q_knight_upgrade:RemoveOnDeath() return false end