dawnbreaker_solar_guardian_lua = class({})
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua", "modifier_dawnbreaker_solar_guardian_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dawnbreaker_solar_guardian_lua_leap", "modifier_dawnbreaker_solar_guardian_lua_leap.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function dawnbreaker_solar_guardian_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_damage.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_healing_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf", context )
	PrecacheResource( "particle", "particles/dvoreckov_qqe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/dvoreckov_qqe.vpcf", context )
end

function dawnbreaker_solar_guardian_lua:Spawn()
	if not IsServer() then
		CustomIndicator:RegisterAbility( self )
		return
	end
end

function dawnbreaker_solar_guardian_lua:CreateCustomIndicator()
	local particle_cast1 = "particles/ui_mouseactions/range_finder_tp_dest.vpcf"
	local particle_cast2 = "particles/ui_mouseactions/range_finder_aoe.vpcf"
	self.effect_cast1 = ParticleManager:CreateParticle( particle_cast1, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	self.effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end

function dawnbreaker_solar_guardian_lua:UpdateCustomIndicator( loc )
	local origin = self:GetCaster():GetAbsOrigin()
	local radius = self:GetSpecialValueFor( "radius" )
	local offset = self:GetSpecialValueFor( "max_offset_distance" )
	local target, point = self:FindValidPoint( loc )

	ParticleManager:SetParticleControl( self.effect_cast1, 0, origin )
	ParticleManager:SetParticleControl( self.effect_cast1, 2, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast1, 3, Vector( offset, 1, 1 ) )
	ParticleManager:SetParticleControl( self.effect_cast1, 4, point )

	ParticleManager:SetParticleControl( self.effect_cast2, 2, point )
	ParticleManager:SetParticleControl( self.effect_cast2, 3, Vector( radius, 1, 1 ) )
end

function dawnbreaker_solar_guardian_lua:DestroyCustomIndicator()
	ParticleManager:DestroyParticle( self.effect_cast1, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast1 )

	ParticleManager:DestroyParticle( self.effect_cast2, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast2 )
end

function dawnbreaker_solar_guardian_lua:FindValidPoint( point )
	local caster = self:GetCaster()
	local offset = self:GetSpecialValueFor( "max_offset_distance" )

	-- find allies
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local target = caster
	local distance = (caster:GetAbsOrigin()-point):Length2D()
	for _,ally in pairs(allies) do
		-- check if distance is closer
		local d = (ally:GetAbsOrigin()-point):Length2D()
		if d<distance then
			distance = d
			target = ally
		end
	end

	-- get offset
	local direction = point-target:GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	point = target:GetAbsOrigin() + direction*offset
	point = GetGroundPosition( point, caster )
	return target,point
end

function dawnbreaker_solar_guardian_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function dawnbreaker_solar_guardian_lua:CastFilterResultLocation( vLoc )
	if IsClient() then
		if self.custom_indicator then
			-- register cursor position
			self.custom_indicator:Register( vLoc )
		end
	end

	if not IsServer() then return end
	if self:GetSpecialValueFor("talent") == 1 then
		return UF_SUCCESS
	end
	local caster = self:GetCaster()
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		vLoc,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		300,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #allies<1 then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function dawnbreaker_solar_guardian_lua:GetCustomCastErrorLocation( vLoc )

	if not IsServer() then return "" end

	local caster = self:GetCaster()
	if self:GetSpecialValueFor("talent") == 1 then
		return ""
	end
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		vLoc,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		300,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #allies<1 then
		return "Ты еблан наведись на героя вражеского блядь"
	end

	return ""
end

function dawnbreaker_solar_guardian_lua:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = nil
	if not self:GetSpecialValueFor("talent") == 1 then
		target,point = self:FindValidPoint( point )
	end
	local channel = self:GetChannelTime()
	local leaptime = self:GetSpecialValueFor( "airtime_duration" )
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_solar_guardian_lua", -- modifier name
		{
			duration = channel+leaptime,
			x = point.x,
			y = point.y,
		} -- kv
	)

	self.point = point
end

function dawnbreaker_solar_guardian_lua:OnChannelFinish( interrupted )
	local caster = self:GetCaster()

	if interrupted then
		local mod = caster:FindModifierByName( "modifier_dawnbreaker_solar_guardian_lua" )
		if mod and (not mod:IsNull()) then
			mod:Destroy()
		end
		return
	end

	local duration = self:GetSpecialValueFor( "airtime_duration" )

	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_dawnbreaker_solar_guardian_lua_leap", -- modifier name
		{
			duration = duration,
			x = self.point.x,
			y = self.point.y,
		} -- kv
	)
end