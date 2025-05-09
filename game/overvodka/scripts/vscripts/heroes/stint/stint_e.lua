LinkLuaModifier( "modifier_inator_stint",       "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_1",           "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_2",           "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_2_debuff",    "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_3",           "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_3_debuff",    "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_4",           "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_4_buff",      "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_5",           "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_5_buff",      "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_slow_aura",   "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_inator_slow_effect", "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )

stint_e = class({})

function stint_e:Precache(context)
    PrecacheResource("model", "models/stint/inator.vmdl", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ringmaster/ringmaster_wheel_destroy.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ringmaster/ringmaster_wheel_aoe.vpcf", context)
    PrecacheResource("particle", "particles/stint_inator_fire.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff_fire.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/naga/naga_ti10_immortal_head/naga_ti10_immortal_song_debuff.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_siren_song.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/naga/naga_ti10_immortal_head/naga_ti10_immortal_song_cast.vpcf", context)
    PrecacheResource("particle", "particles/stint_inator_sleep.vpcf", context)
    PrecacheResource("particle", "particles/stint_inator_invis.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_combined_v2_crimson.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_walk_v2_core_perturb.vpcf", context)
    PrecacheResource("particle", "particles/stint_inator_cooldown.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf", context)
    PrecacheResource("soundfile", "soundevents/inators.vsndevts", context)
end

function stint_e:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function stint_e:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stint_e:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stint_e:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function stint_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local inators = self:GetSpecialValueFor("inators")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local chance = self:GetSpecialValueFor("chance")
    local inator = CreateUnitByName("npc_inator", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    inator:SetControllableByPlayer(playerID, true)
    inator:SetOwner(caster)
    inator:AddNewModifier( self:GetCaster(), self, "modifier_inator_stint", {} )
    inator:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    inator:SetMaximumGoldBounty(gold)
    inator:SetMinimumGoldBounty(gold)
    inator:SetDeathXP(xp)
    local random_modifier = RandomInt(1, inators)
    inator:AddNewModifier(self:GetCaster(), self, "modifier_inator_"..random_modifier, {})
    if self:GetSpecialValueFor("slow") ~= 0 then
        inator:AddNewModifier(self:GetCaster(), self, "modifier_inator_slow_aura", {})
    end
    if self:GetCaster():HasScepter() then
        local random_modifier2 = random_modifier
        while random_modifier2 == random_modifier do
            random_modifier2 = RandomInt(1, inators)
        end
        inator:AddNewModifier(self:GetCaster(), self, "modifier_inator_"..random_modifier2, {})
    end
    EmitSoundOnLocationWithCaster(inator:GetAbsOrigin(), "inator_deploy", caster)
    EmitSoundOn("inator_"..random_modifier, caster)
    if RandomInt(1, 100) <= chance then
        self:EndCooldown()
        local nFXIndex = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
		ParticleManager:ReleaseParticleIndex(nFXIndex)
		ParticleManager:DestroyParticle(nFXIndex, false)
		EmitSoundOn("DOTA_Item.Refresher.Activate", caster)
    end
end

modifier_inator_slow_aura = class({})
function modifier_inator_slow_aura:IsHidden() return true end
function modifier_inator_slow_aura:IsPurgable() return false end
function modifier_inator_slow_aura:OnCreated()
    if not IsServer() then return end
end

function modifier_inator_slow_aura:IsAura() return true end

function modifier_inator_slow_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_inator_slow_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_inator_slow_aura:GetModifierAura()
    return "modifier_inator_slow_effect"
end

function modifier_inator_slow_aura:GetAuraDuration()
    return 0
end

function modifier_inator_slow_aura:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_inator_slow_effect = class({})
function modifier_inator_slow_effect:IsHidden() return false end
function modifier_inator_slow_effect:IsDebuff() return true end
function modifier_inator_slow_effect:IsPurgable() return false end
function modifier_inator_slow_effect:OnCreated()
    if not IsServer() then return end
end

function modifier_inator_slow_effect:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_inator_slow_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_inator_slow_effect:GetEffectName()
    return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_inator_slow_effect:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

modifier_inator_stint = class({})

function modifier_inator_stint:OnCreated()
    if not IsServer() then return end
    self.hit_destroy = self:GetAbility():GetSpecialValueFor("hit_destroy")
    self.pct_damage = self:GetAbility():GetSpecialValueFor("pct_damage")
    self:GetParent():SetBaseMaxHealth(self.hit_destroy)
    self:GetParent():SetMaxHealth(self.hit_destroy)
    self:GetParent():SetHealth(self.hit_destroy)
end

function modifier_inator_stint:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

function modifier_inator_stint:IsHidden() return true end
function modifier_inator_stint:IsPurgable() return false end

function modifier_inator_stint:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
    }
end

function modifier_inator_stint:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return decFuncs
end

function modifier_inator_stint:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local new_health = self:GetParent():GetHealth() - 1
    if new_health <= 0 then
        self:GetParent():Kill(nil, params.attacker)
    else
        self:GetParent():SetHealth(new_health)
    end
end

function modifier_inator_stint:GetDisableHealing()
    return 1
end

function modifier_inator_stint:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_inator_stint:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_inator_stint:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_inator_stint:GetAbsoluteNoDamagePure()
    return 1
end

modifier_inator_1 = class({})
function modifier_inator_1:IsHidden() return true end
function modifier_inator_1:IsPurgable() return false end
function modifier_inator_1:OnCreated()
    if not IsServer() then return end
    self.interval = 0.5
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_ringmaster/ringmaster_wheel_destroy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_inator_1:OnIntervalThink()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_ringmaster/ringmaster_wheel_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = self:GetParent(),
            damage = self:GetAbility():GetSpecialValueFor("damage_first") * self.interval,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        })
    end
end

modifier_inator_2 = class({})
function modifier_inator_2:IsHidden() return true end
function modifier_inator_2:IsPurgable() return false end
function modifier_inator_2:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_inator_2:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    if self:GetParent():IsNull() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/stint_inator_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_inator_2:IsAura() return true end

function modifier_inator_2:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_inator_2:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_inator_2:GetModifierAura()
    return "modifier_inator_2_debuff"
end

function modifier_inator_2:GetAuraDuration()
    return self:GetAbility():GetSpecialValueFor("fire_duration")
end

function modifier_inator_2:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_inator_2_debuff = class({})
function modifier_inator_2_debuff:IsHidden() return false end
function modifier_inator_2_debuff:IsDebuff() return true end
function modifier_inator_2_debuff:IsPurgable() return false end
function modifier_inator_2_debuff:OnCreated()
    if not IsServer() then return end
    self.interval = 0.5
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_inator_2_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("damage_second") * self.interval * self:GetParent():GetMaxHealth() / 100
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })
end

function modifier_inator_2_debuff:GetEffectName()
    return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff_fire.vpcf"
end

modifier_inator_3 = class({})

function modifier_inator_3:IsHidden() return true end
function modifier_inator_3:IsPurgable() return false end

function modifier_inator_3:OnCreated(kv)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.debuff_duration = self:GetAbility():GetSpecialValueFor("duration_third")
    self.applied = {}
    self:PlayEffects()
    self:StartIntervalThink(0.2)
end

function modifier_inator_3:OnIntervalThink()
    local parent = self:GetParent()
    local team   = parent:GetTeamNumber()
    local enemies = FindUnitsInRadius(
        team,
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )
    for _,unit in ipairs(enemies) do
        local idx = unit:entindex()
        if not self.applied[idx] then
            unit:AddNewModifier(parent, self:GetAbility(), "modifier_inator_3_debuff", {duration = self.debuff_duration})
            self.applied[idx] = true
        end
    end
end

function modifier_inator_3:PlayEffects()
	local particle_cast1 = "particles/econ/items/naga/naga_ti10_immortal_head/naga_ti10_immortal_song_cast.vpcf"
	local particle_cast2 = "particles/stint_inator_sleep.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast1, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

modifier_inator_3_debuff = class({})

function modifier_inator_3_debuff:IsHidden()
	return false
end
function modifier_inator_3_debuff:IsDebuff()
	return true
end
function modifier_inator_3_debuff:IsStunDebuff()
	return false
end
function modifier_inator_3_debuff:IsPurgable()
	return false
end
function modifier_inator_3_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_inator_3_debuff:OnCreated( kv )
	self.rate = 1.5
	if not IsServer() then return end
end

function modifier_inator_3_debuff:OnRefresh( kv )
end
function modifier_inator_3_debuff:OnRemoved()
end
function modifier_inator_3_debuff:OnDestroy()
end

function modifier_inator_3_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}

	return funcs
end

function modifier_inator_3_debuff:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_inator_3_debuff:GetOverrideAnimationRate()
	return self.rate
end

function modifier_inator_3_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_inator_3_debuff:GetEffectName()
	return "particles/econ/items/naga/naga_ti10_immortal_head/naga_ti10_immortal_song_debuff.vpcf"
end

function modifier_inator_3_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_inator_3_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_inator_3_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

modifier_inator_4 = class({})
function modifier_inator_4:IsHidden() return true end
function modifier_inator_4:IsPurgable() return false end

function modifier_inator_4:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_combined_v2_crimson.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self:StartIntervalThink(0.5)
end

function modifier_inator_4:OnIntervalThink()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/stint_inator_cooldown.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_inator_4:IsAura() return true end

function modifier_inator_4:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_inator_4:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_inator_4:GetModifierAura()
    return "modifier_inator_4_buff"
end

function modifier_inator_4:GetAuraDuration()
    return 0.5
end

function modifier_inator_4:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_inator_4_buff = class({})

function modifier_inator_4_buff:IsHidden() return false end
function modifier_inator_4_buff:IsPurgable() return false end

function modifier_inator_4_buff:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_walk_v2_core_perturb.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    self.cdr_pct  = self:GetAbility():GetSpecialValueFor("cdr_fourth") * 0.01
    self.interval = 0.03
    self:StartIntervalThink(self.interval)
end

function modifier_inator_4_buff:OnRefresh()
    if not IsServer() then return end
    self.cdr_pct = self:GetAbility():GetSpecialValueFor("cdr_fourth") * 0.01
end

function modifier_inator_4_buff:OnIntervalThink()
    local parent = self:GetParent()
    for i = 0, parent:GetAbilityCount() - 1 do
        local ab = parent:GetAbilityByIndex(i)
        if ab and ab:GetCooldownTimeRemaining() > 0 then
            local rem = ab:GetCooldownTimeRemaining()
            local new_rem = math.max(0, rem - (self.interval * self.cdr_pct))
            ab:EndCooldown()
            ab:StartCooldown(new_rem)
        end
    end
    for slot = 0, 5 do
        local it = parent:GetItemInSlot(slot)
        if it and it:GetCooldownTimeRemaining() > 0 then
            local rem = it:GetCooldownTimeRemaining()
            local new_rem = math.max(0, rem - (self.interval * self.cdr_pct))
            it:EndCooldown()
            it:StartCooldown(new_rem)
        end
    end
end

modifier_inator_5 = class({})
function modifier_inator_5:IsHidden() return true end
function modifier_inator_5:IsPurgable() return false end
function modifier_inator_5:OnCreated()
    if not IsServer() then return end
    local effect_cast = ParticleManager:CreateParticle("particles/stint_inator_invis.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(
        effect_cast,
        false,
        false,
        -1,
        false,
        false
    )
end

function modifier_inator_5:IsAura() return true end

function modifier_inator_5:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_inator_5:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_inator_5:GetModifierAura()
    return "modifier_inator_5_buff"
end

function modifier_inator_5:GetAuraDuration()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("duration_fifth")
    end
end

function modifier_inator_5:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_inator_5:GetAuraEntityReject( target )
    if target == self:GetParent() then
        return true
    end
    return false
end

modifier_inator_5_buff = class({})

function modifier_inator_5_buff:IsHidden() return false end
function modifier_inator_5_buff:IsPurgable() return false end

function modifier_inator_5_buff:DeclareFunctions()
    local funcs = 
    { 
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
    }
    return funcs
end

function modifier_inator_5_buff:CheckState()
    local state = 
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
    return state
end

function modifier_inator_5_buff:GetModifierInvisibilityLevel()
    return 1
end