lion_mana_drain_lua = class({})
LinkLuaModifier( "modifier_lion_mana_drain_lua", "modifier_lion_mana_drain_lua.lua", LUA_MODIFIER_MOTION_NONE )

lion_mana_drain_lua.modifiers = {}
function lion_mana_drain_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then
		return
	end
	local duration = self:GetSpecialValueFor("duration") + 0.1
	local modifier = target:AddNewModifier(
		caster,
		self,
		"modifier_lion_mana_drain_lua",
		{ duration = duration }
	)
	self.modifiers[modifier] = true
	self.sound_cast = "hehe"
	EmitSoundOn(self.sound_cast, caster)

	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		local additional_targets = self:FindAdditionalTargets()
		local count = 0
		for _, additional_target in pairs(additional_targets) do
			if additional_target ~= target then
				local additional_modifier = additional_target:AddNewModifier(
					caster,
					self,
					"modifier_lion_mana_drain_lua",
					{ duration = duration }
				)
				self.modifiers[additional_modifier] = true
				count = count + 1
				if count >= 2 then
					break
				end
			end
		end
	end
end

function lion_mana_drain_lua:Unregister( modifier )
	self.modifiers[modifier] = nil
	local counter = 0
	for modifier,_ in pairs(self.modifiers) do
		if not modifier:IsNull() then
			counter = counter+1
		end
	end
end

function lion_mana_drain_lua:FindAdditionalTargets()
	local caster = self:GetCaster()
	local break_distance = self:GetSpecialValueFor("break_distance")
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		break_distance,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_CLOSEST,
		false
	)
	return targets
end