LinkLuaModifier("modifier_papich_w_clone", "heroes/papich/papich_w_clone", LUA_MODIFIER_MOTION_NONE)

papich_w_clone = class({})
function papich_w_clone:IsHiddenWhenStolen() return false end
function papich_w_clone:IsRefreshable() return true end
function papich_w_clone:IsStealable() return true end
function papich_w_clone:IsNetherWardStealable() return true end

function papich_w_clone:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_loc = caster:GetAbsOrigin()
		local axe_radius = self:GetSpecialValueFor("axe_radius")
		local max_range = self:GetSpecialValueFor("max_range")
		local axe_movement_speed = self:GetSpecialValueFor("axe_movement_speed")
		local whirl_duration = self:GetSpecialValueFor("whirl_duration")
		local direction = caster:GetForwardVector()
		caster:EmitSound("papich_w_clone")
		caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Melee")
		if (math.random(1,100) <= 25) and (caster:GetName() == "npc_dota_hero_troll_warlord") then
			caster:EmitSound("troll_warlord_troll_whirlingaxes_0"..math.random(1,6))
		end
		local index = DoUniqueString("index")
		self[index] = {}
		local axe_pfx = {}
		local axe_loc = {}
		local axe_random = {}
		for i=1, 10, 1 do
			table.insert(axe_pfx, ParticleManager:CreateParticle("particles/econ/items/troll_warlord/troll_ti10_shoulder/troll_ti10_whirling_axe_melee.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster))
			ParticleManager:SetParticleControl(axe_pfx[i], 1, caster_loc)
			ParticleManager:SetParticleControl(axe_pfx[i], 4, Vector(whirl_duration,0,0))
			table.insert(axe_random, math.random()*0.9+1.8)
		end
		local counter = 0
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
		Timers:CreateTimer(FrameTime(), function()
			counter = counter + FrameTime()
			caster_loc = caster:GetAbsOrigin()
			if counter <= (whirl_duration / 2) then
				for i=1, 10, 1 do
					axe_loc[i] = counter * (max_range - axe_radius) * RotateVector2D(direction,36*i + counter*axe_movement_speed):Normalized()
					self:DoAxeStuff(index,counter * (max_range-axe_radius)+axe_radius,caster_loc)
				end
			else
				for i=1, 10, 1 do
					axe_loc[i] = (whirl_duration - counter/2) * (max_range - axe_radius) * RotateVector2D(direction,36*i + counter*axe_movement_speed*axe_random[i]):Normalized()
					self:DoAxeStuff(index,(whirl_duration - counter/2) * (max_range-axe_radius)+axe_radius,caster_loc)
				end
			end
			for i=1, 10, 1 do
				ParticleManager:SetParticleControl(axe_pfx[i], 1, caster_loc + axe_loc[i] + Vector(0,0,40))
			end
			if counter <= whirl_duration then
				return FrameTime()
			else
				for i=1, 10, 1 do
					ParticleManager:DestroyParticle(axe_pfx[i], false)
					ParticleManager:ReleaseParticleIndex(axe_pfx[i])
				end
			end
		end)
	end
end

function papich_w_clone:DoAxeStuff(index,range,caster_loc)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local blind_duration = self:GetSpecialValueFor("blind_duration")
	local blind_stacks = self:GetSpecialValueFor("blind_stacks")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, range, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,enemy in ipairs(enemies) do
		local was_hit = false
		for _, stored_target in ipairs(self[index]) do
			if enemy == stored_target then
				was_hit = true
				break
			end
		end
		if was_hit then
			return nil
		else
			table.insert(self[index],enemy)
		end
		ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = damage, damage_type = self:GetAbilityDamageType()})
		caster:PerformAttack(enemy, true, true, true, true, false, true, true)
		enemy:AddNewModifier(caster, self, "modifier_papich_w_clone", {duration = blind_duration * (1 - enemy:GetStatusResistance()), blind_stacks = blind_stacks})
		enemy:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
	end
end

modifier_papich_w_clone = class({})
function modifier_papich_w_clone:IsDebuff() return true end
function modifier_papich_w_clone:IsHidden() return false end
function modifier_papich_w_clone:IsPurgable() return true end
function modifier_papich_w_clone:IsPurgeException() return false end
function modifier_papich_w_clone:IsStunDebuff() return false end
function modifier_papich_w_clone:RemoveOnDeath() return true end

function modifier_papich_w_clone:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_MISS_PERCENTAGE
		}
		
	return decFuns
end

function modifier_papich_w_clone:OnCreated(params)
	self.miss_chance = self:GetAbility():GetSpecialValueFor("blind_pct")
	self.blood_damage = self:GetAbility():GetSpecialValueFor("blood_damage")
	self:StartIntervalThink(1)
end
function modifier_papich_w_clone:OnIntervalThink()
	self.dmg = self:GetParent():GetHealth() * self.blood_damage * 0.01
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.dmg, damage_type = DAMAGE_TYPE_PURE })
end
function modifier_papich_w_clone:GetModifierMiss_Percentage()
	return self.miss_chance
end

function modifier_papich_w_clone:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_papich_w_clone:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf"
end

function modifier_papich_w_clone:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function RotateVector2D(vec, angle)
    local rad = math.rad(angle)
    local x = vec.x * math.cos(rad) - vec.y * math.sin(rad)
    local y = vec.x * math.sin(rad) + vec.y * math.cos(rad)
    return Vector(x, y, vec.z)
end