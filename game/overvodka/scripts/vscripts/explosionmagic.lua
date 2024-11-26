Megumin_ExplosionMagic = class({})
LinkLuaModifier( "modifier_ExplosionMagic", "modifier_ExplosionMagic.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ExplosionMagic_immunity", "modifier_ExplosionMagic_immunity.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ExplosionMagic_debuff", "modifier_ExplosionMagic_debuff.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnAbilityPhaseStart()
	if IsServer() then
		self.channel_duration = self:GetSpecialValueFor( "channel_duration" )
		local fImmuneDuration = self.channel_duration + self:GetCastPoint()
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ExplosionMagic_immunity", { duration = fImmuneDuration } )

		self.nPreviewFX = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 250, 250, 250 ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 176, 224, 230 ) )
	end

	return true
end

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		self:GetCaster():StopSound("vpis")
		self:GetCaster():RemoveModifierByName("modifier_ExplosionMagic_immunity")
	end
end

function Megumin_ExplosionMagic:OnChannelFinish()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		self:GetCaster():StopSound("vpis")
		self:GetCaster():RemoveModifierByName("modifier_ExplosionMagic_immunity")
	end 
end

function Megumin_ExplosionMagic:OnAbilityChannelSucceeded()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		self:GetCaster():StopSound("vpis")
		self:GetCaster():RemoveModifierByName("modifier_ExplosionMagic_immunity")
	end 
end

-----------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnSpellStart()
	if IsServer() then	
		ParticleManager:DestroyParticle( self.nPreviewFX, false )

		self.effect_radius = self:GetSpecialValueFor( "effect_radius" )
		self.interval = self:GetSpecialValueFor( "interval" )
		self.flNextCast = 0.0

		EmitSoundOn( "vpis", self:GetCaster() )
	end
end

-----------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnChannelThink( flInterval )
	if IsServer() then
	
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		if #targets >= 1 then	
				for _,unit in pairs(targets) do
				
					local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
					local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
					local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 250)
					local knockbackProperties =
					{
						center_x = bump_point.x,
						center_y = bump_point.y,
						center_z = bump_point.z,
						duration = 0.2,
						knockback_duration = 0.2,
						knockback_distance = 100,
						knockback_height = 0
					}
				
					if not unit:HasModifier("modifier_knockback") then
						unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )
						unit:AddNewModifier( self:GetCaster(), nil, "modifier_ExplosionMagic_debuff", { duration = 1 } )
						local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_CUSTOMORIGIN, nil )
						ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
						ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( 750, 750, 750 ) )
					end
				end
		end
	
		self.flNextCast = self.flNextCast + flInterval
		if self.flNextCast >= self.interval  then

			-- Try not to overlap wrath_thinker locations, but use the last position attempted if we spend too long in the loop
			local nMaxAttempts = 7
			local nAttempts = 0
			local vPos = nil

			repeat
				vPos = self:GetCaster():GetOrigin() + RandomVector( RandomInt( 50, self.effect_radius ) )
				local hThinkersNearby = Entities:FindAllByClassnameWithin( "npc_dota_thinker", vPos, 600 )
				local hOverlappingWrathThinkers = {}

				for _, hThinker in pairs( hThinkersNearby ) do
					if ( hThinker:HasModifier( "modifier_ExplosionMagic" ) ) then
						table.insert( hOverlappingWrathThinkers, hThinker )
					end
				end
				nAttempts = nAttempts + 1
				if nAttempts >= nMaxAttempts then
					break
				end
			until ( #hOverlappingWrathThinkers == 0 )

			CreateModifierThinker( self:GetCaster(), self, "modifier_ExplosionMagic", {}, vPos, self:GetCaster():GetTeamNumber(), false )
			self.flNextCast = self.flNextCast - self.interval
		end
		
	end
end

-----------------------------------------------------------------------------