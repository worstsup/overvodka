shkolnik_e = class({})

function shkolnik_e:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_v2_start.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_v2_end.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/zveni.vsndevts", context )
end

function shkolnik_e:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	EmitSoundOnLocationWithCaster( origin, "zveni", self:GetCaster() )
	local max_range = self:GetSpecialValueFor("blink_range")
	local direction = (point - origin)
	ProjectileManager:ProjectileDodge(caster)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end
	FindClearSpaceForUnit( caster, origin + direction, true )
	local ab = caster:FindAbilityByName("shkolnik_peremena")
	if ab and ab:GetLevel() > 0 then
		self:SpawnSchoolboys(caster, origin, ab)
		local duration = self:GetSpecialValueFor("immun")
		if duration > 0 then
			caster:AddNewModifier( caster, self, "modifier_black_king_bar_immune", { duration = duration } )
			self:SpawnSchoolboys(caster, origin, ab)
		end
	end
	self:PlayEffects( origin, direction )
end

function shkolnik_e:SpawnSchoolboys(caster, origin, ab)
	local level = ab:GetLevel()
	if self:GetCaster():HasTalent("special_bonus_unique_shkolnik_7") then level = 6 end
	local schoolboy = CreateUnitByName("npc_schoolboy_"..level, origin, true, caster, nil, caster:GetTeamNumber())
	local schoolboy2 = CreateUnitByName("npc_schoolboy_"..level, caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())

	schoolboy:SetOwner(caster)
	schoolboy:SetControllableByPlayer(caster:GetPlayerID(), true)
	FindClearSpaceForUnit(schoolboy, schoolboy:GetAbsOrigin(), true)
	schoolboy:AddNewModifier(self:GetCaster(), ab, "modifier_kill", {duration = ab:GetSpecialValueFor("schoolboys_duration")})
	schoolboy:AddNewModifier(self:GetCaster(), ab, "modifier_overvodka_creep", {})
	if caster:HasTalent("special_bonus_unique_shkolnik_3") then
		schoolboy:AddNewModifier(caster, ab, "modifier_phased", {})
	end

	schoolboy2:SetOwner(caster)
	schoolboy2:SetControllableByPlayer(caster:GetPlayerID(), true)
	FindClearSpaceForUnit(schoolboy2, schoolboy2:GetAbsOrigin(), true)
	schoolboy2:AddNewModifier(self:GetCaster(), ab, "modifier_kill", {duration = ab:GetSpecialValueFor("schoolboys_duration")})
	schoolboy2:AddNewModifier(self:GetCaster(), ab, "modifier_overvodka_creep", {})
	if caster:HasTalent("special_bonus_unique_shkolnik_3") then
		schoolboy2:AddNewModifier(caster, ab, "modifier_phased", {})
	end
end

function shkolnik_e:PlayEffects( origin, direction )
	local particle_cast_a = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_v2_start.vpcf"
	local particle_cast_b = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_v2_end.vpcf"
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast_a, 1, origin + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
end