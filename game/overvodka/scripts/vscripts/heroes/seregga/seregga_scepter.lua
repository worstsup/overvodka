LinkLuaModifier("modifier_seregga_scepter_flight", "heroes/seregga/seregga_scepter", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_seregga_scepter_slow",   "heroes/seregga/seregga_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_scepter_burn",   "heroes/seregga/seregga_scepter", LUA_MODIFIER_MOTION_NONE)

seregga_scepter = class({})

function seregga_scepter:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("path_length")
	end
end

function seregga_scepter:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_aoe_cast.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", ctx)
    PrecacheResource("model", "models/heroes/phoenix/phoenix_bird.vmdl", ctx)
    PrecacheResource("model", "models/heroes/phoenix/phoenix_wings.vmdl", ctx)
    PrecacheResource("model", "models/heroes/phoenix/phoenix_wings_fx.vmdl", ctx)
    PrecacheResource("model", "models/heroes/phoenix/phoenix_bird_head.vmdl", ctx)
    PrecacheResource("model", "models/seregga/seregga_on_phoenix.vmdl", ctx)
end

function seregga_scepter:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_seregga_scepter_flight", {duration = duration})

    self:_SwapToStop(true)

    caster:EmitSound("Hero_Phoenix.IcarusDive.Cast")
end

function seregga_scepter:_SwapToStop(bToStop)
    local caster = self:GetCaster()
    local main  = self
    local stop  = caster:FindAbilityByName("seregga_scepter_stop")
    if not stop then
        stop = caster:AddAbility("seregga_scepter_stop")
    end
    stop:SetLevel(1)
    if bToStop then
        caster:SwapAbilities("seregga_scepter", "seregga_scepter_stop", false, true)
    else
        caster:SwapAbilities("seregga_scepter", "seregga_scepter_stop", true, false)
    end
end

seregga_scepter_stop = class({})

function seregga_scepter_stop:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local flight = caster:FindModifierByName("modifier_seregga_scepter_flight")
    if flight then
        flight:_AbortNow()
    end
end

modifier_seregga_scepter_flight = class({})

function modifier_seregga_scepter_flight:IsHidden() return true end
function modifier_seregga_scepter_flight:IsPurgable() return false end
function modifier_seregga_scepter_flight:RemoveOnDeath() return true end
function modifier_seregga_scepter_flight:GetPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end

function modifier_seregga_scepter_flight:OnCreated()
    self.parent   = self:GetParent()
    self.ability  = self:GetAbility()

    self:_ApplyWearables()

    self.radius   = self.ability:GetSpecialValueFor("radius")
    self.semi_major = self.ability:GetSpecialValueFor("path_length") / 2
    self.semi_minor = self.ability:GetSpecialValueFor("path_width") / 2
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.ti       = self.ability:GetSpecialValueFor("think_interval")

    self.slow_pct = self.ability:GetSpecialValueFor("slow_pct")
    self.slow_dur = self.ability:GetSpecialValueFor("slow_duration")
    self.burn_pct = self.ability:GetSpecialValueFor("burn_maxhp_pct")
    self.burn_dur = self.ability:GetSpecialValueFor("burn_duration")

    self.impact_damage = self.ability:GetSpecialValueFor("impact_damage")

    self._aborted = false
    self._hit_once = {}
    self.elapsed = 0.0

    if not IsServer() then return end

    self.start_pos = self.parent:GetAbsOrigin()
    self.start_fwd = self.parent:GetForwardVector()
    self.fwd   = self.start_fwd
    self.right = Vector(-self.fwd.y, self.fwd.x, 0):Normalized()

    self.center       = self.start_pos + self.fwd * self.semi_major
    self.theta_start  = -math.pi/2
    self.theta_total  = 2*math.pi

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
        return
    end

    self.fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.parent
    )
    self:StartIntervalThink(self.ti)
    self:StartIntervalThink(self.ti)
end

function modifier_seregga_scepter_flight:_ApplyWearables()
    if not IsServer() then return end
    self.parent.wings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_wings.vmdl"})
    self.parent.wings:FollowEntity(self.parent, true)
    self.parent.wings_fx = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_wings_fx.vmdl"})
    self.parent.wings_fx:FollowEntity(self.parent, true)
    self.parent.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_bird_head.vmdl"})
    self.parent.head:FollowEntity(self.parent, true)
    self.parent.rider = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/seregga/seregga_on_phoenix.vmdl"})
    self.parent.rider:FollowEntity(self.parent, true)
    self.parent.rider:SetParent(self.parent, "attach_neck")
    self.parent.rider:SetLocalOrigin(Vector(0, 0, 0))
	self.parent.rider:SetLocalAngles(0, 0, 0)
	self.parent.rider:SetModelScale(1)
end

function modifier_seregga_scepter_flight:_DestroyWearables()
    if not IsServer() then return end
    if self.parent.wings and not self.parent.wings:IsNull() then
        self.parent.wings:RemoveSelf()
        self.parent.wings = nil
    end
    if self.parent.wings_fx and not self.parent.wings_fx:IsNull() then
        self.parent.wings_fx:RemoveSelf()
        self.parent.wings_fx = nil
    end
    if self.parent.head and not self.parent.head:IsNull() then
        self.parent.head:RemoveSelf()
        self.parent.head = nil
    end
    if self.parent.rider and not self.parent.rider:IsNull() then
        self.parent.rider:RemoveSelf()
        self.parent.rider = nil
    end
end

function modifier_seregga_scepter_flight:_AbortNow()
    self._aborted = true
    if not self:IsNull() then
        self:Destroy()
    end
end

function modifier_seregga_scepter_flight:OnDestroy()
    if not IsServer() then return end
    self:_DestroyWearables()
    self.parent:RemoveHorizontalMotionController(self)
    if not self._aborted then
        FindClearSpaceForUnit(self.parent, self.start_pos, true)
    else
        FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
    end
    self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
    self.parent:EmitSound("Hero_Phoenix.IcarusDive.Stop")

    if self.fx then
        ParticleManager:DestroyParticle(self.fx, false)
        ParticleManager:ReleaseParticleIndex(self.fx)
        self.fx = nil
    end

    if self.ability and not self.ability:IsNull() then
        self.ability:_SwapToStop(false)
    end
end

function modifier_seregga_scepter_flight:UpdateHorizontalMotion(unit, dt)
    if not IsServer() then return end
    self.elapsed = math.min(self.elapsed + dt, self.duration)

    local t = self.elapsed / self.duration
    local theta = self.theta_start + self.theta_total * t

    local a = self.semi_major
    local b = self.semi_minor
    local offset = self.right * (b * math.cos(theta)) + self.fwd * (a * math.sin(theta))

    local pos = self.center + offset
    pos.z = GetGroundHeight(pos, unit)
    unit:SetAbsOrigin(pos)

    local tangent = self.right * (-self.semi_minor * math.sin(theta)) + self.fwd * (self.semi_major * math.cos(theta))
tangent = Vector(tangent.x, tangent.y, 0)

if tangent:Length2D() > 0.001 then
    unit:FaceTowards( unit:GetAbsOrigin() + tangent )
end

end

function modifier_seregga_scepter_flight:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    self._aborted = true
    self:Destroy()
end

function modifier_seregga_scepter_flight:OnIntervalThink()
    if not IsServer() then return end
    local caster = self.parent
    local team   = caster:GetTeamNumber()
    local origin = caster:GetAbsOrigin()
    GridNav:DestroyTreesAroundPoint(origin, 120, false)
    local enemies = FindUnitsInRadius(
        team, origin, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )

    for _,enemy in pairs(enemies) do
        if enemy and enemy:IsAlive() then
            local idx = enemy:entindex()
            if not self._hit_once[idx] then
                enemy:AddNewModifier(caster, self.ability, "modifier_seregga_scepter_slow", { duration = self.slow_dur })
                enemy:AddNewModifier(caster, self.ability, "modifier_seregga_scepter_burn", { duration = self.burn_dur })
                enemy:AddNewModifier(caster, self.ability, "modifier_knockback",
                    {
                        center_x = caster:GetAbsOrigin().x,
                        center_y = caster:GetAbsOrigin().y,
                        center_z = caster:GetAbsOrigin().z,
                        duration = 0.6,
                        knockback_duration = 0.6,
                        knockback_distance = 200,
                        knockback_height = 50
                    })
                ApplyDamage({
                    victim      = enemy,
                    attacker    = caster,
                    damage      = self.impact_damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability     = self.ability
                })
                self._hit_once[idx] = true
            end
        end
    end
    if self.elapsed >= self.duration then
        self:Destroy()
    end
end

function modifier_seregga_scepter_flight:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }
end

function modifier_seregga_scepter_flight:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

function modifier_seregga_scepter_flight:GetModifierModelChange()
    return "models/heroes/phoenix/phoenix_bird.vmdl"
end

function modifier_seregga_scepter_flight:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

modifier_seregga_scepter_slow = class({})

function modifier_seregga_scepter_slow:IsHidden() return false end
function modifier_seregga_scepter_slow:IsPurgable() return true end

function modifier_seregga_scepter_slow:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability then return end
    self.slow_pct = self.ability:GetSpecialValueFor("slow_pct") * -1
end

function modifier_seregga_scepter_slow:OnRefresh()
    self:OnCreated()
end

function modifier_seregga_scepter_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_seregga_scepter_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow_pct or 0
end

modifier_seregga_scepter_burn = class({})

function modifier_seregga_scepter_burn:IsHidden() return false end
function modifier_seregga_scepter_burn:IsPurgable() return true end

function modifier_seregga_scepter_burn:OnCreated()
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.attacker = self:GetCaster()
    self.tick = 0.5
    self.pct = (self.ability and self.ability:GetSpecialValueFor("burn_maxhp_pct") or 0) * 0.01
    self:StartIntervalThink(self.tick)

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_seregga_scepter_burn:OnRefresh()
    if not IsServer() then return end
    self.pct = (self.ability and self.ability:GetSpecialValueFor("burn_maxhp_pct") or 0) * 0.01
end

function modifier_seregga_scepter_burn:OnIntervalThink()
    if not IsServer() then return end
    local victim = self:GetParent()
    if not victim or victim:IsNull() or not victim:IsAlive() then return end
    local maxhp = victim:GetMaxHealth()
    local dmg = maxhp * self.pct * self.tick

    ApplyDamage({
        victim      = victim,
        attacker    = self.attacker or victim,
        damage      = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability     = self.ability
    })
end