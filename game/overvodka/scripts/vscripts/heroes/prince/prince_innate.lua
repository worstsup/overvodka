LinkLuaModifier("modifier_prince_innate", "heroes/prince/prince_innate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE )
prince_innate = class({})

function prince_innate:GetBehavior()
    if self:GetSpecialValueFor("active") == 1 then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
end

function prince_innate:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local radius        = self:GetSpecialValueFor("radius")
    local push_range    = self:GetSpecialValueFor("push_range")
    local push_duration = self:GetSpecialValueFor("push_duration")

    local p = ParticleManager:CreateParticle("particles/prince_innate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 2, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 7, Vector(radius, 0, 0))
    EmitSoundOn("prince_innate", caster)
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    local damage = 0
    if caster:HasTalent("special_bonus_unique_prince_1") then
        damage = self:GetSpecialValueFor("damage")
    end

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            local kb = {
                center_x = caster:GetAbsOrigin().x,
                center_y = caster:GetAbsOrigin().y,
                center_z = caster:GetAbsOrigin().z,
                duration = push_duration,
                knockback_duration = push_duration,
                knockback_distance = push_range,
                knockback_height = 0,
            }
            enemy:AddNewModifier(caster, self, "modifier_knockback", kb)
            enemy:AddNewModifier(caster, self, "modifier_generic_disarmed_lua", { duration = self:GetSpecialValueFor("disarm_duration") })
            if damage > 0 then
                ApplyDamage({
                    victim = enemy,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self,
                })
            end
        end
    end
end

function prince_innate:GetIntrinsicModifierName()
    return "modifier_prince_innate"
end

modifier_prince_innate = class({})

function modifier_prince_innate:IsHidden()   return true end
function modifier_prince_innate:IsPurgable() return false end

function modifier_prince_innate:OnCreated()
    if not IsServer() then return end
    self.attackers = {}
end

function modifier_prince_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

local function cleanup_old_attackers(t, now)
    for k, expire in pairs(t) do
        if expire <= now then
            t[k] = nil
        end
    end
end

function modifier_prince_innate:OnAttackLanded(params)
    if not IsServer() then return end

    local parent  = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end
    if not parent or parent:IsNull() then return end
    if parent:PassivesDisabled() or not parent:IsAlive() or not ability:IsCooldownReady() then return end

    if params.target ~= parent then return end
    local attacker = params.attacker
    if not attacker or attacker:IsNull() then return end
    if attacker:GetTeamNumber() == parent:GetTeamNumber() then return end

    local window          = ability:GetSpecialValueFor("window")
    local attackers_need  = ability:GetSpecialValueFor("attackers_need")
    local radius          = ability:GetSpecialValueFor("radius")
    local push_range      = ability:GetSpecialValueFor("push_range")
    local push_duration   = ability:GetSpecialValueFor("push_duration")

    local now = GameRules:GetGameTime()
    cleanup_old_attackers(self.attackers, now)
    self.attackers[attacker:entindex()] = now + window

    local unique_count = 0
    for _, _ in pairs(self.attackers) do
        unique_count = unique_count + 1
    end

    if unique_count >= attackers_need then
        EmitSoundOn("prince_innate", parent)
        local p = ParticleManager:CreateParticle("particles/prince_innate.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 2, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 7, Vector(radius, 0, 0))
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false
        )
        local damage = 0
        if parent:HasTalent("special_bonus_unique_prince_1") then
            damage = ability:GetSpecialValueFor("damage")
        end
        for _, enemy in ipairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() then
                local kb = {
                    center_x = parent:GetAbsOrigin().x,
                    center_y = parent:GetAbsOrigin().y,
                    center_z = parent:GetAbsOrigin().z,
                    duration = push_duration,
                    knockback_duration = push_duration,
                    knockback_distance = push_range,
                    knockback_height = 0,
                }
                enemy:AddNewModifier(parent, ability, "modifier_knockback", kb)
                enemy:AddNewModifier(parent, ability, "modifier_generic_disarmed_lua", { duration = ability:GetSpecialValueFor("disarm_duration") })
                if damage > 0 then
                    ApplyDamage({
                        victim = enemy,
                        attacker = parent,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability,
                    })
                end
            end
        end
        ability:UseResources(false, false, false, true)
        self.attackers = {}
    end
end