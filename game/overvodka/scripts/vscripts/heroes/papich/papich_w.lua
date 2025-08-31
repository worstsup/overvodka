LinkLuaModifier("modifier_papich_w_thinker", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_enemy",   "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_caster",  "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)

papich_w = class({})

function papich_w:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function papich_w:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_magnetic_cast.vpcf", ctx)
    PrecacheResource("particle", "particles/papich_w.vpcf", ctx)
    PrecacheResource("soundfile","soundevents/papich_w.vsndevts", ctx)
end

function papich_w:OnSpellStart()
    local caster = self:GetCaster()
    local pos    = self:GetCursorPosition()
    local dur    = self:GetSpecialValueFor("duration")
    local rad    = self:GetSpecialValueFor("radius")

    caster:EmitSound("papich_w")
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_magnetic_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)

    caster:AddNewModifier(caster, self, "modifier_papich_w_caster", {
        duration = dur,
        center_x = pos.x, center_y = pos.y, center_z = pos.z,
        radius   = rad
    })

    CreateModifierThinker(caster, self, "modifier_papich_w_thinker",
        { duration = dur, radius = rad }, pos, caster:GetTeamNumber(), false)
end


modifier_papich_w_thinker = class({})

function modifier_papich_w_thinker:IsHidden() return true end
function modifier_papich_w_thinker:IsPurgable() return false end

function modifier_papich_w_thinker:OnCreated(kv)
    self.radius = tonumber(kv.radius or 0)
    if not IsServer() then return end

    self.center  = self:GetParent():GetAbsOrigin()

    local fx = ParticleManager:CreateParticle("particles/papich_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 1, 1))
    self:AddParticle(fx, false, false, -1, false, false)
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
    self.as_slow, self.ms_slow = 0, 0
    self.stolen_int, self.stolen_str = 0, 0
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then if IsServer() then self:Destroy() end return end

    self.as_slow = ability:GetSpecialValueFor("attack_speed_bonus")
    self.ms_slow = ability:GetSpecialValueFor("slow")

    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = ability:GetCaster()
    if not parent or parent:IsNull() or not caster or caster:IsNull() then self:Destroy() return end
	
    local pct = ability:GetSpecialValueFor("intellect_steal_pct")
	if not parent:IsHero() or parent:IsIllusion() then
		self.stolen_int, self.stolen_str = 0, 0
		return
	end
    if parent:IsHero() and not parent:IsIllusion() then
        local base_str = parent:GetStrength()
        self.stolen_int = math.floor(base_str * pct * 0.01 + 0.5)
        if caster:HasScepter() then
            self.stolen_str = math.floor(base_str * pct * 0.01 + 0.5)
        end
    end
	print(self.stolen_int)
    self._caster_buff = caster:FindModifierByName("modifier_papich_w_caster")
    if self._caster_buff and not self._caster_buff:IsNull() then
        self._caster_buff:AddContribution(self.stolen_int, self.stolen_str)
    end
end

function modifier_papich_w_enemy:OnDestroy()
    if not IsServer() then return end
    if self._caster_buff and not self._caster_buff:IsNull() then
        self._caster_buff:RemoveContribution(self.stolen_int, self.stolen_str)
    end
end

function modifier_papich_w_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_papich_w_enemy:GetModifierAttackSpeedBonus_Constant() return -(self.as_slow or 0) end
function modifier_papich_w_enemy:GetModifierMoveSpeedBonus_Percentage()  return -(self.ms_slow or 0) end
function modifier_papich_w_enemy:GetModifierBonusStats_Intellect()       return -(self.stolen_int or 0) end
function modifier_papich_w_enemy:GetModifierBonusStats_Strength()        return -(self.stolen_str or 0) end


modifier_papich_w_caster = class({})

function modifier_papich_w_caster:OnCreated(kv)
    local ability = self:GetAbility()
    self.as = ability and ability:GetSpecialValueFor("attack_speed_bonus") or 0
    self.ms = ability and ability:GetSpecialValueFor("slow") or 0
    self.center = Vector(tonumber(kv.center_x or 0), tonumber(kv.center_y or 0), tonumber(kv.center_z or 0))
    self.radius = tonumber(kv.radius or 0)
    self.total_int, self.total_str = 0, 0
    self.has_scepter = (ability and ability:GetCaster() and ability:GetCaster():HasScepter()) or false

    self._inside = false
    self._victims = 0
    self._has_bonus = false

    if IsServer() then
        self:SetHasCustomTransmitterData(true)
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
    local inside   = self:IsInside()
    local victims  = inside and self:CountVictims() or 0
    local has_bonus= inside and (victims > 0)

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
    return {
        as = self.as or 0, ms = self.ms or 0,
        cx = self.center.x or 0, cy = self.center.y or 0, cz = self.center.z or 0,
        r  = self.radius or 0,
        ti = self.total_int or 0,
        ts = self.total_str or 0,
        hs = self.has_scepter and 1 or 0,
        in_ = self._inside and 1 or 0,
        vb = self._has_bonus and 1 or 0,
    }
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
    local from_str = (self.has_scepter and math.floor((self.total_str or 0) * 0.5 + 0.5) or 0)
    return (self.total_int or 0) + from_str
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