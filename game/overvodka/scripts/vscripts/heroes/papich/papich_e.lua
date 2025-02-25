LinkLuaModifier("modifier_papich_e_passive", "heroes/papich/papich_e.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_min_health", "heroes/papich/papich_e.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_papich_e_charge", "heroes/papich/modifier_papich_e_charge.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e", "heroes/papich/modifier_papich_e.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_papich_e_command", "heroes/papich/papich_e.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_e_heal", "heroes/papich/papich_e.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_papich_bkb", "heroes/papich/papich_e.lua", LUA_MODIFIER_MOTION_NONE )
papich_e = class({})

function papich_e:Precache(context)
    PrecacheResource( "soundfile", "soundevents/papich_e_fly.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_plane.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_start.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_end.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/papich_e_plane_start.vsndevts", context )
end

function papich_e:GetIntrinsicModifierName()
    return "modifier_papich_e_passive"
end

function papich_e:OnChargeFinish( interrupt )
    local caster = self:GetCaster()
    local max_duration = self:GetSpecialValueFor( "chargeup_time" )
    local max_distance = self:GetSpecialValueFor( "max_distance" )
    local speed = self:GetSpecialValueFor( "charge_speed" )
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
    caster:AddNewModifier(
        caster,
        self,
        "modifier_papich_e",
        { duration = -1 }
    )
end

modifier_papich_e_passive = class({})

function modifier_papich_e_passive:IsHidden() return true end
function modifier_papich_e_passive:IsPurgable() return false end
function modifier_papich_e_passive:RemoveOnDeath() return false end

function modifier_papich_e_passive:OnCreated()
    if not self:GetParent():IsRealHero() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.check_interval = 0.1

    if IsServer() then
        self:StartIntervalThink(self.check_interval)
    end
end

function modifier_papich_e_passive:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsTempestDouble() then return end
    if not self:GetParent():IsAlive() then return end
    if not self.ability or not self.parent or self.parent:IsIllusion() then return end
    if not self.ability:IsCooldownReady() then
        self.parent:RemoveModifierByName("modifier_custom_min_health")
        return
    end

    local current_health = self.parent:GetHealth()
    local max_health = self.parent:GetMaxHealth()
    local health_threshold = max_health * 0.05

    if current_health > health_threshold then
        if not self.parent:HasModifier("modifier_custom_min_health") then
            self.parent:AddNewModifier(self.parent, self.ability, "modifier_custom_min_health", {})
        end
    else
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
           caster,
           self.ability,
           "modifier_papich_e_command",
           { duration = duration }
        )
        self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel() - 1))
        caster:FaceTowards(point)
        caster:FaceTowards(point)
        caster:FaceTowards(point)
        local mod = caster:AddNewModifier(
           caster,
            self.ability,
           "modifier_papich_e_charge",
           { duration = duration }
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
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
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