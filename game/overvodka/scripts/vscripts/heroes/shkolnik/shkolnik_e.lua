shkolnik_e = class({})

function shkolnik_e:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_start.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_end.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/zveni.vsndevts", context )
end

function shkolnik_e:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local max_range = self:GetSpecialValueFor("blink_range")
	local direction = (point - origin)
	ProjectileManager:ProjectileDodge(caster)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end
	FindClearSpaceForUnit( caster, origin + direction, true )
	self:PlayEffects( origin, direction )
	caster:AddNewModifier( caster, self, "modifier_black_king_bar_immune", { duration = self:GetSpecialValueFor("immun") } )
end

function shkolnik_e:PlayEffects( origin, direction )
	local particle_cast_a = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_start.vpcf"
	local particle_cast_b = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_end.vpcf"
	local sound_cast_b = "zveni"
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast_a, 1, origin + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_b, self:GetCaster() )
end