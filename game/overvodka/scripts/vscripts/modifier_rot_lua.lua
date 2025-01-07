modifier_rot_lua = class({})
--------------------------------------------------------------------------------

function modifier_rot_lua:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_rot_lua:IsAura()
	if self:GetCaster() == self:GetParent() then
		return true
	end
	
	return false
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetModifierAura()
	return "modifier_rot_lua"
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetAuraRadius()
	return self.rot_radius
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnCreated( kv )
	self.rot_radius = self:GetAbility():GetSpecialValueFor( "rot_radius" )
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.rot_slow = self:GetAbility():GetOrbSpecialValueFor( "rot_slow", "e" )
		self.rot_damage = self:GetAbility():GetOrbSpecialValueFor( "rot_damaged", "w" )
	else
		self.rot_slow = -21
		self.rot_damage = 40
	end
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_secondd" )
	self.rot_tick = self:GetAbility():GetSpecialValueFor( "rot_tick" )
	self.manacost = self.manacost * self:GetParent():GetMaxMana() * 0.01
	self.parent = self:GetParent()

	-- Start interval
	self:Burn()
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			EmitSoundOn( "rotik", self:GetCaster() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.rot_radius, 1, self.rot_radius ) )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		else
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		end

		self:StartIntervalThink( self.rot_tick )
	end
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnDestroy()
	if IsServer() then
		StopSoundOn( "rotik", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function modifier_rot_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_rot_lua:GetModifierMoveSpeedBonus_Percentage( params )
	if self:GetParent() == self:GetCaster() then
		return 0
	end

	return self.rot_slow
end

--------------------------------------------------------------------------------

function modifier_rot_lua:OnIntervalThink()
	if IsServer() then
		if self:GetParent() ~= self:GetCaster() then
		    return 0
	    end
		local flDamagePerTick = self.rot_tick * self.rot_damage
		local mana = self.parent:GetMana()
	    if mana < self.manacost or (self.parent:GetAbilityByIndex( 3 ) ~= self:GetAbility() and self.parent:GetAbilityByIndex( 4 ) ~= self:GetAbility()) then
		    -- turn off
		    if self:GetAbility():GetToggleState() then
		    	self:GetAbility():ToggleAbility()
		    end
		    return
	    end
	    self:Burn()
	end
end

function modifier_rot_lua:Burn()
	-- spend mana

	self.parent:SpendMana( self.manacost, self:GetAbility() )
	if self:GetParent() ~= self:GetCaster() then
		return 0
	end
	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.rot_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		-- apply damage
		self.dmg = self.rot_damage + enemy:GetMaxHealth() * 0.004
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.dmg,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------