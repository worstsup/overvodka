LinkLuaModifier("modifier_silvername_e_facet_1",        "heroes/silvername/silvername_e_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_1_buff",   "heroes/silvername/silvername_e_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_e_facet_1_debuff", "heroes/silvername/silvername_e_facet_1", LUA_MODIFIER_MOTION_NONE)

silvername_e_facet_1 = class({})

function silvername_e_facet_1:IsStealable() return false end

function silvername_e_facet_1:GetIntrinsicModifierName()
	return "modifier_silvername_e_facet_1"
end

function silvername_e_facet_1:OnSpellStart()
	local caster = self:GetCaster()
	if not caster or caster:IsNull() then return end

	local duration = self:GetSpecialValueFor("duration")

	if not IsServer() then return end

	caster:AddNewModifier(
		caster,
		self,
		"modifier_silvername_e_facet_1_buff",
		{ duration = duration }
	)

	Timers:CreateTimer(FrameTime(), function()
		if not caster or caster:IsNull() then return end
        caster:AddNewModifier(
            caster,
            self,
            "modifier_silvername_e_facet_1_buff",
            { duration = duration - FrameTime() }
        )
	end)

	caster:EmitSound("Hero_BountyHunter.Track")
end


modifier_silvername_e_facet_1 = class({})

function modifier_silvername_e_facet_1:IsHidden()   return true end
function modifier_silvername_e_facet_1:IsPurgable() return false end

function modifier_silvername_e_facet_1:OnCreated()

	self.parent  = self:GetParent()
	self.ability = self:GetAbility()

	self:StartIntervalThink(0.1)
end

function modifier_silvername_e_facet_1:OnIntervalThink()
	if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
	if not self.ability or self.ability:IsNull() then return end
    if not self.parent:IsAlive() then return end
    if self.parent:PassivesDisabled() then return end

    local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetAbsOrigin(),
		nil,
		self.ability:GetSpecialValueFor("vision_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
    for _, enemy in ipairs(enemies) do
        AddFOWViewer(self.parent:GetTeamNumber(), enemy:GetAbsOrigin(), 200, 0.15, false)
    end
end

modifier_silvername_e_facet_1_buff = class({})

function modifier_silvername_e_facet_1_buff:IsPurgable() return true end
function modifier_silvername_e_facet_1_buff:IsDebuff()   return false end

function modifier_silvername_e_facet_1_buff:IsAura() return true end

function modifier_silvername_e_facet_1_buff:GetAuraRadius()
	if not self.ability or self.ability:IsNull() then return 0 end
	local vision_radius = self.ability:GetSpecialValueFor("vision_radius")
	return vision_radius * 0.5
end

function modifier_silvername_e_facet_1_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_silvername_e_facet_1_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_silvername_e_facet_1_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_silvername_e_facet_1_buff:GetAuraDuration()
	return 0.3
end

function modifier_silvername_e_facet_1_buff:GetModifierAura()
	return "modifier_silvername_e_facet_1_debuff"
end

function modifier_silvername_e_facet_1_buff:OnCreated(kv)
	self.parent  = self:GetParent()
	self.ability = self:GetAbility()

	self.total_str    = 0
	self.total_agi    = 0
	self.total_int    = 0
	self.total_as     = 0
	self.total_ms_pct = 0

	if not self.ability or self.ability:IsNull() then return end

	if IsServer() then
		self:SetHasCustomTransmitterData(true)
		self:SendBuffRefreshToClients()
	end
end

function modifier_silvername_e_facet_1_buff:OnRefresh(kv)
	if IsServer() then
		self:SendBuffRefreshToClients()
	end
end

function modifier_silvername_e_facet_1_buff:OnDestroy()
	self.total_str    = 0
	self.total_agi    = 0
	self.total_int    = 0
	self.total_as     = 0
	self.total_ms_pct = 0

	if IsServer() then
		local parent = self:GetParent()
		if parent and not parent:IsNull() then
			parent:CalculateStatBonus(true)
		end
		self:SendBuffRefreshToClients()
	end
end

function modifier_silvername_e_facet_1_buff:AddContribution(str_gain, agi_gain, int_gain, as_gain, ms_pct_gain)
	if not IsServer() then return end

	self.total_str    = (self.total_str    or 0) + (str_gain    or 0)
	self.total_agi    = (self.total_agi    or 0) + (agi_gain    or 0)
	self.total_int    = (self.total_int    or 0) + (int_gain    or 0)
	self.total_as     = (self.total_as     or 0) + (as_gain     or 0)
	self.total_ms_pct = (self.total_ms_pct or 0) + (ms_pct_gain or 0)

	local parent = self:GetParent()
	if parent and not parent:IsNull() then
		parent:CalculateStatBonus(true)
	end
	self:SendBuffRefreshToClients()
end

function modifier_silvername_e_facet_1_buff:RemoveContribution(str_gain, agi_gain, int_gain, as_gain, ms_pct_gain)
	if not IsServer() then return end

	self.total_str    = math.max(0, (self.total_str    or 0) - (str_gain    or 0))
	self.total_agi    = math.max(0, (self.total_agi    or 0) - (agi_gain    or 0))
	self.total_int    = math.max(0, (self.total_int    or 0) - (int_gain    or 0))
	self.total_as     = math.max(0, (self.total_as     or 0) - (as_gain     or 0))
	self.total_ms_pct = math.max(0, (self.total_ms_pct or 0) - (ms_pct_gain or 0))

	local parent = self:GetParent()
	if parent and not parent:IsNull() then
		parent:CalculateStatBonus(true)
	end
	self:SendBuffRefreshToClients()
end

function modifier_silvername_e_facet_1_buff:AddCustomTransmitterData()
	return {
		ts = self.total_str    or 0,
		ta = self.total_agi    or 0,
		ti = self.total_int    or 0,
		as = self.total_as     or 0,
		ms = self.total_ms_pct or 0,
	}
end

function modifier_silvername_e_facet_1_buff:HandleCustomTransmitterData(data)
	self.total_str    = data.ts or 0
	self.total_agi    = data.ta or 0
	self.total_int    = data.ti or 0
	self.total_as     = data.as or 0
	self.total_ms_pct = data.ms or 0
end

function modifier_silvername_e_facet_1_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_silvername_e_facet_1_buff:GetModifierBonusStats_Strength()
	return self.total_str or 0
end

function modifier_silvername_e_facet_1_buff:GetModifierBonusStats_Agility()
	return self.total_agi or 0
end

function modifier_silvername_e_facet_1_buff:GetModifierBonusStats_Intellect()
	return self.total_int or 0
end

function modifier_silvername_e_facet_1_buff:GetModifierAttackSpeedBonus_Constant()
	return self.total_as or 0
end

function modifier_silvername_e_facet_1_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.total_ms_pct or 0
end


modifier_silvername_e_facet_1_debuff = class({})

function modifier_silvername_e_facet_1_debuff:IsPurgable() return true end
function modifier_silvername_e_facet_1_debuff:IsDebuff()   return true end

function modifier_silvername_e_facet_1_debuff:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent  = self:GetParent()

	self.steal_str    = 0
	self.steal_agi    = 0
	self.steal_int    = 0
	self.steal_as     = 0
	self.steal_ms_pct = 0

	if not self.ability or self.ability:IsNull() then
		if IsServer() then self:Destroy() end
		return
	end

	if not self.parent or self.parent:IsNull() then
		if IsServer() then self:Destroy() end
		return
	end

	if self.parent:IsDebuffImmune() or self.parent:IsMagicImmune() or self.parent:IsInvulnerable() then
		if IsServer() then self:Destroy() end
		return
	end

	if not self.parent:IsRealHero() then
		if IsServer() then self:Destroy() end
		return
	end

	local caster = self.ability:GetCaster()
	if not caster or caster:IsNull() then
		if IsServer() then self:Destroy() end
		return
	end

	local attr_steal_pct      = self.ability:GetSpecialValueFor("attribute_steal_pct") * 0.01
	local attack_speed_steal  = self.ability:GetSpecialValueFor("attack_speed_steal")
	local movespeed_steal_pct = self.ability:GetSpecialValueFor("movespeed_steal_pct")

	local str   = self.parent:GetStrength()
	local agi   = self.parent:GetAgility()
	local intel = self.parent:GetIntellect(false)

	self.steal_str    = math.floor(str   * attr_steal_pct + 0.5)
	self.steal_agi    = math.floor(agi   * attr_steal_pct + 0.5)
	self.steal_int    = math.floor(intel * attr_steal_pct + 0.5)
	self.steal_as     = attack_speed_steal
	self.steal_ms_pct = movespeed_steal_pct

	if not IsServer() then return end

	self._caster_buff = caster:FindModifierByName("modifier_silvername_e_facet_1_buff")
	if self._caster_buff and not self._caster_buff:IsNull() and self._caster_buff.AddContribution then
		self._caster_buff:AddContribution(
			self.steal_str,
			self.steal_agi,
			self.steal_int,
			self.steal_as,
			self.steal_ms_pct
		)
	end
end

function modifier_silvername_e_facet_1_debuff:OnRefresh(kv)
	if not IsServer() then return end

	if self._caster_buff and not self._caster_buff:IsNull() and self._caster_buff.RemoveContribution then
		self._caster_buff:RemoveContribution(
			self.steal_str,
			self.steal_agi,
			self.steal_int,
			self.steal_as,
			self.steal_ms_pct
		)
	end

	self:OnCreated(kv)
end

function modifier_silvername_e_facet_1_debuff:OnDestroy()
	if not IsServer() then return end

	if self._caster_buff and not self._caster_buff:IsNull() and self._caster_buff.RemoveContribution then
		self._caster_buff:RemoveContribution(
			self.steal_str,
			self.steal_agi,
			self.steal_int,
			self.steal_as,
			self.steal_ms_pct
		)
	end
end

function modifier_silvername_e_facet_1_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_silvername_e_facet_1_debuff:GetModifierBonusStats_Strength()
	return -self.steal_str
end

function modifier_silvername_e_facet_1_debuff:GetModifierBonusStats_Agility()
	return -self.steal_agi
end

function modifier_silvername_e_facet_1_debuff:GetModifierBonusStats_Intellect()
	return -self.steal_int
end

function modifier_silvername_e_facet_1_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.steal_as
end

function modifier_silvername_e_facet_1_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.steal_ms_pct
end
