modifier_generic_motion = class({})

function modifier_generic_motion:IsHidden() return true end
function modifier_generic_motion:IsPurgable() return false end
function modifier_generic_motion:RemoveOnDeath() return true end
function modifier_generic_motion:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_generic_motion:OnCreated(params)
    if not IsServer() then return end

    self.start_pos = self:GetParent():GetAbsOrigin()
    self.end_pos = Vector(params.target_position_x, params.target_position_y, params.target_position_z)
    self.duration = params.duration or 0.5
    self.height = params.height or 200
    self.elapsed_time = 0
    self.direction = (self.end_pos - self.start_pos):Normalized()
    self.distance = (self.end_pos - self.start_pos):Length2D()
    if not self:ApplyHorizontalMotionController() or not self:ApplyVerticalMotionController() then
        self:Destroy()
    end
end

function modifier_generic_motion:OnDestroy()
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers(true)
end

function modifier_generic_motion:UpdateHorizontalMotion(parent, dt)
    if not IsServer() then return end
    self.elapsed_time = self.elapsed_time + dt
    local progress = math.min(self.elapsed_time / self.duration, 1)
    local current_pos = self.start_pos + self.direction * self.distance * progress
    parent:SetAbsOrigin(current_pos)
end

function modifier_generic_motion:UpdateVerticalMotion(parent, dt)
    if not IsServer() then return end
    local progress = math.min(self.elapsed_time / self.duration, 1)
    local height = self.height * 4 * progress * (1 - progress)
    local current_pos = parent:GetAbsOrigin()
    current_pos.z = self.start_pos.z + height
    parent:SetAbsOrigin(current_pos)
end

function modifier_generic_motion:OnHorizontalMotionInterrupted()
    if IsServer() then self:Destroy() end
end

function modifier_generic_motion:OnVerticalMotionInterrupted()
    if IsServer() then self:Destroy() end
end