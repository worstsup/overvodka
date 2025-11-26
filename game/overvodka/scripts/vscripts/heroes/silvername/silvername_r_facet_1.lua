LinkLuaModifier("modifier_silvername_r_facet_1",           "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_r_facet_1_soldier",   "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_silvername_r_facet_1_scepter",   "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)

silvername_r_facet_1 = class({})

function silvername_r_facet_1:IsStealable() return true end

function silvername_r_facet_1:GetIntrinsicModifierName()
    return "modifier_silvername_r_facet_1_scepter"
end

modifier_silvername_r_facet_1_scepter = class({})

function modifier_silvername_r_facet_1_scepter:IsHidden()   return true  end
function modifier_silvername_r_facet_1_scepter:IsPurgable() return false end

function modifier_silvername_r_facet_1_scepter:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    if not IsServer() then return end

    self.next_spawn_time = GameRules:GetGameTime()

    self:StartIntervalThink(0.1)
end

function modifier_silvername_r_facet_1_scepter:OnRefresh()
    if not IsServer() then return end
    self.ability = self:GetAbility()
end

function modifier_silvername_r_facet_1_scepter:OnIntervalThink()
    if not IsServer() then return end

    local parent  = self.parent
    local ability = self.ability

    if not parent or parent:IsNull() then return end
    if not ability or ability:IsNull() then return end
    if ability:GetLevel() <= 0 then return end

    if not parent:IsAlive() then return end
    if not parent:HasScepter() then return end
    if parent:IsIllusion() then return end
    if parent:IsInvisible() then return end

    local scepter_radius   = ability:GetSpecialValueFor("scepter_radius")   or 0
    local scepter_interval = ability:GetSpecialValueFor("scepter_interval") or 0
    local scepter_duration = ability:GetSpecialValueFor("scepter_duration") or 0

    if scepter_radius <= 0 or scepter_interval <= 0 or scepter_duration <= 0 then
        return
    end

    local now = GameRules:GetGameTime()

    if not self.next_spawn_time or now >= self.next_spawn_time then
        ability:SpawnScepterSoldier(parent)
        self.next_spawn_time = now + scepter_interval
    end
end


function silvername_r_facet_1:SpawnScepterSoldier(caster)
    if not IsServer() then return end
    if not caster or caster:IsNull() or not caster:IsAlive() then return end
    local scepter_radius    = self:GetSpecialValueFor("scepter_radius")    or 0
    local scepter_run       = 0.4
    local scepter_duration  = self:GetSpecialValueFor("scepter_duration")  or 0
    local attack_interval   = self:GetSpecialValueFor("attack_interval")   or 1.0

    if scepter_radius <= 0 or scepter_duration <= 0 then return end

    local center = caster:GetAbsOrigin()
    local team   = caster:GetTeamNumber()

    local angle_deg = RandomFloat(0, 360)
    local angle_rad = math.rad(angle_deg)
    local dist      = scepter_radius

    local spawn_pos = center

    local soldier = CreateUnitByName(
        "npc_dota_silvername_clone",
        spawn_pos,
        false,
        caster,
        caster,
        team
    )

    if not soldier then return end

    soldier:SetOwner(caster)
    soldier:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    soldier:SetHasInventory(false)
    soldier:RemoveModifierByName("modifier_fountain_invulnerability")
    soldier:SetCanSellItems(false)
    soldier:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    soldier.IsRealHero = function() return false end
    soldier.IsMainHero = function() return false end
    soldier.IsTempestDouble = function() return true end
    soldier:SetRenderColor(255, 255, 0)

    local damage_min = caster:GetBaseDamageMin() * (self:GetSpecialValueFor("damage") / 100)
    local damage_max = caster:GetBaseDamageMax() * (self:GetSpecialValueFor("damage") / 100) 
    soldier:SetBaseDamageMin(damage_min)
    soldier:SetBaseDamageMax(damage_max)

    for itemSlot = 0, 16 do
        local item = caster:GetItemInSlot(itemSlot)
        if item then
            local name = item:GetName()
            if name ~= "item_rapier"
                and name ~= "item_ward_dispenser"
                and name ~= "item_gem"
                and name ~= "item_refresher"
                and name ~= "item_lesh"
                and name ~= "item_moon_shard"
                and name ~= "item_hand_of_midas"
                and name ~= "item_bablokrad"
                and item:IsPermanent()
            then
                local newItem = CreateItem(name, nil, nil)
                if newItem then
                    soldier:AddItem(newItem)

                    if item:GetCurrentCharges() > 0 then
                        newItem:SetCurrentCharges(item:GetCurrentCharges())
                    end

                    soldier:SwapItems(newItem:GetItemSlot(), itemSlot)

                    newItem:SetSellable(false)
                    newItem:SetDroppable(false)
                    newItem:SetShareability(ITEM_FULLY_SHAREABLE)
                    newItem:SetPurchaser(nil)
                end
            end
        end
    end

    soldier:AddNewModifier(caster, self, "modifier_silvername_r_facet_1_soldier", {
        duration         = scepter_duration,
        radius           = dist,
        angle            = angle_deg,
        attack_interval  = attack_interval,
        run_out_duration = scepter_run,
        static           = 1,
    })
end


function silvername_r_facet_1:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_MonkeyKing.FurArmy.Channel")
    self.castHandle = ParticleManager:CreateParticle("particles/silvername_r_facet_1_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
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
    caster:EmitSound("silvername_r_facet_1")
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

    self.bonus_radius = 0
    self.bonus_count  = 0

    if self.ability and not self.ability:IsNull() then
        if self.caster and self.caster:HasTalent("special_bonus_unique_silvername_8") then
            self.bonus_radius = self.ability:GetSpecialValueFor("bonus_radius") or 0
            self.bonus_count  = self.ability:GetSpecialValueFor("bonus_count")  or 0
        end
    end

    if not IsServer() then return end
    if not self.caster or self.caster:IsNull() then
        self:Destroy()
        return
    end

    self.soldiers = {}

    self:CreateRing(self.inner_radius, self.inner_count)
    self:CreateRing(self.outer_radius, self.outer_count)

    self.max_ring_radius = self.outer_radius
    if self.bonus_radius > 0 and self.bonus_count > 0 then
        self:CreateRing(self.bonus_radius, self.bonus_count)
        self.max_ring_radius = self.bonus_radius
    end

    self.particleHandler = ParticleManager:CreateParticle("particles/silvername_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.particleHandler, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particleHandler, 1, Vector(self.max_ring_radius, 0, 0))
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

            local damage_min = self.caster:GetBaseDamageMin() * (self.ability:GetSpecialValueFor("damage") / 100)
            local damage_max = self.caster:GetBaseDamageMax() * (self.ability:GetSpecialValueFor("damage") / 100) 
            soldier:SetBaseDamageMin(damage_min)
            soldier:SetBaseDamageMax(damage_max)

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

    self.run_out_duration = tonumber(kv.run_out_duration or 1.0)

    self.follow_target = nil
    self.attack_target = nil

    if kv.follow_target_entindex then
        local ent = EntIndexToHScript(tonumber(kv.follow_target_entindex))
        if ent and not ent:IsNull() then
            self.follow_target = ent
            self.attack_target = ent
        end
    end

    self.follow_mode = (self.follow_target ~= nil)

    self.static_mode   = (tonumber(kv.static or 0) == 1)
    self.static_anchor = nil

    if self.follow_mode then
        self.run_out_duration = 0
        self.disarmed         = false
    else
        self.run_out_duration = self.run_out_duration > 0 and self.run_out_duration or 1.0
        self.disarmed         = true
    end

    if not self.parent or self.parent:IsNull() then return end

    self.fixed_attack_rate = self.attack_interval

    if not IsServer() then return end

    self.w_ability          = nil
    self.gold_steal_amount  = 0
    self.gold_steal_pct     = 0
    self.gold_steal_cd      = 0
    self.next_gold_steal    = 0

    if self.caster and not self.caster:IsNull() then
        if self.caster.HasTalent and self.caster:HasTalent("special_bonus_unique_silvername_5") then
            local w = self.caster:FindAbilityByName("silvername_w_facet_1")
            if w and not w:IsNull() and w:GetLevel() > 0 then
                self.w_ability         = w
                self.gold_steal_amount = w:GetSpecialValueFor("gold_steal") or 0
                self.gold_steal_pct    = w:GetSpecialValueFor("gold_steal_pct") or 0
                self.gold_steal_cd     = w:GetCooldown( w:GetLevel() )
            end
        end
    end

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

    if self.follow_mode then
        if not self.follow_target or self.follow_target:IsNull() or not self.follow_target:IsAlive() then
            self:Destroy()
            return
        end
    end

    local angle_rad = math.rad(self.angle_deg)
    local elapsed   = GameRules:GetGameTime() - (self.spawn_time or GameRules:GetGameTime())
    local t         = 1.0

    if self.run_out_duration > 0 then
        t = math.min(math.max(elapsed / self.run_out_duration, 0), 1)
    end

    local pos

    if self.follow_mode then
        local center = self.follow_target:GetAbsOrigin()
        local current_radius = self.radius

        local dx = math.cos(angle_rad) * current_radius
        local dy = math.sin(angle_rad) * current_radius

        pos = center + Vector(dx, dy, 0)

    elseif self.static_mode then
        if not self.static_anchor then
            local center0 = self.caster:GetAbsOrigin()
            local dx      = math.cos(angle_rad) * self.radius
            local dy      = math.sin(angle_rad) * self.radius
            self.static_anchor = center0 + Vector(dx, dy, 0)
        end

        if t < 1.0 then
            local center_run = self.caster:GetAbsOrigin()
            local dx = math.cos(angle_rad) * (self.radius * t)
            local dy = math.sin(angle_rad) * (self.radius * t)
            pos = center_run + Vector(dx, dy, 0)
        else
            pos = self.static_anchor
        end
    else
        local center = self.caster:GetAbsOrigin()
        local current_radius = self.radius * t

        local dx = math.cos(angle_rad) * current_radius
        local dy = math.sin(angle_rad) * current_radius

        pos = center + Vector(dx, dy, 0)
    end

    local ground = GetGroundPosition(pos, self.parent)
    self.parent:SetAbsOrigin(ground)

    if self.follow_mode then
        self.parent:FaceTowards(self.follow_target:GetAbsOrigin())
    else
        self.parent:FaceTowards(self.caster:GetAbsOrigin())
    end

    if not self.follow_mode and not self.static_mode and t < 0.9 then
        if not self.disarmed then
            self.disarmed = true
            self.parent:SetForceAttackTarget(nil)
        end
        return
    end

    if self.static_mode and self.run_out_duration > 0 and elapsed < self.run_out_duration then
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

    local range         = self.parent:Script_GetAttackRange()
    local search_radius = range

    local target = nil

    if self.follow_mode then
        local enemy = self.attack_target
        if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsAttackImmune() then
            local dist = (enemy:GetAbsOrigin() - ground):Length2D()
            if dist <= search_radius then
                target = enemy
            end
        end
    else
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

        for _, enemy in ipairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsAttackImmune() then
                target = enemy
                break
            end
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
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_silvername_r_facet_1_soldier:GetModifierFixedAttackRate()
    return self.fixed_attack_rate or 1.0
end

function modifier_silvername_r_facet_1_soldier:OnAttackLanded(keys)
    if not IsServer() then return end

    if keys.attacker ~= self.parent then return end
    if not self.w_ability then return end

    local target = keys.target
    if not target or target:IsNull() then return end
    if target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if not target:IsRealHero() or target:IsIllusion() then return end

    local attackerPlayerID = self.parent:GetPlayerOwnerID()
    local victimPlayerID   = target:GetPlayerOwnerID()

    if attackerPlayerID == nil or attackerPlayerID == -1 or victimPlayerID == nil or victimPlayerID == -1 then
        return
    end

    local now = GameRules:GetGameTime()
    if self.gold_steal_cd > 0 and now < (self.next_gold_steal or 0) then
        return
    end

    local victimGold = PlayerResource:GetGold(victimPlayerID) or 0

    local fixed = self.gold_steal_amount or 0
    local pct   = self.gold_steal_pct or 0

    local steal = fixed + math.floor(victimGold * pct * 0.01 + 0.5)
    if steal <= 0 then return end

    if steal > victimGold then
        steal = victimGold
    end

    if steal <= 0 then return end

    PlayerResource:SpendGold(victimPlayerID, steal, 4)
    self.caster:ModifyGoldFiltered(steal, false, 0)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.caster, steal, nil)

    if self.gold_steal_cd > 0 then
        self.next_gold_steal = now + self.gold_steal_cd
    end
end