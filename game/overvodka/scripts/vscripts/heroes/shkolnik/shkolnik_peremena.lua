LinkLuaModifier("modifier_overvodka_creep", "modifiers/modifier_overvodka_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drake_q_facet", "heroes/shkolnik/shkolnik_peremena", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drake_q_facet_debuff", "heroes/shkolnik/shkolnik_peremena", LUA_MODIFIER_MOTION_NONE)

shkolnik_peremena = class({})

function shkolnik_peremena:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function shkolnik_peremena:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function shkolnik_peremena:Precache( context )
    PrecacheResource( "soundfile", "soundevents/peremena.vsndevts", context )
    PrecacheResource( "model", "models/drake/shkolnik/shkolnik.vmdl", context )
    PrecacheResource( "particle", "particles/drake_q_spawn.vpcf", context )
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
        local p = ParticleManager:CreateParticle("particles/drake_q_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.schoolboy)
        ParticleManager:SetParticleControl(p, 0, self.schoolboy:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
        self.schoolboy:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("schoolboys_duration")})
        self.schoolboy:AddNewModifier(self:GetCaster(), self, "modifier_overvodka_creep", {})
        if self:GetSpecialValueFor("armor_decrease_duration") > 0 then
            self.schoolboy:AddNewModifier(self:GetCaster(), self, "modifier_drake_q_facet", {})
        end
        if caster:HasTalent("special_bonus_unique_shkolnik_3") then
            self.schoolboy:AddNewModifier(caster, self, "modifier_phased", {})
        end
    end
end

modifier_drake_q_facet = class({})

function modifier_drake_q_facet:IsHidden() return true end
function modifier_drake_q_facet:IsPurgable() return false end

function modifier_drake_q_facet:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_drake_q_facet:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    local target = params.target
    if target:IsBuilding() then return end
    local duration = self:GetAbility():GetSpecialValueFor("armor_decrease_duration") * (1 - target:GetStatusResistance())
    if target:HasModifier("modifier_drake_q_facet_debuff") then
        local debuff = target:FindModifierByName("modifier_drake_q_facet_debuff")
        if debuff then
            debuff:ForceRefresh()
            debuff:SetDuration(duration, true)
        end
    else
        target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_drake_q_facet_debuff", {duration = duration})
    end
end

modifier_drake_q_facet_debuff = class({})

function modifier_drake_q_facet_debuff:IsHidden() return false end
function modifier_drake_q_facet_debuff:IsPurgable() return true end
function modifier_drake_q_facet_debuff:IsDebuff() return true end

function modifier_drake_q_facet_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_drake_q_facet_debuff:OnRefresh()
    if not IsServer() then return end
    if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("armor_decrease_max") * 2 then
        self:IncrementStackCount()
    end
end

function modifier_drake_q_facet_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_drake_q_facet_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount() / 2
end