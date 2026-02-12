LinkLuaModifier("modifier_epstein_innate", "heroes/epstein/epstein_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_innate_phase", "heroes/epstein/epstein_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_innate_post", "heroes/epstein/epstein_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_epstein_innate_clone", "heroes/epstein/epstein_innate", LUA_MODIFIER_MOTION_NONE)

epstein_innate = class({})

function epstein_innate:GetIntrinsicModifierName()
    return "modifier_epstein_innate"
end

modifier_epstein_innate = class({})

function modifier_epstein_innate:IsHidden() return true end
function modifier_epstein_innate:IsPurgable() return false end
function modifier_epstein_innate:RemoveOnDeath() return false end

function modifier_epstein_innate:OnCreated()
    self.parent = self:GetParent()
    if not IsServer() then return end
    self._was_not_original_model = false
    self:StartIntervalThink(0.15)
end

function modifier_epstein_innate:OnRefresh()
    self:OnCreated()
end

function modifier_epstein_innate:_IsOriginalModelNow()
    if not self.parent or self.parent:IsNull() then return false end
    return (self.parent:GetModelName() == "models/epstein/epstein.vmdl" and (not self.parent:HasModifier("modifier_epstein_innate_phase")))
end

function modifier_epstein_innate:_HideWeapon()
    if not IsServer() then return end
    if self.parent.weapon then
        self.parent.weapon:SetModelScale(0)
        self.parent.weapon:SetParent(self.parent, "attach_hitloc")
    end
end

function modifier_epstein_innate:_ShowWeapon()
    if not IsServer() then return end
    if self.parent.weapon then
        self.parent.weapon:SetModelScale(0.5)
        self.parent.weapon:SetParent(self.parent, "attach_weapon")
        self.parent.weapon:SetLocalOrigin(Vector(0, 0, 0))
		self.parent.weapon:SetLocalAngles(0, 0, 0)
    end
end

function modifier_epstein_innate:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self.parent:GetUnitName() ~= "npc_dota_hero_beastmaster" then return end

    local is_original = self:_IsOriginalModelNow()

    if not is_original then
        self._was_not_original_model = true
        self:_HideWeapon()
        return
    end

    if self._was_not_original_model then
        self._was_not_original_model = false
        self:_ShowWeapon()
        return
    end
end
function modifier_epstein_innate:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

local function _IsValidAliveHero(h)
    if not h then return false end
    if h:IsNull() then return false end
    if not IsValidEntity(h) then return false end
    if not h:IsAlive() then return false end
    if h:IsOutOfGame() then return false end
    return true
end

function modifier_epstein_innate:GetMinHealth()
    if not IsServer() then return 0 end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not _IsValidAliveHero(parent) then return 0 end
    if not ability then return 0 end
    if parent:PassivesDisabled() then return 0 end
    if ability:IsCooldownReady() then return 1 end
    return 0
end

function modifier_epstein_innate:SpawnFakeDeathClone(parent, ability, origin)
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end

    local clone = CreateUnitByName("npc_epstein_clone", origin, false, parent, parent, parent:GetTeamNumber())
    if not clone or clone:IsNull() or not IsValidEntity(clone) then return end
    clone:RemoveGesture(ACT_DOTA_SPAWN)
    clone:StartGesture(ACT_DOTA_DIE)
    clone:SetOwner(parent)
    clone:SetControllableByPlayer(-1, false)
    clone:SetForwardVector(parent:GetForwardVector())
    clone:AddNewModifier(parent, ability, "modifier_epstein_innate_clone", { duration = 2.0 })
    Timers:CreateTimer(FrameTime(), function()
        if not clone or clone:IsNull() or not IsValidEntity(clone) then return end
        clone:ForceKill(false)
        clone:RemoveGesture(ACT_DOTA_SPAWN)
        clone:RemoveGesture(ACT_DOTA_SPAWN)
        clone:RemoveGesture(ACT_DOTA_SPAWN)
        clone:RemoveGesture(ACT_DOTA_SPAWN)
        clone:RemoveGesture(ACT_DOTA_SPAWN)
    end)

    Timers:CreateTimer(5.0, function()
        if clone and not clone:IsNull() and IsValidEntity(clone) then
            clone:AddNoDraw()
        end
    end)
end

function modifier_epstein_innate:OnTakeDamage(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.unit ~= parent then return end
    if not _IsValidAliveHero(parent) then return end
    if parent:IsIllusion() then return end

    local ability = self:GetAbility()
    if not ability then return end
    if parent:PassivesDisabled() then return end
    if not ability:IsCooldownReady() then return end
    if parent:HasModifier("modifier_epstein_innate_phase") then return end

    if not params.damage or params.damage <= 0 then return end

    local trigger_hp_pct = ability:GetSpecialValueFor("trigger_hp_pct")

    local hp = parent:GetHealth()
    local maxhp = parent:GetMaxHealth()
    if maxhp <= 0 then return end

    local hp_pct = (hp / maxhp) * 100.0
    if hp_pct > trigger_hp_pct then return end

    local origin = parent:GetAbsOrigin()

    self:SpawnFakeDeathClone(parent, ability, origin)

    parent:AddNewModifier(parent, ability, "modifier_epstein_innate_phase", {
        duration = ability:GetSpecialValueFor("phase_duration"),
        center_x = origin.x, center_y = origin.y, center_z = origin.z
    })

    ability:UseResources(false, false, false, true)
    parent:EmitSound("Hero_VoidSpirit.Dissimilate.Cast")
end

modifier_epstein_innate_phase = class({})

function modifier_epstein_innate_phase:IsHidden() return false end
function modifier_epstein_innate_phase:IsPurgable() return false end

function modifier_epstein_innate_phase:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }
end

function modifier_epstein_innate_phase:GetModifierMoveSpeed_Limit()
    return 0.1
end

function modifier_epstein_innate_phase:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

function modifier_epstein_innate_phase:OnCreated(kv)
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    if not IsServer() then return end

    if not self.ability or not _IsValidAliveHero(self.parent) then
        self:Destroy()
        return
    end

    self.center = Vector(kv.center_x or 0, kv.center_y or 0, kv.center_z or 0)
    self.radius = self.ability:GetSpecialValueFor("blink_radius")
    self.selected = Vector(self.center.x, self.center.y, self.center.z)
    self.parent:AddNoDraw()
    AddFOWViewer(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), self.radius, self:GetDuration() + 0.5, false)

    self.fx_marker = ParticleManager:CreateParticle("particles/epstein_innate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.fx_marker, 0, self.selected)
    ParticleManager:SetParticleControl(self.fx_marker, 1, Vector(self.radius + 275, 0, 1))
    ParticleManager:SetParticleControl(self.fx_marker, 2, Vector(1, 0, 0))

    local fx_start = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_exit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:ReleaseParticleIndex(fx_start)

    EmitSoundOnLocationWithCaster(self.selected, "epstein_innate", self.parent)
end

function modifier_epstein_innate_phase:OnOrder(params)
	if params.unit~=self:GetParent() then return end
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		self:SetValidTarget( params.new_pos )
	elseif
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetValidTarget( params.target:GetOrigin() )
	end
end

function modifier_epstein_innate_phase:SetValidTarget(location)
    if not IsServer() then return end

    local delta = location - self.center
    delta.z = 0
    local dist = delta:Length2D()

    if dist > self.radius then
        delta = delta:Normalized() * self.radius
    end

    local point = self.center + delta
    point = GetGroundPosition(point, self.parent)

    self.selected = point

    if self.point_marker then
        ParticleManager:SetParticleControl(self.point_marker, 0, self.selected)
    else
        self.point_marker = ParticleManager:CreateParticle("particles/epstein_innate.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.point_marker, 0, self.selected)
        ParticleManager:SetParticleControl(self.point_marker, 1, Vector(150, 0, 1))
        ParticleManager:SetParticleControl(self.point_marker, 2, Vector(1, 0, 1))
    end
end

function modifier_epstein_innate_phase:OnDestroy()
    if not IsServer() then return end

    local parent = self.parent
    local ability = self.ability
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end

    parent:RemoveNoDraw()

    if self.fx_marker then
        ParticleManager:DestroyParticle(self.fx_marker, false)
        ParticleManager:ReleaseParticleIndex(self.fx_marker)
        self.fx_marker = nil
    end

    if self.point_marker then
        ParticleManager:DestroyParticle(self.point_marker, false)
        ParticleManager:ReleaseParticleIndex(self.point_marker)
        self.point_marker = nil
    end

    FindClearSpaceForUnit(parent, self.selected, true)

    if ability then
        local heal_pct = ability:GetSpecialValueFor("heal_pct")
        if heal_pct and heal_pct > 0 and parent:IsAlive() then
            local add = math.floor(parent:GetMaxHealth() * heal_pct * 0.01)
            if add > 0 then
                parent:HealWithParams(add, ability, false, true, parent, false)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, add, nil)
            end
        end

        local post_invuln = ability:GetSpecialValueFor("post_invuln")
        if post_invuln and post_invuln > 0 then
            parent:AddNewModifier(parent, ability, "modifier_epstein_innate_post", { duration = post_invuln })
        end
    end

    parent:EmitSound("Hero_VoidSpirit.Dissimilate.TeleportIn")
end

modifier_epstein_innate_post = class({})

function modifier_epstein_innate_post:IsHidden() return true end
function modifier_epstein_innate_post:IsPurgable() return false end

function modifier_epstein_innate_post:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

modifier_epstein_innate_clone = class({})

function modifier_epstein_innate_clone:IsHidden() return true end
function modifier_epstein_innate_clone:IsPurgable() return false end

function modifier_epstein_innate_clone:CheckState()
    return {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end