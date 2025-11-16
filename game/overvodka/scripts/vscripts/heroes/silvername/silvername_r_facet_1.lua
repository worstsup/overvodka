LinkLuaModifier("modifier_silvername_r_facet_1",         "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_r_facet_1_soldier", "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)

silvername_r_facet_1 = class({})

function silvername_r_facet_1:IsStealable() return true end

function silvername_r_facet_1:Precache(ctx)
    PrecacheUnitByNameSync("npc_dota_silvername_clone", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_fur_army_cast.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", ctx)
    PrecacheResource("particle", "particles/status_fx/status_effect_monkey_king_fur_army.vpcf", ctx)
end

function silvername_r_facet_1:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_MonkeyKing.FurArmy.Channel")
    self.castHandle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_cast.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    return true
end

function silvername_r_facet_1:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    self:GetCaster():StopSound("Hero_MonkeyKing.FurArmy.Channel")

    if self.castHandle then
        ParticleManager:DestroyParticle(self.castHandle, true)
        ParticleManager:ReleaseParticleIndex(self.castHandle)
        self.castHandle = nil
    end
end

function silvername_r_facet_1:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    if self.castHandle then
        ParticleManager:DestroyParticle(self.castHandle, false)
        ParticleManager:ReleaseParticleIndex(self.castHandle)
        self.castHandle = nil
    end

    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_silvername_r_facet_1", {
        duration = duration
    })
end


modifier_silvername_r_facet_1 = class({})

function modifier_silvername_r_facet_1:IsPurgable() return false end
function modifier_silvername_r_facet_1:IsDebuff()   return false end

function modifier_silvername_r_facet_1:OnCreated(kv)
    self.caster  = self:GetParent()
    self.ability = self:GetAbility()

    self.inner_radius    = self.ability and self.ability:GetSpecialValueFor("inner_radius") or 300
    self.outer_radius    = self.ability and self.ability:GetSpecialValueFor("outer_radius") or 750
    self.inner_count     = self.ability and self.ability:GetSpecialValueFor("inner_count") or 6
    self.outer_count     = self.ability and self.ability:GetSpecialValueFor("outer_count") or 12
    self.attack_interval = self.ability and self.ability:GetSpecialValueFor("attack_interval") or 1.0

    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end

    self.soldiers = {}

    self:CreateRing(self.inner_radius, self.inner_count)
    self:CreateRing(self.outer_radius, self.outer_count)

    self.particleHandler = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particleHandler, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particleHandler, 1, Vector(self.outer_radius, 0, 0))

    self:StartIntervalThink(FrameTime())
end

function modifier_silvername_r_facet_1:OnIntervalThink()
    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() then return end
    if not self.particleHandler then return end

    ParticleManager:SetParticleControl(self.particleHandler, 0, self.caster:GetAbsOrigin())
end

function modifier_silvername_r_facet_1:OnDestroy()
    if not IsServer() then return end

    if self.soldiers then
        for _, soldier in ipairs(self.soldiers) do
            if soldier and not soldier:IsNull() then
                soldier:SetForceAttackTarget(nil)
                soldier:ForceKill(false)
                UTIL_Remove(soldier)
            end
        end
    end

    if self.particleHandler then
      ParticleManager:DestroyParticle(self.particleHandler, false)
      ParticleManager:ReleaseParticleIndex(self.particleHandler)
    end
end

function modifier_silvername_r_facet_1:CreateRing(radius, count)
    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() then return end

    local origin = self.caster:GetAbsOrigin()
    local team   = self.caster:GetTeamNumber()

    local angle_step = 360 / math.max(count, 1)

    for i = 0, count - 1 do
        local angle_deg = i * angle_step
        local angle_rad = math.rad(angle_deg)

        local dx = math.cos(angle_rad) * radius
        local dy = math.sin(angle_rad) * radius

        local pos = origin + Vector(dx, dy, 0)

        local soldier = CreateUnitByName(
            "npc_dota_silvername_clone",
            pos,
            false,
            self.caster,
            self.caster,
            team
        )

        if soldier then
            soldier:SetOwner(self.caster)
            soldier:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), false)
            soldier:SetHasInventory(false)
            soldier:RemoveModifierByName("modifier_fountain_invulnerability")
            soldier:SetCanSellItems(false)
            soldier:SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
            soldier.IsRealHero = function() return false end
            soldier.IsMainHero = function() return false end
            soldier.IsTempestDouble = function() return true end
            soldier:SetRenderColor(255, 255, 0)

            local avg = self.caster:GetAverageTrueAttackDamage(nil)
            soldier:SetBaseDamageMin(avg)
            soldier:SetBaseDamageMax(avg)

            self:CopyAttackItems(self.caster, soldier)

            soldier:AddNewModifier(self.caster, self.ability, "modifier_silvername_r_facet_1_soldier", {
                radius          = radius,
                angle           = angle_deg,
                attack_interval = self.attack_interval,
            })

            table.insert(self.soldiers, soldier)
        end
    end
end

function modifier_silvername_r_facet_1:CopyAttackItems(fromHero, toHero)
    if not fromHero or fromHero:IsNull() or not toHero or toHero:IsNull() then return end

    for itemSlot = 0,16 do
        local itemName = fromHero:GetItemInSlot(itemSlot)
        if itemName then 
            if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_ward_dispenser" and itemName:GetName() ~= "item_gem" and itemName:GetName() ~= "item_refresher" and itemName:GetName() ~= "item_lesh" and itemName:GetName() ~= "item_moon_shard" and itemName:GetName() ~= "item_hand_of_midas" and itemName:GetName() ~= "item_bablokrad" and itemName:IsPermanent() then
                local newItem = CreateItem(itemName:GetName(), nil, nil)
                toHero:AddItem(newItem)
                if itemName and itemName:GetCurrentCharges() > 0 and newItem and not newItem:IsNull() then
                    newItem:SetCurrentCharges(itemName:GetCurrentCharges())
                end
                if newItem and not newItem:IsNull() then
                    toHero:SwapItems(newItem:GetItemSlot(), itemSlot)
                end
                newItem:SetSellable(false)
                newItem:SetDroppable(false)
                newItem:SetShareability( ITEM_FULLY_SHAREABLE )
                newItem:SetPurchaser( nil )
            end
        end
    end
end


modifier_silvername_r_facet_1_soldier = class({})

function modifier_silvername_r_facet_1_soldier:IsPurgable() return false end
function modifier_silvername_r_facet_1_soldier:IsHidden()   return true  end

function modifier_silvername_r_facet_1_soldier:GetStatusEffectName()
  return "particles/status_fx/status_effect_monkey_king_fur_army.vpcf"
end

function modifier_silvername_r_facet_1_soldier:OnCreated(kv)
    self.parent  = self:GetParent()
    self.caster  = self:GetCaster()
    self.ability = self:GetAbility()

    self.radius          = tonumber(kv.radius or 0)
    self.angle_deg       = tonumber(kv.angle  or 0)
    self.attack_interval = tonumber(kv.attack_interval or 1.0)

    self.run_out_duration = 1.0

    self.disarmed = true

    if not self.parent or self.parent:IsNull() then return end

    self.fixed_attack_rate = self.attack_interval

    if not IsServer() then return end

    if self.caster and not self.caster:IsNull() then
        local center = self.caster:GetAbsOrigin()
        local ground = GetGroundPosition(center, self.parent)
        self.parent:SetAbsOrigin(ground)
    end

    self.spawn_time = GameRules:GetGameTime()
    self.parent:SetForceAttackTarget(nil)

    self:StartIntervalThink(FrameTime())
end


function modifier_silvername_r_facet_1_soldier:OnIntervalThink()
    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    if not self.caster or self.caster:IsNull() or not self.caster:IsAlive() then
        self:Destroy()
        return
    end

    local origin = self.caster:GetAbsOrigin()
    local angle_rad = math.rad(self.angle_deg)

    local elapsed = GameRules:GetGameTime() - (self.spawn_time or GameRules:GetGameTime())
    local t = math.min(math.max(elapsed / self.run_out_duration, 0), 1)
    local current_radius = self.radius * t

    local dx = math.cos(angle_rad) * current_radius
    local dy = math.sin(angle_rad) * current_radius

    local pos    = origin + Vector(dx, dy, 0)
    local ground = GetGroundPosition(pos, self.parent)

    self.parent:SetAbsOrigin(ground)
    self.parent:FaceTowards(origin)

    if t < 0.9 then
        if not self.disarmed then
            self.disarmed = true
            self.parent:SetForceAttackTarget(nil)
        end
        return
    end

    if self.disarmed then
        self.disarmed = false
        self:ForceRefresh()
    end

    local range = self.parent:Script_GetAttackRange()
    local search_radius = range

    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        ground,
        nil,
        search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false
    )

    local target = nil
    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsAttackImmune() then
            target = enemy
            break
        end
    end

    if target then
        self.parent:SetForceAttackTarget(target)
        self.parent:MoveToTargetToAttack(target)
    else
        self.parent:SetForceAttackTarget(nil)
    end
end

function modifier_silvername_r_facet_1_soldier:OnDestroy()
    if not IsServer() then return end
    if self.parent and not self.parent:IsNull() then
        self.parent:SetForceAttackTarget(nil)
        UTIL_Remove(self.parent)
    end
end

function modifier_silvername_r_facet_1_soldier:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DISARMED] = self.disarmed,
    }
end

function modifier_silvername_r_facet_1_soldier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
end

function modifier_silvername_r_facet_1_soldier:GetModifierFixedAttackRate()
    return self.fixed_attack_rate or 1.0
end
