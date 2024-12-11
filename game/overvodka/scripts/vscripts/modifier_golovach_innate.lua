modifier_golovach_innate = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_innate:IsHidden()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_innate:OnCreated( kv )
	-- references
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" ) -- special value
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" ) -- special value
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" ) -- special value
	self.ability_proc = "golovach_hidden"
	self.cooldown = self:GetAbility():GetCooldown( self:GetAbility():GetLevel() )
	local interval = 0.2
	self:StartIntervalThink( interval )
end

function modifier_golovach_innate:OnRefresh( kv )
	-- references
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" ) -- special value
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" ) -- special value
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" ) -- special value
	self.ability_proc = "golovach_hidden"
	self.cooldown = self:GetAbility():GetCooldown( self:GetAbility():GetLevel() )
end

function modifier_golovach_innate:OnDestroy( kv )
end
function modifier_golovach_innate:OnIntervalThink()
	if self:GetParent():HasScepter() and (self:GetAbility():GetCooldownTimeRemaining() >= 235.4 and self:GetAbility():GetCooldownTimeRemaining() <= 236) then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_black_king_bar_immune", {duration = 7})
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.slow_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_generic_silenced_lua",
				{ duration = 7 }
			)
		end
	end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_REINCARNATION,
		-- MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_golovach_innate:ReincarnateTime( params )
	if IsServer() then
		if self:GetAbility():IsFullyCastable() then
			self:Reincarnate()
			return self.reincarnate_time
		end
		return 0
	end
end

--------------------------------------------------------------------------------
-- Helper Function
function modifier_golovach_innate:Reincarnate()
	-- spend resources
	if self:GetParent():HasScepter() then
		self.cooldown = 240
	end
	self:GetAbility():StartCooldown(self.cooldown)
	AddFOWViewer( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 900, 4, false)
	if self:GetParent():HasScepter() then
		-- find affected enemies
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.slow_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		-- apply slow
		for _,enemy in pairs(enemies) do
			local direction = enemy:GetOrigin()-self:GetParent():GetOrigin()
			direction.z = 0
			direction = direction:Normalized()
			enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_golovach_innate_debuff",
				{ duration = self.slow_duration }
			)
			enemy:AddNewModifier(
				self:GetParent(), -- player source
				self:GetAbility(), -- ability source
				"modifier_generic_arc_lua", -- modifier name
				{
					dir_x = direction.x,
					dir_y = direction.y,
					duration = 0.5,
					distance = 500,
					height = 75,
					activity = ACT_DOTA_FLAIL,
				} -- kv
			)
		end
	end
		-- play effects
		self:PlayEffects()
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_golovach_innate:PlayEffects()
	-- get resources
	local particle_cast = "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn.vpcf"
	local sound_cast = "golovach_innate"

	-- play particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.reincarnate_time, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( sound_cast, self:GetParent() )
end