LinkLuaModifier("modifier_surfin_bird", "units/griffins/surfin_bird.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_surfin_bird_debuff", "units/griffins/surfin_bird.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_surfin_bird_buff", "units/griffins/surfin_bird.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_surfin_bird_freeze", "units/griffins/surfin_bird.lua", LUA_MODIFIER_MOTION_NONE)

surfin_bird = class({})

function surfin_bird:GetIntrinsicModifierName()
    return "modifier_surfin_bird"
end


modifier_surfin_bird = class({})

function modifier_surfin_bird:IsHidden() return true end
function modifier_surfin_bird:IsPurgable() return false end

function modifier_surfin_bird:OnCreated()
    if IsServer() then
        self.radius = self:GetAbility():GetSpecialValueFor("AbilityCastRange")
        self.delay = 5
        self:StartIntervalThink(0.5)
        self.enemy_timers = {}
    end
end

function modifier_surfin_bird:OnIntervalThink()
    local ability = self:GetAbility()
    local parent = self:GetParent()

    if not ability or ability:IsCooldownReady() == false then return end

    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local current_time = GameRules:GetGameTime()

    for _, enemy in pairs(enemies) do
        local id = enemy:entindex()

        if not self.enemy_timers[id] then
            self.enemy_timers[id] = current_time
        elseif current_time - self.enemy_timers[id] >= self.delay then

            enemy:AddNewModifier(parent, ability, "modifier_surfin_bird_debuff", {duration = 5})
            parent:AddNewModifier(parent, ability, "modifier_surfin_bird_freeze", {duration = 5})
            self:ApplyBuffToAllies()

            ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))

            self.enemy_timers = {}

            break 
        end
    end
end


function modifier_surfin_bird:ApplyBuffToAllies()
    local allies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, ally in pairs(allies) do
        if ally ~= self:GetParent() then
            ally:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_surfin_bird_buff", {duration = 5})
        end
    end
end

modifier_surfin_bird_freeze = class({})

function modifier_surfin_bird_freeze:IsHidden() return true end
function modifier_surfin_bird_freeze:IsPurgable() return false end 

function modifier_surfin_bird_freeze:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_surfin_bird_freeze:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_surfin_bird_freeze:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("self_incoming_damage")
end

function modifier_surfin_bird_freeze:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()

    parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

    EmitSoundOn("peter_surfin_bird", parent)
end

function modifier_surfin_bird_freeze:OnDestroy()
    if not IsServer() then return end
    self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_2)
end


function modifier_surfin_bird_freeze:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("self_incoming_damage")
end

modifier_surfin_bird_debuff = class({})

function modifier_surfin_bird_debuff:IsDebuff() return true end
function modifier_surfin_bird_debuff:IsPurgable() return true end

function modifier_surfin_bird_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MISS_PERCENTAGE,
    }
end

function modifier_surfin_bird_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("enemy_movespeed_slow")
end

function modifier_surfin_bird_debuff:GetModifierAttackSpeedBonus_Constant()
    return -self:GetAbility():GetSpecialValueFor("enemy_attackspeed_slow")
end

function modifier_surfin_bird_debuff:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("enemy_miss_chance")
end

function modifier_surfin_bird_debuff:OnCreated()
    if not IsServer() then return end

    self.pfx = ParticleManager:CreateParticle(
        "particles/surfin_bird_erny.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        self:GetParent()
    )

    ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.pfx, false, false, -1, false, false)
end



modifier_surfin_bird_buff = class({})

function modifier_surfin_bird_buff:IsBuff() return true end
function modifier_surfin_bird_buff:IsPurgable() return true end

function modifier_surfin_bird_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_surfin_bird_buff:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor("ally_hp_regen_pct")
end

function modifier_surfin_bird_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("ally_damage_bonus_pct")
end
