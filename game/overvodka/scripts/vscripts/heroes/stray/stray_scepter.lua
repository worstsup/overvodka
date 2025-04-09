stray_scepter = class({})
LinkLuaModifier( "modifier_stray_scepter", "heroes/stray/stray_scepter", LUA_MODIFIER_MOTION_NONE )

function stray_scepter:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/stray_scepter.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_spectre/spectre_haunt.vpcf", context )
	PrecacheResource( "particle", "particles/axe_ti9_call_ring_new_1.vpcf", context )
end

function stray_scepter:Spawn()
	if not IsServer() then return end
end

function stray_scepter:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	local outgoing = self:GetSpecialValueFor( "illusion_damage_outgoing" )
	local incoming = self:GetSpecialValueFor( "illusion_damage_incoming" )
	local distance = 70
	local heroes = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
		0,
		false
	)
	EmitGlobalSound("stray_scepter")
    if caster:HasModifier("modifier_stray_r") then
        caster:StopSound("stray_r")
    end
	if #heroes<1 then return end

	local illusions = CreateIllusions(
		caster,
		caster,
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		},
		#heroes,
		distance,
		false,
		true
	)
	
	local i = 0
	for _,hero in pairs(heroes) do
		i = i+1
		local illusion = illusions[i]
		illusion:SetOwner(caster)
		illusion:SetControllableByPlayer( -1, false )
		FindClearSpaceForUnit( illusion, hero:GetOrigin(), false )
		local sound_cast = "Hero_Spectre.Haunt"
		EmitSoundOn( sound_cast, illusion )
	end
	self:SetContextThink( DoUniqueString( "stray_scepter" ),function()
		local i = 0
		for _,hero in pairs(heroes) do
			i = i+1
			local illusion = illusions[i]
			illusion:AddNewModifier(
				caster,
				self,
				"modifier_stray_scepter",
				{
					duration = duration,
					target = hero:entindex(),
				}
			)
		end
	end, FrameTime()*2)
end

modifier_stray_scepter = class({})

function modifier_stray_scepter:IsHidden()
	return true
end
function modifier_stray_scepter:IsPurgable()
	return false
end

function modifier_stray_scepter:OnCreated( kv )
	local delay = self:GetAbility():GetSpecialValueFor( "attack_delay" )
	if not IsServer() then return end
	self.target = EntIndexToHScript( kv.target )
	self.distance = 70
	self.disarm = true
	local nFXIndex = ParticleManager:CreateParticle( "particles/axe_ti9_call_ring_new_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector(10000, 1, 10000 ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
	self:StartIntervalThink( delay )
end

function modifier_stray_scepter:OnRefresh( kv )
	
end

function modifier_stray_scepter:OnRemoved()
end

function modifier_stray_scepter:OnDestroy()
	if not IsServer() then return end

	local haunts = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetCaster():GetOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		0,
		0,
		false
	)
	local found = false
	for _,haunt in pairs(haunts) do
		if haunt~=self:GetParent() and haunt:HasModifier( "modifier_stray_scepter" ) then
			found = true
			break
		end
	end
	if found then return end

end

function modifier_stray_scepter:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = self.disarm,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

function modifier_stray_scepter:OnIntervalThink()
	if self.disarm then
		self:StartIntervalThink( 0.1 )
		self.disarm = false
	else
		self:FollowThink()
	end
end

function modifier_stray_scepter:FollowThink()
	if not self.target:IsAlive() then
		self:GetParent():ForceKill( false )
		self:Destroy()
		return
	end

	local parent = self:GetParent()
	local origin = self.target:GetOrigin()
	local seen = self:GetCaster():CanEntityBeSeenByMyTeam( self.target )

	if not seen then
		if (parent:GetOrigin()-origin):Length2D()>self.distance/2 then
			parent:MoveToPosition( origin )
		end
	else
		if parent:GetAggroTarget()~=self.target then
			local order = {
				UnitIndex = parent:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = self.target:entindex(),
			}
			ExecuteOrderFromTable( order )
		end
	end
end