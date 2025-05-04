LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_w_fear", "heroes/bratishkin/bratishkin_w", LUA_MODIFIER_MOTION_HORIZONTAL)
bratishkin_w = class({})
t = 0
function bratishkin_w:Precache(context)
    PrecacheResource( "particle", "particles/bratishkin_w.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_w_2.vsndevts", context )
end

function bratishkin_w:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
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
function bratishkin_w:GetVectorTargetRange()
	return self:GetSpecialValueFor("distance")
end
function bratishkin_w:OnVectorCastStart(vStartLocation, vDirection)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local direction = self:GetVectorDirection()
    local caster_origin = caster:GetAbsOrigin()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + caster:GetForwardVector() * 50
        direction = caster:GetForwardVector()
    end
    local index = DoUniqueString("bratishkin_w")
    self[index] = {}
    local projectile =
    {
        Ability             = self,
        EffectName          = "particles/bratishkin_w.vpcf",
        vSpawnOrigin        = vStartLocation,
        fDistance           = self:GetVectorTargetRange(),
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
    ProjectileManager:CreateLinearProjectile(projectile)
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
    if not IsServer() then return end
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
        table.insert(self[ExtraData.index], target)
        local distance_knock = self:GetSpecialValueFor("distance_knock")
        local direction = (target:GetAbsOrigin() - location):Normalized()
        local knockback = target:AddNewModifier( self:GetCaster(), self, "modifier_generic_knockback_lua", 
            { duration = 0.75, distance = distance_knock, height = 0, direction_x = direction.x, direction_y = direction.y })
        local damage = self:GetSpecialValueFor("damage")
        ApplyDamage({
            victim = target, 
            attacker = self:GetCaster(), 
            damage = damage, 
            damage_type = DAMAGE_TYPE_MAGICAL, 
            ability = self
        })
        local callback = function()
            local duration = self:GetSpecialValueFor("duration")
            target:AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_w_fear", {
                duration = duration * (1 - target:GetStatusResistance()),
                dir_x = direction.x,
                dir_y = direction.y,
            })
        end
        knockback:SetEndCallback(callback)
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.arrows then
            self[ExtraData.index] = nil
        end
    end
end

modifier_bratishkin_w_fear = class({})

function modifier_bratishkin_w_fear:IsHidden() 
    return false 
end

function modifier_bratishkin_w_fear:IsDebuff() 
    return true 
end

function modifier_bratishkin_w_fear:IsPurgable() 
    return true 
end

function modifier_bratishkin_w_fear:RemoveOnDeath() 
    return true 
end

function modifier_bratishkin_w_fear:OnCreated(kv)
    if not IsServer() then return end
    self.duration = kv.duration or 1.5
    self.dir = Vector(kv.dir_x or 0, kv.dir_y or 0, 0):Normalized()
    self:GetParent():MoveToPosition( self:GetParent():GetAbsOrigin() + self.dir * 2000 )
end


function modifier_bratishkin_w_fear:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
end

function modifier_bratishkin_w_fear:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_bratishkin_w_fear:GetModifierProvidesFOWVision()
	return 1
end

function modifier_bratishkin_w_fear:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }
end
function modifier_bratishkin_w_fear:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf"
end
function modifier_bratishkin_w_fear:GetEffectName()
    return "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf"
end

function modifier_bratishkin_w_fear:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end