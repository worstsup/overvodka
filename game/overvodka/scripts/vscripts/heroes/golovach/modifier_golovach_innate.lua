modifier_golovach_innate = class({})

function modifier_golovach_innate:IsHidden()
	return true
end

function modifier_golovach_innate:OnCreated( kv )
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.ability_proc = "golovach_hidden"
	self.cooldown = self:GetAbility():GetCooldown( self:GetAbility():GetLevel() )
	local interval = 0.2
	self:StartIntervalThink( interval )
end

function modifier_golovach_innate:OnRefresh( kv )
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.ability_proc = "golovach_hidden"
	self.cooldown = self:GetAbility():GetCooldown( self:GetAbility():GetLevel() )
end

function modifier_golovach_innate:OnDestroy( kv )
end
function modifier_golovach_innate:OnIntervalThink()
	if self:GetParent():HasScepter() and (self:GetAbility():GetCooldownTimeRemaining() >= 135.4 and self:GetAbility():GetCooldownTimeRemaining() <= 136) then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_black_king_bar_immune", {duration = 4})
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetOrigin(),
			nil,
			self.slow_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0,
			0,
			false
		)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_generic_silenced_lua",
				{ duration = 3 }
			)
		end
	end
end
function modifier_golovach_innate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_REINCARNATION,
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

function modifier_golovach_innate:Reincarnate()
	if self:GetParent():HasScepter() then
		self.cooldown = 140
	end
	self:GetAbility():StartCooldown(self.cooldown)
	AddFOWViewer( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 900, 4, false)
	if self:GetParent():HasScepter() then
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetOrigin(),
			nil,
			self.slow_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0,
			0,
			false
		)
		for _,enemy in pairs(enemies) do
			local direction = enemy:GetOrigin()-self:GetParent():GetOrigin()
			local distance = (enemy:GetOrigin()-self:GetParent():GetOrigin()):Length2D()
			direction.z = 0
			direction = direction:Normalized()
			enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_golovach_innate_debuff",
				{ duration = self.slow_duration }
			)
			enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_generic_arc_lua",
				{
					dir_x = -direction.x,
					dir_y = -direction.y,
					duration = 0.5,
					distance = distance,
					height = 75,
					activity = ACT_DOTA_FLAIL,
				}
			)
		end
	end
		self:PlayEffects()
end

function modifier_golovach_innate:PlayEffects()
	local particle_cast = "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn.vpcf"
	local sound_cast = "golovach_innate"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.reincarnate_time, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetParent() )
end