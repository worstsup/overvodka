LinkLuaModifier("modifier_bombardiro_bombs",  "units/bombardiro/bombardiro_bombs", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
bombardiro_bombs = class({})

function bombardiro_bombs:IsStealable()
    return false
end

function bombardiro_bombs:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function bombardiro_bombs:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bombardiro_bombs:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function bombardiro_bombs:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function bombardiro_bombs:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    if point == self:GetCaster():GetAbsOrigin() then
        point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector()
    end
    local radius = self:GetSpecialValueFor("radius")
    local duration = 2

    local direction = (point - self:GetCaster():GetAbsOrigin())
    direction.z = 0
    direction = direction:Normalized()

    CreateModifierThinker(caster, self, "modifier_bombardiro_bombs", {duration = duration, target_point_x = point.x , target_point_y = point.y}, point, caster:GetTeamNumber(), false)

end

modifier_bombardiro_bombs = class({})

function modifier_bombardiro_bombs:IsHidden() return true end

function modifier_bombardiro_bombs:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local particle = "particles/bombardiro_bombs_marker.vpcf"
    self.marker_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.marker_particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.marker_particle, 1, Vector(self.radius, 1, self.radius * (-1)))
    self:AddParticle(self.marker_particle, false, false, -1, false, false)
    
    local calldown_first_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(calldown_first_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(calldown_first_particle, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(calldown_first_particle)
    
    self:StartIntervalThink(2)
end

function modifier_bombardiro_bombs:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Gyrocopter.CallDown.Damage")
    local damageTable = { attacker = self:GetCaster(), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() }
    local flag = 0
    local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
    for _,enemy in pairs(enemies) do
        damageTable.victim = enemy
        damageTable.damage = self.damage * enemy:GetMaxHealth() * 0.01
        ApplyDamage( damageTable )
        enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_generic_stunned_lua", { duration = self:GetAbility():GetSpecialValueFor("duration") } )
    end

end