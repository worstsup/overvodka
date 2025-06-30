LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_armature_strike_crit", "items/armature_strike", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_armature_strike", "items/armature_strike", LUA_MODIFIER_MOTION_NONE)

item_armature_strike = class({})
function item_armature_strike:GetIntrinsicModifierName() 
    return "modifier_armature_strike"
end

modifier_armature_strike = class({})

function modifier_armature_strike:IsHidden() return true end
function modifier_armature_strike:IsPurgable() return false end
function modifier_armature_strike:IsPurgeException() return false end
function modifier_armature_strike:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_armature_strike:OnCreated()
    if not IsServer() then return end
    self.critProc = false
end

function modifier_armature_strike:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_armature_strike:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_armature_strike:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
function modifier_armature_strike:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_armature_strike:GetModifierConstantManaRegen()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_armature_strike:GetModifierPreAttack_CriticalStrike(params)
    if self:GetParent():FindAllModifiersByName("modifier_armature_strike")[1] ~= self then return end
    local chance = self:GetAbility():GetSpecialValueFor("chance")
    if RollPercentage(chance) then
        self.critProc = true
        return self:GetAbility():GetSpecialValueFor("crit")
    end
    self.critProc = false
end

function modifier_armature_strike:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    if params.target:IsBuilding() then return end
    if self:GetParent():FindAllModifiersByName("modifier_armature_strike")[1] ~= self then return end
    if self.critProc then
        params.target:EmitSound("armature_crit")
    end
end

function item_armature_strike:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local direction = (point - caster:GetAbsOrigin()):Normalized()
    self.casting_particle = ParticleManager:CreateParticle("particles/armature_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(self.casting_particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlForward(self.casting_particle, 0, direction)
    caster:EmitSound("Hero_MonkeyKing.Strike.Cast")
    return true
end

function item_armature_strike:OnAbilityPhaseInterrupted()
    if self.casting_particle then
        ParticleManager:DestroyParticle(self.casting_particle, false)
        ParticleManager:ReleaseParticleIndex(self.casting_particle)
    end
end
function item_armature_strike:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local ability = self
    local width = ability:GetSpecialValueFor("strike_width")
    local range = ability:GetSpecialValueFor("strike_range")
    local stun_duration = ability:GetSpecialValueFor("stun_duration")
    if self.casting_particle then
        ParticleManager:DestroyParticle(self.casting_particle, false)
        ParticleManager:ReleaseParticleIndex(self.casting_particle)
    end
    local caster_position = caster:GetAbsOrigin()
    local direction = (point - caster_position):Normalized()
    local end_position = caster_position + direction * range
    local buff = caster:AddNewModifier(
        caster,
        self,
        "modifier_armature_strike_crit",
        {  }
    )
    local particle = ParticleManager:CreateParticle("particles/armature_strike.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, caster_position)
    ParticleManager:SetParticleControl(particle, 1, end_position)
    ParticleManager:SetParticleControl(particle, 2, end_position)
    ParticleManager:SetParticleControlForward(particle, 0, direction)
    ParticleManager:ReleaseParticleIndex(particle)

    local enemies = FindUnitsInLine(
        caster:GetTeamNumber(),
        caster_position,
        end_position,
        nil,
        width,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE
    )

    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, ability, "modifier_generic_stunned_lua", { duration = stun_duration })
        caster:PerformAttack(enemy, true, true, true, true, true, false, true)
        if enemy:IsRealHero() then
            local playerID = caster:GetPlayerOwnerID()
            if playerID and PlayerResource:IsValidPlayerID(playerID) then
                if Quests and Quests.IncrementQuest then
                    Quests:IncrementQuest(playerID, "armatureAmount")
                end
            end
        end
    end
    buff:Destroy()
    caster:EmitSound("armature")
end


modifier_armature_strike_crit = class({})

function modifier_armature_strike_crit:IsHidden()
    return true
end

function modifier_armature_strike_crit:IsDebuff()
    return false
end

function modifier_armature_strike_crit:IsPurgable()
    return false
end

function modifier_armature_strike_crit:OnCreated( kv )
    self.bonus_crit = self:GetAbility():GetSpecialValueFor( "crit_multiplier" )
end

function modifier_armature_strike_crit:OnRefresh( kv )
end

function modifier_armature_strike_crit:OnRemoved()
end

function modifier_armature_strike_crit:OnDestroy()
end

function modifier_armature_strike_crit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    }
    return funcs
end

function modifier_armature_strike_crit:GetModifierPreAttack_CriticalStrike( params )
    return self.bonus_crit
end