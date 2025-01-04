dave_loonboon = class({})
LinkLuaModifier( "modifier_dave_loonboon", "heroes/dave/dave_loonboon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_loonboon_plants", "heroes/dave/dave_loonboon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function dave_loonboon:OnSpellStart()
    EmitSoundOn( "dave_loonboon", self:GetCaster() )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dave_loonboon", { duration = self:GetSpecialValueFor( "duration" ) } )
end

function dave_loonboon:OnProjectileHit(target, location)
    if target then
        self.stun_dur = self:GetSpecialValueFor( "stun_dur" )
        self.damage = self:GetSpecialValueFor( "damage" )
        target:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = self.stun_dur })
        ApplyDamage({
            victim = target,
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
        })
    end
end

--------------------------------------------------------------------------------
modifier_dave_loonboon = class({})

function modifier_dave_loonboon:IsPurgable()
    return false
end

function modifier_dave_loonboon:OnCreated( kv )
    self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
    self.facet = self:GetAbility():GetSpecialValueFor( "hasfacet" )
    if self.facet == 1 then
        local sunflower = CreateUnitByName(
            "npc_penek_4",
            self:GetParent():GetAbsOrigin(),
            true,
            self:GetParent(),
            nil,
            self:GetParent():GetTeam()
        )
        EmitSoundOn("gribochki", self:GetParent())
    end
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_dave_loonboon:OnIntervalThink()
    local plants = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        12000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)
    for _,unit in pairs(plants) do
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_dave_loonboon_plants", { duration = 1.55 } )
    end
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),   -- int, your team number
        self:GetParent():GetOrigin(),   -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        self.radius,    -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,    -- int, team filter
        DOTA_UNIT_TARGET_HERO,  -- int, type filter
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,  -- int, flag filter
        FIND_CLOSEST,   -- int, order filter
        false   -- bool, can grow cache
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
        ProjectileManager:CreateLinearProjectile(arrow_projectile)
    end
end


function modifier_dave_loonboon:OnRemoved()
    if self.facet == 1 then
        local sunflower = CreateUnitByName(
            "npc_penek_4",
            self:GetParent():GetAbsOrigin(),
            true,
            self:GetParent(),
            nil,
            self:GetParent():GetTeam()
        )
        EmitSoundOn("gribochki", self:GetParent())
    end
end

--------------------------------------------------------------------------------

function modifier_dave_loonboon:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
function modifier_dave_loonboon_plants:IsPurgable()
    return false
end

function modifier_dave_loonboon_plants:OnCreated( kv )
    self.bonus_as_aura = self:GetAbility():GetSpecialValueFor( "bonus_as_aura" )
end

--------------------------------------------------------------------------------

function modifier_dave_loonboon_plants:OnRemoved()
end

--------------------------------------------------------------------------------

function modifier_dave_loonboon_plants:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_dave_loonboon_plants:GetModifierAttackSpeedBonus_Constant( params )
    return self.bonus_as_aura
end

function modifier_dave_loonboon_plants:GetEffectName()
    return "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf"
end

function modifier_dave_loonboon_plants:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end