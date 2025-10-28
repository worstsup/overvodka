LinkLuaModifier("modifier_seregga_w_debuff", "heroes/seregga/seregga_w", LUA_MODIFIER_MOTION_NONE)

seregga_w = class({})

function seregga_w:Precache(ctx)
    PrecacheResource("particle", "particles/seregga_w_proj_2.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownenergy.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/seregga_sounds.vsndevts", ctx)
end

function seregga_w:_BeginCastChain()
    self.__cast_seq = (self.__cast_seq or 0) + 1
    self.__casts = self.__casts or {}
    self.__casts[self.__cast_seq] = { hit = {} }
    return self.__cast_seq
end

function seregga_w:_MarkHit(cast_id, entindex)
    if not self.__casts or not self.__casts[cast_id] then return end
    self.__casts[cast_id].hit[entindex] = true
end

function seregga_w:_WasHit(cast_id, entindex)
    if not self.__casts or not self.__casts[cast_id] then return false end
    return self.__casts[cast_id].hit[entindex] == true
end

function seregga_w:_EndCastChain(cast_id)
    if not self.__casts then return end
    self.__casts[cast_id] = nil
end

function seregga_w:GetCastRange(loc, target)
    return self.BaseClass.GetCastRange(self, loc, target)
end

function seregga_w:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function seregga_w:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function seregga_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end
    local cast_id = self:_BeginCastChain()
    local duration = self:GetSpecialValueFor("duration")
    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/seregga_w_proj_2.vpcf",
        iMoveSpeed = 800,
        bDodgeable = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {
            cast_id = cast_id,
            rem_dur = duration,
        }
    }
    ProjectileManager:CreateTrackingProjectile(info)

    caster:EmitSound("seregga_w_"..RandomInt(1,2))
end

function seregga_w:OnProjectileHit_ExtraData(target, location, extra)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not extra then return end

    local cast_id = tonumber(extra.cast_id or 0) or 0
    local rem_dur = tonumber(extra.rem_dur or 0) or 0

    if not target or target:IsNull() then
        self:_EndCastChain(cast_id)
        return
    end

    if not target:IsAlive() then
        self:_EndCastChain(cast_id)
        return
    end
    if target:TriggerSpellAbsorb(self) then
        self:_EndCastChain(cast_id)
        return
    end
    local tid = target:entindex()
    if self:_WasHit(cast_id, tid) then
        local next_target, new_dur = self:_FindNextBounceTarget(target, cast_id, rem_dur)
        if next_target and new_dur and new_dur > 0 then
            self:_FireBounce(target, next_target, cast_id, new_dur)
            return true
        end
        self:_EndCastChain(cast_id)
        return true
    end

    if rem_dur > 0 then
        target:AddNewModifier(caster, self, "modifier_seregga_w_debuff", { duration = rem_dur })
    end

    self:_MarkHit(cast_id, tid)
    local reduct_sec = math.max(0, self:GetSpecialValueFor("bounces_dur_reduct") or 0)
    if reduct_sec <= 0 then
        self:_EndCastChain(cast_id)
        return true
    end
    local new_dur = rem_dur - reduct_sec

    local next_target = nil
    if new_dur > 0 then
        next_target = self:_FindNearestEnemyHeroNotHit(target:GetAbsOrigin(), cast_id, caster:GetTeamNumber())
    end

    if next_target and new_dur > 0 then
        self:_FireBounce(target, next_target, cast_id, new_dur)
    else
        self:_EndCastChain(cast_id)
    end

    local damage = self:GetSpecialValueFor("damage")
    if damage > 0 then
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        })
    end

    return true
end

function seregga_w:_FindNearestEnemyHeroNotHit(origin, cast_id, team)
    local range = self:GetSpecialValueFor("bounce_range")

    local enemies = FindUnitsInRadius(team, origin, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
    for _,unit in ipairs(enemies) do
        if unit and unit:IsAlive() and not self:_WasHit(cast_id, unit:entindex()) then
            return unit
        end
    end
    return nil
end

function seregga_w:_FindNextBounceTarget(from_target, cast_id, rem_dur)
    local caster = self:GetCaster()
    local reduct_sec = math.max(0, self:GetSpecialValueFor("bounces_dur_reduct") or 0)
    local new_dur = rem_dur - reduct_sec
    if new_dur <= 0 then return nil, 0 end

    local next_target = self:_FindNearestEnemyHeroNotHit(
        from_target:GetAbsOrigin(),
        cast_id,
        caster:GetTeamNumber()
    )
    return next_target, new_dur
end

function seregga_w:_FireBounce(from_unit, to_unit, cast_id, new_dur)
    if not from_unit or not to_unit then return end
    ProjectileManager:CreateTrackingProjectile({
        Target = to_unit,
        Source = from_unit,
        Ability = self,
        EffectName = "particles/seregga_w_proj_2.vpcf",
        iMoveSpeed = 800,
        bDodgeable = true,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        ExtraData = {
            cast_id = cast_id,
            rem_dur = new_dur,
        }
    })
end


modifier_seregga_w_debuff = class({})

function modifier_seregga_w_debuff:IsPurgable() return true end
function modifier_seregga_w_debuff:IsDebuff()   return true end

function modifier_seregga_w_debuff:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_ti8_immortal_head/dw_crimson_ti8_immortal_cursed_crownenergy.vpcf"
end

function modifier_seregga_w_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_seregga_w_debuff:OnCreated()

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    if not self.ability or self.ability:IsNull() then return end

    self.slow_pct        = self.ability:GetSpecialValueFor("slow_pct")
    self.int_pct_reduce  = self.ability:GetSpecialValueFor("int_pct_reduce")
    self.dmg_amp_pct     = self.ability:GetSpecialValueFor("dmg_amp_pct")

    self.cached_int = math.max(0, self.parent:GetIntellect(false))
    self.int_flat_penalty = math.floor(self.cached_int * self.int_pct_reduce / 100.0) * (-1)
    if not IsServer() then return end
end

function modifier_seregga_w_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_seregga_w_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -math.abs(self.slow_pct or 0)
end

function modifier_seregga_w_debuff:GetModifierBonusStats_Intellect()
    return self.int_flat_penalty or 0
end

function modifier_seregga_w_debuff:GetModifierIncomingDamage_Percentage(keys)
    if self.caster and keys and keys.attacker == self.caster then
        return math.max(0, self.dmg_amp_pct or 0)
    end
    return 0
end

function modifier_seregga_w_debuff:CheckState()
    return {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
end
