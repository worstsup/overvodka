LinkLuaModifier("modifier_papich_r", "heroes/papich/papich_r", LUA_MODIFIER_MOTION_NONE)

papich_r = class({})

local papich_clone_abilities = {
    [0] = { ability = "papich_q_clone" },
    [1] = { ability = "papich_w_clone" },
    [2] = { ability = "papich_maniac" },
    [3] = { ability = "papich_innate" },
    [5] = { ability = "papich_e_clone" },
}

local function EnsureAbility(unit, abilityName)
    local ability = unit:FindAbilityByName(abilityName)
    if ability and not ability:IsNull() then
        return ability
    end

    ability = unit:AddAbility(abilityName)
    if ability and not ability:IsNull() then
        ability:SetStolen(false)
        ability:SetHidden(false)
    end

    return ability
end

local function MoveAbilityToIndex(unit, abilityName, targetIndex)
    local desiredAbility = EnsureAbility(unit, abilityName)
    if not desiredAbility or desiredAbility:IsNull() then
        return
    end

    local currentAbility = unit:GetAbilityByIndex(targetIndex)
    if currentAbility == desiredAbility then
        desiredAbility:SetActivated(true)
        return
    end

    if currentAbility and not currentAbility:IsNull() then
        unit:SwapAbilities(currentAbility:GetAbilityName(), abilityName, false, true)
    else
        desiredAbility:SetActivated(true)
    end
end

local function ConfigurePapichCloneAbilities(clone, ability)
    for slotIndex = 0, 5 do
        local layoutInfo = papich_clone_abilities[slotIndex]
        if layoutInfo then
            MoveAbilityToIndex(clone, layoutInfo.ability, slotIndex)
        end
    end

    for _, layoutInfo in pairs(papich_clone_abilities) do
        local cloneAbility = EnsureAbility(clone, layoutInfo.ability)
        if cloneAbility and not cloneAbility:IsNull() then
            cloneAbility:SetLevel(ability:GetLevel())
        end
    end

    local innate = clone:FindAbilityByName("papich_innate")
    if innate and not innate:IsNull() then
        innate:SetActivated(ability:GetSpecialValueFor("innate_activated") == 1)
    end
end

function papich_r:Precache(context)
    PrecacheResource( "soundfile", "soundevents/papich_r_spawn.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/papich_r_end.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/papich_r_appear.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/fof.vsndevts", context )
    PrecacheResource( "particle", "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/pudge/hungry_clown/hungry_clown_rot_dark.vpcf", context)
end

function papich_r:OnAbilityPhaseStart()
    EmitSoundOn("papich_r_appear", self:GetCaster())
end
function papich_r:OnAbilityPhaseInterrupted()
    StopSoundOn("papich_r_appear", self:GetCaster())
end

function papich_r:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if self.knight ~= nil then
        self.knight:RemoveModifierByName("modifier_papich_r")
    end
    if caster then
        local spawn_point = self:GetCursorPosition()
        local knight = CreateUnitByName( caster:GetUnitName(), spawn_point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber()  )
        if knight then
            self.knight = knight
            knight:AddNewModifier(self:GetCaster(), self, "modifier_papich_r", {duration = self:GetSpecialValueFor("duration")})
            knight:SetUnitCanRespawn(true)
            knight:SetRespawnsDisabled(true)
            knight:RemoveModifierByName("modifier_fountain_invulnerability")
            knight.IsRealHero = function() return true end
            knight.IsMainHero = function() return false end
            knight.IsTempestDouble = function() return true end
            knight:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
            knight:SetRenderColor(85, 85, 85)
            knight:SetAbilityPoints(0)
            knight:SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
            knight:SetPlayerID(self:GetCaster():GetPlayerOwnerID())
            knight:SetHasInventory(false)
            knight:SetCanSellItems(false)
            knight:StartGesture(ACT_DOTA_SPAWN)
            local particle = ParticleManager:CreateParticle( "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, knight )
            ParticleManager:SetParticleControlEnt(particle, 0, knight, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", knight:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)

            for itemSlot = 0,16 do
                local itemName = caster:GetItemInSlot(itemSlot)
                if itemName then 
                    if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_ward_dispenser" and itemName:GetName() ~= "item_gem" and itemName:GetName() ~= "item_refresher" and itemName:GetName() ~= "item_lesh" and itemName:GetName() ~= "item_moon_shard" and itemName:GetName() ~= "item_hand_of_midas" and itemName:GetName() ~= "item_bablokrad" and itemName:IsPermanent() then
                        local newItem = CreateItem(itemName:GetName(), nil, nil)
                        knight:AddItem(newItem)
                        if itemName and itemName:GetCurrentCharges() > 0 and newItem and not newItem:IsNull() then
                            newItem:SetCurrentCharges(itemName:GetCurrentCharges())
                        end
                        if newItem and not newItem:IsNull() then
                            knight:SwapItems(newItem:GetItemSlot(), itemSlot)
                        end
                        newItem:SetSellable(false)
                        newItem:SetDroppable(false)
                        newItem:SetShareability( ITEM_FULLY_SHAREABLE )
                        newItem:SetPurchaser( nil )
                    end
                end
            end
            Timers:CreateTimer(FrameTime(), function()
                for i = 0, DOTA_ITEM_MAX -1 do
                    local item = knight:GetItemInSlot(i)
                    if item and item:GetName() == "item_tpscroll" then
                        knight:RemoveItem(item)
                    end
                end
            end)
            while knight:GetLevel() < caster:GetLevel() do
                knight:HeroLevelUp( false )
                knight:SetAbilityPoints(0)
            end
            ConfigurePapichCloneAbilities(knight, self)
            knight:CalculateStatBonus(true)
        end
    end
end


modifier_papich_r = class({})

function modifier_papich_r:IsPurgable() return false end
function modifier_papich_r:IsPurgeException() return false end

function modifier_papich_r:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("papich_r_spawn")
    local particle_ambient = ParticleManager:CreateParticle( "particles/econ/items/pudge/hungry_clown/hungry_clown_rot_dark.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    self:AddParticle(particle_ambient, false, false, -1, false, false)
    self.check_interval = 0.1

    if IsServer() then
        self:StartIntervalThink(self.check_interval)
    end
end

function modifier_papich_r:OnIntervalThink()
    if not IsServer() then return end
    local current_health = self:GetParent():GetHealth()
    local max_health = self:GetParent():GetMaxHealth()
    local health_threshold = max_health * 0.01
    if current_health <= health_threshold or not self:GetCaster() then
        self:Destroy()
    end
end
function modifier_papich_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_LIFETIME_FRACTION,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
    }
end

function modifier_papich_r:GetAttackSound()
    return "fof"
end

function modifier_papich_r:GetModifierModelChange()
    return "arthas/papich_maniac.vmdl"
end

function modifier_papich_r:GetModifierModelScale()
    return 10
end

function modifier_papich_r:GetModifierAttackRangeBonus()
    return -350
end

function modifier_papich_r:GetModifierIncomingDamage_Percentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("incoming_damage") - 100
end

function modifier_papich_r:GetModifierTotalDamageOutgoing_Percentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("outgoing_damage") - 100
end

function modifier_papich_r:GetUnitLifetimeFraction( params )
	return ( ( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration() )
end

function modifier_papich_r:OnDestroy()
    if not IsServer() then return end
    self:GetParent():EmitSound("papich_r_end")
    local particle_target = ParticleManager:CreateParticle( "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(particle_target, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_target)
    for _, mod in pairs(self:GetParent():FindAllModifiers()) do
        if mod ~= self then
            mod:Destroy()
        end
    end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _, unit in pairs(units) do
        if unit ~= self:GetParent() then
            if unit:IsRealHero() and not unit:IsTempestDouble() then
                for _, mod in pairs(unit:FindAllModifiers()) do
                    if mod and mod:GetCaster() == self:GetParent() then
                        mod:Destroy()
                    end
                end
            end
        end
    end
    if self:GetAbility() then
        self:GetAbility().knight = nil
    end
    UTIL_Remove(self:GetParent())
end

function modifier_papich_r:GetMinHealth()
    return 1
end