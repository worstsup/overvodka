LinkLuaModifier("modifier_item_byebye_teleport", "items/modifier_item_byebye_teleport", LUA_MODIFIER_MOTION_NONE)

item_byebye = class({})

function item_byebye:Precache(context)
    PrecacheResource("particle", "particles/items2_fx/teleport_start.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/teleport_end.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", context)
end

function item_byebye:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if self:IsCasterBlocked(caster) then
        caster:Interrupt()
        return
    end

    local spawn_entity = FindSpawnEntityForTeam(caster:GetTeamNumber())
    if not spawn_entity then
        caster:Interrupt()
        return
    end

    self.point_start = caster:GetAbsOrigin()
    self.point = GetGroundPosition(spawn_entity:GetAbsOrigin(), nil)
    EmitSoundOn("byebye_start", caster)
    self:CreateLegacyBlinkParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
    self:StartTeleportVisuals(caster, self.point)
end

function item_byebye:OnChannelThink(_)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if caster:IsStunned() or caster:IsRooted() or caster:IsHexed() then
        caster:Stop()
        caster:Interrupt()
    end
end

function item_byebye:OnChannelFinish(bInterrupted)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local destination = self.point
    local point_start = self.point_start or caster:GetAbsOrigin()

    StopSoundOn("byebye_start", caster)
    self:CleanupTeleport(caster)

    if not bInterrupted and destination and not self:IsCasterBlocked(caster) then
        self:FinishTeleport(caster, destination, point_start)
    end

    self:SpendCharge(1)
end

function item_byebye:StartTeleportVisuals(caster, destination)
    self.teleport_center = CreateUnitByName("npc_dota_companion", destination, false, nil, nil, caster:GetTeamNumber())
    if self.teleport_center then
        self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_phased", {})
        self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_invulnerable", {})
        self.teleport_center:SetAbsOrigin(destination)
    end

    caster:StartGesture(ACT_DOTA_TELEPORT)
    AddFOWViewer(caster:GetTeamNumber(), destination, 400, self:GetChannelTime() + 0.5, false)

    local modifier = caster:AddNewModifier(caster, self, "modifier_item_byebye_teleport", {
        duration = self:GetChannelTime(),
        center = self.teleport_center and self.teleport_center:entindex() or nil,
    })

    if not modifier then
        self:CleanupTeleport(caster)
        return
    end

    local particle_start = ParticleManager:CreateParticle("particles/items2_fx/teleport_start.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_start, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_start, 2, Vector(255, 255, 255))
    modifier:AddParticle(particle_start, false, false, -1, false, false)

    if self.teleport_center then
        local particle_end = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.teleport_center)
        ParticleManager:SetParticleControlEnt(particle_end, 1, self.teleport_center, PATTACH_ABSORIGIN_FOLLOW, nil, self.teleport_center:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_end, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.teleport_center:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(particle_end, 4, Vector(0.9, 0, 0))
        ParticleManager:SetParticleControlEnt(particle_end, 5, self.teleport_center, PATTACH_ABSORIGIN_FOLLOW, nil, self.teleport_center:GetAbsOrigin(), true)
        modifier:AddParticle(particle_end, false, false, -1, false, false)
    end
end

function item_byebye:FinishTeleport(caster, destination, point_start)
    ProjectileManager:ProjectileDodge(caster)
    self:CreateLegacyBlinkParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
    EmitSoundOnLocationWithCaster(point_start, "Portal.Hero_Disappear", caster)
    caster:SetAbsOrigin(destination)
    FindClearSpaceForUnit(caster, destination, true)
    caster:Stop()
    caster:Interrupt()
    caster:EmitSound("Portal.Hero_Disappear")
    caster:EmitSound("byebye")
    caster:StartGesture(ACT_DOTA_TELEPORT_END)

    local arrival_particle = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(arrival_particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(arrival_particle)
    self:CreateLegacyBlinkParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
end

function item_byebye:CleanupTeleport(caster)
    if caster and not caster:IsNull() then
        caster:RemoveModifierByName("modifier_item_byebye_teleport")
        caster:RemoveGesture(ACT_DOTA_TELEPORT)
    end

    if self.teleport_center and not self.teleport_center:IsNull() then
        UTIL_Remove(self.teleport_center)
    end

    self.teleport_center = nil
    self.point = nil
    self.point_start = nil
end

function item_byebye:IsCasterBlocked(caster)
    return caster:HasModifier("modifier_zhenya_r_caster") or caster:HasModifier("modifier_silence_item")
end

function item_byebye:CreateLegacyBlinkParticle(particle_name, attach, owner)
    local particle = ParticleManager:CreateParticle(particle_name, attach, owner)
    ParticleManager:ReleaseParticleIndex(particle)
end

function item_byebye:GetAbilityTextureName()
    return "byebye"
end
