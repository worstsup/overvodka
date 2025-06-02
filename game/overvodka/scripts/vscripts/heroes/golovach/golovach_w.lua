LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )

golovach_w = class({})

function golovach_w:Precache( context )
	PrecacheResource( "soundfile", "soundevents/golovach_w.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/queen_of_pain/qop_2022_immortal/queen_2022_scream_of_pain_owner_blue.vpcf", context )
end

function golovach_w:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	EmitSoundOn("golovach_w", caster)
	local fear_particle1 = ParticleManager:CreateParticle( "particles/econ/items/queen_of_pain/qop_2022_immortal/queen_2022_scream_of_pain_owner_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( fear_particle1, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fear_particle1, 1, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fear_particle1, 2, caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( fear_particle1 )
	local fear_particle2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( fear_particle2, 0, caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( fear_particle2 )
	local fear_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("fear_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(fear_enemies) do
		unit:AddNewModifier(caster, self, "modifier_dark_willow_debuff_fear", {duration = self:GetSpecialValueFor("fear_duration")})
		ApplyDamage({victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	end
	local invis_duration = self:GetSpecialValueFor("invis_duration")
	if invis_duration > 0 then
		caster:AddNewModifier(caster, self, "modifier_invisible", {duration = invis_duration})
	end
	local silence_radius = self:GetSpecialValueFor("radius")
	if silence_radius > 0 then
		local silence_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, silence_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for _,unit in pairs(silence_enemies) do
			unit:AddNewModifier(caster, self, "modifier_generic_silenced_lua", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end