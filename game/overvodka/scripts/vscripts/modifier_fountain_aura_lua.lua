ability_fountain = class({})

modifier_overvodka_fountain_passive = class({})

local FOUNTAIN_REGEN_AURA_RADIUS = 1275
local FOUNTAIN_ATTACK_RADIUS = 1300
local FOUNTAIN_ATTACK_INTERVAL = 0.5
local FOUNTAIN_THINK_INTERVAL = 0.05
local FOUNTAIN_DAMAGE_PCT = 0.25
local FOUNTAIN_CUSTOM_INTERACTION_RADIUS = 1500
local FOUNTAIN_PUSH_DISTANCE = 1600
local FOUNTAIN_HIT_SOUND = "Ability.LagunaBlade"
local FOUNTAIN_HIT_PARTICLE = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf"

function modifier_overvodka_fountain_passive:IsHidden() return true end
function modifier_overvodka_fountain_passive:IsPurgable() return false end
function modifier_overvodka_fountain_passive:IsPurgeException() return false end
function modifier_overvodka_fountain_passive:RemoveOnDeath() return false end

function modifier_overvodka_fountain_passive:IsAura()
	return true
end

function modifier_overvodka_fountain_passive:GetModifierAura()
	return "modifier_fountain_aura_effect_lua"
end

function modifier_overvodka_fountain_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_overvodka_fountain_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_overvodka_fountain_passive:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_overvodka_fountain_passive:GetAuraDuration()
	return 0.1
end

function modifier_overvodka_fountain_passive:GetAuraRadius()
	return FOUNTAIN_REGEN_AURA_RADIUS
end

function modifier_overvodka_fountain_passive:DeclareFunctions()
	local funcs = {}
	if MODIFIER_PROPERTY_DISABLE_AUTOATTACK then
		table.insert(funcs, MODIFIER_PROPERTY_DISABLE_AUTOATTACK)
	end
	return funcs
end

function modifier_overvodka_fountain_passive:GetDisableAutoAttack()
	return 1
end

function modifier_overvodka_fountain_passive:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_overvodka_fountain_passive:OnCreated(params)
	if not IsServer() then return end

	self.fountain = self:GetParent()
	if params and params.fountain then
		local fountain = EntIndexToHScript(params.fountain)
		if fountain and not fountain:IsNull() then
			self.fountain = fountain
		end
	end

	self.attack_time = FOUNTAIN_ATTACK_INTERVAL
	self:StartIntervalThink(FOUNTAIN_THINK_INTERVAL)
end

function modifier_overvodka_fountain_passive:OnIntervalThink()
	if not IsServer() then return end

	self:ProcessOvervodkaCustomInteractions()

	self.attack_time = (self.attack_time or 0) + FOUNTAIN_THINK_INTERVAL
	if self.attack_time < FOUNTAIN_ATTACK_INTERVAL then
		return
	end

	self.attack_time = 0
	self:AttackEnemies()
end

function modifier_overvodka_fountain_passive:ProcessOvervodkaCustomInteractions()
	local fountain = self:GetParent()
	if not fountain or fountain:IsNull() then return end

	local enemies = FindUnitsInRadius(
		fountain:GetTeamNumber(),
		fountain:GetAbsOrigin(),
		nil,
		FOUNTAIN_CUSTOM_INTERACTION_RADIUS,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO,
		0,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		if enemy and not enemy:IsNull() then
			if enemy:IsAlive() and enemy:HasModifier("modifier_mazellov_r") and not enemy:HasModifier("modifier_knockback") then
				local direction = (enemy:GetAbsOrigin() - fountain:GetAbsOrigin()):Normalized()
				local distance = (fountain:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
				local new_pos = enemy:GetAbsOrigin() + direction * (FOUNTAIN_PUSH_DISTANCE - distance)
				FindClearSpaceForUnit(enemy, new_pos, true)
			end

			if enemy:HasModifier("modifier_epstein_island_on_island") then
				fountain:AddNewModifier(fountain, nil, "modifier_generic_disarmed_lua", {duration = 0.1})
			end
		end
	end
end

function modifier_overvodka_fountain_passive:IsAttackDisabled()
	local fountain = self.fountain or self:GetParent()
	if not fountain or fountain:IsNull() then
		return true
	end

	return fountain:HasModifier("modifier_generic_disarmed_lua")
end

function modifier_overvodka_fountain_passive:AttackEnemies()
	local fountain = self.fountain or self:GetParent()
	if not fountain or fountain:IsNull() then return end
	if self:IsAttackDisabled() then return end

	local units = FindUnitsInRadius(
		fountain:GetTeamNumber(),
		fountain:GetAbsOrigin(),
		nil,
		FOUNTAIN_ATTACK_RADIUS,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	for _, target in pairs(units) do
		if target and not target:IsNull() and target:IsAlive() and target:GetUnitName() ~= "npc_dota_courier" then
			if target:IsRealHero() then
				target:EmitSound(FOUNTAIN_HIT_SOUND)
			end

			local particle = ParticleManager:CreateParticle(FOUNTAIN_HIT_PARTICLE, PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(particle, 0, fountain, PATTACH_POINT_FOLLOW, "attach_attack1", fountain:GetAbsOrigin() + Vector(0, 0, 96), true)
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

			ApplyDamage({
				attacker = fountain,
				victim = target,
				ability = nil,
				damage = target:GetMaxHealth() * FOUNTAIN_DAMAGE_PCT,
				damage_type = DAMAGE_TYPE_PURE,
			})

			if target and not target:IsNull() and target:IsAlive() and not target:IsRealHero() then
				target:Kill(nil, fountain)
			end
		end
	end
end

modifier_fountain_aura_lua = modifier_overvodka_fountain_passive
