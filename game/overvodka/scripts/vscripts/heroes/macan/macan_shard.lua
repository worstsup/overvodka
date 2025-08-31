macan_shard = class({})

function macan_shard:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/sdvg.vsndevts", context )
end

function macan_shard:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "illusion_duration" )
	local outgoing = self:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = self:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 300
	local illusions = {}
	local num_illusions = 8
	local angle_step = 360 / num_illusions
	local radius = distance

	for i = 1, num_illusions do
		local angle = math.rad(angle_step * (i - 1))
		local spawn_pos = caster:GetAbsOrigin() + Vector(math.cos(angle), math.sin(angle), 0) * radius

		local illusion = CreateIllusions(
			caster,
			caster,
			{
				outgoing_damage = outgoing,
				incoming_damage = incoming,
				duration = duration,
			},
			1,
			0,
			false,
			true
		)[1]

		if illusion then
			FindClearSpaceForUnit(illusion, spawn_pos, false)
			table.insert(illusions, illusion)
		end
	end
	EmitSoundOn( "sdvg", self:GetCaster() )
	EmitSoundOn( "Hero_Terrorblade.ConjureImage", self:GetCaster() )
end