LinkLuaModifier("modifier_amor_ultimate_beer", "heroes/amor/amor_r", LUA_MODIFIER_MOTION_NONE)

amor_ultimate = class({})

function amor_ultimate:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_splash.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/elder_titan/elder_titan_2021/elder_titan_2021_earth_splitter.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", ctx)
end

function amor_ultimate:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("amor_r")
    return true
end

function amor_ultimate:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound("amor_r")
end

function amor_ultimate:GetBehavior()
    local caster = self:GetCaster()
    if caster and caster:HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function amor_ultimate:GetAOERadius()
    return self:GetSpecialValueFor("slam_radius")
end

function amor_ultimate:GetCastRange(location, target)
    local caster = self:GetCaster()
    if caster and caster:HasScepter() then
        return self:GetSpecialValueFor("scepter_cast_range")
    end
    return self:GetSpecialValueFor("slam_radius")
end

function amor_ultimate:OnAbilityUpgrade( hAbility )
    if not IsServer() then return end
    local result = self.BaseClass.OnAbilityUpgrade( self, hAbility )
    if hAbility == self then
        local ability = self:GetCaster():FindAbilityByName("amor_f")
        if ability then
            ability:SetLevel(ability:GetLevel() + 1)
        end
    end
    return result
end

function amor_ultimate:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    if caster:HasScepter() then
        local point = self:GetCursorPosition()
        local origin = caster:GetAbsOrigin()
        local v = (point - origin); v.z = 0
        local dist = v:Length2D()

        local fw = v
        if fw:Length2D() < 0.01 then
            fw = caster:GetForwardVector()
        else
            fw = fw:Normalized()
        end
        fw.z = 0

        local fly_speed = 2500
        local duration = math.max(0.12, dist / fly_speed)

        local arc = caster:AddNewModifier(
            caster, self, "modifier_generic_arc_lua",
            {
                target_x = point.x, target_y = point.y, duration = duration,
                distance = dist, height = 50, start_offset = 0, end_offset = 0,
                fix_end = 0, fix_duration = 1, fix_height = 0,
                isStun = 0, isRestricted = 0, isForward = 1, activity = 2,
            }
        )

        if arc and not arc:IsNull() and arc.SetEndCallback then
            arc:SetEndCallback(function(interrupted)
                if not IsServer() then return end
                if interrupted then return end
                if not caster or caster:IsNull() then return end

                local landing_pos = GetGroundPosition(point, caster)
                FindClearSpaceForUnit(caster, landing_pos, true)

                self:_ExecuteUltimateAt(caster, landing_pos, fw)
            end)
        else
            local landing_pos = GetGroundPosition(point, caster)
            FindClearSpaceForUnit(caster, landing_pos, true)
            self:_ExecuteUltimateAt(caster, landing_pos, fw)
        end

        return
    end

    local origin = caster:GetAbsOrigin()
    local fw = caster:GetForwardVector(); fw.z = 0
    if fw:Length2D() < 0.01 then fw = Vector(1, 0, 0) end
    fw = fw:Normalized()

    self:_ExecuteUltimateAt(caster, origin, fw)
end

function amor_ultimate:_ExecuteUltimateAt(caster, center, fw)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local team = caster:GetTeamNumber()

    local slam_radius   = self:GetSpecialValueFor("slam_radius")
    local clap_damage   = self:GetSpecialValueFor("clap_damage")
    local beer_duration = self:GetSpecialValueFor("beer_duration")
    local crack_delay   = self:GetSpecialValueFor("crack_delay")
    local crack_width   = self:GetSpecialValueFor("crack_width")
    local crack_length  = self:GetSpecialValueFor("crack_length")
    self.beer_dps       = self:GetSpecialValueFor("beer_dps")

    fw = fw or caster:GetForwardVector()
    fw.z = 0
    if fw:Length2D() < 0.01 then fw = Vector(1, 0, 0) end
    fw = fw:Normalized()

    local right = Vector(-fw.y, fw.x, 0)

    local s1 = center - fw * crack_length * 0.5
    local e1 = center + fw * crack_length * 0.5
    local s2 = center - right * crack_length * 0.5
    local e2 = center + right * crack_length * 0.5

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_splash.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, center)
    ParticleManager:SetParticleControl(p, 1, center)
    ParticleManager:SetParticleControl(p, 3, center)
    ParticleManager:ReleaseParticleIndex(p)

    local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p2, 0, center)
    ParticleManager:SetParticleControl(p2, 1, Vector(slam_radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(p2)

    GridNav:DestroyTreesAroundPoint(center, slam_radius, false)
    caster:EmitSound("Hero_Brewmaster.ThunderClap")

    local enemies = FindUnitsInRadius(
        team, center, nil, slam_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            enemy:AddNewModifier(caster, self, "modifier_amor_ultimate_beer", { duration = beer_duration * (1 - enemy:GetStatusResistance()), dps = self.beer_dps })
            ApplyDamage({ victim = enemy, attacker = caster, damage = clap_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self })
        end
    end

    EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)

    local crack_particles = {}
    crack_particles[#crack_particles+1] = self:_CreateCrackParticle(s1, e1, crack_delay)
    crack_particles[#crack_particles+1] = self:_CreateCrackParticle(e1, s1, crack_delay)
    crack_particles[#crack_particles+1] = self:_CreateCrackParticle(s2, e2, crack_delay)
    crack_particles[#crack_particles+1] = self:_CreateCrackParticle(e2, s2, crack_delay)

    local affected = {}

    Timers:CreateTimer(crack_delay, function()
        if not caster or caster:IsNull() then return nil end

        for _, pid in ipairs(crack_particles) do
            if pid then
                ParticleManager:DestroyParticle(pid, false)
                ParticleManager:ReleaseParticleIndex(pid)
            end
        end
        EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
        self:_ExplodeCrack(caster, s1, e1, crack_width, affected)
        self:_ExplodeCrack(caster, s2, e2, crack_width, affected)

        return nil
    end)
end

function amor_ultimate:_CreateCrackParticle(start_pos, end_pos, delay)
    local caster = self:GetCaster()
    local p = ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_2021/elder_titan_2021_earth_splitter.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(p, 0, start_pos)
    ParticleManager:SetParticleControl(p, 1, end_pos)
    ParticleManager:SetParticleControl(p, 3, Vector(0, delay, 0))
    return p
end

function amor_ultimate:_ClosestPointOnSegment(a, b, p)
    local ab = b - a; ab.z = 0
    local ap = p - a; ap.z = 0

    local ab_len2 = ab:Dot(ab)
    if ab_len2 < 0.001 then
        return a
    end

    local t = ap:Dot(ab) / ab_len2
    t = math.max(0, math.min(1, t))
    local res = a + ab * t
    res.z = p.z
    return res
end

function amor_ultimate:_ExplodeCrack(caster, start_pos, end_pos, width, affected)
    local team = caster:GetTeamNumber()

    local hp_pct = self:GetSpecialValueFor("crack_hp_pct")
    local beer_duration = self:GetSpecialValueFor("beer_duration")

    local enemies = FindUnitsInLine(team, start_pos, end_pos, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            local eid = enemy:entindex()
            if not affected[eid] then
                affected[eid] = true

                enemy:Interrupt()
                ExecuteOrderFromTable({UnitIndex = eid, OrderType = DOTA_UNIT_ORDER_STOP})

                local nearest = self:_ClosestPointOnSegment(start_pos, end_pos, enemy:GetAbsOrigin())
                nearest = GetGroundPosition(nearest, enemy)
                FindClearSpaceForUnit(enemy, nearest, false)

                enemy:AddNewModifier(caster, self, "modifier_amor_ultimate_beer", { duration = beer_duration * (1 - enemy:GetStatusResistance()), dps = self.beer_dps })
                ApplyDamage({victim = enemy, attacker = caster,damage = enemy:GetMaxHealth() * hp_pct * 0.01, damage_type = DAMAGE_TYPE_MAGICAL, ability = self, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
            end
        end
    end
end

modifier_amor_ultimate_beer = class({})

function modifier_amor_ultimate_beer:IsHidden() return false end
function modifier_amor_ultimate_beer:IsDebuff() return true end
function modifier_amor_ultimate_beer:IsPurgable() return true end

function modifier_amor_ultimate_beer:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_debuff.vpcf"
end

function modifier_amor_ultimate_beer:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_amor_ultimate_beer:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_amor_ultimate_beer:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return -ability:GetSpecialValueFor("beer_slow_pct")
end

function modifier_amor_ultimate_beer:OnCreated(kv)
    if not IsServer() then return end

    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if not ability or ability:IsNull() then return end
    if not caster or caster:IsNull() then return end
    if not parent or parent:IsNull() then return end

    self.tick = ability:GetSpecialValueFor("beer_tick") or 0.25

    self.dps = kv.dps or ability:GetSpecialValueFor("beer_dps") or 0
    self:StartIntervalThink(self.tick)
end

function modifier_amor_ultimate_beer:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local parent  = self:GetParent()
    if not ability or ability:IsNull() then return end
    if not caster or caster:IsNull() then return end
    if not parent or parent:IsNull() or not parent:IsAlive() then return end
    local dmg = self.dps * self.tick
    ApplyDamage({victim = parent, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end
