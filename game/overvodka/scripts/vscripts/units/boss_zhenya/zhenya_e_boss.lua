zhenya_e_boss = class({})

function zhenya_e_boss:OnAbilityPhaseStart()
    if not IsServer() then return true end

    self.precast_particle = ParticleManager:CreateParticle(
        "particles/zhenya_e_boss.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetCaster()
    )

    return true
end

function zhenya_e_boss:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    if self.precast_particle then
        ParticleManager:DestroyParticle(self.precast_particle, false)
        ParticleManager:ReleaseParticleIndex(self.precast_particle)
        self.precast_particle = nil
    end
end

function zhenya_e_boss:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("leap_duration")
    local height   = self:GetSpecialValueFor("leap_height")

    local modifier = caster:AddNewModifier(
        caster,
        self,
        "modifier_generic_arc_lua",
        {
            duration     = duration,
            distance     = 0,
            height       = height,
            fix_end      = 1,
            fix_duration = 1,
            fix_height   = 1,
            isStun       = 1,
            isRestricted = 1,
            isForward    = 0,
            isInvulnerable = 1,
        }
    )

    if modifier and not modifier:IsNull() then
        modifier:SetEndCallback(function(interrupted)
            if interrupted then return end
            self:OnLeapLanded()
        end)
    end
end

function zhenya_e_boss:OnLeapLanded()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() or not caster:IsAlive() then return end

    local origin = caster:GetAbsOrigin()
    local team   = caster:GetTeamNumber()

    local radius      = self:GetSpecialValueFor("radius")
    local damage_pct  = self:GetSpecialValueFor("damage_pct")
    local knock_dist  = self:GetSpecialValueFor("knockback_distance")
    local knock_dur   = self:GetSpecialValueFor("knockback_duration")
    local knock_height= self:GetSpecialValueFor("knockback_height")

    local pfx = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(pfx, 0, origin)
    ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)

    caster:EmitSound("Hero_Centaur.HoofStomp")

    local enemies = FindUnitsInRadius(
        team, origin, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    if not enemies or #enemies == 0 then return end

    local damageTable = {
        attacker    = caster,
        damage_type = DAMAGE_TYPE_PURE,
        ability     = self,
    }

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull()
            and enemy:IsAlive()
            and not enemy:IsBuilding()
            and not enemy:IsOther() then

            enemy:AddNewModifier(
                caster,
                self,
                "modifier_knockback",
                {
                    center_x          = origin.x,
                    center_y          = origin.y,
                    center_z          = origin.z,
                    duration          = knock_dur,
                    knockback_duration= knock_dur,
                    knockback_distance= knock_dist,
                    knockback_height  = knock_height,
                }
            )
            local dmg = enemy:GetMaxHealth() * (damage_pct * 0.01)
            damageTable.victim = enemy
            damageTable.damage = dmg
            ApplyDamage(damageTable)
        end
    end
end
