LinkLuaModifier("modifier_evil_monke", "units/griffins/evil_monke.lua", LUA_MODIFIER_MOTION_NONE)

evil_monke = class({})

function evil_monke:GetIntrinsicModifierName()
    return "modifier_evil_monke"
end

modifier_evil_monke = class({})

function modifier_evil_monke:IsHidden() return true end
function modifier_evil_monke:IsPurgable() return false end

function modifier_evil_monke:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_evil_monke:OnDeath(params)
    if not IsServer() then return end

    if params.unit ~= self:GetParent() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local position = parent:GetAbsOrigin()

    local monke = CreateUnitByName("npc_evil_monke", position, true, nil, nil, parent:GetTeamNumber())
    monke:SetOwner(parent)
    monke:SetControllableByPlayer(parent:GetPlayerOwnerID(), true)

    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_jump_launch_ring.vpcf", PATTACH_ABSORIGIN, monke)
    ParticleManager:SetParticleControl(fx, 0, monke:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(fx)

    monke:AddNewModifier(parent, nil, "modifier_kill", {duration = 45})
end
