LinkLuaModifier("modifier_prince_innate", "heroes/prince/prince_innate", LUA_MODIFIER_MOTION_NONE)

prince_innate = class({})

function prince_innate:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local radius        = self:GetSpecialValueFor("radius")
    local push_range    = self:GetSpecialValueFor("push_range")
    local push_duration = self:GetSpecialValueFor("push_duration")
    local disarm_duration = self:GetSpecialValueFor("disarm_duration")
    local caster_origin = caster:GetAbsOrigin()

    local p = ParticleManager:CreateParticle("particles/prince_innate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, caster_origin)
    ParticleManager:SetParticleControl(p, 2, caster_origin)
    ParticleManager:SetParticleControl(p, 7, Vector(radius, 0, 0))
    EmitSoundOn("prince_innate", caster)
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster_origin,
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
    local kb = {
        center_x = caster_origin.x,
        center_y = caster_origin.y,
        center_z = caster_origin.z,
        duration = push_duration,
        knockback_duration = push_duration,
        knockback_distance = push_range,
        knockback_height = 0,
    }
    local disarm_kv = { duration = disarm_duration }
    local damage_table = {
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }

    for _, enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            enemy:AddNewModifier(caster, self, "modifier_knockback", kb)
            enemy:AddNewModifier(caster, self, "modifier_generic_disarmed_lua", disarm_kv)
            if damage > 0 then
                damage_table.victim = enemy
                ApplyDamage(damage_table)
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
function modifier_prince_innate:RemoveOnDeath() return false end

function modifier_prince_innate:OnCreated()
    self.parent = self:GetParent()
    if not IsServer() then return end
    self.attackers = {}
    self._was_not_original_model = false
    self:StartIntervalThink(0.15)
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

function modifier_prince_innate:OnRefresh()
    self:OnCreated()
end

function modifier_prince_innate:_IsOriginalModelNow()
    if not self.parent or self.parent:IsNull() then return false end
    return self.parent:GetModelName() == "models/prince/prince.vmdl"
end

function modifier_prince_innate:_HideWeapon()
    if not IsServer() then return end
    if self.parent.weapon then
        self.parent.weapon:SetModelScale(0)
        self.parent.weapon:SetParent(self.parent, "attach_hitloc")
    end
end

function modifier_prince_innate:_ShowWeapon()
    if not IsServer() then return end
    if self.parent.weapon then
        self.parent.weapon:SetModelScale(1)
        self.parent.weapon:SetParent(self.parent, "attach_sword")
        self.parent.weapon:SetLocalOrigin(Vector(0, 0, 0))
        self.parent.weapon:SetLocalAngles(0, 0, 0)
    end
end

function modifier_prince_innate:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self.parent:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

    local is_original = self:_IsOriginalModelNow()

    if not is_original then
        self._was_not_original_model = true
        self:_HideWeapon()
        return
    end

    if self._was_not_original_model then
        self._was_not_original_model = false
        self:_ShowWeapon()
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
        local parent_origin = parent:GetAbsOrigin()
        local p = ParticleManager:CreateParticle("particles/prince_innate.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p, 0, parent_origin)
        ParticleManager:SetParticleControl(p, 2, parent_origin)
        ParticleManager:SetParticleControl(p, 7, Vector(radius, 0, 0))
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            parent_origin,
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
        local disarm_duration = ability:GetSpecialValueFor("disarm_duration")
        local kb = {
            center_x = parent_origin.x,
            center_y = parent_origin.y,
            center_z = parent_origin.z,
            duration = push_duration,
            knockback_duration = push_duration,
            knockback_distance = push_range,
            knockback_height = 0,
        }
        local disarm_kv = { duration = disarm_duration }
        local damage_table = {
            attacker = parent,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        }
        for _, enemy in ipairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() then
                enemy:AddNewModifier(parent, ability, "modifier_knockback", kb)
                enemy:AddNewModifier(parent, ability, "modifier_generic_disarmed_lua", disarm_kv)
                if damage > 0 then
                    damage_table.victim = enemy
                    ApplyDamage(damage_table)
                end
            end
        end
        ability:UseResources(false, false, false, true)
        self.attackers = {}
    end
end