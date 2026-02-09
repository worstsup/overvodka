LinkLuaModifier( "modifier_amor_q",               "heroes/amor/amor_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_amor_q_trail_thinker", "heroes/amor/amor_q", LUA_MODIFIER_MOTION_NONE )

amor_q = class({})

function amor_q:Precache( ctx )
    PrecacheResource( "soundfile", "soundevents/amor_sounds.vsndevts", ctx )
    PrecacheResource( "particle", "particles/units/heroes/hero_slardar/slardar_sprint.vpcf", ctx )
    PrecacheResource( "particle", "particles/amor_q_trail.vpcf", ctx )
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_self_attack.vpcf", ctx )
end

function amor_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    caster:AddNewModifier( caster, self, "modifier_amor_q", { duration = self:GetSpecialValueFor( "duration" ) } )
    caster:EmitSound("amor_q")
end

modifier_amor_q = class({})

function modifier_amor_q:IsHidden() return false end
function modifier_amor_q:IsDebuff() return false end
function modifier_amor_q:IsPurgable() return true end

function modifier_amor_q:OnCreated()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.bonus_speed = ability:GetSpecialValueFor("bonus_speed") or 0
    self.has_facet = (ability:GetSpecialValueFor("has_facet") or 0)

    self.trail_duration = ability:GetSpecialValueFor("trail_duration") or 0
    self.trail_interval = 0.2
    self.trail_min_distance = 80

    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local ult = caster:FindAbilityByName("amor_ultimate")
    if (not ult or ult:IsNull()) or (ult:GetLevel() <= 0) then
        self.has_facet = 0
    end

    self.mod = caster:AddNewModifier(caster, ability, "modifier_item_vindicators_axe", {})

    if self.has_facet == 1 then
        self._last_drop = caster:GetAbsOrigin()
        self:StartIntervalThink(self.trail_interval)
        self:_DropTrail()
    end
end

function modifier_amor_q:OnRefresh()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.bonus_speed = ability:GetSpecialValueFor("bonus_speed") or 0
end

function modifier_amor_q:OnDestroy()
    if not IsServer() then return end
    if self.mod and not self.mod:IsNull() then
        self.mod:Destroy()
    end
end

function modifier_amor_q:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_amor_q:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_speed or 0
end

function modifier_amor_q:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_amor_q:GetEffectName()
    return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end

function modifier_amor_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_amor_q:OnIntervalThink()
    if not IsServer() then return end
    self:_DropTrail()
end

function modifier_amor_q:_DropTrail()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if not caster or caster:IsNull() then return end
    if not ability or ability:IsNull() then return end

    local pos = caster:GetAbsOrigin()

    if self._last_drop then
        local dv = pos - self._last_drop
        dv.z = 0
        if dv:Length2D() < (self.trail_min_distance or 0) then
            return
        end
    end

    self._last_drop = pos

    CreateModifierThinker(
        caster,
        ability,
        "modifier_amor_q_trail_thinker",
        { duration = self.trail_duration },
        GetGroundPosition(pos, caster),
        caster:GetTeamNumber(),
        false
    )
end

modifier_amor_q_trail_thinker = class({})

function modifier_amor_q_trail_thinker:IsHidden() return true end
function modifier_amor_q_trail_thinker:IsPurgable() return false end

function modifier_amor_q_trail_thinker:OnCreated()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    self.radius = ability:GetSpecialValueFor("trail_radius") or 200
    self.apply_interval = 0.1
    self.debuff_dur = 1

    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local p = ParticleManager:CreateParticle("particles/amor_q_trail.vpcf", PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, Vector(200,200,200))
    self:AddParticle(p, false, false, -1, false, false)

	if RandomInt(1, 2) == 1 then
		local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_self_attack.vpcf", PATTACH_ABSORIGIN, parent)
		ParticleManager:SetParticleControl(p2, 0, parent:GetAbsOrigin())
		self:AddParticle(p2, false, false, -1, false, false)
	end

    self:StartIntervalThink(self.apply_interval)
end

function modifier_amor_q_trail_thinker:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local parent = self:GetParent()
    local q_ability = self:GetAbility()
    if not caster or caster:IsNull() then return end
    if not parent or parent:IsNull() then return end
    if not q_ability or q_ability:IsNull() then return end

    local ult = caster:FindAbilityByName("amor_ultimate")
    if not ult or ult:IsNull() or (ult:GetLevel() or 0) <= 0 then
        return
    end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), parent:GetAbsOrigin(),
		nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            enemy:AddNewModifier(caster, ult, "modifier_amor_ultimate_beer", { duration = self.debuff_dur * (1 - enemy:GetStatusResistance()), dps = ult:GetSpecialValueFor("beer_dps") })
        end
    end
end
