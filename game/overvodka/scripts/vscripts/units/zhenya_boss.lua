modifier_zhenya_boss = class({})

function modifier_zhenya_boss:IsHidden() return true end
function modifier_zhenya_boss:IsPurgable() return false end
function modifier_zhenya_boss:IsPurgeException() return false end
function modifier_zhenya_boss:IsPermanent() return true end
function modifier_zhenya_boss:RemoveOnDeath() return false end

function modifier_zhenya_boss:OnCreated()
    if not IsServer() then return end

    self.parent  = self:GetParent()

    self.state   = "RUN_TO_HAMSTER"
    self.moving  = false
    self.reached = false
    self.pushedUnits = {}
    self.phase2Started = false

    self.abilityQ = nil
    self.abilityW = nil
    self.abilityE = nil
    self.nextAbilityTime = nil
    self.lastAbilityName = nil
    self.castLockUntil = 0

    if OvervodkaEvents then
        self.hamster = OvervodkaEvents.zhenyaHamster
    else
        self.hamster = nil
    end
    self.parent:AddNewModifier(self.parent, self, "modifier_zhenya_boss_running", {})
    self:StartIntervalThink(0.1)
end

function modifier_zhenya_boss:OnIntervalThink()
    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then
        self:Destroy()
        return
    end

    local ALL_TEAMS = {
        DOTA_TEAM_CUSTOM_1,
        DOTA_TEAM_CUSTOM_2,
        DOTA_TEAM_CUSTOM_3,
        DOTA_TEAM_CUSTOM_4,
        DOTA_TEAM_CUSTOM_5,
        DOTA_TEAM_CUSTOM_6,
        DOTA_TEAM_CUSTOM_7,
        DOTA_TEAM_CUSTOM_8,
        DOTA_TEAM_GOODGUYS,
        DOTA_TEAM_BADGUYS,
    }

    local position = self.parent:GetAbsOrigin()
    for _, team in ipairs(ALL_TEAMS) do
        AddFOWViewer(team, position, 500, 0.2, false)
    end

    if self.state == "RUN_TO_HAMSTER" then
        self:ThinkRunToHamster()
    elseif self.state == "PHASE1" then
        self:ThinkPhase1()
    elseif self.state == "TRANSFORMING" then

    elseif self.state == "PHASE2" then
        self:ThinkPhase2()
    end
    if self.state == "PHASE1" or self.state == "TRANSFORMING" or self.state == "PHASE2" then
        self:ClampToMid()
    end
end

function modifier_zhenya_boss:ThinkRunToHamster()
    if not IsServer() then return end

    if (not self.hamster or self.hamster:IsNull()) and OvervodkaEvents then
        self.hamster = OvervodkaEvents.zhenyaHamster
    end

    if not self.hamster or self.hamster:IsNull() or (not self.hamster:IsAlive()) then
        return
    end

    local bossPos    = self.parent:GetAbsOrigin()
    local hamsterPos = self.hamster:GetAbsOrigin()

    local distance = (hamsterPos - bossPos):Length2D()
    local stopDistance = 200.0

    if distance > stopDistance then
        self.parent:MoveToPosition(hamsterPos)
        self.moving = true
        self:PushUnitsAlongTheWay()
        return
    end

    if not self.reached then
        self.reached = true
        self.parent:Stop()
        self.parent:StartGesture(ACT_DOTA_ATTACK)

        Timers:CreateTimer(0.5, function()
            if not self or self:IsNull() then return end
            if not self.parent or self.parent:IsNull() then return end
            if not self.hamster or self.hamster:IsNull() then return end

            self:AttachHamster()
            self.parent:RemoveModifierByName("modifier_zhenya_boss_running")

            if not self.parent:HasModifier("modifier_zhenya_boss_phase1") then
                self.parent:AddNewModifier(self.parent, nil, "modifier_zhenya_boss_phase1", {})
            end

            self.nextAbilityTime = GameRules:GetGameTime() + 6.0
            self.lastAbilityName = nil

            self.state = "PHASE1"
        end)
    end
end

function modifier_zhenya_boss:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_zhenya_boss:OnDeath(event)
    if not IsServer() then return end

    local unit = event.unit
    if not unit or unit:IsNull() then return end
    if unit ~= self.parent then
        return
    end
    EmitGlobalSound("zhenya_boss_death")
    if OvervodkaEvents then
        OvervodkaEvents.zhenyaBossActive = false
        OvervodkaEvents.zhenyaBoss       = nil
    end

    local origin = unit:GetAbsOrigin()

    EmitGlobalSound("Item.PickUpGemWorld")

    local count = 20

    local spiralArms     = 4
    local angleStep      = math.rad(18)
    local radiusStart    = 150
    local radiusStep     = 90
    local spawnInterval  = 0.08

    for i = 0, count - 1 do
        local idx = i

        Timers:CreateTimer(idx * spawnInterval, function()
            local item = CreateItem("item_zhenya_present", nil, nil)
            if not item then return end

            local spawnPoint = origin

            local arm = idx % spiralArms
            local t   = math.floor(idx / spiralArms)

            local baseAngle = t * angleStep
            local armOffset = (2 * math.pi / spiralArms) * arm
            local angle     = baseAngle + armOffset

            local radius = radiusStart + radiusStep * t
            radius = radius + RandomFloat(-15, 15)

            local dir = Vector(math.cos(angle), math.sin(angle), 0)
            local targetPos = spawnPoint + dir * radius

            local drop = CreateItemOnPositionForLaunch(spawnPoint, item)
            item:LaunchLootInitialHeight(false, 0, 500, 0.75, targetPos)
        end)
    end
end


function modifier_zhenya_boss:ThinkPhase1()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end

    local maxHP = self.parent:GetMaxHealth()
    local threshold = math.floor(maxHP * 0.5 + 10.5)

    if self.parent:GetHealth() <= threshold and not self.phase2Started then
        self:EnterPhase2()
        return
    end

    self:ThinkAbilities()
    self:BasicAttackAI()
end

function modifier_zhenya_boss:ThinkPhase2()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end

    self:ThinkAbilities()
    self:BasicAttackAI()
end

function modifier_zhenya_boss:EnterPhase2()
    if not IsServer() then return end
    if self.phase2Started then return end
    self.phase2Started = true

    self.state = "TRANSFORMING"

    self.parent:Stop()

    if self.hamster and not self.hamster:IsNull() then
        self.hamster:RemoveModifierByName("modifier_zhenya_hamster_carried")
    end

    self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_6)

    Timers:CreateTimer(1.0, function()
        if not self or self:IsNull() then return end
        if not self.parent or self.parent:IsNull() then return end
        if not self.parent:IsAlive() then return end

        if self.parent:HasModifier("modifier_zhenya_boss_phase1") then
            self.parent:RemoveModifierByName("modifier_zhenya_boss_phase1")
        end

        if not self.parent:HasModifier("modifier_zhenya_boss_phase2") then
            self.parent:AddNewModifier(self.parent, nil, "modifier_zhenya_boss_phase2", {})
        end

        self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_6)

        self.state = "PHASE2"
    end)
end

function modifier_zhenya_boss:BasicAttackAI()
    if not IsServer() then return end

    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end
    local now = GameRules:GetGameTime()
    if self.castLockUntil and now < self.castLockUntil then return end
    if self.parent:IsChanneling() then return end

    local team   = self.parent:GetTeamNumber()
    local origin = self.parent:GetAbsOrigin()
    local radius = 1200

    local enemies = FindUnitsInRadius(
        team, origin, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST, false
    )

    local target = nil
    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive()
        and not enemy:IsBuilding() and not enemy:IsOther() then
            target = enemy
            break
        end
    end

    if target then
        self.parent:MoveToTargetToAttack(target)
    end
end

local function CanCastAbility(ability)
    if not ability or ability:IsNull() then return false end
    if ability:GetLevel() <= 0 then return false end
    if not ability:IsActivated() then return false end
    if not ability:IsFullyCastable() then return false end
    return true
end

function modifier_zhenya_boss:ClampToMid()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    local pos = self.parent:GetAbsOrigin()
    local v   = pos - Vector(0, 0, 0)
    v.z       = 0

    local dist = v:Length2D()
    if dist <= 3200 then
        return
    end

    local newPos = Vector(0, 0, 0) + v:Normalized() * 3200
    newPos = GetGroundPosition(newPos, self.parent)

    self.parent:SetAbsOrigin(newPos)
    ResolveNPCPositions(newPos, 128)
end


function modifier_zhenya_boss:ThinkAbilities()
    if not IsServer() then return end
    if self.state ~= "PHASE1" and self.state ~= "PHASE2" then return end
    if not self.parent or self.parent:IsNull() then return end
    if not self.parent:IsAlive() then return end

    if self.parent:IsStunned() or self.parent:IsHexed() or self.parent:IsChanneling() then
        return
    end

    local now = GameRules:GetGameTime()
    if self.castLockUntil and now < self.castLockUntil then return end
    if not self.nextAbilityTime or now < self.nextAbilityTime then return end

    if not self.abilityQ or self.abilityQ:IsNull() then
        self.abilityQ = self.parent:FindAbilityByName("zhenya_q_boss")
    end
    if not self.abilityW or self.abilityW:IsNull() then
        self.abilityW = self.parent:FindAbilityByName("zhenya_w_boss")
    end
    if not self.abilityE or self.abilityE:IsNull() then
        self.abilityE = self.parent:FindAbilityByName("zhenya_e_boss")
    end

    local team   = self.parent:GetTeamNumber()
    local origin = self.parent:GetAbsOrigin()
    local searchRadius = 1200

    local enemies = FindUnitsInRadius(
        team, origin, nil, searchRadius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST, false
    )

    if not enemies or #enemies == 0 then
        self.nextAbilityTime = now + 1.0
        return
    end

    local target = enemies[1]
    if not target or target:IsNull() then
        self.nextAbilityTime = now + 1.0
        return
    end

    local order
    if self.state == "PHASE2" then
        order = { "Q", "W", "E" }
    else
        order = { "Q", "W" }
    end

    local startIndex = 1
    if self.lastAbilityName then
        for i, name in ipairs(order) do
            if name == self.lastAbilityName then
                startIndex = (i % #order) + 1
                break
            end
        end
    end

    local casted = false

    for step = 1, #order do
        local idx = ((startIndex - 1 + step - 1) % #order) + 1
        local name = order[idx]

        if name == "Q" then
            if CanCastAbility(self.abilityQ) then
                local qRadius = 800
                local qEnemies = FindUnitsInRadius(
                    team, origin, nil, qRadius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                if qEnemies and #qEnemies > 0 then
                    self.parent:CastAbilityNoTarget(self.abilityQ, -1)
                    self.lastAbilityName = "Q"
                    self.castLockUntil   = now + 0.4
                    casted = true
                    break
                end
            end

        elseif name == "W" then
            if CanCastAbility(self.abilityW) then
                local wPos = origin + RandomVector(200)
                self.parent:CastAbilityOnPosition(wPos, self.abilityW, -1)
                self.lastAbilityName = "W"
                self.castLockUntil   = now + 0.4
                casted = true
                break
            end

        elseif name == "E" then
            if self.state == "PHASE2" and CanCastAbility(self.abilityE) then
                local eRadius = 600
                local eEnemies = FindUnitsInRadius(
                    team, origin, nil, eRadius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                if eEnemies and #eEnemies > 0 then
                    self.parent:CastAbilityNoTarget(self.abilityE, -1)
                    self.lastAbilityName = "E"
                    self.castLockUntil   = now + 1.1
                    casted = true
                    break
                end
            end
        end
    end

    if casted then
        self.nextAbilityTime = now + 6.0
    else
        self.nextAbilityTime = now + 1.0
    end
end

function modifier_zhenya_boss:PushUnitsAlongTheWay()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    local team   = self.parent:GetTeamNumber()
    local origin = self.parent:GetAbsOrigin()
    local radius = 400
    local distance = 500

    local enemies = FindUnitsInRadius(
        team,
        origin,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    if not enemies or #enemies == 0 then return end
    local damageTable = {
		attacker = self.parent,
		damage_type = DAMAGE_TYPE_PURE,
		ability = nil,
	}
    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and enemy ~= self.parent and enemy:IsAlive() then
            if not enemy:IsBuilding() and not enemy:IsOther() and enemy:GetUnitName() ~= "npc_hamster" then
                local entid = enemy:entindex()
                if not self.pushedUnits[entid] then
                    print("ZHENYA FOUND ENEMY!")
                    enemy:AddNewModifier(
                        self.parent, nil,
                        "modifier_knockback",
                        {
                            center_x = origin.x,
                            center_y = origin.y,
                            center_z = origin.z,
                            duration = 0.5,
                            knockback_duration = 0.5,
                            knockback_distance = distance,
                            knockback_height = 200,
                        }
                    )
                    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf", PATTACH_POINT_FOLLOW, enemy )
                    ParticleManager:SetParticleControlEnt(effect_cast, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
                    ParticleManager:ReleaseParticleIndex( effect_cast )
                    damageTable.damage = enemy:GetMaxHealth() * 0.15
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)
                    self.pushedUnits[entid] = true
                end
            end
        end
    end
end

function modifier_zhenya_boss:AttachHamster()
    if not IsServer() then return end

    if not self.hamster or self.hamster:IsNull() then return end
    if not self.parent or self.parent:IsNull() then return end

    self.hamster:SetParent(self.parent, "attach_hamster")
    self.hamster:SetAbsOrigin(self.parent:GetAbsOrigin())

    self.hamster:AddNewModifier(self.parent, nil, "modifier_zhenya_hamster_carried", {boss_entindex = self.parent:entindex()})

    self.parent.carriedHamster = self.hamster
end

function modifier_zhenya_boss:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION]               = true,
        [MODIFIER_STATE_DEBUFF_IMMUNE]                  = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

function modifier_zhenya_boss:OnDestroy()
    if not IsServer() then return end
    _G.global_sounds_muted = false
    local boss = self.parent or self:GetParent()
    if not boss or boss:IsNull() then return end

    if not boss:IsAlive() then return end

    if self.hamster and not self.hamster:IsNull() then
        self.hamster:RemoveModifierByName("modifier_zhenya_hamster_carried")
    end

    if OvervodkaEvents then
        OvervodkaEvents.zhenyaBossActive = false
        OvervodkaEvents.zhenyaBoss = nil
    end

    boss:Stop()

    local origin = boss:GetAbsOrigin()
    local center = Vector(0, 0, 0)
    local dir = origin - center
    dir.z = 0
    if dir:Length2D() < 0.01 then
        dir = RandomVector(1)
    end
    dir = dir:Normalized()

    local runDistance = 9000
    local runPos = origin + dir * runDistance

    boss:MoveToPosition(runPos)

    boss:AddNewModifier(boss, nil, "modifier_zhenya_boss_escape", {})

    Timers:CreateTimer(15.0, function()
        if not boss or boss:IsNull() then return end
        if boss:IsAlive() then
            boss:ForceKill(false)
            boss:AddNoDraw()
        end
    end)
end


modifier_zhenya_hamster_carried = class({})

function modifier_zhenya_hamster_carried:IsHidden() return true end
function modifier_zhenya_hamster_carried:IsPurgable() return false end
function modifier_zhenya_hamster_carried:IsPurgeException() return false end
function modifier_zhenya_hamster_carried:RemoveOnDeath() return false end

function modifier_zhenya_hamster_carried:OnCreated(kv)
    if not IsServer() then return end

    self.boss = nil

    if kv and kv.boss_entindex then
        local idx = tonumber(kv.boss_entindex)
        if idx and idx > 0 then
            local ent = EntIndexToHScript(idx)
            if ent and not ent:IsNull() then
                self.boss = ent
            end
        end
    end
end

function modifier_zhenya_hamster_carried:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_AVOID_DAMAGE,
    }
end

function modifier_zhenya_hamster_carried:GetModifierAvoidDamage()
    return 1
end

function modifier_zhenya_hamster_carried:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]        = true,
        [MODIFIER_STATE_OUT_OF_GAME]    = true,
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]  = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

function modifier_zhenya_hamster_carried:OnDestroy()
    if not IsServer() then return end

    local hamster = self:GetParent()
    if not hamster or hamster:IsNull() then return end

    local boss = self.boss
    local dropPos

    if boss and not boss:IsNull() then
        dropPos = boss:GetAbsOrigin()
    else
        dropPos = hamster:GetAbsOrigin()
    end

    hamster:SetParent(nil, "")
    hamster:SetAbsOrigin(dropPos)

    local ang = hamster:GetAnglesAsVector()
    hamster:SetAngles(0, ang.y, 0)

    local dir
    if boss and not boss:IsNull() then
        dir = boss:GetForwardVector()
        if dir:Length2D() < 0.01 then
            dir = Vector(1, 0, 0)
        end
    else
        dir = Vector(1, 0, 0)
    end

    dir.z = 0
    dir = dir:Normalized()

    local perp = Vector(-dir.y, dir.x, 0):Normalized()
    local side = RandomInt(0, 1) == 0 and 1 or -1
    dir = (dir + perp * 0.4 * side):Normalized()

    hamster:AddNewModifier(
        hamster,
        nil,
        "modifier_generic_arc_lua",
        {
            dir_x        = dir.x,
            dir_y        = dir.y,
            duration     = 0.5,
            distance     = 250,
            height       = 200,
            fix_end      = 0,
            fix_duration = 0,
            fix_height   = 1,
            isStun       = 1,
        }
    )
end

modifier_zhenya_boss_running = class({})

function modifier_zhenya_boss_running:IsHidden() return true end
function modifier_zhenya_boss_running:IsPurgable() return false end
function modifier_zhenya_boss_running:IsPurgeException() return false end
function modifier_zhenya_boss_running:RemoveOnDeath() return false end

function modifier_zhenya_boss_running:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_zhenya_boss_running:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    }
end

function modifier_zhenya_boss_running:GetModifierMoveSpeed_Limit()
    return 600
end

function modifier_zhenya_boss_running:GetModifierMoveSpeed_Absolute()
    return 600
end

function modifier_zhenya_boss_running:GetModifierMoveSpeedOverride()
    return 600
end

modifier_zhenya_boss_phase1 = class({})

function modifier_zhenya_boss_phase1:IsHidden() return false end
function modifier_zhenya_boss_phase1:IsPurgable() return false end
function modifier_zhenya_boss_phase1:IsDebuff() return false end
function modifier_zhenya_boss_phase1:IsBuff() return true end

function modifier_zhenya_boss_phase1:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local maxHP = parent:GetMaxHealth()
    self.min_health = math.floor(maxHP * 0.5 + 0.5)

    local q = parent:FindAbilityByName("zhenya_q_boss")
    local w = parent:FindAbilityByName("zhenya_w_boss")
    local e = parent:FindAbilityByName("zhenya_innate_boss")

    if q and not q:IsNull() then q:SetLevel(1) end
    if w and not w:IsNull() then w:SetLevel(1) end
    if e and not e:IsNull() then e:SetLevel(1) end
end

function modifier_zhenya_boss_phase1:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end

function modifier_zhenya_boss_phase1:GetMinHealth()
    return self.min_health or 0
end


modifier_zhenya_boss_phase2 = class({})

function modifier_zhenya_boss_phase2:IsHidden() return false end
function modifier_zhenya_boss_phase2:IsPurgable() return false end
function modifier_zhenya_boss_phase2:IsDebuff() return false end
function modifier_zhenya_boss_phase2:IsBuff() return true end

function modifier_zhenya_boss_phase2:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local q = parent:FindAbilityByName("zhenya_q_boss")
    local w = parent:FindAbilityByName("zhenya_w_boss")
    local e = parent:FindAbilityByName("zhenya_innate_boss")
    local leap = parent:FindAbilityByName("zhenya_e_boss")

    if q and not q:IsNull() then q:SetLevel(2) end
    if w and not w:IsNull() then w:SetLevel(2) end
    if e and not e:IsNull() then e:SetLevel(2) end
    if leap and not leap:IsNull() and leap:GetLevel() < 1 then
        leap:SetLevel(1)
    end
end

function modifier_zhenya_boss_phase2:DeclareFunctions()
    return {
        -- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


modifier_zhenya_boss_escape = class({})

function modifier_zhenya_boss_escape:IsHidden() return true end
function modifier_zhenya_boss_escape:IsPurgable() return false end
function modifier_zhenya_boss_escape:IsPurgeException() return false end
function modifier_zhenya_boss_escape:RemoveOnDeath() return false end

function modifier_zhenya_boss_escape:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE]                  = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]             = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED]            = false,
    }
end

function modifier_zhenya_boss_escape:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    }
end

function modifier_zhenya_boss_escape:GetModifierMoveSpeed_Limit()
    return 600
end

function modifier_zhenya_boss_escape:GetModifierMoveSpeed_Absolute()
    return 600
end

function modifier_zhenya_boss_escape:GetModifierMoveSpeedBase_Override()
    return 600
end