LinkLuaModifier("modifier_kolibri_innate", "heroes/kolibri/kolibri_innate", LUA_MODIFIER_MOTION_NONE)

kolibri_innate = class({})

function kolibri_innate:GetIntrinsicModifierName()
	return "modifier_kolibri_innate"
end

modifier_kolibri_innate = class({})

function modifier_kolibri_innate:IsHidden() return true end
function modifier_kolibri_innate:IsPurgable() return false end

function modifier_kolibri_innate:OnCreated()
end
function modifier_kolibri_innate:OnRefresh()
end

function modifier_kolibri_innate:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
    }
end