modifier_slark_essence_shift_lua = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_slark_essence_shift_lua:IsHidden()
	return false
end
function modifier_slark_essence_shift_lua:IsDebuff()
	return false
end

function modifier_slark_essence_shift_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_slark_essence_shift_lua:OnCreated( kv )
	-- references
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_slark_essence_shift_lua:OnRefresh( kv )
	-- references
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.ms = self:GetAbility():GetSpecialValueFor( "ms" )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_slark_essence_shift_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_slark_essence_shift_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end
function modifier_slark_essence_shift_lua:OnIntervalThink()
	if self:GetParent():IsIllusion() then return end
	-- find enemies
	if self:GetParent():HasModifier("modifier_silver_edge_debuff") then return end
	if self:GetParent():HasModifier("modifier_break") then return end
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
		if enemy:IsIllusion() == false then
			local debuff = enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_slark_essence_shift_lua_debuff",
				{
					stack_duration = self.duration,
				}
			)

		-- Apply buff to self
			self:AddStack( duration )

		-- Play effects
			self:PlayEffects( enemy )
		end
	end
end


function modifier_slark_essence_shift_lua:GetModifierBonusStats_Strength()
	return self:GetStackCount() * self.agi_gain
end
function modifier_slark_essence_shift_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetStackCount() * self.ms
end

--------------------------------------------------------------------------------
-- Helper
function modifier_slark_essence_shift_lua:AddStack( duration )
	-- Add counter
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_slark_essence_shift_lua_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self

	-- Add stack
	self:IncrementStackCount()
end

function modifier_slark_essence_shift_lua:RemoveStack()
	self:DecrementStackCount()
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_slark_essence_shift_lua:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_slark/slark_essence_shift.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end