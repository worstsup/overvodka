LinkLuaModifier("modifier_dave_scepter", "heroes/dave/dave_scepter", LUA_MODIFIER_MOTION_NONE)

dave_scepter = class({})

function dave_scepter:Spawn()
    if not IsServer() then return end
    if self:IsTrained() then return end
    self:SetLevel(1)
end

function dave_scepter:GetIntrinsicModifierName()
    return "modifier_dave_scepter"
end

function dave_scepter:OnProjectileHit(target, location)
    if not target or target:IsNull() then return true end
    if target:IsInvulnerable() then return true end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end

    local max_hp = target:GetMaxHealth()
    local damage = max_hp * (self:GetSpecialValueFor("damage") or 15) / 100

    ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS, ability = self })

    return true
end

modifier_dave_scepter = class({})

function modifier_dave_scepter:IsHidden() return true end
function modifier_dave_scepter:IsPurgable() return false end
function modifier_dave_scepter:RemoveOnDeath() return false end
function modifier_dave_scepter:IsPermanent() return true end

function modifier_dave_scepter:OnCreated()
    if not IsServer() then return end

    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self._was_mana_zero = (self.parent and self.parent:GetMana() <= 0)

    self:StartIntervalThink(0.2)
end

function modifier_dave_scepter:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self.parent:GetMana() > 0 then
        self._was_mana_zero = false
    end
end

function modifier_dave_scepter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_dave_scepter:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self.parent or self:GetParent()
    if not parent or parent:IsNull() then return end
    if params.unit ~= parent then return end

    if parent:IsIllusion() then return end
    if parent:PassivesDisabled() then return end

    local ability = self.ability or self:GetAbility()
    if not ability or ability:IsNull() then return end
    if ability:GetLevel() <= 0 then return end
    if not ability:IsCooldownReady() then return end

    if parent:GetMana() > 0 then return end
    if self._was_mana_zero then return end

    local attacker = params.attacker
    if not attacker or attacker:IsNull() then return end
    if attacker:GetTeamNumber() == parent:GetTeamNumber() then return end
    if not attacker:IsHero() then return end
    if attacker:IsIllusion() then return end

    EmitSoundOn("dave_scepter", parent)

    ProjectileManager:CreateTrackingProjectile({
        Target = attacker,
        Source = parent,
        Ability = ability,
        EffectName = "particles/dave_missile.vpcf",
        iMoveSpeed = 600,
        vSourceLoc = parent:GetAbsOrigin(),
        bDodgeable = true,
        bProvidesVision = false,
    })

    ability:UseResources(false, false, false, true)

    self._was_mana_zero = true
end
