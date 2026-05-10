LinkLuaModifier("modifier_cheaters_glasses", "items/cheaters_glasses", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cheaters_glasses_active", "items/cheaters_glasses", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cheaters_glasses_debuff", "items/cheaters_glasses", LUA_MODIFIER_MOTION_NONE)

cheaters_glasses = class({})

function cheaters_glasses:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", context)
end

function cheaters_glasses:GetIntrinsicModifierName()
    return "modifier_cheaters_glasses"
end

function cheaters_glasses:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("invis_duration")
    local delay = self:GetSpecialValueFor("invis_delay")
    Timers:CreateTimer(delay, function()
        if not IsValid(self, caster) then return end
        caster:AddNewModifier(caster, self, "modifier_cheaters_glasses_active", {duration = duration})
    end)
    EmitSoundOn("Item.GlimmerCape.Activate", caster)
end

function cheaters_glasses:QueueInvisAttack(attacker, target, record, damage, debuff_duration)
    if not IsServer() then return end
    if not record or record == -1 then return end
    if not IsValid(attacker, target) then return end

    self.invis_attack_records = self.invis_attack_records or {}
    self.invis_attack_records[record] = {
        attacker = attacker,
        target = target,
        damage = damage,
        debuff_duration = debuff_duration,
    }
end

function cheaters_glasses:ConsumeInvisAttack(params)
    if not IsServer() then return end
    if not params.record or not self.invis_attack_records then return end

    local record_data = self.invis_attack_records[params.record]
    self.invis_attack_records[params.record] = nil

    if not record_data then return end
    if not IsValid(record_data.attacker, record_data.target) then return end
    if params.attacker ~= record_data.attacker then return end
    if params.target ~= record_data.target then return end

    return record_data
end

function cheaters_glasses:ClearInvisAttackRecord(record)
    if not IsServer() then return end
    if not record or not self.invis_attack_records then return end
    self.invis_attack_records[record] = nil
end


modifier_cheaters_glasses_active = class({})

function modifier_cheaters_glasses_active:IsHidden() return false end
function modifier_cheaters_glasses_active:IsPurgable() return false end

function modifier_cheaters_glasses_active:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self:OnRefresh()
    if not IsServer() then return end
    self.p = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    self:AddParticle(self.p, false, false, -1, false, false)
end

function modifier_cheaters_glasses_active:OnRefresh()
    if not self.ability then return end
    self.movespeed = self.ability:GetSpecialValueFor("bonus_movement_speed")
    self.damage = self.ability:GetSpecialValueFor("invis_damage")
    self.debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")
end

function modifier_cheaters_glasses_active:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_cheaters_glasses_active:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_cheaters_glasses_active:OnAbilityExecuted(params)
	if not IsServer() then return end
	if params.unit~=self.parent then return end
	self:Destroy()
end

function modifier_cheaters_glasses_active:OnAttack(params)
	if not IsServer() then return end
	if params.attacker~=self.parent then return end
    if not IsValid(self.ability, params.target) then return end

    self.ability:QueueInvisAttack(self.parent, params.target, params.record, self.damage, self.debuff_duration)
	self:Destroy()
end

function modifier_cheaters_glasses_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_cheaters_glasses_active:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end


modifier_cheaters_glasses_debuff = class({})

function modifier_cheaters_glasses_debuff:IsHidden() return false end
function modifier_cheaters_glasses_debuff:IsDebuff() return true end
function modifier_cheaters_glasses_debuff:IsPurgable() return true end

function modifier_cheaters_glasses_debuff:CheckState()
    return {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

function modifier_cheaters_glasses_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
    }
end

function modifier_cheaters_glasses_debuff:GetModifierProvidesFOWVision()
    return 1
end

function modifier_cheaters_glasses_debuff:OnCreated()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_cheaters_glasses_debuff:OnIntervalThink()
    if not IsServer() then return end
    if not IsValid(self.parent, self.caster, self.ability) or not self.parent:IsAlive() then
        self:Destroy()
        return
    end

    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), 150, 0.15, false)
    self.parent:AddNewModifier(self.caster, self.ability, "modifier_truesight", {duration = 0.15})
end


modifier_cheaters_glasses = class({})

function modifier_cheaters_glasses:IsHidden() return true end
function modifier_cheaters_glasses:IsPurgable() return false end
function modifier_cheaters_glasses:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_cheaters_glasses:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self:OnRefresh()
    if not IsServer() then return end
    self.crosshair_particles = {}
    self:StartIntervalThink(0.1)
end

function modifier_cheaters_glasses:OnRefresh()
    if not self.ability then return end
    self.damage = self.ability:GetSpecialValueFor("bonus_damage")
    self.attack_speed = self.ability:GetSpecialValueFor("bonus_attack_speed")
    self.radius = self.ability:GetSpecialValueFor("true_sight_radius")
end

function modifier_cheaters_glasses:DestroyCrosshairParticle(enemy)
    if not self.crosshair_particles or not self.crosshair_particles[enemy] then return end

    ParticleManager:DestroyParticle(self.crosshair_particles[enemy], false)
    ParticleManager:ReleaseParticleIndex(self.crosshair_particles[enemy])
    self.crosshair_particles[enemy] = nil
end

function modifier_cheaters_glasses:DestroyAllCrosshairParticles()
    if not self.crosshair_particles then return end

    for enemy,_ in pairs(self.crosshair_particles) do
        self:DestroyCrosshairParticle(enemy)
    end
end

function modifier_cheaters_glasses:OnIntervalThink()
    if not IsServer() then return end
    if not IsValid(self.ability, self.parent) then
        self:DestroyAllCrosshairParticles()
        self:Destroy()
        return
    end
    if self.parent:IsIllusion() then return end

    local active_crosshairs = {}
    local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,enemy in pairs(enemies) do
        local was_invisible = enemy:IsInvisible()
        enemy:AddNewModifier(self.parent, self.ability, "modifier_truesight", {duration = 0.15})
        if was_invisible then
            active_crosshairs[enemy] = true
            if not self.crosshair_particles[enemy] then
                self.crosshair_particles[enemy] = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", PATTACH_OVERHEAD_FOLLOW, enemy, self.parent:GetTeamNumber())
            end
        end
    end

    for enemy,_ in pairs(self.crosshair_particles) do
        if not active_crosshairs[enemy] then
            self:DestroyCrosshairParticle(enemy)
        end
    end
end

function modifier_cheaters_glasses:OnDestroy()
    if not IsServer() then return end
    self:DestroyAllCrosshairParticles()
end

function modifier_cheaters_glasses:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
    }
end

function modifier_cheaters_glasses:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self.parent then return end
    if not IsValid(self.ability) then return end

    local record_data = self.ability:ConsumeInvisAttack(params)
    if not record_data then return end

    params.target:AddNewModifier(self.parent, self.ability, "modifier_cheaters_glasses_debuff", {duration = record_data.debuff_duration})
    ApplyDamage({victim = params.target, attacker = self.parent, damage = record_data.damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self.ability})
end

function modifier_cheaters_glasses:OnAttackFail(params)
    if not IsServer() then return end
    if params.attacker ~= self.parent then return end
    if not IsValid(self.ability) then return end
    self.ability:ClearInvisAttackRecord(params.record)
end

function modifier_cheaters_glasses:OnAttackRecordDestroy(params)
    if not IsServer() then return end
    if not IsValid(self.ability) then return end
    self.ability:ClearInvisAttackRecord(params.record)
end

function modifier_cheaters_glasses:GetModifierPreAttack_BonusDamage()
    if not self.ability then return end
    return self.damage
end

function modifier_cheaters_glasses:GetModifierAttackSpeedBonus_Constant()
    if not self.ability then return end
    return self.attack_speed
end
