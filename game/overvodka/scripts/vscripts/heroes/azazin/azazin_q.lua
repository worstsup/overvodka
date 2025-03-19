LinkLuaModifier("modifier_azazin_q_pull", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_azazin_q_tree_walk_aura", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_azazin_q_tree_walk", "heroes/azazin/azazin_q", LUA_MODIFIER_MOTION_NONE)
azazin_q = class({})
k = 0
function azazin_q:Precache(context)
    PrecacheResource("particle", "particles/azazin_q.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_hero_pudge.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_1.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_2.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q_3.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/azazin_q.vsndevts", context)
	PrecacheResource("model", "models/props_tree/ti7/ggbranch.vmdl", context)
end

function azazin_q:GetCastRange(location, target)
    return self:GetSpecialValueFor("cast_range")
end

function azazin_q:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function azazin_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    if not target or target:IsInvulnerable() then
        return
    end

    local projectile_speed = 1600

    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/azazin_q.vpcf",
        iMoveSpeed = projectile_speed,
        bDodgeable = true,
        bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(info)
	caster:EmitSound("azazin_q")
	if k == 0 then
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_1", caster)
		k = 1
	elseif k == 1 then
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_2", caster)
		k = 2
	elseif k == 2 then
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"azazin_q_3", caster)
		k = 0
	end
end

function azazin_q:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not target then return end

    local caster = self:GetCaster()
    local min_pull = self:GetSpecialValueFor("min_pull")
    local max_pull = self:GetSpecialValueFor("max_pull")
    local pull_duration = 0.25
    local current_distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    local effective_distance = math.min(current_distance, max_pull)
    local pull_distance = effective_distance - min_pull
    if pull_distance <= 0 then 
        pull_distance = -pull_distance
    end
    if target:IsMagicImmune() or target:IsDebuffImmune() then
        local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        caster:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
            duration = pull_duration,
            distance = pull_distance,
            dir_x = direction.x,
            dir_y = direction.y,
            other_ent = target:entindex()
        })
        caster:EmitSound("Hero_Pudge.AttackHookImpact")
        return
    end

    if target:IsInvulnerable() then return end
    local directionCaster = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
    local directionTarget = -directionCaster

    caster:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
        duration = pull_duration,
        distance = pull_distance,
        dir_x = directionCaster.x,
        dir_y = directionCaster.y,
        other_ent = target:entindex()
    })
    target:AddNewModifier(caster, self, "modifier_azazin_q_pull", {
        duration = pull_duration,
        distance = pull_distance,
        dir_x = directionTarget.x,
        dir_y = directionTarget.y,
        other_ent = caster:entindex()
    })

    caster:EmitSound("Hero_Pudge.AttackHookImpact")
    target:EmitSound("Hero_Pudge.AttackHookImpact")
end


modifier_azazin_q_pull = class({})

function modifier_azazin_q_pull:IsHidden() return true end
function modifier_azazin_q_pull:IsPurgable() return false end
function modifier_azazin_q_pull:RemoveOnDeath() return true end
function modifier_azazin_q_pull:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_azazin_q_pull:OnCreated(kv)
    if not IsServer() then return end
    self.distance = kv.distance or 0
    self.duration = kv.duration or 0.3
    self.dir = Vector(kv.dir_x or 0, kv.dir_y or 0, 0):Normalized()
    self.speed = self.distance / self.duration
    self.elapsed = 0
    self.origin = self:GetParent():GetAbsOrigin()
    if kv.other_ent then
        self.other_ent = EntIndexToHScript(tonumber(kv.other_ent))
    end
    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_azazin_q_pull:UpdateHorizontalMotion(unit, dt)
    if not IsServer() then return end
    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.duration then
        dt = self.duration - (self.elapsed - dt)
        local newPos = unit:GetAbsOrigin() + self.dir * self.speed * dt
        unit:SetAbsOrigin(newPos)
        self:OnHorizontalMotionInterrupted(unit)
        return
    end
    local newPos = unit:GetAbsOrigin() + self.dir * self.speed * dt
    unit:SetAbsOrigin(newPos)
end

function modifier_azazin_q_pull:OnHorizontalMotionInterrupted(unit)
    if not IsServer() then return end
    self:Destroy()
end

function modifier_azazin_q_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
	self:GetCaster():StopSound("azazin_q")
    local parent = self:GetParent()
    if self.other_ent and not self.other_ent:IsNull() then
        local new_forward = (self.other_ent:GetAbsOrigin() - parent:GetAbsOrigin()):Normalized()
        parent:SetForwardVector(new_forward)
		parent:MoveToTargetToAttack(self.other_ent)
        local midpoint = (parent:GetAbsOrigin() + self.other_ent:GetAbsOrigin()) * 0.5
        self:SpawnTreeRing(midpoint)
        if self:GetAbility():GetSpecialValueFor("wark_through_trees") == 1 then
            CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_azazin_q_tree_walk_aura", {duration = self:GetAbility():GetSpecialValueFor("ring_duration")}, midpoint, self:GetCaster():GetTeamNumber(), false)
        end
    end
end

function modifier_azazin_q_pull:SpawnTreeRing(point)
    if not IsServer() then return end
    local ability = self:GetAbility()
    local ring_radius = ability:GetSpecialValueFor("radius")
    local ring_duration = ability:GetSpecialValueFor("ring_duration")
    local num_trees = 24
    for i = 1, num_trees do
        local angle = math.rad((360 / num_trees) * i)
        local treePos = point + Vector(math.cos(angle), math.sin(angle), 0) * ring_radius
        CreateTempTreeWithModel(treePos, ring_duration, "models/props_tree/ti7/ggbranch.vmdl")
    end
	GridNav:DestroyTreesAroundPoint( point, ring_radius - 50, false )
    AddFOWViewer(self:GetCaster():GetTeamNumber(), point, ring_radius, ring_duration, false)
end

function modifier_azazin_q_pull:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

modifier_azazin_q_tree_walk_aura = class({})
function modifier_azazin_q_tree_walk_aura:IsHidden() return true end
function modifier_azazin_q_tree_walk_aura:IsPurgable() return false end
function modifier_azazin_q_tree_walk_aura:IsAura() return true end
function modifier_azazin_q_tree_walk_aura:GetModifierAura() return "modifier_azazin_q_tree_walk" end
function modifier_azazin_q_tree_walk_aura:GetAuraDuration() return 0.1 end
function modifier_azazin_q_tree_walk_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") + 100 end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_azazin_q_tree_walk_aura:GetAuraSearchFlags() return 0 end

modifier_azazin_q_tree_walk = class({})
function modifier_azazin_q_tree_walk:IsHidden() return true end
function modifier_azazin_q_tree_walk:IsPurgable() return false end
function modifier_azazin_q_tree_walk:CheckState()
    return {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = self:GetCaster() == self:GetParent(),
    }
end