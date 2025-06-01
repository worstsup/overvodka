dave_loonboon = class({})
LinkLuaModifier( "modifier_dave_loonboon", "heroes/dave/dave_loonboon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_loonboon_plants", "heroes/dave/dave_loonboon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_sunflower_passive", "heroes/dave/dave_sunflower", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_sunflower_passive_aura", "heroes/dave/dave_sunflower", LUA_MODIFIER_MOTION_NONE )

function dave_loonboon:Precache(context)
    PrecacheResource( "soundfile", "soundevents/dave_loonboon.vsndevts", context )
    PrecacheResource( "particle", "particles/invoker_chaos_meteor_dave.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf", context )
    PrecacheResource("soundfile", "soundevents/gribochki.vsndevts", context )
    PrecacheResource("model", "pvz/sunflower_defaultflower_mesh.vmdl", context )
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", context )
end

hit = false
function dave_loonboon:OnSpellStart()
    if not IsServer() then return end
    EmitSoundOn( "dave_loonboon", self:GetCaster() )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dave_loonboon", { duration = self:GetSpecialValueFor( "duration" ) } )
end

function dave_loonboon:OnProjectileHitHandle(target, location, projectilehandle)
    if not target then return end
    local caster = self:GetCaster()
    local ability = self
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_dur")
    if not hit then
        hit = true
        target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_duration })
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        })
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),
            target:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )
        for _, enemy in pairs(enemies) do
            if enemy ~= target then
                local projectile_direction = (enemy:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
                local projectile_info = {
                    Ability = self,
                    EffectName = "particles/invoker_chaos_meteor_dave.vpcf",
                    vSpawnOrigin = target:GetAbsOrigin(),
                    fDistance = 900,
                    fStartRadius = 115,
                    fEndRadius = 120,
                    Source = caster,
                    bHasFrontalCone = false,
                    bReplaceExisting = false,
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    bDeleteOnHit = true,
                    vVelocity = projectile_direction * 1000,
                    bProvidesVision = true,
                    iVisionRadius = 200,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                }
                ProjectileManager:DestroyLinearProjectile(projectilehandle)
                ProjectileManager:CreateLinearProjectile(projectile_info)
                return
            end
        end
    else
        target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = stun_duration })
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        })
    end
end

modifier_dave_loonboon = class({})

function modifier_dave_loonboon:IsPurgable()
    return false
end

function modifier_dave_loonboon:OnCreated( kv )
    if not IsServer() then return end
    self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
    self.facet = self:GetAbility():GetSpecialValueFor( "hasfacet" )
    if self.facet == 1 and self:GetParent():FindAbilityByName("dave_sunflower") then
        local sunflower = CreateUnitByName("npc_sunflower", self:GetParent():GetAbsOrigin(), true, self:GetParent(), nil, self:GetParent():GetTeamNumber())
        sunflower:SetOwner(self:GetParent())
        FindClearSpaceForUnit(sunflower, sunflower:GetAbsOrigin(), true)
        local ability = self:GetParent():FindAbilityByName("dave_sunflower")
        sunflower:AddNewModifier(self:GetParent(), ability, "modifier_dave_sunflower_passive", {duration = ability:GetSpecialValueFor('duration')})
        EmitSoundOn("gribochki", self:GetParent())
    end
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_dave_loonboon:OnIntervalThink()
    if not IsServer() then return end
    local plants = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        12000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
        FIND_ANY_ORDER,
        false)
    for _,unit in pairs(plants) do
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_dave_loonboon_plants", { duration = 1.55 } )
    end
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )
    if #enemies == 0 then return end
    t = 0
    for _,enemy in pairs(enemies) do
        if t == 1 then return end
        local target = enemy:GetAbsOrigin()
        local projectile_direction = (target - self:GetParent():GetAbsOrigin())
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()
        local distince = 900
        local arrow_projectile = {
            Ability             = self:GetAbility(),
            EffectName          = "particles/invoker_chaos_meteor_dave.vpcf",
            vSpawnOrigin        = self:GetParent():GetAbsOrigin(),
            fDistance           = distince,
            fStartRadius        = 115,
            fEndRadius          = 120,
            Source              = self:GetParent(),
            bHasFrontalCone     = false,
            bReplaceExisting    = false,
            iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bDeleteOnHit        = true,
            vVelocity           = projectile_direction * 1000,
            bProvidesVision     = true,
            iVisionRadius       = 200,
            iVisionTeamNumber   = self:GetParent():GetTeamNumber(),
        }
        t = t + 1
        hit = false
        ProjectileManager:CreateLinearProjectile(arrow_projectile)
    end
end


function modifier_dave_loonboon:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end
function modifier_dave_loonboon:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

function modifier_dave_loonboon:GetModifierMoveSpeedBonus_Percentage( params )
    return self.move_speed
end

function modifier_dave_loonboon:GetEffectName()
    return "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf"
end

function modifier_dave_loonboon:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_dave_loonboon_plants = class({})

function modifier_dave_loonboon_plants:IsPurgable()
    return false
end

function modifier_dave_loonboon_plants:OnCreated( kv )
    self.bonus_as_aura = self:GetAbility():GetSpecialValueFor( "bonus_as_aura" )
end


function modifier_dave_loonboon_plants:OnRemoved()
end


function modifier_dave_loonboon_plants:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_dave_loonboon_plants:GetModifierAttackSpeedBonus_Constant( params )
    return self.bonus_as_aura
end

function modifier_dave_loonboon_plants:GetEffectName()
    return "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf"
end

function modifier_dave_loonboon_plants:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end