LinkLuaModifier("modifier_eldzhey_r", "heroes/eldzhey/eldzhey_r.lua", LUA_MODIFIER_MOTION_NONE)

eldzhey_r = class({})

function eldzhey_r:Precache(context)
    PrecacheResource("particle", "particles/eldzhey_r.vpcf", context)
    PrecacheResource("particle", "particles/leshrac_disco_tnt_new.vpcf", context)
    PrecacheResource("soundfile", "soundevents/jinsi.vsndevts", context)
end

function eldzhey_r:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function eldzhey_r:OnSpellStart()
    if not IsServer() then return end

    local caster   = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local duration = self:GetSpecialValueFor("duration")
    local point = self:GetCursorPosition()

    CreateModifierThinker(caster, self, "modifier_eldzhey_r", { duration = duration }, point, caster:GetTeamNumber(), false)
    AddFOWViewer(caster:GetTeamNumber(), point, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor( "duration" ) + 0.25, false )
end

modifier_eldzhey_r = class({})

function modifier_eldzhey_r:IsPurgable()  return false end
function modifier_eldzhey_r:IsHidden()    return true  end

function modifier_eldzhey_r:OnCreated(kv)
    if not IsServer() then return end

    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end

    self.radius = self.ability:GetSpecialValueFor("radius")
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.damage_pct = self.ability:GetSpecialValueFor("damage_pct")

    self.center = self.parent:GetAbsOrigin()

    local pfx = ParticleManager:CreateParticle("particles/leshrac_disco_tnt_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, self.center)
    ParticleManager:SetParticleControl(pfx, 2, Vector(self.radius - 75, 0, 0))
    self:AddParticle(pfx, false, false, -1, false, false)
    if not global_sounds_muted then
        self.parent:EmitSound("jinsi")
    end
    self:StartIntervalThink(0.25)
end

function modifier_eldzhey_r:OnIntervalThink()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then
        self:Destroy()
        return
    end
    self:Knock()
end

function modifier_eldzhey_r:Knock()
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then return end
    if not self.caster or self.caster:IsNull() then return end

    local center = self.center or self.parent:GetAbsOrigin()
    local radius = self.radius

    local particle = ParticleManager:CreateParticle("particles/eldzhey_r.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, center)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local targets = FindUnitsInRadius(self.caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

    for _, unit in pairs(targets) do
        if unit and not unit:IsNull() then
            local dmg = unit:GetHealth() * self.damage_pct * 0.01 + self.damage

            local unit_pos = unit:GetAbsOrigin()
            local direction = (unit_pos - center):Normalized()
            local distance = (unit_pos - center):Length2D()
            local bump_point = center + direction * (distance + 150)

            local knockbackProperties = {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = 0.15,
                knockback_duration = 0.15,
                knockback_distance = 0,
                knockback_height = 75,
            }

            if unit:HasModifier("modifier_knockback") then
                unit:RemoveModifierByName("modifier_knockback")
            end

            unit:AddNewModifier(self.caster, self.ability, "modifier_knockback", knockbackProperties)

            ApplyDamage({
                victim = unit,
                attacker = self.caster,
                damage = dmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self.ability
            })
        end
    end
end