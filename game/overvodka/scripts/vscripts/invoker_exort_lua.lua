invoker_exort_lua = class({})
LinkLuaModifier( "modifier_invoker_exort_lua", "modifier_invoker_exort_lua.lua", LUA_MODIFIER_MOTION_NONE )

function invoker_exort_lua:IsStealable()
	return false
end
--------------------------------------------------------------------------------
-- Ability Start
function invoker_exort_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	if caster:GetUnitName() == "npc_dota_hero_invoker" then
	-- add modifier
		local modifier = caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_invoker_exort_lua", -- modifier name
			{  } -- kv
		)

		-- register to invoke ability
		self.invoke:AddOrb( modifier )
	end
end

--------------------------------------------------------------------------------
-- Ability Events
function invoker_exort_lua:OnUpgrade()
	if not self.invoke then
		-- if first time, upgrade and init Invoke
		local invoke = self:GetCaster():FindAbilityByName( "invoker_invoke_lua" )
		if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
		self.invoke = invoke
	else
		-- update status
		self.invoke:UpdateOrb("modifier_invoker_exort_lua", self:GetLevel())
	end
end