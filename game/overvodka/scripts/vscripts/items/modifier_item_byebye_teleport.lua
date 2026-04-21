modifier_item_byebye_teleport = class({})

function modifier_item_byebye_teleport:IsHidden() return true end
function modifier_item_byebye_teleport:IsPurgable() return false end

function modifier_item_byebye_teleport:OnCreated(kv)
    if not IsServer() then return end

    kv = kv or {}
    self.parent = self:GetParent()
    self.center = kv.center and EntIndexToHScript(kv.center) or nil

    self.parent:EmitSound("Portal.Loop_Appear")
    if self.center and not self.center:IsNull() then
        self.center:EmitSound("Portal.Loop_Appear")
    end
end

function modifier_item_byebye_teleport:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_item_byebye_teleport:GetOverrideAnimation()
    return ACT_DOTA_TELEPORT
end

function modifier_item_byebye_teleport:OnDestroy()
    if not IsServer() then return end

    local parent = self.parent or self:GetParent()
    if parent and not parent:IsNull() then
        parent:StopSound("Portal.Loop_Appear")
    end

    if self.center and not self.center:IsNull() then
        self.center:StopSound("Portal.Loop_Appear")
    end
end
