LinkLuaModifier("modifier_royale_w_melee", "heroes/royale/royale_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_w_ranged", "heroes/royale/royale_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_overvodka_creep", "modifiers/modifier_overvodka_creep", LUA_MODIFIER_MOTION_NONE)

royale_w = class({})

function royale_w:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("model", "models/royale/goblins/melee/g_sword.vmdl", context)
    PrecacheResource("model", "models/royale/goblins/ranged/spear.vmdl", context)
    PrecacheResource("model", "models/royale/goblins/ranged/bochka.vmdl", context)
    PrecacheUnitByNameSync("npc_goblin_melee", context)
    PrecacheUnitByNameSync("npc_goblin_ranged", context)
end

function royale_w:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_w:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local spawnPoint = self:GetCursorPosition()

    local duration   = self:GetSpecialValueFor("duration")
    local melee_dmg  = self:GetSpecialValueFor("melee_dmg")
    local melee_hp   = self:GetSpecialValueFor("melee_hp")
    local ranged_dmg = self:GetSpecialValueFor("ranged_dmg")
    local ranged_hp  = self:GetSpecialValueFor("ranged_hp")
    local gold       = self:GetSpecialValueFor("gold")
    local xp         = self:GetSpecialValueFor("xp")
    local spacing    = 150
    local forwardDist = 150

    local dir = (spawnPoint - caster:GetAbsOrigin()):Normalized()
    local perp = Vector(-dir.y, dir.x, 0)

    local sideOffset = spacing * 0.5
    for i = 1, 3 do
        local lateral = (i - 2) * spacing
        local isSide = (i ~= 2)

        local zOffsetM = isSide and (-sideOffset) or 0
        local posF = spawnPoint + dir * forwardDist + perp * lateral + dir * zOffsetM
        local melee = CreateUnitByName("npc_goblin_melee", posF, true, caster, caster, caster:GetTeamNumber())
        melee:SetOwner(caster)
        melee:SetControllableByPlayer(caster:GetPlayerID(), true)
        melee:SetForwardVector(dir)
        melee:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
        melee:AddNewModifier(caster, self, "modifier_royale_w_melee", {})
        melee:AddNewModifier(caster, self, "modifier_overvodka_creep", {})
        melee:SetBaseMaxHealth(melee_hp)
        melee:SetMaxHealth(melee_hp)
        melee:SetHealth(melee_hp)
        melee:SetBaseDamageMin(melee_dmg)
        melee:SetBaseDamageMax(melee_dmg)
        melee:SetMinimumGoldBounty(gold)
        melee:SetMaximumGoldBounty(gold)
        melee:SetDeathXP(xp)
        local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/royale/goblins/melee/g_sword.vmdl"})
        weapon:FollowEntityMerge(melee, "attach_attack1")

        local zOffsetR = isSide and sideOffset or 0
        local posB = spawnPoint - dir * forwardDist + perp * lateral + dir * zOffsetR
        local ranged = CreateUnitByName("npc_goblin_ranged", posB, true, caster, caster, caster:GetTeamNumber())
        ranged:SetOwner(caster)
        ranged:SetControllableByPlayer(caster:GetPlayerID(), true)
        ranged:SetForwardVector(dir)
        ranged:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
        ranged:AddNewModifier(caster, self, "modifier_royale_w_ranged", {})
        ranged:AddNewModifier(caster, self, "modifier_overvodka_creep", {})
        ranged:SetBaseMaxHealth(ranged_hp)
        ranged:SetMaxHealth(ranged_hp)
        ranged:SetHealth(ranged_hp)
        ranged:SetBaseDamageMin(ranged_dmg)
        ranged:SetBaseDamageMax(ranged_dmg)
        ranged:SetMinimumGoldBounty(gold)
        ranged:SetMaximumGoldBounty(gold)
        ranged:SetDeathXP(xp)
        local bochka = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/royale/goblins/ranged/bochka.vmdl"})
        bochka:FollowEntityMerge(ranged, "attach_bochka")
        local spear = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/royale/goblins/ranged/spear.vmdl"})
        spear:FollowEntityMerge(ranged, "attach_attack1")
    end

    EmitSoundOnLocationWithCaster(spawnPoint, "GoblinGang.Deploy", caster)
end

modifier_royale_w_melee = class({})
function modifier_royale_w_melee:IsHidden() return true end
function modifier_royale_w_melee:IsPurgable() return false end

function modifier_royale_w_melee:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK }
end

function modifier_royale_w_melee:OnAttack(params)
    if params.attacker == self:GetParent() then
        EmitSoundOn("GoblinGang.Melee.Attack", params.attacker)
    end
end

modifier_royale_w_ranged = class({})
function modifier_royale_w_ranged:IsHidden() return true end
function modifier_royale_w_ranged:IsPurgable() return false end

function modifier_royale_w_ranged:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK }
end

function modifier_royale_w_ranged:OnAttack(params)
    if params.attacker == self:GetParent() then
        EmitSoundOn("GoblinGang.Ranged.Attack", params.attacker)
    end
end