thomas_ability_three = class({})

LinkLuaModifier( "modifier_thomas_ability_three_buff", "bebra.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_thomas_ability_three_debuff", "bebra.lua", LUA_MODIFIER_MOTION_NONE)

function thomas_ability_three:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end
    local distance = 900
    local speed = 1200

    local caster_origin = self:GetCaster():GetAbsOrigin()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + self:GetCaster():GetForwardVector() * 50
        vDirection = self:GetCaster():GetForwardVector()
    end

    CreateModifierThinker(self:GetCaster(), self, "modifier_thomas_ability_three_buff", {
        duration        = distance / speed,
        direction_x     = vDirection.x,
        direction_y     = vDirection.y,
    }, vStartLocation, self:GetCaster():GetTeamNumber(), false)
end

modifier_thomas_ability_three_buff = class({})

function modifier_thomas_ability_three_buff:OnCreated( params )
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.speed = 1200
    self.total_damage = self.ability:GetSpecialValueFor("damage")
    self.duration           = params.duration
    self.direction          = Vector(params.direction_x, params.direction_y, 0)
    self.direction_angle    = math.deg(math.atan2(self.direction.x, self.direction.y))

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/kotl_illuminate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle, 1, self.direction * self.speed)
    ParticleManager:SetParticleControl(self.particle, 3, self.parent:GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self.hit_targets = {}
    self:OnIntervalThink()
    self:StartIntervalThink(FrameTime())
end

function modifier_thomas_ability_three_buff:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    local damage = self.total_damage
    local valid_targets =   {}

    for _, target in pairs(targets) do
        local target_pos    = target:GetAbsOrigin()
        local target_angle  = math.deg(math.atan2((target_pos.x - self.parent:GetAbsOrigin().x), target_pos.y - self.parent:GetAbsOrigin().y))
        local difference = math.abs(self.direction_angle - target_angle)
        if difference <= 90 or difference >= 270 then
            table.insert(valid_targets, target)
        end
    end

    for _, target in pairs(valid_targets) do
        local hit_already = false
        for _, hit_target in pairs(self.hit_targets) do
            if hit_target == target then
                hit_already = true
                break
            end
        end
        if not hit_already then

            local damageTable = 
            {
                victim          = target,
                damage          = damage,
                damage_type     = DAMAGE_TYPE_MAGICAL,
                damage_flags    = DOTA_DAMAGE_FLAG_NONE,
                attacker        = self.caster,
                ability         = self.ability
            }
            
            ApplyDamage(damageTable)

            target:AddNewModifier(self.caster, self.ability, "modifier_thomas_ability_three_debuff", {duration = self.ability:GetSpecialValueFor("duration") * (1-target:GetStatusResistance())})

            target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target")
            target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target.Secondary")

            local particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact_small.vpcf"
            if target:IsHero() then
                particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf"
            end

            local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            table.insert(self.hit_targets, target)
        end
    end

    self.parent:SetAbsOrigin(self.parent:GetAbsOrigin() + (self.direction * self.speed * FrameTime()))
end

function modifier_thomas_ability_three_buff:OnDestroy()
    if not IsServer() then return end
    self.parent:RemoveSelf()
end

modifier_thomas_ability_three_debuff = class({})

function modifier_thomas_ability_three_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_thomas_ability_three_debuff:CheckState()
    if not self:GetCaster():HasShard() then return end
    return 
    {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_thomas_ability_three_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end