LinkLuaModifier("modifier_papich_passive", "papich_passive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_min_health", "papich_passive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_papich_e_charge", "modifier_papich_e_charge.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e", "modifier_papich_e.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_papich_e_command", "papich_passive.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e_heal", "papich_passive.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_bkb", "papich_passive.lua", LUA_MODIFIER_MOTION_NONE )
papich_passive = class({})

function papich_passive:GetIntrinsicModifierName()
    return "modifier_papich_passive"
end

function papich_passive:OnChargeFinish( interrupt )
    -- unit identifier
    local caster = self:GetCaster()

    -- load data
    local max_duration = self:GetSpecialValueFor( "chargeup_time" )
    local max_distance = self:GetSpecialValueFor( "max_distance" )
    local speed = self:GetSpecialValueFor( "charge_speed" )

    -- find charge modifier
    local charge_duration = max_duration
    local mod = caster:FindModifierByName( "modifier_papich_e_charge" )
    if mod then
        charge_duration = mod:GetElapsedTime()

        mod.charge_finish = true
        mod:Destroy()
    end

    local distance = max_distance * charge_duration/max_duration
    local duration = distance/speed
    local caster = self:GetCaster()
    local team = caster:GetTeam()
    local point = 0
    local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
    for _,fountainEnt in pairs( fountainEntities ) do
        if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
            point = fountainEnt:GetAbsOrigin()
            break
        end
    end
    caster:FaceTowards(point)
    if interrupted then return end

    -- add modifier
    caster:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_papich_e", -- modifier name
        { duration = -1 } -- kv
    )

    -- play effects
end

modifier_papich_passive = class({})

function modifier_papich_passive:IsHidden() return true end
function modifier_papich_passive:IsPurgable() return false end
function modifier_papich_passive:RemoveOnDeath() return false end

function modifier_papich_passive:OnCreated()
    if not self:GetParent():IsRealHero() then return end
    if self:GetParent():IsTempestDouble() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.check_interval = 0.1

    if IsServer() then
        self:StartIntervalThink(self.check_interval)
    end
end

function modifier_papich_passive:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsTempestDouble() then return end
    if not self:GetParent():IsAlive() then return end
    -- Ensure ability and caster are valid
    if not self.ability or not self.parent or self.parent:IsIllusion() then return end

    -- Check if the ability is on cooldown
    if not self.ability:IsCooldownReady() then
        self.parent:RemoveModifierByName("modifier_custom_min_health")
        return
    end

    local current_health = self.parent:GetHealth()
    local max_health = self.parent:GetMaxHealth()
    local health_threshold = max_health * 0.05

    if current_health > health_threshold then
        -- Grant min health modifier if not already applied
        if not self.parent:HasModifier("modifier_custom_min_health") then
            self.parent:AddNewModifier(self.parent, self.ability, "modifier_custom_min_health", {})
        end
    else
        -- Remove min health modifier and start cooldown
        if self.parent:HasModifier("modifier_brb_test") then
            self.parent:RemoveModifierByName("modifier_brb_test")
            self.parent:RemoveModifierByName("modifier_brb_test_attack_target")
        end
        if self.parent:HasModifier("modifier_axe_berserkers_call_lua_debuff") then
            self.parent:RemoveModifierByName("modifier_axe_berserkers_call_lua_debuff")
        end
        if self.parent:HasModifier("modifier_generic_stunned_lua") then
            self.parent:RemoveModifierByName("modifier_generic_stunned_lua")
        end
        if self.parent:HasModifier("modifier_golovach_e") then
            self.parent:RemoveModifierByName("modifier_golovach_e")
        end
        if self.parent:HasModifier("modifier_dark_willow_debuff_fear") then
            self.parent:RemoveModifierByName("modifier_dark_willow_debuff_fear")
        end
        if self.parent:HasModifier("modifier_generic_arc_lua") then
            self.parent:RemoveModifierByName("modifier_generic_arc_lua")
        end
        if self.parent:HasModifier("modifier_generic_knockback_lua") then
            self.parent:RemoveModifierByName("modifier_generic_knockback_lua")
        end
        if self.parent:HasModifier("modifier_serega_sven") then
            self.parent:RemoveModifierByName("modifier_serega_sven")
        end
        if self.parent:IsMoving() or self.parent:IsChanneling() or self.parent:IsAttacking() then
            self.parent:Stop()
        end
        local caster = self:GetParent()
        local team = caster:GetTeam()
        local point = 0
        local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
        for _,fountainEnt in pairs( fountainEntities ) do
            if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
               point = fountainEnt:GetAbsOrigin()
               break
            end
        end
        self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        self.parent:Purge( true, true, false, true, true )
        caster:FaceTowards(point)
        local duration = self:GetAbility():GetSpecialValueFor( "chargeup_time" )
        local mod = caster:AddNewModifier(
           caster, -- player source
           self.ability, -- ability source
           "modifier_papich_e_command", -- modifier name
           { duration = duration } -- kv
        )
        self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel() - 1))
        caster:FaceTowards(point)
        caster:FaceTowards(point)
        caster:FaceTowards(point)
        -- load data
        -- add modifier
        local mod = caster:AddNewModifier(
           caster, -- player source
            self.ability, -- ability source
           "modifier_papich_e_charge", -- modifier name
           { duration = duration } -- kv
        )
        if self.parent:HasModifier("modifier_custom_min_health") then
            self.parent:RemoveModifierByName("modifier_custom_min_health")
        end
        caster:FaceTowards(point)
    end
end
modifier_custom_min_health = class({})

function modifier_custom_min_health:IsHidden() return true end
function modifier_custom_min_health:IsPurgable() return false end
function modifier_custom_min_health:RemoveOnDeath() return false end

function modifier_custom_min_health:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_custom_min_health:GetMinHealth()
    return 1
end
modifier_papich_e_command = class({})
function modifier_papich_e_command:IsHidden()
    return true
end

function modifier_papich_e_command:IsDebuff()
    return false
end

function modifier_papich_e_command:IsPurgable()
    return false
end
function modifier_papich_e_command:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }

    return state
end

modifier_papich_e_heal = class({})
function modifier_papich_e_heal:IsHidden() return true end
function modifier_papich_e_heal:IsPurgable() return false end

function modifier_papich_e_heal:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
end

function modifier_papich_e_heal:GetModifierHealthRegenPercentage()
    return 25
end
function modifier_papich_e_heal:GetModifierTotalPercentageManaRegen()
    return 25
end

modifier_papich_bkb = class({})
function modifier_papich_bkb:IsHidden() return false end
function modifier_papich_bkb:IsPurgable() return false end

function modifier_papich_bkb:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
    return state
end
function modifier_papich_bkb:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end