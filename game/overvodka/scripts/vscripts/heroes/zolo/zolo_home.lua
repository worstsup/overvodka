zolo_home = class({})
--------------------------------------------------------------------------------
-- Ability Start
function zolo_home:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local team = caster:GetTeam()
	ProjectileManager:ProjectileDodge(caster)
	local target_point = 0
	local duration = self:GetSpecialValueFor( "illusion_duration" )
	local outgoing = self:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = self:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 0
	local num = self:GetSpecialValueFor( "illusion_num" )
	local illusions = CreateIllusions(
		caster, -- hOwner
		caster, -- hHeroToCopy
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		}, -- hModiiferKeys
		num, -- nNumIllusions
		distance, -- nPadding
		false, -- bScramblePosition
		true -- bFindClearSpace
	)
	local invis_duration = self:GetSpecialValueFor("invis_duration")
	local max_range = self:GetSpecialValueFor("blink_range")
	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
			target_point = fountainEnt:GetAbsOrigin()
			break
		end
    end
    local origin_point = caster:GetAbsOrigin()
    local difference_vector = target_point - origin_point
    difference_vector = difference_vector:Normalized() * max_range
	caster:SetAbsOrigin(origin_point + difference_vector)
	FindClearSpaceForUnit(caster, origin_point + difference_vector, false)
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_invisible", -- modifier name
		{duration = invis_duration} -- kv
	)
	-- Play effects
	self:PlayEffects( origin_point, difference_vector )
end

--------------------------------------------------------------------------------
function zolo_home:PlayEffects( origin, direction )
	-- Get Resources
	local particle_cast_a = "particles/econ/events/spring_2021/blink_dagger_spring_2021_start_lvl2.vpcf"
	local sound_cast_a = "Hero_QueenOfPain.Blink_out"

	local particle_cast_b = "particles/econ/events/spring_2021/blink_dagger_spring_2021_end_lvl2.vpcf"
	local sound_cast_b = "Hero_QueenOfPain.Blink_in"

	-- At original position
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast_a, 1, origin + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	EmitSoundOnLocationWithCaster( origin, sound_cast_a, self:GetCaster() )
	EmitSoundOnLocationWithCaster( origin, "zolo_home", self:GetCaster() )

	-- At original position
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_b, self:GetCaster() )
end