macan_e = class({})
LinkLuaModifier( "modifier_macan_e", "heroes/macan/macan_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_macan_e_debuff", "heroes/macan/macan_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_macan_e_stack", "heroes/macan/macan_e", LUA_MODIFIER_MOTION_NONE )

function macan_e:GetIntrinsicModifierName()
	return "modifier_macan_e"
end

modifier_macan_e = class({})
function modifier_macan_e:IsHidden()
	return false
end
function modifier_macan_e:IsDebuff()
	return false
end

function modifier_macan_e:IsPurgable()
	return false
end

function modifier_macan_e:OnCreated( kv )
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.stack_steal = self:GetParent():FindAbilityByName("macan_w"):GetSpecialValueFor( "stack_steal" )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_macan_e:OnRefresh( kv )
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.stack_steal = self:GetParent():FindAbilityByName("macan_w"):GetSpecialValueFor( "stack_steal" )
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
end

function modifier_macan_e:OnDestroy( kv )

end

function modifier_macan_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function modifier_macan_e:OnAbilityFullyCast( params )
	if IsServer() then
		local ability = params.ability
		local caster = self:GetParent()
		if ability:GetName() == "macan_w" and params.target:IsRealHero() and not params.target:IsIllusion() then
			local target = params.target
			if target:HasModifier("modifier_macan_e_debuff") then
				local debuff = target:FindModifierByName("modifier_macan_e_debuff")
				local stacks_to_steal = self.stack_steal
				if stacks_to_steal > 0 then
					for i = 1, stacks_to_steal do
						self:AddStack(self.duration)
						target:AddNewModifier(
							self:GetParent(),
							self:GetAbility(),
							"modifier_macan_e_debuff",
							{
								stack_duration = self.duration,
							}
						)
					end
				end
			end
		end
	end
end


function modifier_macan_e:OnIntervalThink()
	if not self:GetParent():IsAlive() then return end
	if self:GetParent():IsIllusion() then return end
	if self:GetParent():PassivesDisabled() then return end
	self.stack_steal = self:GetParent():FindAbilityByName("macan_w"):GetSpecialValueFor( "stack_steal" )
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		0,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		if enemy:IsIllusion() == false then
			local debuff = enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_macan_e_debuff",
				{
					stack_duration = self.duration,
				}
			)
			self:AddStack( duration )
			self:PlayEffects( enemy )
		end
	end
end


function modifier_macan_e:GetModifierBonusStats_Strength()
	return self:GetStackCount() * self.agi_gain
end

function modifier_macan_e:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_macan_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_macan_e:RemoveStack()
	self:DecrementStackCount()
end
function modifier_macan_e:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_slark/slark_essence_shift.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_macan_e_debuff = class({})

function modifier_macan_e_debuff:IsHidden()
	return false
end
function modifier_macan_e_debuff:IsDebuff()
	return true
end
function modifier_macan_e_debuff:IsPurgable()
	return false
end

function modifier_macan_e_debuff:OnCreated( kv )
	self.stat_loss = self:GetAbility():GetSpecialValueFor( "stat_loss" )
	self.duration = kv.stack_duration
	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_macan_e_debuff:OnRefresh( kv )
	self.stat_loss = self:GetAbility():GetSpecialValueFor( "stat_loss" )
	self.duration = kv.stack_duration

	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_macan_e_debuff:OnDestroy( kv )
end

function modifier_macan_e_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_macan_e_debuff:GetModifierBonusStats_Strength()
	return self:GetStackCount() * -self.stat_loss
end


function modifier_macan_e_debuff:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_macan_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_macan_e_debuff:RemoveStack()
	self:DecrementStackCount()

	if self:GetStackCount()<=0 then
		self:Destroy()
	end
end

modifier_macan_e_stack = class({})

function modifier_macan_e_stack:IsHidden()
	return true
end
function modifier_macan_e_stack:IsPurgable()
	return false
end
function modifier_macan_e_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_macan_e_stack:OnCreated( kv )
end

function modifier_macan_e_stack:OnRemoved()
	if IsServer() then
		self.modifier:RemoveStack()
	end
end