LinkLuaModifier("modifier_silvername_w_facet_1", "heroes/silvername/silvername_w_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_w_facet_1_boost", "heroes/silvername/silvername_w_facet_1", LUA_MODIFIER_MOTION_NONE)

silvername_w_facet_1 = class({})

function silvername_w_facet_1:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_lancer.vsndevts", ctx)
end

function silvername_w_facet_1:IsStealable() return false end

function silvername_w_facet_1:GetIntrinsicModifierName()
	return "modifier_silvername_w_facet_1"
end

function silvername_w_facet_1:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end

function silvername_w_facet_1:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end

modifier_silvername_w_facet_1 = class({})

function modifier_silvername_w_facet_1:IsHidden()		return true end
function modifier_silvername_w_facet_1:IsPurgable()		return false end
function modifier_silvername_w_facet_1:RemoveOnDeath()	return false end

function modifier_silvername_w_facet_1:OnCreated()
	if not IsServer() then return end

	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.bRushChecking = false
	self.target = nil

	self:StartIntervalThink(0.1)
end

function modifier_silvername_w_facet_1:OnIntervalThink()
	if not IsServer() then return end
	if not self.bRushChecking or not self.target or self.target:IsNull() then return end
	if not self.ability or self.ability:IsNull() then return end

	if self.parent:GetAggroTarget() ~= self.target then
		self.target = nil
		self.bRushChecking = false
		return
	end

	local min_dist = self.ability:GetSpecialValueFor("min_distance")
	local max_dist = self.ability:GetSpecialValueFor("max_distance")

	local dist = (self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D()

	if dist <= max_dist and dist >= min_dist then
		self:StartRush(self.target)
		self.bRushChecking = false
		self.target = nil
	end
end

function modifier_silvername_w_facet_1:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
	}
end

function modifier_silvername_w_facet_1:OnOrder(keys)
	if not IsServer() then return end
	if keys.unit ~= self.parent then return end
	if not self.ability or self.ability:IsNull() then return end

	if self.ability:GetToggleState() then return end
	if self.parent:PassivesDisabled() then return end

	if keys.order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then
		self.target = nil
		self.bRushChecking = false
		return
	end

	local target = keys.target
	if not target or target:IsNull() then return end
	if target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	if not self.ability:IsCooldownReady() then return end

	local min_dist = self.ability:GetSpecialValueFor("min_distance")
	local max_dist = self.ability:GetSpecialValueFor("max_distance")

	local dist = (target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D()

	if dist <= max_dist and dist >= min_dist then
		self:StartRush(target)
		self.target = nil
		self.bRushChecking = false
	else
		self.target = target
		self.bRushChecking = true
	end
end

function modifier_silvername_w_facet_1:StartRush(target)
	if not IsServer() then return end
	if not target or target:IsNull() then return end
	if not self.ability or self.ability:IsNull() then return end

	self.parent:EmitSound("Hero_PhantomLancer.PhantomEdge")

	local max_duration = self.ability:GetSpecialValueFor("max_duration")

	local modifier = self.parent:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_silvername_w_facet_1_boost",
		{
			duration = max_duration,
			target_entindex = target:entindex(),
		}
	)

	if modifier then
		self.ability:UseResources(false, false, false, true)
	end
end

modifier_silvername_w_facet_1_boost = class({})

function modifier_silvername_w_facet_1_boost:IsPurgable() return false end

function modifier_silvername_w_facet_1_boost:GetEffectName()
	return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function modifier_silvername_w_facet_1_boost:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_silvername_w_facet_1_boost:OnCreated(kv)
	self.parent  = self:GetParent()
	self.ability = self:GetAbility()

	self.bonus_speed   = self.ability and self.ability:GetSpecialValueFor("bonus_speed") or 800
	self.gold_steal    = self.ability and self.ability:GetSpecialValueFor("gold_steal") or 0
	self.gold_steal_pct = self.ability and self.ability:GetSpecialValueFor("gold_steal_pct") or 0

	if not IsServer() then return end

	if kv and kv.target_entindex then
		self.target = EntIndexToHScript(kv.target_entindex)
	end

	self.gold_stolen = false

	self.destroy_orders = {
		[DOTA_UNIT_ORDER_MOVE_TO_POSITION]	= true,
		[DOTA_UNIT_ORDER_ATTACK_MOVE]		= true,

		[DOTA_UNIT_ORDER_STOP]				= true,
		[DOTA_UNIT_ORDER_CONTINUE]			= true,
		[DOTA_UNIT_ORDER_CAST_POSITION]		= true,
		[DOTA_UNIT_ORDER_CAST_TARGET]		= true,
		[DOTA_UNIT_ORDER_CAST_TARGET_TREE]	= true,
		[DOTA_UNIT_ORDER_CAST_TOGGLE]		= true,
		[DOTA_UNIT_ORDER_HOLD_POSITION]		= true,
		[DOTA_UNIT_ORDER_DROP_ITEM]			= true,
		[DOTA_UNIT_ORDER_GIVE_ITEM]			= true,
		[DOTA_UNIT_ORDER_PICKUP_ITEM]		= true,
		[DOTA_UNIT_ORDER_PICKUP_RUNE]		= true,
	}
end

function modifier_silvername_w_facet_1_boost:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_silvername_w_facet_1_boost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_silvername_w_facet_1_boost:GetModifierMoveSpeed_AbsoluteMin()
	return self.bonus_speed
end

function modifier_silvername_w_facet_1_boost:OnOrder(keys)
	if not IsServer() then return end
	if keys.unit ~= self.parent then return end

	local order = keys.order_type

	if order == DOTA_UNIT_ORDER_ATTACK_TARGET or order == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		if self.target and not self.target:IsNull() and keys.target then
			if keys.target ~= self.target then
				self:Destroy()
			end
		else
			self:Destroy()
		end
		return
	end

	if self.destroy_orders[order] then
		self:Destroy()
	end
end

function modifier_silvername_w_facet_1_boost:OnStateChanged(keys)
	if not IsServer() then return end
	if keys.unit ~= self.parent then return end

	if self.parent:IsStunned() or self.parent:IsNightmared() or self.parent:IsHexed() or self.parent:IsOutOfGame() or self.parent:IsRooted() then
		self:Destroy()
	end
end

function modifier_silvername_w_facet_1_boost:OnAttackLanded(keys)
	if not IsServer() then return end
	if self.gold_stolen then return end
	if keys.attacker ~= self.parent then return end

	local target = keys.target
	if not target or target:IsNull() then return end
	if target ~= self.target then
        self:Destroy()
		return
	end

	if not target:IsRealHero() then
		self:Destroy()
		return
	end

	local attackerPlayerID = self.parent:GetPlayerOwnerID()
	local victimPlayerID   = target:GetPlayerOwnerID()

	if attackerPlayerID == nil or attackerPlayerID == -1 or victimPlayerID == nil or victimPlayerID == -1 then
		self:Destroy()
		return
	end

	local victimGold = PlayerResource:GetGold(victimPlayerID) or 0

	local fixed = self.gold_steal or 0
	local pct   = self.gold_steal_pct or 0

	local steal = fixed + math.floor(victimGold * pct * 0.01 + 0.5)
	if steal <= 0 then
		self:Destroy()
		return
	end

	if steal > victimGold then
		steal = victimGold
	end

    PlayerResource:SpendGold(victimPlayerID, steal, 4)
    self.parent:ModifyGold(steal, false, 0)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.parent, steal, nil)

	self.gold_stolen = true
	self:Destroy()
end
