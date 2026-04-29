LinkLuaModifier("modifier_visitor_w_guest_solo",  "heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_w_guest_group", "heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_w_enemy_fear",  "heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_w_scepter_buff","heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_w_stun_1",      "heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_w_stun_2",      "heroes/pale_visitor/visitor_w", LUA_MODIFIER_MOTION_NONE)

visitor_w = class({})

function visitor_w:Precache(ctx)
    PrecacheResource("particle", "particles/visitor_w.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_muerta/muerta_spell_fear_debuff.vpcf", ctx)
    PrecacheResource("particle", "particles/black_king_bar_avatar_sasavot.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/visitor_sounds.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_muerta.vsndevts", ctx)
end

function visitor_w:GetBehavior()
	local additive = self:GetCaster():HasScepter() and 1099511627776 or 0
    local behavior = self.BaseClass.GetBehavior(self)
    return tonumber(tostring(behavior)) + additive
end

function visitor_w:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level)
end

function visitor_w:GetManaCost(level)
	return self.BaseClass.GetManaCost(self, level)
end

local function CountEnemiesAround(unit, radius)
    local enemies = FindUnitsInRadius(
        unit:GetTeamNumber(),
        unit:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER,
        false
    )
    local n = 0
    for _,e in ipairs(enemies) do
        if e:IsAlive() and e:IsRealHero() then
            n = n + 1
        end
    end
    return n, enemies
end

local function IsAloneAroundTarget(target, caster, radius)
	if not target or target:IsNull() then return false end

	local map = GetMapName() or ""
	local onlyAlliesOfTarget = (map == "overvodka_duo" or map == "overvodka_5x5")

	local teamFilter
	if onlyAlliesOfTarget then
		teamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	else
		teamFilter = DOTA_UNIT_TARGET_TEAM_BOTH
	end

	local units = FindUnitsInRadius(
		target:GetTeamNumber(),
		target:GetAbsOrigin(),
		nil,
		radius,
		teamFilter,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
		FIND_ANY_ORDER,
		false
	)

	local count = 0
	for _,u in ipairs(units) do
		if u ~= target and u ~= caster and u:IsRealHero() and u:IsAlive() then
			if onlyAlliesOfTarget then
				count = count + 1
			else
				count = count + 1
			end
			if count > 0 then return false end
		end
	end

	return true
end

function visitor_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("check_radius")

    if caster:HasScepter() and self:GetAltCastState() then
        local scepter_radius = self:GetSpecialValueFor("scepter_check_radius")
        local count, enemies = CountEnemiesAround(caster, scepter_radius)
        if count >= self:GetSpecialValueFor("scepter_count") then
            caster:Purge(true, true, false, true, true)

            local dur_self = count * self:GetSpecialValueFor("scepter_buff_dur")
            caster:AddNewModifier(caster, self, "modifier_visitor_w_scepter_buff", { duration = dur_self })

            local base_stun = count * self:GetSpecialValueFor("scepter_stun_dur")
            for _,enemy in ipairs(enemies) do
                if enemy and enemy:IsAlive() then
                    enemy:AddNewModifier(caster, self, "modifier_visitor_w_stun_2",
                        { duration = base_stun })
                    AddFOWViewer( caster:GetTeamNumber(), enemy:GetAbsOrigin(), 150, base_stun + 0.1, false )
                    local p = ParticleManager:CreateParticle("particles/visitor_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                    ParticleManager:SetParticleControlEnt(p, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(p, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(p, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                    ParticleManager:ReleaseParticleIndex(p)
                end
            end

            EmitSoundOn("visitor_w", caster)
            EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Bane.Nightmare", caster)
            return
        end
    end

    local guest_dur  = self:GetSpecialValueFor("guest_duration")
    local enemy_dur  = self:GetSpecialValueFor("enemy_duration")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        self:GetSpecialValueFor("find_range"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_CLOSEST,
        false
    )

    local target = nil
    for _,e in ipairs(enemies) do
        if e:IsAlive() then target = e; break end
    end

    if not target then
        self:RefundManaCost()
        self:EndCooldown()
        SendErrorToPlayer(caster:GetPlayerOwnerID(), "#CUSTOM_ERROR_no_enemies_found")
        return
    end

    local alone = IsAloneAroundTarget(target, caster, radius)
    EmitSoundOn("visitor_w", target)
    if alone then
        caster:AddNewModifier(caster, self, "modifier_visitor_w_guest_solo", { duration = guest_dur })
        target:AddNewModifier(caster, self, "modifier_visitor_w_enemy_fear",
            { duration = enemy_dur * (1 - target:GetStatusResistance()) })
    else
        caster:AddNewModifier(caster, self, "modifier_visitor_w_guest_group", { duration = guest_dur })
        target:AddNewModifier(caster, self, "modifier_visitor_w_stun_1",
            { duration = self:GetSpecialValueFor("enemy_stun_dur") })
        AddFOWViewer( caster:GetTeamNumber(), target:GetAbsOrigin(), 150, self:GetSpecialValueFor("enemy_stun_dur") + 0.1, false )
    end
    local p = ParticleManager:CreateParticle("particles/visitor_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(p, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
end


modifier_visitor_w_guest_solo = class({})

function modifier_visitor_w_guest_solo:IsPurgable() return false end

function modifier_visitor_w_guest_solo:OnCreated()
	self.as = self:GetAbility():GetSpecialValueFor("guest_bonus_as")
	self.ms = self:GetAbility():GetSpecialValueFor("guest_bonus_ms_pct")
end

function modifier_visitor_w_guest_solo:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			 MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_visitor_w_guest_solo:GetModifierAttackSpeedBonus_Constant()
	return self.as or 0
end

function modifier_visitor_w_guest_solo:GetModifierMoveSpeedBonus_Percentage()
	return self.ms or 0
end


modifier_visitor_w_guest_group = class({})

function modifier_visitor_w_guest_group:IsPurgable() return false end

function modifier_visitor_w_guest_group:OnCreated()
	self.ms = self:GetAbility():GetSpecialValueFor("guest_bonus_ms_pct")
end

function modifier_visitor_w_guest_group:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_visitor_w_guest_group:GetModifierMoveSpeedBonus_Percentage()
	return self.ms or 0
end

function modifier_visitor_w_guest_group:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end

function modifier_visitor_w_guest_group:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_visitor_w_guest_group:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_visitor_w_guest_group:OnAttack( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		self:Destroy()
	end
end

function modifier_visitor_w_guest_group:GetModifierInvisibilityLevel()
    return 1
end


modifier_visitor_w_enemy_fear = class({})

function modifier_visitor_w_enemy_fear:IsPurgable() return false end
function modifier_visitor_w_enemy_fear:IsDebuff() return true end

function modifier_visitor_w_enemy_fear:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("enemy_slow_pct")
	if not IsServer() then return end
	self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.step   = 450
    EmitSoundOn( "Hero_Muerta.DeadShot.Fear", self.parent )
    self:StartIntervalThink(0.05)
end

function modifier_visitor_w_enemy_fear:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() or not self.parent:IsAlive() then return end
    if not self.caster or self.caster:IsNull() or not self.caster:IsAlive() then return end

    local ppos = self.parent:GetAbsOrigin()
    local cpos = self.caster:GetAbsOrigin()

    local dir = ppos - cpos
    dir.z = 0
    local len = dir:Length2D()
    if len < 1 then
        dir = self.parent:GetForwardVector()
		dir.z = 0
    else
        dir = dir / len
    end

    local dest = ppos + dir * self.step

    if not self.parent.IsDebuffImmune or not self.parent:IsDebuffImmune() then
        self.parent:MoveToPosition(dest)
    end
end


function modifier_visitor_w_enemy_fear:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_visitor_w_enemy_fear:GetModifierMoveSpeedBonus_Percentage()
	return self.slow or 0
end

function modifier_visitor_w_enemy_fear:CheckState()
    return {
        [MODIFIER_STATE_FEARED]              = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED]  = true,
        [MODIFIER_STATE_PROVIDES_VISION]     = true,
    }
end

function modifier_visitor_w_enemy_fear:GetEffectName()
    return "particles/units/heroes/hero_muerta/muerta_spell_fear_debuff.vpcf"
end

function modifier_visitor_w_enemy_fear:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_visitor_w_scepter_buff = class({})

function modifier_visitor_w_scepter_buff:IsPurgable() return false end
function modifier_visitor_w_scepter_buff:IsBuff() return true end

function modifier_visitor_w_scepter_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_visitor_w_scepter_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("scepter_mag_resist")
end

function modifier_visitor_w_scepter_buff:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
end

function modifier_visitor_w_scepter_buff:GetEffectName()
    return "particles/black_king_bar_avatar_sasavot.vpcf"
end
function modifier_visitor_w_scepter_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_visitor_w_stun_1 = class({})

function modifier_visitor_w_stun_1:IsDebuff() return true end
function modifier_visitor_w_stun_1:IsStunDebuff() return true end

function modifier_visitor_w_stun_1:OnCreated( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_visitor_w_stun_1:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_visitor_w_stun_1:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_visitor_w_stun_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_visitor_w_stun_1:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_visitor_w_stun_1:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_visitor_w_stun_1:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


modifier_visitor_w_stun_2 = class({})

function modifier_visitor_w_stun_2:IsDebuff() return true end
function modifier_visitor_w_stun_2:IsStunDebuff() return true end

function modifier_visitor_w_stun_2:OnCreated( kv )
	if not IsServer() then return end
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_visitor_w_stun_2:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_visitor_w_stun_2:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_visitor_w_stun_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_visitor_w_stun_2:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_visitor_w_stun_2:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_visitor_w_stun_2:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end