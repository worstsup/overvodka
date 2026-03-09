LinkLuaModifier("modifier_leon_e_lollipop", "heroes/leon/leon_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leon_e", "heroes/leon/leon_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_leon_e_buff", "heroes/leon/leon_e", LUA_MODIFIER_MOTION_NONE)

leon_e = class({})

function leon_e:Precache(context)
    PrecacheResource( "particle", "particles/leon_e.vpcf", context )
    PrecacheResource( "particle", "particles/hero_spawn_hero_level_6_model_core_glow_rostik.vpcf", context )
    PrecacheResource( "particle", "particles/hero_spawn_hero_level_6_sparks_b_rostik.vpcf", context )
    PrecacheResource( "particle", "particles/leon_attack_e.vpcf", context )
    PrecacheUnitByNameSync( "npc_lollipop", context )
end

function leon_e:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function leon_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local lollipop = CreateUnitByName("npc_lollipop", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    lollipop:SetControllableByPlayer(playerID, true)
    lollipop:SetOwner(caster)
    lollipop:AddNewModifier( self:GetCaster(), self, "modifier_leon_e_lollipop", {} )
    lollipop:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    lollipop:SetMaximumGoldBounty(gold)
    lollipop:SetMinimumGoldBounty(gold)
    lollipop:SetDeathXP(xp)
    lollipop:AddNewModifier(self:GetCaster(), self, "modifier_leon_e", {})
    local p = ParticleManager:CreateParticle("particles/hero_spawn_hero_level_6_model_core_glow_rostik.vpcf", PATTACH_ABSORIGIN_FOLLOW, lollipop)
    ParticleManager:SetParticleControl(p, 10, lollipop:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    local p2 = ParticleManager:CreateParticle("particles/hero_spawn_hero_level_6_sparks_b_rostik.vpcf", PATTACH_ABSORIGIN_FOLLOW, lollipop)
    ParticleManager:SetParticleControl(p2, 0, lollipop:GetAbsOrigin())
    ParticleManager:SetParticleControl(p2, 1, lollipop:GetAbsOrigin())
    ParticleManager:SetParticleControl(p2, 10, lollipop:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p2)
    EmitSoundOnLocationWithCaster(lollipop:GetAbsOrigin(), "Leon.Clones.Spawn", caster)
end

modifier_leon_e = class({})
function modifier_leon_e:IsHidden() return true end
function modifier_leon_e:IsPurgable() return false end
function modifier_leon_e:OnCreated()
    if not IsServer() then return end

    local effect_cast = ParticleManager:CreateParticle("particles/leon_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(effect_cast, false, false, -1, false, false)

    local ab = self:GetAbility()
    self._petal_interval = 1.0
    if ab and not ab:IsNull() then
        self._petal_interval = ab:GetSpecialValueFor("interval")
        if self._petal_interval <= 0 then self._petal_interval = 1.0 end
    end
    self.t = 0
    self:StartIntervalThink(self._petal_interval)
end

function modifier_leon_e:OnIntervalThink()
    if not IsServer() then return end

    local lollipop = self:GetParent()
    if not lollipop or lollipop:IsNull() or (not lollipop:IsAlive()) then return end

    local e = self:GetAbility()
    if not e or e:IsNull() then
        self:Destroy()
        return
    end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() or (not caster:IsAlive()) then return end

    local q = caster:FindAbilityByName("leon_q")
    if not q or q:IsNull() or q:GetLevel() <= 0 then return end

    local origin = lollipop:GetAbsOrigin()

    local range  = e:GetSpecialValueFor("proj_range")
    if range <= 0 then range = 1 end

    local speed  = q:GetSpecialValueFor("projectile_speed")
    local radius = q:GetSpecialValueFor("blade_radius")
    local pct    = q:GetSpecialValueFor("attack_damage_pct")
    local far    = q:GetSpecialValueFor("damage_far_pct")

    if radius <= 0 then radius = 28 end
    if speed <= 0 then speed = 1200 end
    local facet = (e:GetSpecialValueFor("facet_enabled") == 1)
    local team = caster:GetTeamNumber()
    local travel_time = range / speed
    local blades_count = self:GetAbility():GetSpecialValueFor("blades_count")
    local period = 360 / blades_count
    local sound = "Leon.Lollipop.Blades"
    if facet then
        sound = "Leon.Lollipop.Blades.Facet"
    end
    lollipop:EmitSound(sound)
    for k = 0, blades_count - 1 do
        local ang = (self.t % 2 == 0 and k * period or k * period + period / 2)
        local dir = RotatePosition(Vector(0,0,0), QAngle(0, ang, 0), Vector(1,0,0))
        dir.z = 0
        dir = dir:Normalized()

        ProjectileManager:CreateLinearProjectile({
            Ability = q,
            EffectName = "particles/leon_attack_e.vpcf",
            vSpawnOrigin = origin,
            fDistance = range,
            fStartRadius = radius,
            fEndRadius   = radius,

            Source = caster,

            iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_COURIER + DOTA_UNIT_TARGET_OTHER,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,

            bDeleteOnHit = true,
            bProvidesVision = true,
            iVisionRadius = 100,
            iVisionTeamNumber = team,

            vVelocity = dir * speed,

            ExtraData = {
                lolli = 1,
                src   = lollipop:entindex(),
                tick  = tick,
                phase = 0,

                ox = origin.x, oy = origin.y, oz = origin.z,
                range = range,
                pct   = pct,
                far   = far,
            }
        })
        if facet then
            local dir_copy = Vector(dir.x, dir.y, 0)
            local endpos = origin + dir_copy * range
            endpos.z = origin.z

            Timers:CreateTimer(travel_time, function()
                if not self or self:IsNull() then return end
                if not lollipop or lollipop:IsNull() or (not lollipop:IsAlive()) then return end
                if not caster or caster:IsNull() or (not caster:IsAlive()) then return end
                if not q or q:IsNull() then return end

                ProjectileManager:CreateLinearProjectile({
                    Ability = q,
                    EffectName = "particles/leon_attack_e.vpcf",
                    vSpawnOrigin = endpos,
                    fDistance = range,
                    fStartRadius = radius,
                    fEndRadius   = radius,

                    Source = caster,

                    iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_COURIER + DOTA_UNIT_TARGET_OTHER,
                    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,

                    bDeleteOnHit = true,
                    bProvidesVision = true,
                    iVisionRadius = 100,
                    iVisionTeamNumber = team,

                    vVelocity = (-dir_copy) * speed,

                    ExtraData = {
                        lolli = 1,
                        src   = lollipop:entindex(),
                        tick  = tick,
                        phase = 1,

                        ox = endpos.x, oy = endpos.y, oz = endpos.z,
                        range = range,
                        pct   = pct,
                        far   = far,
                    }
                })
            end)
        end
    end
    self.t = self.t + 1
end


function modifier_leon_e:IsAura() return true end

function modifier_leon_e:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_leon_e:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_leon_e:GetModifierAura()
    return "modifier_leon_e_buff"
end

function modifier_leon_e:GetAuraDuration()
    if self:GetAbility() then
        return 0.2
    end
end

function modifier_leon_e:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

function modifier_leon_e:GetAuraEntityReject( target )
    if target == self:GetParent() then
        return true
    end
    return false
end

modifier_leon_e_lollipop = class({})

function modifier_leon_e_lollipop:OnCreated()
    if not IsServer() then return end
    self.hit_destroy = self:GetAbility():GetSpecialValueFor("hit_destroy")
    self.pct_damage = 1
    self:GetParent():SetBaseMaxHealth(self.hit_destroy)
    self:GetParent():SetMaxHealth(self.hit_destroy)
    self:GetParent():SetHealth(self.hit_destroy)
    self:StartIntervalThink(0.1)
end

function modifier_leon_e_lollipop:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetAbility() then
        self:Destroy()
        return
    end
end

function modifier_leon_e_lollipop:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

function modifier_leon_e_lollipop:IsHidden() return true end
function modifier_leon_e_lollipop:IsPurgable() return false end

function modifier_leon_e_lollipop:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
    }
end

function modifier_leon_e_lollipop:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
end

function modifier_leon_e_lollipop:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local new_health = self:GetParent():GetHealth() - 1
    if params.attacker == self:GetCaster() then
        if new_health <= 0 then
            self:GetParent():Kill(nil, params.attacker)
        end
    else
        if new_health <= 0 then
            self:GetParent():Kill(nil, params.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_leon_e_lollipop:GetDisableHealing()
    return 1
end

function modifier_leon_e_lollipop:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_leon_e_lollipop:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_leon_e_lollipop:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_leon_e_lollipop:GetAbsoluteNoDamagePure()
    return 1
end

modifier_leon_e_buff = class({})

function modifier_leon_e_buff:IsHidden() return false end
function modifier_leon_e_buff:IsPurgable() return false end

function modifier_leon_e_buff:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
    }
end

function modifier_leon_e_buff:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end

function modifier_leon_e_buff:GetModifierInvisibilityLevel()
    return 1
end