LinkLuaModifier( "modifier_serega_blink", "heroes/pirat/modifier_serega_blink", LUA_MODIFIER_MOTION_NONE )

serega_blink = class({})

function serega_blink:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", context )
	PrecacheResource( "particle", "particles/antimage_manavoid_basher_cast_gold_new.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/serega_blink.vsndevts", context )
end

function serega_blink:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local max_range = self:GetSpecialValueFor("blink_range")
	local direction = (point - origin)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end
	FindClearSpaceForUnit( caster, origin + direction, true )
	self:PlayEffects( origin, direction )
	caster:AddNewModifier( caster, self, "modifier_serega_blink", { duration = 4 } )
end

function serega_blink:PlayEffects( origin, direction )
	local particle_cast_a = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf"
	local particle_cast_b = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf"
	local sound_cast_b = "serega_blink"
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_b, self:GetCaster() )
end