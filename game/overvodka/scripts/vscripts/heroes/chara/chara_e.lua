LinkLuaModifier( "modifier_chara_e", "heroes/chara/chara_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chara_e_debuff", "heroes/chara/chara_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chara_e_effect_webm", "heroes/chara/chara_e", LUA_MODIFIER_MOTION_NONE )
chara_e = class({})

function chara_e:Precache( ctx )
	PrecacheResource( "soundfile", "soundevents/chara_sounds.vsndevts", ctx )
    PrecacheResource("particle", "particles/t2x2_scepter_debuff.vpcf", ctx )
end

function chara_e:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local target   = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if target:TriggerSpellAbsorb(self) then return end
    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "chara_e", caster)

    caster:AddNewModifier(caster, self, "modifier_chara_e", {
        target   = target:entindex(),
        duration = duration
    })

    target:AddNewModifier(caster, self, "modifier_chara_e_debuff", {
        duration   = duration * (1 - target:GetStatusResistance()),
        caster_e   = caster:entindex(),
        interval   = self:GetSpecialValueFor("interval"),
        fear_only  = 0,
    })

    if not target:IsDebuffImmune() then
        target:AddNewModifier(caster, self, "modifier_chara_e_effect_webm", {duration = duration})
    end
end


modifier_chara_e = class({})

function modifier_chara_e:IsPurgable() return false end

function modifier_chara_e:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    self:GetParent():SetForceAttackTarget(self.target)
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(0.05)
end

function modifier_chara_e:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()

    parent:Interrupt()
    parent:SetForceAttackTarget(nil)
    parent:SetForceAttackTargetAlly(nil)

    local after = self:GetAbility():GetSpecialValueFor("after_duration") or 0.5

    if self.target and not self.target:IsNull() and self.target:IsAlive() then
        self.target:AddNewModifier(parent, self:GetAbility(), "modifier_chara_e_debuff", {
            duration  = after * (1 - self.target:GetStatusResistance()),
            caster_e  = parent:entindex(),
            fear_only = 1,
        })
        parent:MoveToTargetToAttack(self.target)
    else
        parent:Stop()
    end
end

function modifier_chara_e:OnIntervalThink()
    if not IsServer() then return end
    if self.target == nil or not self.target:IsAlive() or ( self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then
        if not self:IsNull() then
            self:Destroy()
            return
        end
    else
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 100, 0.1, true)
        self:GetParent():MoveToTargetToAttack(self.target)
    end
end

function modifier_chara_e:CheckState()
    return
    {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end

function modifier_chara_e:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_chara_e:OnAttack(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and params.target == self.target then
        self:Destroy()
    end
end

function modifier_chara_e:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ms_bonus")
end

modifier_chara_e_debuff = class({})

function modifier_chara_e_debuff:IsHidden() return false end
function modifier_chara_e_debuff:IsPurgable() return true end
function modifier_chara_e_debuff:IsDebuff() return true end

function modifier_chara_e_debuff:OnCreated(kv)
    if not IsServer() then return end

    self.ability   = self:GetAbility()
    self.parent    = self:GetParent()
    self.caster    = EntIndexToHScript(tonumber(kv.caster_e or -1)) or self:GetCaster()

    local dps      = (self.ability and self.ability:GetSpecialValueFor("damage")) or 0
    self.interval  = tonumber(kv.interval or 0.25) or 0.25
    self.fear_only = tonumber(kv.fear_only or 0) == 1

    self.tick_damage = (self.fear_only and 0) or (dps * self.interval)

    self._nextDamageTime = GameRules:GetGameTime() + self.interval

    self:StartIntervalThink(0.05)
end

function modifier_chara_e_debuff:OnIntervalThink()
    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() or not self.caster:IsAlive() then
    else
        local ppos = self.parent:GetAbsOrigin()
        local cpos = self.caster:GetAbsOrigin()

        local dir = (ppos - cpos)
        dir.z = 0
        local len = dir:Length2D()
        if len < 1 then
            dir = self.parent:GetForwardVector()
            dir.z = 0
        else
            dir = dir / len
        end

        local dest = ppos + dir * 450
        if not self.parent:IsDebuffImmune() then
            self:GetParent():MoveToPosition(dest)
        end
    end

    if not self.fear_only and GameRules:GetGameTime() >= self._nextDamageTime then
        self._nextDamageTime = self._nextDamageTime + self.interval

        if self.parent:IsAlive() and self.ability and not self.ability:IsNull() then
            ApplyDamage({
                victim      = self.parent,
                attacker    = self.caster or self:GetCaster(),
                damage      = self.tick_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability     = self.ability,
            })
        end
    end
end

function modifier_chara_e_debuff:CheckState()
    return {
        [MODIFIER_STATE_FEARED]             = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
    }
end

function modifier_chara_e_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_chara_e_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("fear_slow_pct")
end

function modifier_chara_e_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_chara_e_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_chara_e_debuff:GetEffectName()
	return "particles/t2x2_scepter_debuff.vpcf"
end

function modifier_chara_e_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_chara_e_effect_webm = class({})

function modifier_chara_e_effect_webm:IsPurgable() return false end
function modifier_chara_e_effect_webm:IsHidden() return true end

function modifier_chara_e_effect_webm:OnCreated()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerOwnerID()
    if playerID ~= nil and playerID ~= -1 then
        local player = PlayerResource:GetPlayer(playerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "CharaScreamerTrue", {})
        end
    end
end

function modifier_chara_e_effect_webm:OnDestroy()
    if not IsServer() then return end
    local playerID = self:GetParent():GetPlayerOwnerID()
    if playerID ~= nil and playerID ~= -1 then
        local player = PlayerResource:GetPlayer(playerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "CharaScreamerFalse", {})
        end
    end
end