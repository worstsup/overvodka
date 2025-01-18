LinkLuaModifier("modifier_gaster_blaster", "gaster_blaster", LUA_MODIFIER_MOTION_NONE)

gaster_blaster = class({})

function gaster_blaster:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_laser.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_start.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_shoot.vsndevts", context)
end

function gaster_blaster:OnSpellStart()
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("blast_delay")
    local blaster_radius = self:GetSpecialValueFor("blaster_radius")
    local laser_length = self:GetSpecialValueFor("laser_length")
    local laser_width = self:GetSpecialValueFor("laser_width")
    local blaster = CreateUnitByName("npc_gaster_blaster", target_point, false, caster, caster, caster:GetTeamNumber())
    blaster:AddNewModifier(caster, self, "modifier_gaster_blaster", {duration = delay})
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        target_point,
        nil,
        blaster_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    if #enemies > 0 then
        local target = enemies[1]
        local vDirection = (target:GetAbsOrigin() - blaster:GetAbsOrigin()):Normalized()
        blaster:SetForwardVector(vDirection)
        Timers:CreateTimer(delay, function()
            if not blaster:IsNull() and blaster:IsAlive() then
                local laser_end = target_point + vDirection * laser_length
                local units = FindUnitsInLine(
                    caster:GetTeamNumber(),
                    target_point,
                    laser_end,
                    nil,
                    laser_width,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    0
                )
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster)
                ParticleManager:SetParticleControl(particle, 9, blaster:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 1, laser_end)
                ParticleManager:ReleaseParticleIndex(particle)
                blaster:EmitSound("gaster_blaster_shoot")
                for _,unit in pairs(units) do
                    ApplyDamage({
                        victim = unit,
                        attacker = caster,
                        damage = self:GetSpecialValueFor("damage"),
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    })
                end
            blaster:ForceKill(false)
            end
        end)
    else
        blaster:ForceKill(false)
    end
end

modifier_gaster_blaster = class({})

function modifier_gaster_blaster:IsHidden() return true end
function modifier_gaster_blaster:IsPurgable() return false end

function modifier_gaster_blaster:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()
    parent:EmitSound("gaster_blaster_start")

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControl(self.particle, 0, parent:GetAbsOrigin())
end
function modifier_gaster_blaster:CheckState()
    return {
            [MODIFIER_STATE_UNSELECTABLE]=true,
            [MODIFIER_STATE_NO_HEALTH_BAR]=true,
            [MODIFIER_STATE_INVULNERABLE]=true,
            [MODIFIER_STATE_OUT_OF_GAME]=true,
            [MODIFIER_STATE_NO_UNIT_COLLISION]=true,
            [MODIFIER_STATE_NOT_ON_MINIMAP]=true,
        }
end
function modifier_gaster_blaster:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end