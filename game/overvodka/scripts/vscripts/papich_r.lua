LinkLuaModifier("modifier_papich_r", "papich_r", LUA_MODIFIER_MOTION_NONE)

papich_r = class({})
function papich_r:OnAbilityPhaseStart()
    EmitSoundOn("papich_r_appear", self:GetCaster())
end
function papich_r:OnAbilityPhaseInterrupted()
    StopSoundOn("papich_r_appear", self:GetCaster())
end
function papich_r:OnSpellStart()
    if not IsServer() then return end
     self.abilities_list = 
    {
        {"imba_keeper_of_the_light_illuminate", "papich_q_clone"},
        {"imba_arc_warden_magnetic_field", "papich_w_clone"},
        {"papich_passive", "papich_maniac"},
        {"papich_r",   "papich_e_clone"},
    }
    local target = Entities:FindByNameNearest("npc_dota_hero_skeleton_king", self:GetCaster():GetAbsOrigin(), 10000)
    if self.knight ~= nil then
        self.knight:RemoveModifierByName("modifier_papich_r")
    end
    if target then
        local spawn_point = self:GetCaster():GetAbsOrigin() + RandomVector(250)
        local knight = CreateUnitByName( target:GetUnitName(), spawn_point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber()  )
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
                local itemName = target:GetItemInSlot(itemSlot)
                if itemName then 
                    if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_ward_dispenser" and itemName:GetName() ~= "item_gem" and itemName:GetName() ~= "item_lesh" and itemName:GetName() ~= "item_moon_shard" and itemName:GetName() ~= "item_hand_of_midas" and itemName:IsPermanent() then
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
            while knight:GetLevel() < target:GetLevel() do
                knight:HeroLevelUp( false )
                knight:SetAbilityPoints(0)
            end
            for _, info in pairs(self.abilities_list) do
                knight:SwapAbilities(info[1], info[2], false, true)
            end
            for i = 0, 24 do
                local ability = target:GetAbilityByIndex(i)
                if ability then
                    local knight_ability = knight:FindAbilityByName(ability:GetAbilityName())
                    if i == 3 then
                        knight_ability:SetActivated(false)
                    end
                    if knight_ability then
                        knight_ability:SetLevel(self:GetLevel())
                    end
                end
            end
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
    local particle_ambient = ParticleManager:CreateParticle( "particles/econ/courier/courier_greevil_black/courier_greevil_black_ambient_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt(particle_ambient, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
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
    if current_health <= health_threshold then
        self:Destroy()
    end
end
function modifier_papich_r:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_LIFETIME_FRACTION,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
function modifier_papich_r:OnAttackLanded( params )
    if params.attacker ~= self:GetParent() then return end
    local sound_cast = "fof"
    EmitSoundOn( sound_cast, params.target )
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
    return self:GetAbility():GetSpecialValueFor("incoming_damage") - 100
end

function modifier_papich_r:GetModifierTotalDamageOutgoing_Percentage()
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
            if unit:IsRealHero() then
                for _, mod in pairs(unit:FindAllModifiers()) do
                    if mod and mod:GetCaster() == self:GetParent() then
                        mod:Destroy()
                    end
                end
            end
        end
    end
    self:GetAbility().knight = nil
    UTIL_Remove(self:GetParent())
end

function modifier_papich_r:GetMinHealth()
    return 1
end