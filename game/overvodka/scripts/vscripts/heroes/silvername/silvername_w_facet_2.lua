LinkLuaModifier("modifier_silvername_w_facet_2_target", "heroes/silvername/silvername_w_facet_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_w_facet_2_forced", "heroes/silvername/silvername_w_facet_2", LUA_MODIFIER_MOTION_NONE)

silvername_w_facet_2 = class({})

function silvername_w_facet_2:IsStealable() return true end

function silvername_w_facet_2:FindRandomTarget(caster, search_radius)
    if not caster or caster:IsNull() then return nil end

    local team = caster:GetTeamNumber()
    local pos  = caster:GetAbsOrigin()
    local playerID = caster:GetPlayerOwnerID()

    local candidates = {}

    table.insert(candidates, caster)

    local allies = FindUnitsInRadius(
        team, pos, nil, search_radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )

    for _,unit in ipairs(allies) do
        if unit ~= caster and unit:GetPlayerOwnerID() == playerID then
            table.insert(candidates, unit)
        end
    end

    local enemies = FindUnitsInRadius(
        team, pos, nil, search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_ANY_ORDER, false
    )

    for _,unit in ipairs(enemies) do
        table.insert(candidates, unit)
    end

    if #candidates == 0 then
        return nil
    end

    local idx = RandomInt(1, #candidates)
    return candidates[idx]
end

function silvername_w_facet_2:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local aggro_radius   = self:GetSpecialValueFor("aggro_radius")
    local reflect_radius = self:GetSpecialValueFor("reflect_radius")
    local reflect_pct    = self:GetSpecialValueFor("reflect_pct")
    local duration       = self:GetSpecialValueFor("duration")
    local chair_radius   = self:GetSpecialValueFor("chair_search_radius")
    local target = nil
    if caster.silvername_chair_unit and not caster.silvername_chair_unit:IsNull() and caster.silvername_chair_unit:IsAlive() then
        target = caster.silvername_chair_unit
    end

    if not target or target:IsNull() or not target:IsAlive() then
        target = self:FindRandomTarget(caster, chair_radius)
    end

    if not target or target:IsNull() or not target:IsAlive() then
        return
    end

    local target_mod = target:AddNewModifier(
        caster,
        self,
        "modifier_silvername_w_facet_2_target",
        {
            duration       = duration,
            reflect_radius = reflect_radius,
            reflect_pct    = reflect_pct,
        }
    )

    if not target_mod then return end

    local target_index = target:entindex()

    local team = caster:GetTeamNumber()
    local pos  = caster:GetAbsOrigin()
    local playerID = caster:GetPlayerOwnerID()

    local allies = FindUnitsInRadius(
        team, pos, nil, aggro_radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
        FIND_ANY_ORDER, false
    )

    for _,unit in ipairs(allies) do
        if unit and not unit:IsNull() then
            if (unit == caster or unit:GetPlayerOwnerID() == playerID) and not unit:HasModifier("modifier_silvername_w_facet_2_target") then
                unit:AddNewModifier(
                    caster,
                    self,
                    "modifier_silvername_w_facet_2_forced",
                    {
                        duration          = duration,
                        target_entindex   = target_index,
                    }
                )
            end
        end
    end

    local enemies = FindUnitsInRadius(
        team, pos, nil, aggro_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )

    for _,unit in ipairs(enemies) do
        if unit and not unit:IsNull() and not unit:HasModifier("modifier_silvername_w_facet_2_target") then
            if not unit:IsDebuffImmune() or caster:HasTalent("special_bonus_unique_silvername_8") then
                unit:AddNewModifier(
                    caster,
                    self,
                    "modifier_silvername_w_facet_2_forced",
                    {
                        duration          = duration,
                        target_entindex   = target_index,
                    }
                )
            end
        end
    end

    local effect_cast = ParticleManager:CreateParticle( "particles/silvername_w_facet_2_call.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( aggro_radius, aggro_radius, aggro_radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    caster:EmitSound("silvername_w_facet_2_"..RandomInt(1,4))
end

modifier_silvername_w_facet_2_target = class({})

function modifier_silvername_w_facet_2_target:IsPurgable()   return false end
function modifier_silvername_w_facet_2_target:IsHidden()     return false end

function modifier_silvername_w_facet_2_target:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_mark_overhead.vpcf"
end

function modifier_silvername_w_facet_2_target:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_silvername_w_facet_2_target:OnCreated(kv)
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    self.damage_sum     = 0
    self.reflect_radius = tonumber(kv.reflect_radius or 0)
    self.reflect_pct    = tonumber(kv.reflect_pct or 0)

    if IsServer() then
        self.end_time = GameRules:GetGameTime() + (self:GetDuration() or 0)
        self:SetStackCount(0)
        CustomGameEventManager:Send_ServerToAllClients(
            "silvername_w_facet_2_target_start",
            { entindex = self.parent:entindex() }
        )
        local p = ParticleManager:CreateParticle("particles/nightstalker_ti10_crimson_aura_smoke_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 1, self.parent:GetAbsOrigin())
        self:AddParticle(p, false, false, -1, false, false)
    end
end

function modifier_silvername_w_facet_2_target:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_silvername_w_facet_2_target:GetMinHealth()
    return 1
end

function modifier_silvername_w_facet_2_target:OnTakeDamage(event)
    if not IsServer() then return end
    if event.unit ~= self.parent then return end
    if not self.ability or self.ability:IsNull() then return end

    if bit.band(event.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then
        return
    end

    local dmg = event.original_damage or 0
    if event.damage_type == DAMAGE_TYPE_PHYSICAL then
        local armor = self.parent:GetPhysicalArmorValue(false)
        local factor = 0.06
        local dmg_mult = 1 - ((factor * armor) / (1 + factor * math.abs(armor)))
        dmg = dmg * dmg_mult
    end
    if event.damage_type == DAMAGE_TYPE_MAGICAL then
        local mag_resist = self.parent:Script_GetMagicalArmorValue(false, event.inflictor)
        dmg = dmg * (1 - mag_resist)
    end
    if dmg > 0 then
        self.damage_sum = self.damage_sum + dmg
        self:SetStackCount( math.floor(self.damage_sum + 0.5) )
    end
end

function modifier_silvername_w_facet_2_target:OnDestroy()
    if not IsServer() then return end
    CustomGameEventManager:Send_ServerToAllClients(
        "silvername_w_facet_2_target_end",
        { entindex = self.parent:entindex() }
    )
    if not self.ability or self.ability:IsNull() then return end
    if not self.caster or self.caster:IsNull() then return end
    local p = ParticleManager:CreateParticle("particles/silvername_w_facet_2_exp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 8, Vector(self.reflect_radius * 5, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)

    if self.damage_sum <= 0 then return end

    local pct = self.reflect_pct or self.ability:GetSpecialValueFor("reflect_pct") or 0
    if pct <= 0 then return end

    local total_reflect = self.damage_sum * pct * 0.01

    local radius = self.reflect_radius or self.ability:GetSpecialValueFor("reflect_radius") or 0
    if radius <= 0 then return end

    local victims = FindUnitsInRadius(
        self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(),
        nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    local valid_targets = {}
    for _,enemy in ipairs(victims) do
        if enemy and not enemy:IsNull() and enemy:IsAlive()
            and not enemy:IsInvulnerable()
        then
            table.insert(valid_targets, enemy)
        end
    end

    local count = #valid_targets
    if count == 0 then return end

    local damage_each = total_reflect / count

    local damage_table = {
        attacker = self.caster,
        damage = damage_each,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
    }

    for _,enemy in ipairs(valid_targets) do
        damage_table.victim = enemy
        ApplyDamage(damage_table)
    end
end

modifier_silvername_w_facet_2_forced = class({})

function modifier_silvername_w_facet_2_forced:IsHidden()   return false end
function modifier_silvername_w_facet_2_forced:IsPurgable() return true end

function modifier_silvername_w_facet_2_forced:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_silvername_w_facet_2_forced:OnCreated(kv)
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    if IsServer() then
        if kv and kv.target_entindex then
            local ent = EntIndexToHScript(tonumber(kv.target_entindex))
            if ent and not ent:IsNull() then
                self.target = ent
            end
        end

        self:StartIntervalThink(0.1)
    end
end

function modifier_silvername_w_facet_2_forced:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    if not self.target or self.target:IsNull() or not self.target:IsAlive() then
        self:Destroy()
        return
    end

    if self.parent:IsDebuffImmune() and not self.caster:HasTalent("special_bonus_unique_silvername_8") then
        self:Destroy()
        return
    end

    self.parent:SetForceAttackTarget(self.target)
    self.parent:MoveToTargetToAttack(self.target)
end

function modifier_silvername_w_facet_2_forced:OnDestroy()
    if not IsServer() then return end
    if self.parent and not self.parent:IsNull() then
        self.parent:SetForceAttackTarget(nil)
    end
end

function modifier_silvername_w_facet_2_forced:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_ALLIES]      = true,
        [MODIFIER_STATE_TAUNTED]            = true,
    }
end
