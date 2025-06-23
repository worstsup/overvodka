stariy_lasers = class({})

LinkLuaModifier( "modifier_stariy_lasers_thinker", "heroes/stariy/modifier_stariy_lasers_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_linger_thinker", "heroes/stariy/modifier_stariy_lasers_linger_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_debuff", "heroes/stariy/modifier_stariy_lasers_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_fly", "heroes/stariy/modifier_stariy_fly", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_pull_thinker", "heroes/stariy/stariy_lasers", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_pull", "heroes/stariy/stariy_lasers", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_lasers_pull_cooldown", "heroes/stariy/stariy_lasers", LUA_MODIFIER_MOTION_NONE )

function stariy_lasers:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_burn.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_linger.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_tgt_ring.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_debug_ring.vpcf", context )
	PrecacheResource( "particle", "particles/stariy_lasers_facet.vpcf", context)
	PrecacheResource( "particle", "particles/stariy_lasers_wings.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/stariy_ult.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/stariy_ult_start.vsndevts", context )
end

function stariy_lasers:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function stariy_lasers:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_6
end

function stariy_lasers:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn( "stariy_ult_start", caster )
	self.radius = self:GetSpecialValueFor( "radius" )
	self.facet = (self:GetSpecialValueFor("has_facet") == 1)
	caster:AddNewModifier( caster, self, "modifier_stariy_fly", {duration = 1.5} )
	if IsServer() then
		self:PlayEffects1()
		if not caster:HasModifier("modifier_stariy_lasers_pull_cooldown") and self.facet then 
			caster:AddNewModifier(caster, self, "modifier_stariy_lasers_pull_cooldown", {duration = self:GetSpecialValueFor("cooldown_pull")})
			self.thinker = CreateModifierThinker(
				caster,
				self,
				"modifier_stariy_lasers_pull_thinker",
				{},
				caster:GetOrigin(),
				caster:GetTeamNumber(),
				false
			)
			local radius = self:GetSpecialValueFor( "pull_radius" )

			self.effect_radius = ParticleManager:CreateParticle( "particles/stariy_lasers_facet.vpcf", PATTACH_ABSORIGIN, caster )
			ParticleManager:SetParticleControl( self.effect_radius, 0, caster:GetOrigin() )
			ParticleManager:SetParticleControl( self.effect_radius, 1, Vector(radius,radius, 0) )
		end
		StartSoundEventFromPositionReliable( "Aghanim.StaffBeams.WindUp", caster:GetAbsOrigin() )
		self.nChannelFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_beam_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		self.vecTargets = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
		for k,enemy in pairs ( self.vecTargets ) do
			if enemy ~= nil then
				enemy.nWarningFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_debug_ring.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( enemy.nWarningFXIndex, 0, enemy:GetAbsOrigin() )
				enemy.vSourceLoc = enemy:GetAbsOrigin()
			end
		end
		if self.phaseUpdateTimer then
			Timers:RemoveTimer(self.phaseUpdateTimer)
		end
		self.phaseUpdateTimer = Timers:CreateTimer(function()
			if self.vecTargets then
				for _, enemy in pairs(self.vecTargets) do
					if enemy and not enemy:IsNull() then
						enemy.vSourceLoc = enemy:GetAbsOrigin()
						if enemy.nWarningFXIndex then
							ParticleManager:SetParticleControl(enemy.nWarningFXIndex, 0, enemy:GetAbsOrigin())
						end
					end
				end
			end
			if caster:IsChanneling() or caster:IsAlive() then
				return 0.03
			end
		end)
	end
	return true
end

function stariy_lasers:OnAbilityPhaseInterrupted()
	StopSoundOn( "stariy_ult_start", self:GetCaster() )
	self:GetCaster():RemoveModifierByName( "modifier_stariy_fly" )
	ParticleManager:DestroyParticle( self.nChannelFX, false )
	if self.thinker then self.thinker:Destroy() end
	self.thinker = nil
	self:StopEffects1( false )
	for k,enemy in pairs ( self.vecTargets ) do
		if enemy ~= nil then
			ParticleManager:DestroyParticle(enemy.nWarningFXIndex, false)
		end
	end
end

function stariy_lasers:OnSpellStart()
	if IsServer() then
		if self.thinker then self.thinker:Destroy() end
		self.thinker = nil
		EmitSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		EmitSoundOn( "stariy_ult", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		self.Projectiles = {}

		for k,enemy in pairs ( self.vecTargets ) do
			if enemy ~= nil then
				local hBeamThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_stariy_lasers_thinker", { duration = self:GetChannelTime() }, enemy.vSourceLoc, self:GetCaster():GetTeamNumber(), false )
				ParticleManager:DestroyParticle( enemy.nWarningFXIndex, false )
				local projectile =
				{
					Target = enemy,
					Source = hBeamThinker,
					Ability = self,
					EffectName = "",
					iMoveSpeed = self:GetSpecialValueFor( "beam_speed" ),
					vSourceLoc = enemy.vSourceLoc,
					bDodgeable = false,
					bProvidesVision = false,
					flExpireTime = GameRules:GetGameTime() + self:GetChannelTime(),
					bIgnoreObstructions = true,
					bSuppressTargetCheck = true,
				}

				projectile.hThinker = hBeamThinker

				local nProjectileHandle = ProjectileManager:CreateTrackingProjectile( projectile )
				projectile.nProjectileHandle = nProjectileHandle

				local nBeamFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eyes", self:GetCaster():GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 1, projectile.hThinker, PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
				projectile.nFXIndex = nBeamFXIndex

				table.insert( self.Projectiles, projectile )
			end
		end
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_stariy_fly", {duration = 6,} )
		self:StopEffects1( true )
	end
end

function stariy_lasers:PlayEffects1()
	local particle_precast = "particles/stariy_lasers_wings.vpcf"
	self.effect_precast = ParticleManager:CreateParticle( particle_precast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
end
function stariy_lasers:StopEffects1( success )

	if self.effect_radius then 
		ParticleManager:DestroyParticle( self.effect_radius, false )
		ParticleManager:ReleaseParticleIndex(self.effect_radius)
		self.effect_radius = nil
	end
	if not success then
		ParticleManager:DestroyParticle( self.effect_precast, true )
	end
	ParticleManager:ReleaseParticleIndex( self.effect_precast )
end
function stariy_lasers:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		local Projectile = nil
		for k,v in pairs( self.Projectiles ) do
			if v.nProjectileHandle == nProjectileHandle then
				Projectile = v 
				break
			end
		end

		if Projectile == nil then
			return
		end

		local vLocation = ProjectileManager:GetTrackingProjectileLocation( nProjectileHandle )
		if Projectile.hThinker ~= nil and not Projectile.hThinker:IsNull() then
			vLocation = GetGroundPosition( vLocation, Projectile.hThinker )
			Projectile.hThinker:SetOrigin( vLocation )

			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 1, vLocation )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 9, self:GetCaster():GetAbsOrigin() )
		end
	end
end

local function isUnitInTable(unit, table)
    for _, u in ipairs(table) do
        if u == unit then
            return true
        end
    end
    return false
end

function stariy_lasers:OnChannelThink( flInterval )
	if IsServer() then
		self.newTargets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
		for k,enemy in pairs ( self.newTargets ) do
			if enemy ~= nil and not isUnitInTable(enemy, self.vecTargets) then
				enemy.vSourceLoc = enemy:GetAbsOrigin()
				local hBeamThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_stariy_lasers_thinker", { duration = self:GetChannelTime() }, enemy.vSourceLoc, self:GetCaster():GetTeamNumber(), false )
				local projectile =
				{
					Target = enemy,
					Source = hBeamThinker,
					Ability = self,
					EffectName = "",
					iMoveSpeed = self:GetSpecialValueFor( "beam_speed" ),
					vSourceLoc = enemy.vSourceLoc,
					bDodgeable = false,
					bProvidesVision = false,
					flExpireTime = GameRules:GetGameTime() + self:GetChannelTime(),
					bIgnoreObstructions = true,
					bSuppressTargetCheck = true,
				}

				projectile.hThinker = hBeamThinker

				local nProjectileHandle = ProjectileManager:CreateTrackingProjectile( projectile )
				projectile.nProjectileHandle = nProjectileHandle

				local nBeamFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_eyes", self:GetCaster():GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 1, projectile.hThinker, PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
				projectile.nFXIndex = nBeamFXIndex
				table.insert(self.vecTargets, enemy)
				table.insert( self.Projectiles, projectile )
			end
		end
	end
end

function stariy_lasers:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
		StopSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		StopSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		StopSoundOn( "stariy_ult", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Stop", self:GetCaster() )
		self:GetCaster():RemoveModifierByName( "modifier_stariy_fly" )
		for _,v in pairs ( self.Projectiles ) do
			ParticleManager:DestroyParticle( v.nFXIndex, false )
			if v.hThinker and v.hThinker:IsNull() == false then
				UTIL_Remove( v.hThinker )
			end
		end
	end
end

modifier_stariy_lasers_pull_thinker = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
})


function modifier_stariy_lasers_pull_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "pull_radius" )
end


function modifier_stariy_lasers_pull_thinker:OnDestroy()
	if IsServer() then
	 	UTIL_Remove( self:GetParent())
	end
end

function modifier_stariy_lasers_pull_thinker:IsAura()
	return true
end

function modifier_stariy_lasers_pull_thinker:GetModifierAura()
	return "modifier_stariy_lasers_pull"
end

function modifier_stariy_lasers_pull_thinker:GetAuraRadius()
	return self.radius
end

function modifier_stariy_lasers_pull_thinker:GetAuraDuration()
	return 0.1
end

function modifier_stariy_lasers_pull_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_stariy_lasers_pull_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_stariy_lasers_pull_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_stariy_lasers_pull = {}

function modifier_stariy_lasers_pull:IsHidden()
	return false
end

function modifier_stariy_lasers_pull:IsDebuff()
	return true
end

function modifier_stariy_lasers_pull:IsStunDebuff()
	return true
end

function modifier_stariy_lasers_pull:IsPurgable()
	return true
end

function modifier_stariy_lasers_pull:OnCreated( kv )
	self.pull_speed = self:GetAbility():GetSpecialValueFor( "pull_drag_speed" )
	self.center = self:GetCaster():GetAbsOrigin()
	self:StartIntervalThink(FrameTime())
end


function modifier_stariy_lasers_pull:OnIntervalThink()
	if IsClient() then return end
	local direction = self.center - self:GetParent():GetOrigin()
	direction.z = 0
	direction = direction:Normalized()
	local point = self:GetParent():GetOrigin() + direction * self.pull_speed * FrameTime()

 	self:GetParent():SetOrigin(point)
end

function modifier_stariy_lasers_pull:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	end
end

modifier_stariy_lasers_pull_cooldown = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})