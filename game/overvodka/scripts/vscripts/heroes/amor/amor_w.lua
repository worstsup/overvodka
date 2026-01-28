LinkLuaModifier("modifier_amor_w_self_buff",    "heroes/amor/amor_w",           LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_w_slow",         "heroes/amor/amor_w",           LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua",     "modifier_generic_arc_lua",     LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

amor_w = class({})

function amor_w:Precache( ctx )
    PrecacheResource( "soundfile", "soundevents/amor_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", ctx )
end

local function StartKnockUtility(unit, push_dir, duration)
	local end_time = GameRules:GetGameTime() + (duration or 0) + 0.1

	Timers:CreateTimer(function()
		if not unit or unit:IsNull() or not unit:IsAlive() then
			return nil
		end
		if GameRules:GetGameTime() >= end_time then
			return nil
		end
		local pos = unit:GetAbsOrigin()
		GridNav:DestroyTreesAroundPoint(pos, 100, false)

		return 0.05
	end)
end

function amor_w:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not caster or caster:IsNull() or not target or target:IsNull() then return end

	if target:TriggerSpellAbsorb(self) then return end

	local damage        = self:GetSpecialValueFor("damage")
	local stun_dur      = self:GetSpecialValueFor("stun_duration")
	local width         = self:GetSpecialValueFor("sneeze_width")
	local knock_dist    = self:GetSpecialValueFor("knock_distance")
	local knock_dur     = self:GetSpecialValueFor("knock_duration")
	local slow_dur      = self:GetSpecialValueFor("slow_duration")
	local self_buff_dur = self:GetSpecialValueFor("self_bonus_duration")

	local origin = caster:GetAbsOrigin()
	local tpos   = target:GetAbsOrigin()

	local dir = (tpos - origin)
	dir.z = 0
	if dir:Length2D() < 1 then
		dir = caster:GetForwardVector()
	else
		dir = dir:Normalized()
	end

	caster:EmitSound("Hero_Beastmaster.Primal_Roar")
	caster:AddNewModifier(caster, self, "modifier_amor_w_self_buff", { duration = self_buff_dur })

	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(p, 0, origin)
	ParticleManager:SetParticleControl(p, 1, tpos)
	ParticleManager:ReleaseParticleIndex(p)

	local dmg = {attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}

	dmg.victim = target
	target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_dur })
	target:AddNewModifier(caster, self, "modifier_amor_w_slow", { duration = slow_dur * (1 - target:GetStatusResistance()) })

	target:EmitSound("Hero_Beastmaster.Primal_Roar.Target")

    ApplyDamage(dmg)

	local enemies = FindUnitsInLine(
		caster:GetTeamNumber(), origin, tpos,
		nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

	for _, enemy in ipairs(enemies) do
		if enemy and not enemy:IsNull() and enemy ~= target and enemy:IsAlive() then
			dmg.victim = enemy

			enemy:AddNewModifier(caster, self, "modifier_amor_w_slow", { duration = slow_dur * (1 - enemy:GetStatusResistance()) })

			local epos = enemy:GetAbsOrigin()
			local toE = epos - origin
			toE.z = 0

			local t = toE:Dot(dir)
			local closest = origin + dir * t

			local away = (epos - closest)
			away.z = 0

			if away:Length2D() < 1 then
				away = Vector(-dir.y, dir.x, 0)
			else
				away = away:Normalized()
			end
			enemy:FaceTowards(epos + away * 100)
			enemy:SetForwardVector(away)

			enemy:AddNewModifier(caster, self, "modifier_generic_arc_lua", {
				dir_x = away.x,
				dir_y = away.y,
				distance = knock_dist,
				duration = knock_dur,

				height = 0,
				fix_duration = 1,
				fix_end = 1,
				fix_height = 1,

				isStun = 0,
				isRestricted = 0,
				isForward = 1,
			})
			StartKnockUtility(enemy, away, knock_dur)
            ApplyDamage(dmg)
		end
	end
end


modifier_amor_w_self_buff = class({})

function modifier_amor_w_self_buff:IsHidden() return false end
function modifier_amor_w_self_buff:IsDebuff() return false end
function modifier_amor_w_self_buff:IsPurgable() return true end

function modifier_amor_w_self_buff:OnCreated()
	local abil = self:GetAbility()
	self.ms = abil and abil:GetSpecialValueFor("self_bonus_ms_pct") or 0
	self.as = abil and abil:GetSpecialValueFor("self_bonus_as") or 0
end

function modifier_amor_w_self_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_amor_w_self_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms or 0
end

function modifier_amor_w_self_buff:GetModifierAttackSpeedPercentage()
	return self.as or 0
end

function modifier_amor_w_self_buff:OnTooltip()
	return self.as
end


modifier_amor_w_slow = class({})

function modifier_amor_w_slow:IsHidden() return false end
function modifier_amor_w_slow:IsDebuff() return true end
function modifier_amor_w_slow:IsPurgable() return true end

function modifier_amor_w_slow:OnCreated()
	local abil = self:GetAbility()
	self.ms = abil and abil:GetSpecialValueFor("slow_ms_pct") or 0
	self.as = abil and abil:GetSpecialValueFor("slow_as") or 0
end

function modifier_amor_w_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_amor_w_slow:GetModifierMoveSpeedBonus_Percentage()
	return -(self.ms or 0)
end

function modifier_amor_w_slow:GetModifierAttackSpeedPercentage()
	return -(self.as or 0)
end

function modifier_amor_w_slow:OnTooltip()
	return self.as
end

function modifier_amor_w_slow:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function modifier_amor_w_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end