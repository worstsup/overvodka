LinkLuaModifier("modifier_amor_w_self_buff",    "heroes/amor/amor_w",           LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_w_slow",         "heroes/amor/amor_w",           LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_amor_w_superslow",    "heroes/amor/amor_w",           LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_arc_lua",     "modifier_generic_arc_lua",     LUA_MODIFIER_MOTION_BOTH)

amor_w = class({})

function amor_w:Precache( ctx )
    PrecacheResource( "soundfile", "soundevents/amor_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/amor_w.vpcf", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", ctx )
	PrecacheResource( "particle", "particles/jugg_fall20_immortal_healing_ward_death_sparks_flash.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_largo/largo_catchy_lick_heal.vpcf", ctx )
end

function amor_w:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound( "amor_w" )
    return true
end

function amor_w:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound( "amor_w" )
end

function amor_w:GetAOERadius()
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and caster:HasShard() then
        return self:GetSpecialValueFor("shard_radius")
    end
    return 0
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

    caster:AddNewModifier(caster, self, "modifier_amor_w_self_buff", { duration = self_buff_dur })

    local p = ParticleManager:CreateParticle("particles/amor_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    ParticleManager:SetParticleControl(p, 0, origin)
    ParticleManager:SetParticleControl(p, 1, tpos)
    ParticleManager:ReleaseParticleIndex(p)

    local dmg = {attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}
	local aoe_mark = {}
    dmg.victim = target
    target:AddNewModifier(caster, self, "modifier_amor_w_superslow", { duration = stun_dur * (1 - target:GetStatusResistance()) })
    target:AddNewModifier(caster, self, "modifier_amor_w_slow", { duration = slow_dur * (1 - target:GetStatusResistance()) })
    if caster:HasTalent("special_bonus_unique_amor_4") then
        caster:PerformAttack(target, true, true, true, true, false, false, true)
    end
    ApplyDamage(dmg)

    if caster:HasShard() then
        local shard_radius = self:GetSpecialValueFor("shard_radius")
        if shard_radius and shard_radius > 0 then
            local enemies_aoe = FindUnitsInRadius(
                caster:GetTeamNumber(),
                tpos, nil, shard_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0, 0, false
            )

            for _, enemy in ipairs(enemies_aoe) do
                if enemy and not enemy:IsNull() and enemy:IsAlive() and enemy ~= target then
                    local eid = enemy:entindex()
                    dmg.victim = enemy
                    enemy:AddNewModifier(caster, self, "modifier_amor_w_superslow", { duration = stun_dur * (1 - enemy:GetStatusResistance()) })
                    enemy:AddNewModifier(caster, self, "modifier_amor_w_slow", { duration = slow_dur * (1 - enemy:GetStatusResistance()) })
                    if caster:HasTalent("special_bonus_unique_amor_4") then
                        caster:PerformAttack(enemy, true, true, true, true, false, false, true)
                    end
					aoe_mark[eid] = true
                    ApplyDamage(dmg)
                end
            end
        end
    end

	local enemies_line = FindUnitsInLine(
        caster:GetTeamNumber(), origin, tpos,
        nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE
    )

    for _, enemy in ipairs(enemies_line) do
        if enemy and not enemy:IsNull() and enemy ~= target and enemy:IsAlive() and not aoe_mark[enemy:entindex()] then
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
            enemy:AddNewModifier(caster, self, "modifier_generic_arc_lua", {
                dir_x = away.x, dir_y = away.y,
                distance = knock_dist, duration = knock_dur, height = 0,
                fix_duration = 1, fix_end = 1, fix_height = 1,
                isStun = 0, isRestricted = 0, isForward = 1,
            })
            self:TreesDestroy(enemy, away, knock_dur)
            ApplyDamage(dmg)
        end
    end
end


function amor_w:TreesDestroy(unit, push_dir, duration)
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
    self.mag_resist = abil and abil:GetSpecialValueFor("magic_resist_reduction") or 0
end

function modifier_amor_w_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_amor_w_slow:GetModifierMoveSpeedBonus_Percentage()
	return -(self.ms or 0)
end

function modifier_amor_w_slow:GetModifierAttackSpeedPercentage()
	return -(self.as or 0)
end

function modifier_amor_w_slow:GetModifierMagicalResistanceBonus()
    return -(self.mag_resist or 0)
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


modifier_amor_w_superslow = class({})

function modifier_amor_w_superslow:IsHidden() return false end
function modifier_amor_w_superslow:IsDebuff() return true end
function modifier_amor_w_superslow:IsPurgable() return true end

function modifier_amor_w_superslow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_amor_w_superslow:GetModifierMoveSpeedBonus_Percentage()
    return -100
end