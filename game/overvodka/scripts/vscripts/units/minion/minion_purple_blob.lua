LinkLuaModifier("modifier_minion_purple_blob_passive", "units/minion/minion_purple_blob", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_disarmed_lua", "modifier_generic_disarmed_lua", LUA_MODIFIER_MOTION_NONE)

minion_purple_blob = class({})

function minion_purple_blob:GetIntrinsicModifierName()
    return "modifier_minion_purple_blob_passive"
end

function minion_purple_blob:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not target then return end
    local caster = self:GetCaster()
    local damage_base = self:GetSpecialValueFor("damage_base")
    local damage_pct  = self:GetSpecialValueFor("damage_pct")
    local duration = self:GetSpecialValueFor("duration")
    local target_current_health = target:GetHealth()
    local damage = damage_base + (damage_pct / 100) * target_current_health
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self,
    })
    if target and not target:IsNull() then
        target:AddNewModifier(caster, self, "modifier_generic_disarmed_lua", { duration = duration })
    end
    caster:EmitSound("minion_purple_blob")
end

modifier_minion_purple_blob_passive = class({})

function modifier_minion_purple_blob_passive:IsHidden() return true end
function modifier_minion_purple_blob_passive:IsPurgable() return false end
function modifier_minion_purple_blob_passive:RemoveOnDeath() return false end

function modifier_minion_purple_blob_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HEALTH_GAINED,
    }
end

function modifier_minion_purple_blob_passive:OnCreated(kv)
    if not IsServer() then return end
    local parent = self:GetParent()
    if GetMapName() ~= "overvodka_5x5" then
        parent:SetMinimumGoldBounty(200)
        parent:SetMaximumGoldBounty(200)
        parent:SetDeathXP(250)
    end
    self.triggered = false
    self:StartIntervalThink(0.1)
end

function modifier_minion_purple_blob_passive:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent:PassivesDisabled() then return end
    if parent:GetHealth() >= parent:GetMaxHealth() * 0.9 then
        self.triggered = false
    end
end

function modifier_minion_purple_blob_passive:OnHealthGained(params)
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end
    local parent = self:GetParent()
    if parent:GetHealth() >= parent:GetMaxHealth() * 0.9 then
        self.triggered = false
    end
end

function modifier_minion_purple_blob_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if params.unit ~= parent then return end
    if parent:GetHealth() < parent:GetMaxHealth() * 0.5 and not self.triggered then
        self.triggered = true
        local ability = self:GetAbility()
        local search_radius = ability:GetSpecialValueFor("radius")
        local team = parent:GetTeamNumber()
        local enemies = FindUnitsInRadius(team, parent:GetAbsOrigin(), nil, search_radius, 
                            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
        if #enemies > 0 then
            local target = enemies[1]
            local projectile_speed = 1000
            local info = {
                Target = target,
                Source = parent,
                Ability = ability,
                EffectName = "particles/minion_purple_blob.vpcf",
                iMoveSpeed = projectile_speed,
                bDodgeable = true,
                bProvidesVision = false,
            }
            ProjectileManager:CreateTrackingProjectile(info)
            parent:EmitSound("minion_purple_blob.trigger")
        end
    end
end
