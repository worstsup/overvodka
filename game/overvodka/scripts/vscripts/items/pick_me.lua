LinkLuaModifier("modifier_item_pick_me", "items/pick_me", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_pick_me_windwalk", "items/pick_me", LUA_MODIFIER_MOTION_NONE)

item_pick_me = class({})

function item_pick_me:GetIntrinsicModifierName()
    return "modifier_item_pick_me"
end

function item_pick_me:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not IsValid(caster) then return end

    local illusion_duration = self:GetSpecialValueFor("illusion_duration")
    local outgoing = self:GetSpecialValueFor("illusion_outgoing_damage")
    local incoming = self:GetSpecialValueFor("illusion_incoming_damage")

    OvervodkaCreateIllusions(
        caster,
        caster,
        {
            outgoing_damage = outgoing,
            incoming_damage = incoming,
            duration = illusion_duration,
        },
        1,
        0,
        false,
        true
    )

    caster:Purge(false, true, false, false, false)
    caster:AddNewModifier(caster, self, "modifier_item_pick_me_windwalk", {duration = self:GetSpecialValueFor("duration")})
    local p = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(p)
end


modifier_item_pick_me = class({})

function modifier_item_pick_me:IsHidden() return true end
function modifier_item_pick_me:IsPurgable() return false end
function modifier_item_pick_me:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_pick_me:OnCreated()
    self.ability = self:GetAbility()
    self:OnRefresh()
end

function modifier_item_pick_me:OnRefresh()
    if not self.ability then return end

    self.bonus_agility = self.ability:GetSpecialValueFor("bonus_agility")
    self.bonus_attack_speed = self.ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
    self.bonus_movement_speed_percentage = self.ability:GetSpecialValueFor("bonus_movement_speed_percentage")
end

function modifier_item_pick_me:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
    }
end

function modifier_item_pick_me:GetModifierBonusStats_Agility()
    if not self.ability then return end
    return self.bonus_agility
end

function modifier_item_pick_me:GetModifierPreAttack_BonusDamage()
    if not self.ability then return end
    return self.bonus_damage
end

function modifier_item_pick_me:GetModifierAttackSpeedBonus_Constant()
    if not self.ability then return end
    return self.bonus_attack_speed
end

function modifier_item_pick_me:GetModifierMoveSpeedBonus_Percentage_Unique()
    if not self.ability then return end
    return self.bonus_movement_speed_percentage
end


modifier_item_pick_me_windwalk = class({})

function modifier_item_pick_me_windwalk:IsHidden() return true end
function modifier_item_pick_me_windwalk:IsPurgable() return true end

function modifier_item_pick_me_windwalk:OnCreated()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.attack_record = nil
    self.attack_consumed = false
    self:SetStackCount(0)
    self:OnRefresh()
end

function modifier_item_pick_me_windwalk:OnRefresh()
    if not self.ability then return end

    self.bonus_movement_speed = self.ability:GetSpecialValueFor("bonus_movement_speed")
    self.stun_duration = self.ability:GetSpecialValueFor("stun_dur")
    self.invis_damage = self.ability:GetSpecialValueFor("invis_damage")
end

function modifier_item_pick_me_windwalk:CheckState()
    if self:GetStackCount() == 1 then return {} end

    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_item_pick_me_windwalk:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_pick_me_windwalk:OnAttack(params)
    if not IsServer() then return end
    if params.attacker ~= self.parent then return end
    if self:GetStackCount() == 1 then return end
    if not IsValid(self.parent, self.ability, params.target) then return end
    if not params.record or params.record == -1 then
        self:Destroy()
        return
    end

    self:SetStackCount(1)
    self.attack_record = params.record
    self:SetDuration(-1, true)
end

function modifier_item_pick_me_windwalk:GetModifierProcAttack_BonusDamage_Physical(params)
    if not IsServer() then return end
    if self.attack_consumed then return 0 end
    if params.attacker ~= self.parent then return end
    if params.record ~= self.attack_record then return end
    if not IsValid(self.parent, self.ability, params.target) then return 0 end
    if params.target:IsBuilding() or params.target:IsOther() or params.target:IsWard() then return 0 end

    self.attack_consumed = true
    params.target:AddNewModifier(self.parent, self.ability, "modifier_generic_stunned_lua", {duration = self.stun_duration})
    EmitSoundOn("Hero_Spirit_Breaker.GreaterBash", params.target)

    return self.invis_damage
end

function modifier_item_pick_me_windwalk:OnAttackFail(params)
    if not IsServer() then return end
    if params.attacker ~= self.parent then return end
    if params.record ~= self.attack_record then return end

    self:Destroy()
end

function modifier_item_pick_me_windwalk:OnAttackRecordDestroy(params)
    if not IsServer() then return end
    if params.record ~= self.attack_record then return end

    self:Destroy()
end

function modifier_item_pick_me_windwalk:OnAbilityExecuted(params)
    if not IsServer() then return end
    if params.unit ~= self.parent then return end
    if self:GetStackCount() == 1 then return end

    self:Destroy()
end

function modifier_item_pick_me_windwalk:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 1 then return 0 end
    return 1
end

function modifier_item_pick_me_windwalk:GetModifierMoveSpeedBonus_Percentage()
    if not self.ability then return end
    if self:GetStackCount() == 1 then return 0 end
    return self.bonus_movement_speed
end
