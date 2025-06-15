LinkLuaModifier("modifier_mazellov_w_thinker", "heroes/mazellov/mazellov_w", LUA_MODIFIER_MOTION_NONE)

mazellov_w = class({})

function mazellov_w:GetCastRange(location, target)
    return self:GetSpecialValueFor("max_distance")
end

function mazellov_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local direction = (point - caster:GetAbsOrigin()):Normalized()
    if point == caster:GetAbsOrigin() then
        direction = caster:GetForwardVector()
    end
    direction.z = 0
    caster:EmitSound("mazellov_w_start")
    local radius = self:GetSpecialValueFor("projectile_width")
    local damage = self:GetSpecialValueFor("damage")

    local speed = self:GetSpecialValueFor("projectile_speed")
    local distance = self:GetSpecialValueFor("max_distance")
    local travel_time = distance / speed

    local spawn_origin = caster:GetAbsOrigin()

    local proj_info = {
        Ability = self,
        EffectName = "particles/ringmaster_wheel_projectile_linear.vpcf",
        vSpawnOrigin = spawn_origin,
        fDistance = distance,
        fStartRadius = radius,
        fEndRadius = radius,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        vVelocity = direction * speed,
        bProvidesVision = true,
        iVisionRadius = 300,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {
            damage = damage,
            radius = radius,
            speed = speed,
            x = spawn_origin.x,
            y = spawn_origin.y,
            z = spawn_origin.z,
            dir_x = direction.x,
            dir_y = direction.y,
            dir_z = direction.z,
            time = GameRules:GetGameTime()
        }
    }

    local projectile_id = ProjectileManager:CreateLinearProjectile(proj_info)

    local thinker = CreateModifierThinker(caster, self, "modifier_mazellov_w_thinker", {
        duration = travel_time,
        damage = damage,
        radius = radius,
        speed = speed,
        dir_x = direction.x,
        dir_y = direction.y,
        dir_z = direction.z,
        x = spawn_origin.x,
        y = spawn_origin.y,
        z = spawn_origin.z
    }, spawn_origin, caster:GetTeamNumber(), false)

    caster.mazellov_orb_direction = direction
    caster.mazellov_orb_start = spawn_origin
    caster.mazellov_orb_speed = speed
    caster.mazellov_orb_start_time = GameRules:GetGameTime()
    caster.mazellov_orb_expire = GameRules:GetGameTime() + travel_time
    caster.mazellov_orb_projectile = projectile_id
    caster.mazellov_orb_teleported = false
end

function mazellov_w:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        ApplyDamage({
            victim = target,
            attacker = self:GetCaster(),
            ability = self,
            damage = ExtraData.damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end
end

modifier_mazellov_w_thinker = class({})

function modifier_mazellov_w_thinker:OnCreated(kv)
    if not IsServer() then return end
    local secondary = self:GetCaster():FindAbilityByName("mazellov_d")
    if secondary and not secondary:IsNull() then
        secondary:SetActivated(true)
    end
    self.damage = kv.damage * 0.10
    self.radius = kv.radius
    self.speed = kv.speed

    self.origin = Vector(kv.x, kv.y, kv.z)
    self.direction = Vector(kv.dir_x, kv.dir_y, kv.dir_z):Normalized()
    self.start_time = GameRules:GetGameTime()

    self:StartIntervalThink(0.2)
end

function modifier_mazellov_w_thinker:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local time_passed = GameRules:GetGameTime() - self.start_time
    local current_pos = self.origin + self.direction * self.speed * time_passed

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        current_pos,
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _,enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            ability = ability,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end
end

function modifier_mazellov_w_thinker:OnDestroy()
    local secondary = self:GetCaster():FindAbilityByName("mazellov_d")
    if secondary and not secondary:IsNull() and secondary:IsActivated() then
        secondary:SetActivated(false)
    end
end

function modifier_mazellov_w_thinker:IsHidden() return true end
function modifier_mazellov_w_thinker:IsPurgable() return false end
