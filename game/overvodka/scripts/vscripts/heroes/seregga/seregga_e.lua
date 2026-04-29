seregga_e = class({})

function seregga_e:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", ctx)
    PrecacheResource("particle", "particles/ui_mouseactions/range_finder_tower_aoe.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/seregga_sounds.vsndevts", ctx)
end

function seregga_e:GetBehavior()
	local additive = self:GetSpecialValueFor("has_facet") == 1 and 1099511627776 or 0
    local behavior = self.BaseClass.GetBehavior(self)
    return tonumber(tostring(behavior)) + additive
end

function seregga_e:OnAbilityPhaseStart()
    if not IsServer() then return true end
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    EmitSoundOn("seregga_e_cast", caster)
    self.warning_pfx = ParticleManager:CreateParticle("particles/ui_mouseactions/range_finder_tower_aoe.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.warning_pfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.warning_pfx, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(self.warning_pfx, 2, Vector(1, 0, 0))
    return true
end

function seregga_e:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    local caster = self:GetCaster()
    StopSoundOn("seregga_e_cast", caster)
    if self.warning_pfx then
        ParticleManager:DestroyParticle(self.warning_pfx, false)
        ParticleManager:ReleaseParticleIndex(self.warning_pfx)
        self.warning_pfx = nil
    end
end

function seregga_e:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local push_distance = self:GetSpecialValueFor("push_distance")
    local push_duration = self:GetSpecialValueFor("push_duration")

    if self.warning_pfx then
        ParticleManager:DestroyParticle(self.warning_pfx, false)
        ParticleManager:ReleaseParticleIndex(self.warning_pfx)
        self.warning_pfx = nil
    end

    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(pfx)
    caster:EmitSound("Hero_Brewmaster.ThunderClap")

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    local pull_mode = (self:GetSpecialValueFor("has_facet") == 1) and self:GetAltCastState()
    local pull_stop_offset = 50

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            if pull_mode then
                local enemy_pos = enemy:GetAbsOrigin()
                local dir = (enemy_pos - origin)
                local dist = dir:Length2D()
                if dist > 0.01 then
                    dir = dir:Normalized()
                    local travel = math.max(0, dist - pull_stop_offset)
                    if travel > 0 then
                        local center = enemy_pos + dir * travel
                        local kb = {
                            center_x = center.x,
                            center_y = center.y,
                            center_z = center.z,
                            duration = push_duration,
                            knockback_duration = push_duration,
                            knockback_distance = travel,
                            knockback_height = 0,
                        }
                        enemy:AddNewModifier(caster, self, "modifier_knockback", kb)
                    end
                end
            else
                local kb = {
                    center_x = origin.x,
                    center_y = origin.y,
                    center_z = origin.z,
                    duration = push_duration,
                    knockback_duration = push_duration,
                    knockback_distance = push_distance,
                    knockback_height = 0,
                }
                enemy:AddNewModifier(caster, self, "modifier_knockback", kb)
            end
            ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
        end
    end
end