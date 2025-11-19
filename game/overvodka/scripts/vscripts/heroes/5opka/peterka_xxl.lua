LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

peterka_xxl = class({})

function peterka_xxl:Precache(ctx)
    PrecacheResource("particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", ctx)
end

function peterka_xxl:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("cast_range")
	end
end

function peterka_xxl:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function peterka_xxl:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local point = self:GetCursorPosition()
    local origin = caster:GetAbsOrigin()

    local duration = self:GetSpecialValueFor("fly_time")
    local direction = (point - origin)
    local max_range = self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
    if direction:Length2D() > max_range then
        direction = direction:Normalized() * max_range
    end

    local distance = direction:Length2D()
    point = origin + direction
    local k = caster.peterka_xxl_sound_index or 0
    caster.peterka_xxl_sound_index = (k + 1) % 2
    caster:EmitSound("peterka_xxl_"..k)
    StopSoundOn("5opka_e", caster)
    StopSoundOn("5opka_e_cast", caster)

    local arc = caster:AddNewModifier(
        caster,
        self,
        "modifier_generic_arc_lua",
        {
            target_x = point.x,
            target_y = point.y,
            duration = duration,
            distance = distance,
            height = 450,
            start_offset = 0,
            end_offset   = 0,
            fix_end      = 1,
            fix_duration = 1,
            fix_height   = 1,
            isStun       = 0,
            isRestricted = 1,
            isForward    = 1,
            activity     = 3,
        }
    )

    if arc then
        arc:SetEndCallback(function(interrupted)
            if not IsServer() then return end
            if interrupted then return end

            local landing_pos = GetGroundPosition(point, caster)
            FindClearSpaceForUnit(caster, landing_pos, true)

            caster:EmitSound("Hero_EarthShaker.EchoSlam")
            local stun_duration = self:GetSpecialValueFor("stun_duration")
            local radius = self:GetSpecialValueFor("radius")
            local base_damage = self:GetSpecialValueFor("damage")
            local damage_per_hero  = self:GetSpecialValueFor("damage_per_hero")
            local damage_per_unit  = self:GetSpecialValueFor("damage_per_unit")

            local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf", PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl(particle, 0, Vector(landing_pos.x,landing_pos.y,landing_pos.z))
            ParticleManager:SetParticleControl(particle, 1, Vector(250,250,landing_pos.z))
            ParticleManager:SetParticleControl(particle, 2, Vector(landing_pos.x,landing_pos.y,landing_pos.z))
            local units = FindUnitsInRadius(caster:GetTeamNumber(), landing_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
            if #units == 0 then
                return
            end
            local hero_count = 0
            local unit_count = 0
            for _, enemy in ipairs(units) do
                if enemy and not enemy:IsNull() then
                    if enemy:IsRealHero() and not enemy:IsIllusion() then
                        hero_count = hero_count + 1
                    else
                        unit_count = unit_count + 1
                    end
                end
            end

            local bonus_damage = hero_count * damage_per_hero + unit_count * damage_per_unit
            local total_damage = base_damage + bonus_damage

            for _,enemy in ipairs(units) do
                enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = stun_duration })
                ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = total_damage, damage_type = DAMAGE_TYPE_MAGICAL})
            end
        end)
    end
end