LinkLuaModifier("modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_q_shard_torrent_slow", "heroes/pistol/pistol_q", LUA_MODIFIER_MOTION_NONE)

pistol_q = class({})

function pistol_q:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_slardar/slardar_crush.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_slark/slark_pounce_trail_water_drops.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/pistol_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", ctx)
end

function pistol_q:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
	end
end

function pistol_q:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function pistol_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local origin = caster:GetAbsOrigin()

    local duration = self:GetSpecialValueFor("fly_time")
    self:StartCooldown(duration)
    local max_range = self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
    local direction = caster:GetForwardVector():Normalized() * max_range
    direction.z = 0

    local distance = direction:Length2D()
    local point = origin + direction

    if not caster:HasModifier("modifier_pistol_mute") and not caster:HasModifier("modifier_pistol_w_active") then
        caster:EmitSound("pistol_q")
    end
    local trail = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_trail_water_drops.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local arc = caster:AddNewModifier(
        caster, self, "modifier_generic_arc_lua",
        {
            target_x = point.x, target_y = point.y, duration = duration, distance = distance,
            height = 50, start_offset = 0, end_offset = 0, fix_end = 0, fix_duration = 1, 
            fix_height = 0, isStun = 0, isRestricted = 0, isForward = 1, activity = 1,
        }
    )
    if arc then
        arc:SetEndCallback(function(interrupted)
            if not IsServer() then return end
            if trail then
                ParticleManager:DestroyParticle(trail, false)
            end
            if interrupted then return end

            local landing_pos = GetGroundPosition(point, caster)
            GridNav:DestroyTreesAroundPoint(landing_pos, 200, false)
            FindClearSpaceForUnit(caster, landing_pos, true)
            EmitSoundOnLocationWithCaster(landing_pos, "Hero_Tidehunter.AnchorSmash", caster)

            local stun_duration = self:GetSpecialValueFor("stun_duration")
            local radius = self:GetSpecialValueFor("radius")
            local damage = self:GetSpecialValueFor("damage")

            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_crush.vpcf", PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(p, 0, Vector(landing_pos.x,landing_pos.y,landing_pos.z))
            ParticleManager:SetParticleControl(p, 1, Vector(radius, radius, radius))
            ParticleManager:ReleaseParticleIndex(p)

            for i = 1, 2 do
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(particle, 0, Vector(landing_pos.x,landing_pos.y,landing_pos.z))
                ParticleManager:ReleaseParticleIndex(particle)
            end
            
            local units = FindUnitsInRadius(caster:GetTeamNumber(), landing_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)

            for _,enemy in ipairs(units) do
                local p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                ParticleManager:ReleaseParticleIndex(p2)
                enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = stun_duration})
                ApplyDamage({victim = enemy, attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            end

            if caster:HasShard() then
                local shard_delay = self:GetSpecialValueFor("shard_torrent_delay")
                local shard_radius = self:GetSpecialValueFor("shard_torrent_radius")
                local shard_damage = self:GetSpecialValueFor("shard_torrent_damage")
                local shard_slow_dur = self:GetSpecialValueFor("shard_torrent_slow_duration")

                local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(bubbles, 0, landing_pos)
                ParticleManager:SetParticleControl(bubbles, 1, Vector(shard_radius, 0, 0))
                EmitSoundOnLocationWithCaster(landing_pos, "Ability.pre.Torrent", caster)
                Timers:CreateTimer(math.max(0, shard_delay), function()
                    if bubbles then
                        ParticleManager:DestroyParticle(bubbles, false)
                        ParticleManager:ReleaseParticleIndex(bubbles)
                        bubbles = nil
                    end

                    if not self or self:IsNull() then return end
                    if not caster or caster:IsNull() or (not caster:IsAlive()) then return end

                    EmitSoundOnLocationWithCaster(landing_pos, "Ability.Torrent", caster)

                    local splash = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(splash, 0, landing_pos)
                    ParticleManager:SetParticleControl(splash, 1, Vector(shard_radius, 0, 0))
                    ParticleManager:ReleaseParticleIndex(splash)

                    local enemies2 = FindUnitsInRadius(
                        caster:GetTeamNumber(), landing_pos, nil,
                        shard_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false
                    )

                    for _, enemy in pairs(enemies2) do
                        if not enemy or enemy:IsNull() then return end
                        enemy:AddNewModifier(caster, self, "modifier_pistol_q_shard_torrent_slow", {duration = shard_slow_dur * (1 - enemy:GetStatusResistance())})
                        ApplyDamage({ victim = enemy, attacker = caster, ability = self, damage = shard_damage, damage_type = DAMAGE_TYPE_MAGICAL})
                    end
                end)
            end
        end)
    end
end

modifier_pistol_q_shard_torrent_slow = class({})

function modifier_pistol_q_shard_torrent_slow:IsHidden() return false end
function modifier_pistol_q_shard_torrent_slow:IsDebuff() return true end
function modifier_pistol_q_shard_torrent_slow:IsPurgable() return true end

function modifier_pistol_q_shard_torrent_slow:OnCreated()
    self.ms = self:GetAbility():GetSpecialValueFor("shard_torrent_slow_ms")
    self.as = self:GetAbility():GetSpecialValueFor("shard_torrent_slow_as")
end

function modifier_pistol_q_shard_torrent_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
    }
end

function modifier_pistol_q_shard_torrent_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self.ms or 0
end

function modifier_pistol_q_shard_torrent_slow:GetModifierAttackSpeedPercentage()
    return -self.as or 0
end