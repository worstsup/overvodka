LinkLuaModifier("modifier_gaster_blaster", "heroes/sans/gaster_blaster", LUA_MODIFIER_MOTION_NONE)

gaster_blaster = class({})

function gaster_blaster:Precache(context)
    PrecacheResource("particle", "particles/sans_laser.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_start.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_shoot.vsndevts", context)
end

function gaster_blaster:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_nyx_vendetta_damage" )
end

function gaster_blaster:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
end

function gaster_blaster:GetVectorTargetRange()
    return 10000
end

function gaster_blaster:OnVectorCastStart(vStartLocation, direction_new)
    local caster = self:GetCaster()
    local target_point = self:GetVectorPosition()
    local delay = self:GetSpecialValueFor("blast_delay")
    local laser_length = self:GetSpecialValueFor("laser_length")
    local laser_width = self:GetSpecialValueFor("laser_width")
    local caster_origin = caster:GetAbsOrigin()
    local dmg = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("int_damage") * self:GetCaster():GetIntellect(false) * 0.01
    AddFOWViewer(caster:GetTeamNumber(), target_point, self:GetSpecialValueFor("blaster_vision"), 2, false)
    local function CreateBlaster(position, direction)
        local blaster = CreateUnitByName("npc_gaster_blaster", position, false, caster, caster, caster:GetTeamNumber())
        blaster:AddNewModifier(caster, self, "modifier_gaster_blaster", {duration = delay + 0.5})
        blaster:SetForwardVector(direction)
        
        Timers:CreateTimer(delay, function()
            if not blaster:IsNull() and blaster:IsAlive() then
                local laser_end = position + direction * laser_length
                local units = FindUnitsInLine(
                    caster:GetTeamNumber(),
                    position,
                    laser_end,
                    nil,
                    laser_width,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    0
                )
                local particle = ParticleManager:CreateParticle("particles/sans_laser.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster)
                ParticleManager:SetParticleControl(particle, 9, blaster:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 1, laser_end)
                ParticleManager:ReleaseParticleIndex(particle)
                blaster:EmitSound("gaster_blaster_shoot")
                local dmg_r = dmg * self:GetCaster():FindAbilityByName("sans_r"):GetSpecialValueFor("blasters_damage_pct") * 0.01
                for _, unit in pairs(units) do
                    ApplyDamage({
                        victim = unit,
                        attacker = caster,
                        damage = dmg_r,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    })
                end
                blaster:ForceKill(false)
            end
        end)
    end
    local blaster = CreateUnitByName("npc_gaster_blaster", target_point, false, caster, caster, caster:GetTeamNumber())
    blaster:AddNewModifier(caster, self, "modifier_gaster_blaster", {duration = delay + 0.5})
    local direction_new = self:GetVectorDirection()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + caster:GetForwardVector() * 50
        direction_new = caster:GetForwardVector()
    end
    blaster:SetForwardVector(direction_new)
    Timers:CreateTimer(delay, function()
        if not blaster:IsNull() and blaster:IsAlive() then
            local laser_end = target_point + direction_new * laser_length
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
            local particle = ParticleManager:CreateParticle("particles/sans_laser.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster)
            ParticleManager:SetParticleControl(particle, 9, blaster:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 1, laser_end)
            ParticleManager:ReleaseParticleIndex(particle)
            blaster:EmitSound("gaster_blaster_shoot")
            for _,unit in pairs(units) do
                ApplyDamage({
                    victim = unit,
                    attacker = caster,
                    damage = dmg,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                })
            end
        blaster:ForceKill(false)
        end
    end)

    if caster:HasModifier("modifier_sans_r") then
        local function RotateVector2D(vec, angle)
            local x = vec.x
            local y = vec.y
            local cos = math.cos(angle)
            local sin = math.sin(angle)
            return Vector(x * cos - y * sin, x * sin + y * cos, 0)
        end
        local angle = math.rad(40)
        local offset1 = RotateVector2D(direction_new, angle) * 200
        local offset2 = RotateVector2D(direction_new, -angle) * 200
        local dir_1 = RotateVector2D(direction_new, -angle/2)
        local dir_2 = RotateVector2D(direction_new, angle/2)
        CreateBlaster(target_point + offset1, dir_1)
        CreateBlaster(target_point + offset2, dir_2)
    end
end

modifier_gaster_blaster = class({})

function modifier_gaster_blaster:IsHidden() return true end
function modifier_gaster_blaster:IsPurgable() return false end

function modifier_gaster_blaster:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    parent:EmitSound("gaster_blaster_start")
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

function modifier_gaster_blaster:GetEffectName()
    return "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf"
end

function modifier_gaster_blaster:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end