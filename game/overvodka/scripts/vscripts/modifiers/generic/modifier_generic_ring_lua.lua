--[[
    Usage parameters
        kv.start_radius (0)
        kv.end_radius (0)
        kv.width (100)
        kv.speed (0)

        kv.target_team
        kv.target_type
        kv.target_flags

        kv.IsCircle (1)
            0: expanding radius (filled circle)
            1: expanding donut with width (hollow inside)

    Callback set after creating modifier:
        modifier:SetCallback( function( unit, wave_radius ) ... end ) -- wave_radius OPTIONAL arg
        modifier:SetEndCallback( function() ... end )
]]

modifier_generic_ring_lua = class({})

function modifier_generic_ring_lua:IsHidden() return true end
function modifier_generic_ring_lua:IsDebuff() return false end
function modifier_generic_ring_lua:IsStunDebuff() return false end
function modifier_generic_ring_lua:IsPurgable() return false end
function modifier_generic_ring_lua:RemoveOnDeath() return false end
function modifier_generic_ring_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_generic_ring_lua:OnCreated(kv)
    if not IsServer() then return end

    self.start_radius = tonumber(kv.start_radius) or 0
    self.end_radius   = tonumber(kv.end_radius)   or 0
    self.width        = tonumber(kv.width)        or 100
    self.speed        = tonumber(kv.speed)        or 0

    self.outward = self.end_radius >= self.start_radius
    if not self.outward then
        self.speed = -self.speed
    end

    self.target_team  = tonumber(kv.target_team)  or 0
    self.target_type  = tonumber(kv.target_type)  or 0
    self.target_flags = tonumber(kv.target_flags) or 0

    local isCircleKV = tonumber(kv.IsCircle)
    if isCircleKV == nil then isCircleKV = 1 end
    self.is_donut = (isCircleKV == 1) -- 1 = donut, 0 = filled circle

    self.targets = {}
end

function modifier_generic_ring_lua:OnDestroy()
    if self.EndCallback then
        self.EndCallback()
    end
    if not IsServer() then return end

    if self:GetParent():GetClassname() == "npc_dota_thinker" then
        UTIL_Remove(self:GetParent())
    end
end

function modifier_generic_ring_lua:SetCallback(callback)
    self.Callback = callback
    self:StartIntervalThink(0.03)
    self:OnIntervalThink()
end

function modifier_generic_ring_lua:SetEndCallback(callback)
    self.EndCallback = callback
end

function modifier_generic_ring_lua:OnIntervalThink()
    if not IsServer() then return end
    if not self.Callback then return end

    local radius = self.start_radius + self.speed * self:GetElapsedTime()

    if (not self.outward and radius < self.end_radius) or (self.outward and radius > self.end_radius) then
        self:Destroy()
        return
    end

    local origin = self:GetParent():GetAbsOrigin()

    local targets = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        origin,
        nil,
        radius,
        self.target_team,
        self.target_type,
        self.target_flags,
        0,
        false
    )

    for _, target in pairs(targets) do
        if target and not target:IsNull() and not self.targets[target] then

            local ok = true
            if self.is_donut then
                local dist = (target:GetAbsOrigin() - origin):Length2D()
                ok = dist > (radius - self.width)
            end

            if ok then
                self.targets[target] = true
                -- safe: extra arg ignored if callback has only 1 param
                self.Callback(target, radius)
            end
        end
    end
end