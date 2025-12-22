LinkLuaModifier("modifier_papich_w_thinker", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_enemy",   "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_caster",  "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_pull",    "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_ally",    "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)

papich_w = class({})

function papich_w:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function papich_w:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_magnetic_cast.vpcf", ctx)
    PrecacheResource("particle", "particles/papich_w.vpcf", ctx)
    PrecacheResource("particle", "particles/papich_w_pull.vpcf", ctx)
    PrecacheResource("soundfile","soundevents/papich_w.vsndevts", ctx)
end

function papich_w:GetBehavior()
    local behavior = self.BaseClass.GetBehavior(self)
    local caster   = self:GetCaster()

    if caster and caster:HasScepter() then
        local nBehavior = tonumber(tostring(behavior))
        return nBehavior + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end

    return behavior
end

function papich_w:CastFilterResultTarget(target)
	if self:GetCaster():HasScepter() then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
	end
    return UF_SUCCESS
end

function papich_w:OnSpellStart()
    local caster = self:GetCaster()
    local dur    = self:GetSpecialValueFor("duration")
    local rad    = self:GetSpecialValueFor("radius")

    if not caster or caster:IsNull() then return end

    local pos    = self:GetCursorPosition()
    local target = nil

    if caster:HasScepter() then
        local t = self:GetCursorTarget()
        if t and not t:IsNull()
            and t:GetTeamNumber() == caster:GetTeamNumber()
        then
            target = t
            pos    = t:GetAbsOrigin()
        end
    end

    caster:EmitSound("papich_w")
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_magnetic_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)

    local follow_ent = target and target:entindex() or nil

    caster:AddNewModifier(caster, self, "modifier_papich_w_caster", {
        duration  = dur,
        center_x  = pos.x, center_y = pos.y, center_z = pos.z,
        radius    = rad,
        follow_ent = follow_ent,
    })

    if target and target ~= caster then
        target:AddNewModifier(caster, self, "modifier_papich_w_ally", {duration = dur})
    end

    CreateModifierThinker(
        caster, self, "modifier_papich_w_thinker",
        {
            duration   = dur,
            radius     = rad,
            follow_ent = follow_ent,
        },
        pos,
        caster:GetTeamNumber(),
        false
    )
end

modifier_papich_w_thinker = class({})

function modifier_papich_w_thinker:IsHidden() return true end
function modifier_papich_w_thinker:IsPurgable() return false end

function modifier_papich_w_thinker:OnCreated(kv)
    self.radius = tonumber(kv.radius or 0)

    if not IsServer() then
        self.center = self:GetParent():GetAbsOrigin()
        return
    end

    self.center = self:GetParent():GetAbsOrigin()

    self.follow_target = nil
    if kv.follow_ent ~= nil then
        local idx = tonumber(kv.follow_ent)
        if idx then
            local ent = EntIndexToHScript(idx)
            if ent and not ent:IsNull() then
                self.follow_target = ent
            end
        end
    end

    local fx = ParticleManager:CreateParticle("particles/papich_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 1, 1))
    self:AddParticle(fx, false, false, -1, false, false)
    if self:GetCaster():HasScepter() then
        local pull = ParticleManager:CreateParticle("particles/papich_w_pull.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
        self:AddParticle(fx, false, false, -1, false, false)
    end
    if self.follow_target then
        self:StartIntervalThink(0.03)
    end
end

function modifier_papich_w_thinker:OnIntervalThink()
    if not IsServer() then return end

    if not self.follow_target or self.follow_target:IsNull() or not self.follow_target:IsAlive() then
        self:StartIntervalThink(-1)
        return
    end

    self.center = self.follow_target:GetAbsOrigin()
    if self:GetParent() and not self:GetParent():IsNull() then
        self:GetParent():SetAbsOrigin(self.center)
    end
end

function modifier_papich_w_thinker:IsAura() return true end
function modifier_papich_w_thinker:GetAuraRadius() return self.radius end
function modifier_papich_w_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_papich_w_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_papich_w_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_papich_w_thinker:GetAuraDuration() return 0.3 end
function modifier_papich_w_thinker:GetModifierAura() return "modifier_papich_w_enemy" end

function modifier_papich_w_thinker:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if caster and not caster:IsNull() then
        local buff = caster:FindModifierByName("modifier_papich_w_caster")
        if buff and not buff:IsNull() and buff.SetTotals then
            buff:SetTotals(0, 0)
        end
    end
    if self:GetParent() and not self:GetParent():IsNull() then
        UTIL_Remove(self:GetParent())
    end
end


modifier_papich_w_enemy = class({})

function modifier_papich_w_enemy:IsDebuff() return true end
function modifier_papich_w_enemy:IsPurgable() return true end

function modifier_papich_w_enemy:OnCreated()
    self.as_slow     = 0
    self.ms_slow     = 0
    self.stolen_int  = 0

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
        if IsServer() then self:Destroy() end
        return
    end

    self.as_slow = ability:GetSpecialValueFor("attack_speed_bonus")
    self.ms_slow = ability:GetSpecialValueFor("slow")

    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = ability:GetCaster()
    if not parent or parent:IsNull() or not caster or caster:IsNull() then
        self:Destroy()
        return
    end

    local pct = ability:GetSpecialValueFor("intellect_steal_pct") or 0

    if not parent:IsHero() or parent:IsIllusion() then
        self.stolen_int = 0
        return
    end

    local base_str = parent:GetStrength()
    self.stolen_int = math.floor(base_str * pct * 0.01 + 0.5)

    self._caster_buff = caster:FindModifierByName("modifier_papich_w_caster")
    if self._caster_buff and not self._caster_buff:IsNull() then
        self._caster_buff:AddContribution(self.stolen_int, 0)
    end
end

function modifier_papich_w_enemy:OnDestroy()
    if not IsServer() then return end
    if self._caster_buff and not self._caster_buff:IsNull() then
        self._caster_buff:RemoveContribution(self.stolen_int, 0)
    end
end

function modifier_papich_w_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_papich_w_enemy:GetModifierAttackSpeedBonus_Constant()
    return -(self.as_slow or 0)
end

function modifier_papich_w_enemy:GetModifierMoveSpeedBonus_Percentage()
    return -(self.ms_slow or 0)
end

function modifier_papich_w_enemy:GetModifierBonusStats_Intellect()
    return -(self.stolen_int or 0)
end


modifier_papich_w_caster = class({})

function modifier_papich_w_caster:OnCreated(kv)
    local ability = self:GetAbility()
    self.as = ability and ability:GetSpecialValueFor("attack_speed_bonus") or 0
    self.ms = ability and ability:GetSpecialValueFor("slow") or 0

    self.center = Vector(
        tonumber(kv.center_x or 0),
        tonumber(kv.center_y or 0),
        tonumber(kv.center_z or 0)
    )
    self.radius = tonumber(kv.radius or 0)

    self.total_int = 0
    self.total_str = 0

    self.follow_target = nil
    if kv.follow_ent ~= nil then
        local idx = tonumber(kv.follow_ent)
        if idx then
            local ent = EntIndexToHScript(idx)
            if ent and not ent:IsNull() then
                self.follow_target = ent
            end
        end
    end

    self.has_scepter = ability
        and ability:GetCaster()
        and ability:GetCaster():HasScepter()
        or false

    self._inside    = false
    self._victims   = 0
    self._has_bonus = false

    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        self._txData = self._txData or {}
        self:StartIntervalThink(0.2)
        self:SendBuffRefreshToClients()
    end
end


function modifier_papich_w_caster:IsInside()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end
    return (parent:GetAbsOrigin() - self.center):Length2D() <= (self.radius or 0)
end

function modifier_papich_w_caster:SetTotals(int_total, str_total)
    self.total_int = int_total or 0
    self.total_str = str_total or 0
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            parent:CalculateStatBonus(true)
        end
        self:SendBuffRefreshToClients()
    end
end

function modifier_papich_w_caster:CountVictims()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return 0 end
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        self.center, nil, self.radius or 0,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )
    local c = 0
    for _,u in ipairs(enemies) do
        if u and not u:IsNull() and u:IsAlive() and not u:IsOutOfGame() and not u:IsIllusion() then
            c = c + 1
        end
    end
    return c
end

function modifier_papich_w_caster:OnIntervalThink()
    if self.follow_target and not self.follow_target:IsNull() and self.follow_target:IsAlive() then
        self.center = self.follow_target:GetAbsOrigin()
    end

    local inside   = self:IsInside()
    local victims  = inside and self:CountVictims() or 0
    local has_bonus= inside and (victims > 0)

    if self.has_scepter then
        local ability = self:GetAbility()
        local parent  = self:GetParent()
        if ability and not ability:IsNull() and parent and not parent:IsNull() then
            local pull_radius = ability:GetSpecialValueFor("pull_radius") or self.radius or 0

            local enemies = FindUnitsInRadius(
                parent:GetTeamNumber(),
                self.center,
                nil,
                pull_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                FIND_ANY_ORDER,
                false
            )

            for _,enemy in ipairs(enemies) do
                if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsDebuffImmune() then
                    enemy:AddNewModifier(
                        parent,
                        ability,
                        "modifier_papich_w_pull",
                        {
                            duration = 0.25,
                            center_x = self.center.x,
                            center_y = self.center.y,
                            center_z = self.center.z,
                        }
                    )
                end
            end
        end
    end

    if inside ~= self._inside or victims ~= self._victims or has_bonus ~= self._has_bonus then
        self._inside   = inside
        self._victims  = victims
        self._has_bonus= has_bonus
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            parent:CalculateStatBonus(true)
        end
        self:SendBuffRefreshToClients()
    end
end

function modifier_papich_w_caster:AddContribution(int_gain, str_gain)
    self.total_int = (self.total_int or 0) + (int_gain or 0)
    self.total_str = (self.total_str or 0) + (str_gain or 0)
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then parent:CalculateStatBonus(true) end
        self:SendBuffRefreshToClients()
    end
end

function modifier_papich_w_caster:RemoveContribution(int_gain, str_gain)
    self.total_int = math.max(0, (self.total_int or 0) - (int_gain or 0))
    self.total_str = math.max(0, (self.total_str or 0) - (str_gain or 0))
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then parent:CalculateStatBonus(true) end
        self:SendBuffRefreshToClients()
    end
end

function modifier_papich_w_caster:AddCustomTransmitterData()
    self._txData = self._txData or {}
    local t = self._txData

    t.as = self.as or 0
    t.ms = self.ms or 0

    t.cx = self.center and self.center.x or 0
    t.cy = self.center and self.center.y or 0
    t.cz = self.center and self.center.z or 0

    t.r  = self.radius or 0

    t.ti = self.total_int or 0
    t.ts = self.total_str or 0

    t.hs = self.has_scepter and 1 or 0
    t.in_ = self._inside and 1 or 0
    t.vb = self._has_bonus and 1 or 0

    return t
end

function modifier_papich_w_caster:HandleCustomTransmitterData(d)
    self.as, self.ms = d.as or 0, d.ms or 0
    self.center = Vector(d.cx or 0, d.cy or 0, d.cz or 0)
    self.radius = d.r or 0
    self.total_int, self.total_str = d.ti or 0, d.ts or 0
    self.has_scepter = (d.hs == 1)
    self._inside = (d.in_ == 1)
    self._has_bonus = (d.vb == 1)
end

function modifier_papich_w_caster:IsHidden()
    return not self._inside
end

function modifier_papich_w_caster:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
end

function modifier_papich_w_caster:GetModifierAttackSpeedBonus_Constant()
    return (self._has_bonus and self.as) or 0
end

function modifier_papich_w_caster:GetModifierMoveSpeedBonus_Percentage()
    return (self._has_bonus and self.ms) or 0
end

function modifier_papich_w_caster:GetModifierBonusStats_Intellect()
    if not self._inside then return 0 end
    return self.total_int or 0
end

function modifier_papich_w_caster:GetModifierEvasion_Constant(params)
    if not params or not params.attacker then return 0 end
    if not self._inside then return 0 end
    local dist = (params.attacker:GetAbsOrigin() - self.center):Length2D()
    if dist > (self.radius or 0) then
        local ability = self:GetAbility()
        return ability and ability:GetSpecialValueFor("evasion_chance") or 0
    end
    return 0
end

modifier_papich_w_pull = class({})

function modifier_papich_w_pull:IsHidden()      return true end
function modifier_papich_w_pull:IsDebuff()      return true  end
function modifier_papich_w_pull:IsStunDebuff()  return true  end
function modifier_papich_w_pull:IsPurgable()    return false  end

function modifier_papich_w_pull:OnCreated(kv)
    if not IsServer() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
        self:Destroy()
        return
    end

    self.pull_speed = ability:GetSpecialValueFor("pull_speed") or 0

    self.center = Vector(
        tonumber(kv.center_x or 0),
        tonumber(kv.center_y or 0),
        tonumber(kv.center_z or 0)
    )

    self:StartIntervalThink(FrameTime())
end

function modifier_papich_w_pull:OnRefresh(kv)
    if not IsServer() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
        self:Destroy()
        return
    end

    self.center = Vector(
        tonumber(kv.center_x or 0),
        tonumber(kv.center_y or 0),
        tonumber(kv.center_z or 0)
    )
end

function modifier_papich_w_pull:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then
        self:Destroy()
        return
    end

    local direction = self.center - parent:GetAbsOrigin()
    direction.z = 0
    if direction:Length2D() < 200 then return end

    direction = direction:Normalized()
    local point = parent:GetAbsOrigin() + direction * self.pull_speed * FrameTime()

    parent:SetAbsOrigin(point)
end

function modifier_papich_w_pull:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        if not parent:IsOutOfGame() and not parent:IsInvulnerable() then
            FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        end
    end
end

modifier_papich_w_ally = class({})

function modifier_papich_w_ally:IsHidden()      return false end
function modifier_papich_w_ally:IsDebuff()      return false end
function modifier_papich_w_ally:IsPurgable()    return true  end

function modifier_papich_w_ally:OnCreated(kv)
    self.caster     = self:GetCaster()
    self.ability    = self:GetAbility()

    self:SetHasCustomTransmitterData(true)
    self._txData = self._txData or {}
    if IsServer() then
        self:StartIntervalThink(0.2)
        self:SendBuffRefreshToClients()
    end
end

function modifier_papich_w_ally:OnRefresh(kv)
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()
end

function modifier_papich_w_ally:OnIntervalThink()
    if not IsServer() then return end

    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end

    local buff = self.caster:FindModifierByName("modifier_papich_w_caster")
    if not buff or buff:IsNull() then
        self.as        = 0
        self.ms        = 0
        self.total_int = 0
    else
        self.as        = buff.as or 0
        self.ms        = buff.ms or 0
        self.total_int = buff.total_int or 0
    end

    self:SendBuffRefreshToClients()
end

function modifier_papich_w_ally:AddCustomTransmitterData()
    self._txData = self._txData or {}
    local t = self._txData

    t.as = self.as or 0
    t.ms = self.ms or 0
    t.ti = self.total_int or 0

    return t
end

function modifier_papich_w_ally:HandleCustomTransmitterData(data)
    self.as        = data.as or 0
    self.ms        = data.ms or 0
    self.total_int = data.ti or 0
end

function modifier_papich_w_ally:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_papich_w_ally:GetModifierAttackSpeedBonus_Constant()
    if (self.total_int or 0) <= 0 then
        return 0
    end
    return self.as or 0
end

function modifier_papich_w_ally:GetModifierMoveSpeedBonus_Percentage()
    if (self.total_int or 0) <= 0 then
        return 0
    end
    return self.ms or 0
end

function modifier_papich_w_ally:GetModifierBonusStats_Intellect()
    return self.total_int or 0
end