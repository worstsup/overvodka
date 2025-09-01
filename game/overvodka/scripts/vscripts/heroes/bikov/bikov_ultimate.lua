bikov_ultimate = class({})

LinkLuaModifier("modifier_bikov_r_caster",      "heroes/bikov/bikov_ultimate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bikov_r_hold",        "heroes/bikov/bikov_ultimate", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_bikov_r_throw_timer", "heroes/bikov/bikov_ultimate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

function bikov_ultimate:Precache(ctx)
    PrecacheResource("soundfile",  "soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", ctx)
    PrecacheResource("soundfile",  "soundevents/bikov_sounds.vsndevts", ctx)
    PrecacheResource("particle",   "particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", ctx)
    PrecacheResource("particle",   "particles/units/heroes/hero_primal_beast/primal_beast_footstomp.vpcf", ctx)
end

function bikov_ultimate:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function bikov_ultimate:GetChannelTime()
    return self:GetSpecialValueFor("hold_time")
end

function bikov_ultimate:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then
        caster:Interrupt()
        return
    end
    local hold = self:GetChannelTime()
    self._grabbed = target
    self._hold = target:AddNewModifier(caster, self, "modifier_bikov_r_hold", { duration = hold })
    caster:AddNewModifier(caster, self, "modifier_bikov_r_caster", { duration = hold })
    local windup   = math.max(0.0, self:GetSpecialValueFor("throw_windup") or 0.45)
    local animRate = self:GetSpecialValueFor("throw_anim_rate") or 1.0

    self._windup_timer = Timers:CreateTimer(math.max(0.03, hold - windup), function()
        if not caster:IsChanneling() then return end
        caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, animRate)
    end)

    EmitSoundOn("bikov_r", caster)
end

function bikov_ultimate:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    if self._windup_timer then
        Timers:RemoveTimer(self._windup_timer)
        self._windup_timer = nil
    end
    local caster = self:GetCaster()
    if caster and not caster:IsNull() then
        caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
    end
    local cm = caster and caster:FindModifierByName("modifier_bikov_r_caster")
    if cm then cm:Destroy() end
    local target = self._grabbed
    self._grabbed = nil
    if self._hold and not self._hold:IsNull() then
        self._hold:Destroy()
    end
    self._hold = nil

    if not target or target:IsNull() then return end

    if bInterrupted then
        StopSoundOn("bikov_r", caster)
        FindClearSpaceForUnit(target, caster:GetAbsOrigin() + caster:GetForwardVector()*80, true)
        return
    end
    self:ThrowTarget(caster, target)
end

function bikov_ultimate:ThrowTarget(caster, target)
    if not IsServer() then return end
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

    local distance = self:GetSpecialValueFor("throw_distance")
    local height   = self:GetSpecialValueFor("throw_height")
    local dur      = self:GetSpecialValueFor("throw_duration")

    target:RemoveModifierByName("modifier_knockback")
    target:AddNewModifier(caster, self, "modifier_knockback", {
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z,
        duration = dur,
        knockback_duration = dur,
        knockback_distance = distance,
        knockback_height   = height,
        should_stun = 0,
    })

    target:AddNewModifier(caster, self, "modifier_bikov_r_throw_timer", {
        duration = dur
    })
end


modifier_bikov_r_caster = class({})

function modifier_bikov_r_caster:IsHidden() return true end
function modifier_bikov_r_caster:IsPurgable() return false end

function modifier_bikov_r_caster:OnCreated()
    self._scale = 0
    local ab = self:GetAbility()
    if ab and not ab:IsNull() then
        self._scale = ab:GetSpecialValueFor("caster_scale") or 0
    end
end

function modifier_bikov_r_caster:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_bikov_r_caster:CheckState()
    return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = self:GetParent():HasShard(),
    }
end

function modifier_bikov_r_caster:GetModifierDisableTurning() return 1 end
function modifier_bikov_r_caster:GetModifierModelScale()     return self._scale or 0 end


modifier_bikov_r_hold = class({})

function modifier_bikov_r_hold:IsHidden() return false end
function modifier_bikov_r_hold:IsPurgable() return true end
function modifier_bikov_r_hold:IsStunDebuff() return true end

function modifier_bikov_r_hold:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.parent = self:GetParent()

    self._orig_angles = self.parent:GetAnglesAsVector()

    local fallbacks = { "attach_attack2", "attach_attack1", "attach_hitloc" }
    self.attach_name = "attach_attack2"
    for _,name in ipairs(fallbacks) do
        if self.caster:ScriptLookupAttachment(name) ~= 0 then
            self.attach_name = name
            break
        end
    end

    local hit = self.parent:ScriptLookupAttachment("attach_hitloc")
    local hit_pos = (hit ~= 0) and self.parent:GetAttachmentOrigin(hit) or self.parent:GetAbsOrigin()
    self.delta = self.parent:GetAbsOrigin() - hit_pos

    if not self:ApplyHorizontalMotionController() then self:Destroy() return end
    if not self:ApplyVerticalMotionController()   then self:Destroy() return end
    self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST)
end

function modifier_bikov_r_hold:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]           = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

function modifier_bikov_r_hold:UpdateHorizontalMotion(me, dt)
    if self.parent:IsOutOfGame() or self.parent:IsInvulnerable() then self:Destroy() return end
    local attach = self.caster:ScriptLookupAttachment(self.attach_name)
    local pos    = self.caster:GetAttachmentOrigin(attach)
    local ang    = self.caster:GetAttachmentAngles(attach)

    local d = RotatePosition(Vector(0,0,0), QAngle(180-ang.x, 180+ang.y, 0), self.delta)
    pos = pos + d

    me:SetLocalAngles(180-ang.x, 180+ang.y, 0)
    me:SetOrigin(pos)
end

function modifier_bikov_r_hold:UpdateVerticalMotion(me, dt)
    local a  = self.caster:ScriptLookupAttachment(self.attach_name)
    local p  = self.caster:GetAttachmentOrigin(a)
    local ang= self.caster:GetAttachmentAngles(a)
    local d  = RotatePosition(Vector(0,0,0), QAngle(180-ang.x, 180+ang.y, 0), self.delta)
    p = p + d
    local cur = me:GetOrigin()
    cur.z = p.z
    me:SetOrigin(cur)
end

function modifier_bikov_r_hold:OnHorizontalMotionInterrupted() self:Destroy() end
function modifier_bikov_r_hold:OnVerticalMotionInterrupted()   self:Destroy() end

function modifier_bikov_r_hold:OnDestroy()
    if not IsServer() then return end
    self.parent:RemoveHorizontalMotionController(self)
    self.parent:RemoveVerticalMotionController(self)

    if self._orig_angles then
        self.parent:SetAngles(0, self._orig_angles.y, 0)
    else
        local yaw = self.parent:GetAnglesAsVector().y
        self.parent:SetAngles(0, yaw, 0)
    end
end

modifier_bikov_r_throw_timer = class({})

function modifier_bikov_r_throw_timer:IsHidden() return true end
function modifier_bikov_r_throw_timer:IsPurgable() return false end

function modifier_bikov_r_throw_timer:OnDestroy()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local caster  = ability and ability:GetCaster() or nil
    local parent  = self:GetParent()
    if not ability or not caster or caster:IsNull() or not parent or parent:IsNull() then return end

    local yaw = parent:GetAnglesAsVector().y
    parent:SetAngles(0, yaw, 0)

    local radius = ability:GetSpecialValueFor("impact_radius")
    local dmg    = ability:GetSpecialValueFor("impact_damage")
    local stun   = ability:GetSpecialValueFor("impact_stun")

    local pos = parent:GetAbsOrigin()

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), pos, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )

    local damageTable = {
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
    }

    for _,e in ipairs(enemies) do
        if e and not e:IsNull() then
            damageTable.victim = e
            ApplyDamage(damageTable)
            e:AddNewModifier(caster, ability, "modifier_generic_stunned_lua",
                { duration = stun })
        end
    end
    local pct = ability:GetSpecialValueFor("damage_hp") or 0
    if pct > 0 and parent and not parent:IsNull() then
        local extra = parent:GetMaxHealth() * pct * 0.01
        ApplyDamage({
            victim      = parent,
            attacker    = caster,
            damage      = extra,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability     = ability,
        })
    end
    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, pos)
    ParticleManager:SetParticleControl(fx, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(fx)

    EmitSoundOnLocationWithCaster(pos, "Hero_PrimalBeast.Pulverize.Impact", caster)
end
