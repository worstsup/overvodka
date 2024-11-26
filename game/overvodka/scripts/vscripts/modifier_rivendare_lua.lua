modifier_rivendare_lua = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_rivendare_lua:IsHidden()
	return false
end

function modifier_rivendare_lua:IsDebuff()
	return false
end

function modifier_rivendare_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_rivendare_lua:OnCreated( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnRefresh( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_rivendare_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end
function modifier_rivendare_lua:OnIntervalThink()
	-- find enemies
	if self:GetParent():IsAlive() and not self:GetParent():IsInvisible() and not self:GetParent():IsOutOfGame() then
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

	-- damage enemies
		for _,enemy in pairs(enemies) do
			local debuff = enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_rivendare_lua_debuff",
				{
					duration = self.duration,
				}
			)

		end
	end
end
