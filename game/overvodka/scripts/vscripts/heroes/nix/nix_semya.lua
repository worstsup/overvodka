LinkLuaModifier( "modifier_nix_semya_debuff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nix_semya_steal_debuff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nix_semya_steal_buff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)

nix_semya = class({}) 

function nix_semya:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function nix_semya:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function nix_semya:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function nix_semya:Precache(context)
	PrecacheResource("particle", "particles/nix_w.vpcf", context)
	PrecacheResource("particle", "particles/pravin_nix_w.vpcf", context)
	PrecacheResource("soundfile", "soundevents/semya.vsndevts", context)
end

function nix_semya:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("semya")
    self.modifier = target:AddNewModifier( self:GetCaster(), self, "modifier_nix_semya_debuff", { duration = duration } )
end

modifier_nix_semya_debuff = class({})

function modifier_nix_semya_debuff:IsPurgable() return false end

function modifier_nix_semya_debuff:GetCurrentParticleName()
    local caster = self:GetCaster()
    if caster and not caster:IsNull() and caster:HasModifier("modifier_nix_swap_pravin") then
        return "particles/pravin_nix_w.vpcf"
    end

    return "particles/nix_w.vpcf"
end

function modifier_nix_semya_debuff:RefreshParticle()
    if not IsServer() then return end

    local particle_name = self:GetCurrentParticleName()
    if self.current_particle_name == particle_name then return end

    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    self.particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), true)
    self.current_particle_name = particle_name
end

function modifier_nix_semya_debuff:ApplySemyaTick()
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local damage = self:GetAbility():GetSpecialValueFor("dps")
    local damage_steal = self:GetAbility():GetSpecialValueFor("damage_steal")
    local magresist = self:GetAbility():GetSpecialValueFor("magresist")
    local ms = self:GetAbility():GetSpecialValueFor("ms")

    if damage > 0 then
        ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
    end

    if self:GetParent() and not self:GetParent():IsNull() and not self:GetParent():IsDebuffImmune() then
        local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_buff", { duration = duration })
        if buff then
            buff:AddStack({
                damage = damage_steal,
                magresist = magresist,
                ms = ms,
            })
        end

        local debuff = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_debuff", { duration = duration })
        if debuff then
            debuff:AddStack({
                damage = damage_steal,
                magresist = magresist,
                ms = ms,
            })
        end
    end
end

function modifier_nix_semya_debuff:OnCreated()
    if not IsServer() then return end
    self.logic_interval = 1
    self.next_logic_time = GameRules:GetGameTime() + self.logic_interval

    self:ApplySemyaTick()
    self:RefreshParticle()
    self:StartIntervalThink(0.1)
end

function modifier_nix_semya_debuff:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
    local caster = self:GetCaster()
    if caster and not caster:IsNull() then
        caster:StopSound("semya")
    end
end

function modifier_nix_semya_debuff:OnIntervalThink()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("break_distance")

    self:RefreshParticle()

    if self:GetParent():IsInvulnerable() or self:GetParent():IsIllusion() or ( not self:GetCaster():IsAlive()) then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > radius then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    local game_time = GameRules:GetGameTime()
    while game_time >= (self.next_logic_time or 0) do
        self:ApplySemyaTick()
        self.next_logic_time = (self.next_logic_time or game_time) + self.logic_interval
    end
end

modifier_nix_semya_steal_buff = class ({})

function modifier_nix_semya_steal_buff:IsPurgable() return false end

function modifier_nix_semya_steal_buff:OnCreated()
    self.damage_total = 0
    self.magresist_total = 0
    self.ms_total = 0
    self._txData = self._txData or {}

    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
end

function modifier_nix_semya_steal_buff:AddCustomTransmitterData()
    self._txData.damage_total = self.damage_total or 0
    self._txData.magresist_total = self.magresist_total or 0
    self._txData.ms_total = self.ms_total or 0
    return self._txData
end

function modifier_nix_semya_steal_buff:HandleCustomTransmitterData(data)
    if not data then return end
    self.damage_total = tonumber(data.damage_total) or 0
    self.magresist_total = tonumber(data.magresist_total) or 0
    self.ms_total = tonumber(data.ms_total) or 0
end

function modifier_nix_semya_steal_buff:AddStack(values)
    if not IsServer() then return end
    values = values or {}

    self.damage_total = (self.damage_total or 0) + (tonumber(values.damage) or 0)
    self.magresist_total = (self.magresist_total or 0) + (tonumber(values.magresist) or 0)
    self.ms_total = (self.ms_total or 0) + (tonumber(values.ms) or 0)

    self:SetStackCount((self:GetStackCount() or 0) + 1)
    self:SendBuffRefreshToClients()
end

function modifier_nix_semya_steal_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_nix_semya_steal_buff:GetModifierMagicalResistanceBonus()
    return self.magresist_total or 0
end

function modifier_nix_semya_steal_buff:GetModifierPreAttack_BonusDamage()
	return self.damage_total or 0
end

function modifier_nix_semya_steal_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_total or 0
end

modifier_nix_semya_steal_debuff = class ({})

function modifier_nix_semya_steal_debuff:OnCreated()
    self.damage_total = 0
    self.magresist_total = 0
    self.ms_total = 0
    self._txData = self._txData or {}

    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
end

function modifier_nix_semya_steal_debuff:AddCustomTransmitterData()
    self._txData.damage_total = self.damage_total or 0
    self._txData.magresist_total = self.magresist_total or 0
    self._txData.ms_total = self.ms_total or 0
    return self._txData
end

function modifier_nix_semya_steal_debuff:HandleCustomTransmitterData(data)
    if not data then return end
    self.damage_total = tonumber(data.damage_total) or 0
    self.magresist_total = tonumber(data.magresist_total) or 0
    self.ms_total = tonumber(data.ms_total) or 0
end

function modifier_nix_semya_steal_debuff:AddStack(values)
    if not IsServer() then return end
    values = values or {}

    self.damage_total = (self.damage_total or 0) + (tonumber(values.damage) or 0)
    self.magresist_total = (self.magresist_total or 0) + (tonumber(values.magresist) or 0)
    self.ms_total = (self.ms_total or 0) + (tonumber(values.ms) or 0)

    self:SetStackCount((self:GetStackCount() or 0) + 1)
    self:SendBuffRefreshToClients()
end

function modifier_nix_semya_steal_debuff:IsPurgable() return false end

function modifier_nix_semya_steal_debuff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return declfuncs
end

function modifier_nix_semya_steal_debuff:GetModifierMagicalResistanceBonus()
    return -(self.magresist_total or 0)
end

function modifier_nix_semya_steal_debuff:GetModifierPreAttack_BonusDamage()
	return -(self.damage_total or 0)
end

function modifier_nix_semya_steal_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -(self.ms_total or 0)
end