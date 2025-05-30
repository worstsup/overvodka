LinkLuaModifier( "modifier_kolyan_innate", "heroes/kolyan/kolyan_innate", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kolyan_innate_buff", "heroes/kolyan/kolyan_innate", LUA_MODIFIER_MOTION_NONE )

kolyan_innate = class({})

function kolyan_innate:Precache(context)
    PrecacheResource("particle", "particles/kolyan_innate.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_spirit_bear_fetch_loop_blue.vpcf", context)
    PrecacheResource("soundfile", "soundevents/kolyan_innate.vsndevts", context )
end

function kolyan_innate:GetIntrinsicModifierName()
    return "modifier_kolyan_innate"
end

modifier_kolyan_innate = class({})

function modifier_kolyan_innate:IsHidden() return true end
function modifier_kolyan_innate:IsPurgable() return false end

function modifier_kolyan_innate:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED,
    }
    return funcs
end

function modifier_kolyan_innate:OnHeroKilled(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.target:GetTeamNumber() == parent:GetTeamNumber() then return end
    if params.attacker ~= parent then return end
    if not params.target or not params.target:IsRealHero() or params.target:IsIllusion() then return end
    local ability = self:GetAbility()
    local existingBuff = parent:FindModifierByName("modifier_kolyan_innate_buff")
    if existingBuff then
        local newDuration = existingBuff:GetRemainingTime() + ability:GetSpecialValueFor("duration")
        existingBuff:SetDuration(newDuration, true)
    else
        parent:AddNewModifier(parent, ability, "modifier_kolyan_innate_buff", { duration = ability:GetSpecialValueFor("duration") })
    end
    self.effect_cast = ParticleManager:CreateParticle( "particles/kolyan_innate.vpcf", PATTACH_WORLDORIGIN, parent )
    ParticleManager:SetParticleControl( self.effect_cast, 0, parent:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
    EmitSoundOn("kolyan_innate", parent)
end

modifier_kolyan_innate_buff = class({})

function modifier_kolyan_innate_buff:IsHidden() return false end
function modifier_kolyan_innate_buff:IsPurgable() return true end

function modifier_kolyan_innate_buff:OnCreated()
    local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spirit_bear_fetch_loop_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt( effect, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    self:AddParticle(effect, false, false, -1, false, false)
end

function modifier_kolyan_innate_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_kolyan_innate_buff:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_kolyan_innate_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end

function modifier_kolyan_innate_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end