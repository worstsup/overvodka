LinkLuaModifier("modifier_mazellov_w_thinker", "heroes/mazellov/mazellov_w", LUA_MODIFIER_MOTION_NONE)

mazellov_w = class({})

function Mazellov_EnableReturnAbility(caster, base_ability)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end
    if not base_ability or base_ability:IsNull() then return end

    if base_ability:IsStolen() then
        local return_ability = caster:FindAbilityByName("mazellov_d")
        local added_temporarily = false

        if not return_ability or return_ability:IsNull() then
            return_ability = caster:AddAbility("mazellov_d")
            added_temporarily = return_ability ~= nil
            if return_ability and not return_ability:IsNull() then
                return_ability:SetStolen(true)
            end
        end

        if not return_ability or return_ability:IsNull() then return end

        return_ability:SetLevel(1)
        return_ability:SetHidden(false)
        return_ability:SetActivated(true)

        base_ability:SetHidden(true)
        base_ability:SetActivated(false)
        caster:SwapAbilities(base_ability:GetAbilityName(), return_ability:GetAbilityName(), false, true)

        caster.mazellov_orb_return_enabled = true
        caster.mazellov_orb_return_base_name = base_ability:GetAbilityName()
        caster.mazellov_orb_return_name = return_ability:GetAbilityName()
        caster.mazellov_orb_return_added_temporarily = added_temporarily
        return
    end

    local return_ability = caster:FindAbilityByName("mazellov_d")
    if not return_ability or return_ability:IsNull() then return end

    return_ability:SetActivated(true)
    caster.mazellov_orb_return_enabled = true
    caster.mazellov_orb_return_base_name = nil
    caster.mazellov_orb_return_name = return_ability:GetAbilityName()
    caster.mazellov_orb_return_added_temporarily = false
end

function Mazellov_DisableReturnAbility(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end
    if not caster.mazellov_orb_return_enabled then return end

    local return_name = caster.mazellov_orb_return_name or "mazellov_d"
    local return_ability = caster:FindAbilityByName(return_name)
    local base_name = caster.mazellov_orb_return_base_name
    local base_ability = base_name and caster:FindAbilityByName(base_name) or nil

    if base_ability and not base_ability:IsNull() and return_ability and not return_ability:IsNull() then
        caster:SwapAbilities(base_ability:GetAbilityName(), return_ability:GetAbilityName(), true, false)
        base_ability:SetHidden(false)
        base_ability:SetActivated(true)
        return_ability:SetHidden(true)
        return_ability:SetActivated(false)
    elseif return_ability and not return_ability:IsNull() then
        return_ability:SetActivated(false)
    end

    caster.mazellov_orb_return_enabled = nil
    caster.mazellov_orb_return_base_name = nil
    caster.mazellov_orb_return_name = nil
    caster.mazellov_orb_return_added_temporarily = nil
end

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
    Mazellov_EnableReturnAbility(self:GetCaster(), self:GetAbility())
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
    Mazellov_DisableReturnAbility(self:GetCaster())
end

function modifier_mazellov_w_thinker:IsHidden() return true end
function modifier_mazellov_w_thinker:IsPurgable() return false end
