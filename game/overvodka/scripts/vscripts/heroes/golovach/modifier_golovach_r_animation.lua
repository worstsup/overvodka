modifier_golovach_r_animation = class({})

function modifier_golovach_r_animation:IsHidden()
	return true
end

function modifier_golovach_r_animation:IsDebuff()
	return false
end

function modifier_golovach_r_animation:IsPurgable()
	return false
end

function modifier_golovach_r_animation:OnCreated( kv )
end
function modifier_golovach_r_animation:OnDestroy( kv )
end

function modifier_golovach_r_animation:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
	return funcs
end

function modifier_golovach_r_animation:GetActivityTranslationModifiers()
	return "unleash"
end