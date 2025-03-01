LinkLuaModifier("modifier_evelone_nose", "heroes/evelone/evelone_nose.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_evelone_nose_vision", "heroes/evelone/evelone_nose.lua", LUA_MODIFIER_MOTION_NONE)

evelone_nose = class({})

function evelone_nose:GetIntrinsicModifierName()
    return "modifier_evelone_nose"
end

function evelone_nose:Precache(context)
    PrecacheResource("particle", "particles/evelone_nose.vpcf", context)
    PrecacheResource("particle", "particles/evelone_nose_2.vpcf", context)
end

modifier_evelone_nose = class({})

function modifier_evelone_nose:IsHidden() return true end
function modifier_evelone_nose:IsPurgable() return false end

function modifier_evelone_nose:OnCreated()
    if IsServer() then
        if self:GetParent():IsIllusion() then
            self:Destroy()
            return
        end
        self.vision_radius = 100
        self:StartIntervalThink(FrameTime())
        self.already_created = 0
        self.was_ultimated = 0
    end
end

function modifier_evelone_nose:OnIntervalThink()
    local parent = self:GetParent()
    local parent_forward = parent:GetForwardVector()
    local origin = parent:GetAbsOrigin()
    if not parent:IsAlive() then return end
    self:UpdateVisionCone()
    self:ProcessEnemies()
    self.particle_cast = "particles/evelone_nose.vpcf"
    if parent:HasModifier("modifier_evelone_r") and self.already_created == 1 then
        ParticleManager:DestroyParticle(self.effect_cast, true)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)
        self.particle_cast = "particles/evelone_nose_2.vpcf"
        self.effect_cast = ParticleManager:CreateParticleForTeam(self.particle_cast, PATTACH_POINT_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
        self.already_created = 0
        self.was_ultimated = 1
    end
    if self.was_ultimated == 1 and not parent:HasModifier("modifier_evelone_r") then
        ParticleManager:DestroyParticle(self.effect_cast, true)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)
        self.already_created = 0
        self.was_ultimated = 0
    end
    if self.already_created == 0 and not parent:HasModifier("modifier_evelone_r") then
        self.effect_cast = ParticleManager:CreateParticleForTeam(self.particle_cast, PATTACH_POINT_FOLLOW, self:GetParent(), self:GetParent():GetTeamNumber())
        self.already_created = 1
    end
    ParticleManager:SetParticleControl(self.effect_cast, 0, origin + parent_forward * 450)
    ParticleManager:SetParticleControl(self.effect_cast, 2, origin + parent_forward * 1000)
end

function modifier_evelone_nose:UpdateVisionCone()
    local parent = self:GetParent()
    local origin = parent:GetAbsOrigin()
    local forward = parent:GetForwardVector()
    local radius = self:GetAbility():GetSpecialValueFor("cone_radius")
    local angle = math.rad(self:GetAbility():GetSpecialValueFor("cone_angle") * 0.5)
    local steps = 12
    local distance_step = radius / 4
    local angle_step = math.pi * 2 / steps
    for distance = distance_step, radius, distance_step do
        for i = -steps/2, steps/2 do
            local current_angle = angle_step * i
            if math.abs(current_angle) <= angle then
                local dir = RotateVector(forward, math.deg(current_angle))
                local pos = origin + dir * distance
                AddFOWViewer(parent:GetTeamNumber(), pos, self.vision_radius, 0.2, false)
                AddFOWViewer(parent:GetTeamNumber(), pos, self.vision_radius, 0.2, true)
            end
        end
    end
end

function modifier_evelone_nose:ProcessEnemies()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("cone_radius")
    local angle = ability:GetSpecialValueFor("cone_angle") * 0.5
    local origin = parent:GetAbsOrigin()
    local forward = parent:GetForwardVector()
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        origin,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        local to_target = (enemy:GetAbsOrigin() - origin):Normalized()
        local dot = forward:Dot(to_target)
        local angle_to_target = math.deg(math.acos(dot))
        
        if angle_to_target <= angle then
            enemy:AddNewModifier(parent, ability, "modifier_evelone_nose_vision", {duration = 0.5})
        else
            enemy:RemoveModifierByName("modifier_evelone_nose_vision")
        end
    end
end

function modifier_evelone_nose:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast, true)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)
    end
end

function RotateVector(v, degrees)
    local radians = math.rad(degrees)
    local cos = math.cos(radians)
    local sin = math.sin(radians)
    return Vector(
        v.x * cos - v.y * sin,
        v.x * sin + v.y * cos,
        v.z
    ):Normalized()
end

modifier_evelone_nose_vision = class({})

function modifier_evelone_nose_vision:IsHidden() return true end
function modifier_evelone_nose_vision:IsPurgable() return false end

function modifier_evelone_nose_vision:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = false
    }
end

function modifier_evelone_nose_vision:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end