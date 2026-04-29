LinkLuaModifier("modifier_papich_w_clone", "heroes/papich/papich_w_clone", LUA_MODIFIER_MOTION_NONE)

papich_w_clone = class({})
function papich_w_clone:IsHiddenWhenStolen() return false end
function papich_w_clone:IsRefreshable() return true end
function papich_w_clone:IsStealable() return true end
function papich_w_clone:IsNetherWardStealable() return true end

function papich_w_clone:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local axe_radius = self:GetSpecialValueFor("axe_radius")
	local max_range = self:GetSpecialValueFor("max_range")
	local axe_movement_speed = self:GetSpecialValueFor("axe_movement_speed")
	local blind_duration = self:GetSpecialValueFor("blind_duration")
	local damage = self:GetSpecialValueFor("damage")
	local damage_type = self:GetAbilityDamageType()
	local target_team = self:GetAbilityTargetTeam()
	local target_type = self:GetAbilityTargetType()
	local target_flags = self:GetAbilityTargetFlags()
	local whirl_duration = self:GetSpecialValueFor("whirl_duration")
	local expand_duration = math.min(0.35, whirl_duration * 0.5)
	local return_duration = math.min(0.7, whirl_duration * 0.25)
	local particle_linger = 0.05
	local base_direction = caster:GetForwardVector()
	local axe_count = 8
	local angle_step = 360 / math.max(axe_count, 1)
	local hit_targets = {}
	local axe_pfx = {}
	local axe_loc = {}
	local elapsed = 0

	caster:EmitSound("papich_w_clone")
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Melee")
	if (math.random(1,100) <= 25) and (caster:GetName() == "npc_dota_hero_troll_warlord") then
		caster:EmitSound("troll_warlord_troll_whirlingaxes_0"..math.random(1,6))
	end

	for i = 1, axe_count do
		axe_pfx[i] = ParticleManager:CreateParticle("particles/econ/items/troll_warlord/troll_ti10_shoulder/troll_ti10_whirling_axe_melee.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(axe_pfx[i], 1, caster_loc)
		ParticleManager:SetParticleControl(axe_pfx[i], 4, Vector(whirl_duration + particle_linger, 0, 0))
	end

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)

	Timers:CreateTimer(FrameTime(), function()
		if not caster or caster:IsNull() or not caster:IsAlive() then
			for i = 1, axe_count do
				if axe_pfx[i] then
					ParticleManager:DestroyParticle(axe_pfx[i], false)
					ParticleManager:ReleaseParticleIndex(axe_pfx[i])
				end
			end
			return
		end

		local interval = FrameTime()
		elapsed = elapsed + interval
		caster_loc = caster:GetAbsOrigin()

		local distance = max_range
		if elapsed < expand_duration then
			distance = max_range * elapsed / expand_duration
		elseif elapsed >= whirl_duration - return_duration then
			distance = max_range * math.max((whirl_duration - elapsed) / return_duration, 0)
		end

		for i = 1, axe_count do
			local angle = math.rad(angle_step * (i - 1) + elapsed * axe_movement_speed)
			local direction = Vector(
				base_direction.x * math.cos(angle) - base_direction.y * math.sin(angle),
				base_direction.x * math.sin(angle) + base_direction.y * math.cos(angle),
				0
			):Normalized()
			axe_loc[i] = caster_loc + direction * distance
			ParticleManager:SetParticleControl(axe_pfx[i], 1, axe_loc[i] + Vector(0, 0, 40))
		end

		if elapsed <= whirl_duration then
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),
				caster_loc,
				nil,
				max_range + axe_radius,
				target_team,
				target_type,
				target_flags,
				FIND_ANY_ORDER,
				false
			)

			for _, enemy in ipairs(enemies) do
				local entindex = enemy:entindex()
				if not hit_targets[entindex] then
					for i = 1, axe_count do
						if (enemy:GetAbsOrigin() - axe_loc[i]):Length2D() <= axe_radius then
							hit_targets[entindex] = true
							enemy:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
							ApplyDamage({
								victim = enemy,
								attacker = caster,
								ability = self,
								damage = damage,
								damage_type = damage_type
							})
							if enemy and not enemy:IsNull() then
								enemy:AddNewModifier(caster, self, "modifier_papich_w_clone", {duration = blind_duration * (1 - enemy:GetStatusResistance())})
							end
							break
						end
					end
				end
			end
		end

		if elapsed < whirl_duration + particle_linger then
			return FrameTime()
		end

		for i = 1, axe_count do
			if axe_pfx[i] then
				ParticleManager:DestroyParticle(axe_pfx[i], false)
				ParticleManager:ReleaseParticleIndex(axe_pfx[i])
			end
		end
	end)
end

modifier_papich_w_clone = class({})
function modifier_papich_w_clone:IsDebuff() return true end
function modifier_papich_w_clone:IsHidden() return false end
function modifier_papich_w_clone:IsPurgable() return true end
function modifier_papich_w_clone:IsPurgeException() return false end
function modifier_papich_w_clone:IsStunDebuff() return false end
function modifier_papich_w_clone:RemoveOnDeath() return true end

function modifier_papich_w_clone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_papich_w_clone:OnCreated()
	local ability = self:GetAbility()
	self.miss_chance = ability and ability:GetSpecialValueFor("blind_pct") or 0
	self.blood_damage = ability and ability:GetSpecialValueFor("blood_damage") or 0
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_papich_w_clone:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local damage = parent:GetHealth() * self.blood_damage * 0.01
	ApplyDamage({ victim = parent, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE })
end

function modifier_papich_w_clone:GetModifierMiss_Percentage()
	return self.miss_chance or 0
end

function modifier_papich_w_clone:OnTooltip()
	return self.blood_damage or 0
end

function modifier_papich_w_clone:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf"
end

function modifier_papich_w_clone:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end