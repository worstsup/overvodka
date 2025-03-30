LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE)
bratishkin_w = class({})
t = 0
function bratishkin_w:Precache(context)
    PrecacheResource( "particle", "particles/bratishkin_w.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w_2.vsndevts", context )
end

function bratishkin_w:HasTalent(talentName)
    if self:GetCaster():FindAbilityByName(talentName) ~= nil then
        local ability = self:GetCaster():FindAbilityByName(talentName)
        if ability and ability:GetLevel() > 0 then
            return true
        end
    end
    return false
end

function bratishkin_w:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function bratishkin_w:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function bratishkin_w:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bratishkin_w:GetBehavior()
    if self:HasTalent("special_bonus_unique_legion_commander_8") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_POINT
end

function bratishkin_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_loc = self:GetCursorPosition()
    local caster_loc = caster:GetAbsOrigin()
    local distance = self:GetCastRange(caster_loc,caster)
    local direction
    if target_loc == caster_loc or self:HasTalent("special_bonus_unique_legion_commander_8") then
        direction = caster:GetForwardVector()
    else
        direction = (target_loc - caster_loc):Normalized()
    end
    local index = DoUniqueString("bratishkin_w")
    self[index] = {}
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/bratishkin_w.vpcf",
        vSpawnOrigin        = caster_loc,
        fDistance           = self:GetSpecialValueFor("distance"),
        fStartRadius        = 175,
        fEndRadius          = 225,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 1.5,
        bDeleteOnHit        = false,
        vVelocity           = Vector(direction.x,direction.y,0) * 800,
        bProvidesVision     = false,
        ExtraData           = {index = index, damage = damage}
    }
    if self:HasTalent("special_bonus_unique_legion_commander_8") then
        for i = 1, 12 do
            ProjectileManager:CreateLinearProjectile(projectile)
            projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,30*i,0), caster:GetForwardVector()) * 1000
        end
    else
        ProjectileManager:CreateLinearProjectile(projectile)
    end
    self:GetCaster():EmitSound("bratishkin_w")
    if t == 0 then
        self:GetCaster():EmitSound("bratishkin_w_1")
        t = 1
    elseif t == 1 then
        self:GetCaster():EmitSound("bratishkin_w_2")
        t = 0
    end
end

function bratishkin_w:OnProjectileHit_ExtraData(target, location, ExtraData)
    if target then
        local was_hit = false
        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end
        if was_hit then
            return false
        end
        table.insert(self[ExtraData.index],target)
        local distance_knock = self:GetSpecialValueFor("distance_knock")
        local direction = (target:GetAbsOrigin() - location):Normalized()
        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", { duration = 0.75 * (1 - target:GetStatusResistance()), distance = distance_knock, height = 0, direction_x = direction.x, direction_y = direction.y})
        local damage = self:GetSpecialValueFor("damage")
        ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        local callback = function()
            local duration = self:GetSpecialValueFor('duration')
            target:AddNewModifier(self:GetCaster(), self, "modifier_dark_willow_debuff_fear", {duration = duration * (1 - target:GetStatusResistance())})
        end
        knockback:SetEndCallback( callback )
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end