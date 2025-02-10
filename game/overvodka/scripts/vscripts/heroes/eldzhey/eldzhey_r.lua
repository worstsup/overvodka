LinkLuaModifier("modifier_eldzhey_r", "heroes/eldzhey/eldzhey_r.lua", LUA_MODIFIER_MOTION_NONE)

eldzhey_r = class({})

function eldzhey_r:Precache(context)
    PrecacheResource( "particle", "particles/eldzhey_r.vpcf", context)
    PrecacheResource( "particle", "particles/leshrac_disco_tnt_new.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/jinsi.vsndevts", context )
end

function eldzhey_r:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function eldzhey_r:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function eldzhey_r:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function eldzhey_r:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("jinsi")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_eldzhey_r", {duration = duration}) 
end

modifier_eldzhey_r = class({})

function modifier_eldzhey_r:IsPurgable()
    return false
end

function modifier_eldzhey_r:OnDestroy()
    if not IsServer() then return end
end

function modifier_eldzhey_r:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( 0.25 )
end

function modifier_eldzhey_r:OnIntervalThink()
    if not IsServer() then return end
    self:Knock()
end

function modifier_eldzhey_r:Knock()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/eldzhey_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    for _,unit in pairs(targets) do
        local damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
        local dmg = unit:GetHealth() * damage_pct * 0.01 + damage
        ApplyDamage({victim = unit, attacker = self:GetParent(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})

        local distance = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
        local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
        local bump_point = self:GetParent():GetAbsOrigin() + direction * (distance + 150)

        local knockbackProperties =
        {
             center_x = bump_point.x,
             center_y = bump_point.y,
             center_z = bump_point.z,
             duration = 0.2,
             knockback_duration = 0.2,
             knockback_distance = 0,
             knockback_height = 75,
        }
     
        if unit:HasModifier("modifier_knockback") then
            unit:RemoveModifierByName("modifier_knockback")
        end
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    end
end

function modifier_eldzhey_r:GetEffectName()
    return "particles/leshrac_disco_tnt_new.vpcf"
end

function modifier_eldzhey_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end