LinkLuaModifier("modifier_nightfall_innate_teleport", "heroes/nightfall/nightfall_innate", LUA_MODIFIER_MOTION_NONE)

nightfall_innate = class({})

function nightfall_innate:Precache(context)
    PrecacheResource("particle", "particles/items_fx/black_king_bar_avatar.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/teleport_start.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/teleport_end.vpcf", context)
end

function nightfall_innate:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end

function nightfall_innate:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local spawn_entity = FindSpawnEntityForTeam(caster:GetTeamNumber())
    if not spawn_entity then return end

    self.point_start = caster:GetAbsOrigin()
    self.point = GetGroundPosition(spawn_entity:GetAbsOrigin(), nil)
    self.teleport_center = CreateUnitByName("npc_dota_companion", self.point, false, nil, nil, caster:GetTeamNumber())
    if self.teleport_center then
        self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_phased", {})
        self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_invulnerable", {})
        self.teleport_center:SetAbsOrigin(self.point)
    end

    caster:StartGesture(ACT_DOTA_TELEPORT)
    AddFOWViewer(caster:GetTeamNumber(), self.point, 400, self:GetChannelTime() + 0.5, false)

    local modifier = caster:AddNewModifier(caster, self, "modifier_nightfall_innate_teleport", {
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

function nightfall_innate:OnChannelThink(_)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if caster:IsStunned() or caster:IsRooted() or caster:IsHexed() then
        caster:Stop()
        caster:Interrupt()
    end
end

function nightfall_innate:OnChannelFinish(bInterrupted)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local destination = self.point
    local point_start = self.point_start or caster:GetAbsOrigin()

    self:CleanupTeleport(caster)

    if bInterrupted then return end
    if not destination then return end

    EmitSoundOnLocationWithCaster(point_start, "Portal.Hero_Disappear", caster)
    caster:SetAbsOrigin(destination)
    FindClearSpaceForUnit(caster, destination, true)
    caster:Stop()
    caster:Interrupt()
    caster:EmitSound("Portal.Hero_Disappear")
    caster:StartGesture(ACT_DOTA_TELEPORT_END)
end

function nightfall_innate:CleanupTeleport(caster)
    if caster and not caster:IsNull() then
        caster:RemoveModifierByName("modifier_nightfall_innate_teleport")
        caster:RemoveGesture(ACT_DOTA_TELEPORT)
    end

    if self.teleport_center and not self.teleport_center:IsNull() then
        UTIL_Remove(self.teleport_center)
    end

    self.teleport_center = nil
    self.point = nil
    self.point_start = nil
end

modifier_nightfall_innate_teleport = class({})

function modifier_nightfall_innate_teleport:IsHidden() return false end
function modifier_nightfall_innate_teleport:IsPurgable() return false end
function modifier_nightfall_innate_teleport:GetTexture() return "item_black_king_bar" end

function modifier_nightfall_innate_teleport:OnCreated(kv)
    kv = kv or {}
    self.magic_resistance = self:GetAbility() and self:GetAbility():GetSpecialValueFor("magic_resistance") or 0

    if not IsServer() then return end

    self.parent = self:GetParent()
    self.center = kv.center and EntIndexToHScript(kv.center) or nil

    self.parent:EmitSound("DOTA_Item.BlackKingBar.Activate")
    self:StartTeleportLoopSound()
end

function modifier_nightfall_innate_teleport:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_nightfall_innate_teleport:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_nightfall_innate_teleport:GetModifierMagicalResistanceBonus()
    return self.magic_resistance
end

function modifier_nightfall_innate_teleport:GetOverrideAnimation()
    return ACT_DOTA_TELEPORT
end

function modifier_nightfall_innate_teleport:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
end

function modifier_nightfall_innate_teleport:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_nightfall_innate_teleport:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_nightfall_innate_teleport:StartTeleportLoopSound()
    if not IsServer() then return end

    self.parent:EmitSound("Portal.Loop_Appear")
    if self.center and not self.center:IsNull() then
        self.center:EmitSound("Portal.Loop_Appear")
    end
end

function modifier_nightfall_innate_teleport:OnDestroy()
    if not IsServer() then return end

    local parent = self.parent or self:GetParent()
    if parent and not parent:IsNull() then
        parent:StopSound("Portal.Loop_Appear")
    end

    if self.center and not self.center:IsNull() then
        self.center:StopSound("Portal.Loop_Appear")
    end
end
