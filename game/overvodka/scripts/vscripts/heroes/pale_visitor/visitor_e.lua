LinkLuaModifier("modifier_visitor_e_orb", "heroes/pale_visitor/visitor_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_e_amp", "heroes/pale_visitor/visitor_e", LUA_MODIFIER_MOTION_NONE)

visitor_e = class({})

function visitor_e:GetIntrinsicModifierName()
	return "modifier_visitor_e_orb"
end

function visitor_e:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange()
end

function visitor_e:Precache(ctx)
    PrecacheResource("particle", "particles/econ/items/venomancer/mechamancer/mechamancer_gale_impact.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_noxious_plague_slow.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/visitor_sounds.vsndevts", ctx)
end

function visitor_e:OnOrbImpact(params)
    if not IsServer() then return end
    local caster = params.attacker
    local target = params.target
    if not caster or not target or target:IsNull() or not target:IsAlive() then return end

    local bonus_damage  = self:GetSpecialValueFor("bonus_damage")
    local amp_per_stack = self:GetSpecialValueFor("amp_per_stack")
    local max_stacks    = self:GetSpecialValueFor("max_stacks")
    local dur           = self:GetSpecialValueFor("amp_duration")
    EmitSoundOn("visitor_e", target)
    local p = ParticleManager:CreateParticle("particles/econ/items/venomancer/mechamancer/mechamancer_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(p, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
    if bonus_damage > 0 then
        ApplyDamage({
            victim      = target,
            attacker    = caster,
            damage      = bonus_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability     = self,
        })
    end
    if target and not target:IsNull() then
        if not target:IsAlive() then return end
        local mod = target:FindModifierByName("modifier_visitor_e_amp")
        if not mod then
            mod = target:AddNewModifier(caster, self, "modifier_visitor_e_amp", { duration = dur })
        end
        if mod then
            mod.amp_per_stack = amp_per_stack
            mod:SetDuration(dur, true)
            local new_count = math.min(max_stacks, (mod:GetStackCount() or 0) + 1)
            mod:SetStackCount(new_count)
        end
    end
end


modifier_visitor_e_orb = class({})

function modifier_visitor_e_orb:IsHidden() return true end
function modifier_visitor_e_orb:IsPurgable() return false end
function modifier_visitor_e_orb:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_visitor_e_orb:OnCreated()
    self.ability = self:GetAbility()
    self.cast = false
    self.records = {}
end

function modifier_visitor_e_orb:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }
end

function modifier_visitor_e_orb:GetModifierPreAttack_CriticalStrike(params)
    if params.attacker ~= self:GetParent() then return end
    if self:ShouldLaunch(params.target) then
        local crit_mult = (self.ability and self.ability:GetSpecialValueFor("crit_mult"))
        self.records[params.record] = { fire = true, crit_mult = crit_mult }
        return crit_mult
    end
end


function modifier_visitor_e_orb:OnAttack(params)
    if params.attacker ~= self:GetParent() then return end
    if params.no_attack_cooldown then return end

    local rec = self.records[params.record]
    if rec and rec.fire then
        self.ability:UseResources(true, true, false, true)
        if self.ability.OnOrbFire then self.ability:OnOrbFire(params) end
    end

    self.cast = false
end

function modifier_visitor_e_orb:GetModifierProcAttack_Feedback(params)
    local rec = self.records[params.record]
    if rec and rec.fire then
        if self.ability.OnOrbImpact then self.ability:OnOrbImpact(params) end
    end
end

function modifier_visitor_e_orb:OnAttackFail(params)
    local rec = self.records[params.record]
    if rec and rec.fire and self.ability.OnOrbFail then
        self.ability:OnOrbFail(params)
    end
end

function modifier_visitor_e_orb:OnAttackRecordDestroy(params)
    self.records[params.record] = nil
end

function modifier_visitor_e_orb:OnOrder(params)
    if params.unit ~= self:GetParent() then return end

    if params.ability then
        if params.ability == self:GetAbility() then
            self.cast = true
            return
        end
        local behavior = params.ability:GetBehaviorInt()
        local pass = self:FlagExist(behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL)
                  or self:FlagExist(behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT)
                  or self:FlagExist(behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL)
        if self.cast and (not pass) then
            self.cast = false
        end
    else
        if self.cast then
            if self:FlagExist(params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION)
            or self:FlagExist(params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET)
            or self:FlagExist(params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE)
            or self:FlagExist(params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET)
            or self:FlagExist(params.order_type, DOTA_UNIT_ORDER_STOP)
            or self:FlagExist(params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION) then
                self.cast = false
            end
        end
    end
end

function modifier_visitor_e_orb:GetModifierProjectileName()
    if not self.ability.GetProjectileName then return end
    if self:ShouldLaunch(self:GetCaster():GetAggroTarget()) then
        return self.ability:GetProjectileName()
    end
end

function modifier_visitor_e_orb:ShouldLaunch(target)
    if self.ability:GetAutoCastState() then
        if self.ability.CastFilterResultTarget ~= CDOTA_Ability_Lua.CastFilterResultTarget then
            if self.ability:CastFilterResultTarget(target) == UF_SUCCESS then
                self.cast = true
            end
        else
            local nResult = UnitFilter(
                target,
                self.ability:GetAbilityTargetTeam(),
                self.ability:GetAbilityTargetType(),
                self.ability:GetAbilityTargetFlags(),
                self:GetCaster():GetTeamNumber()
            )
            if nResult == UF_SUCCESS then
                self.cast = true
            end
        end
    end

    if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
        return true
    end
    return false
end

function modifier_visitor_e_orb:FlagExist(a,b)
    local p,c,d=1,0,b
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c==d
end


modifier_visitor_e_amp = class({})

function modifier_visitor_e_amp:IsPurgable() return false end
function modifier_visitor_e_amp:IsDebuff() return true end

function modifier_visitor_e_amp:OnCreated()
    self.amp_per_stack = self.amp_per_stack or (self:GetAbility() and self:GetAbility():GetSpecialValueFor("amp_per_stack") or 0)
end

function modifier_visitor_e_amp:OnRefresh()
end

function modifier_visitor_e_amp:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_visitor_e_amp:GetModifierIncomingDamage_Percentage()
    local stacks = self:GetStackCount() or 0
    local per = self.amp_per_stack or 0
    return stacks * per
end

function modifier_visitor_e_amp:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_noxious_plague_slow.vpcf"
end

function modifier_visitor_e_amp:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
