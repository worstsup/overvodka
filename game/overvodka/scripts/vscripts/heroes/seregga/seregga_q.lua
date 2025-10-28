LinkLuaModifier("modifier_seregga_q_biceps",        "heroes/seregga/seregga_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_q_aegis",         "heroes/seregga/seregga_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_seregga_q_shard_window",  "heroes/seregga/seregga_q", LUA_MODIFIER_MOTION_NONE)
seregga_q = class({})

local function _ShardMul(unit)
    return (unit and unit:HasModifier("modifier_seregga_q_shard_window")) and 2 or 1
end

function seregga_q:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/seregga_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/seregga_q_shard.vpcf", ctx)
    PrecacheResource("model", "models/creeps/roshan/aegis.vmdl", ctx)
    PrecacheResource("particle", "particles/items_fx/aegis_respawn.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_cast_crimson.vpcf", ctx)
end

function seregga_q:OnUpgrade()
    if not IsServer() then return end
    local caster = self:GetCaster()

    if self:GetLevel() == 1 and not self._initialized then
        self._mode = "biceps"
        caster:AddNewModifier(caster, self, "modifier_seregga_q_biceps", {})
        self._initialized = true
        self:EndCooldown()
        return
    end

    if self._mode == "aegis" then
        local mod = caster:FindModifierByName("modifier_seregga_q_aegis")
        if mod then mod:ForceRefresh() end
    else
        local mod = caster:FindModifierByName("modifier_seregga_q_biceps")
        if mod then mod:ForceRefresh() end
    end
end

function seregga_q:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_seregga_q_aegis") then
        return "seregga_q_aegis"
    end
    return "seregga_q_biceps"
end

function seregga_q:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function seregga_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local mode = self._mode or "biceps"

    if mode == "biceps" then
        caster:RemoveModifierByName("modifier_seregga_q_biceps")
        caster:AddNewModifier(caster, self, "modifier_seregga_q_aegis", {})
        self._mode = "aegis"
    else
        caster:RemoveModifierByName("modifier_seregga_q_aegis")
        caster:AddNewModifier(caster, self, "modifier_seregga_q_biceps", {})
        self._mode = "biceps"
    end

    if caster:HasShard() then
        caster:AddNewModifier(caster, self, "modifier_seregga_q_shard_window", { duration = self:GetSpecialValueFor("shard_duration") })
    end

    caster:EmitSound("seregga_q")
    self:UseResources(false, false, false, true)
end


modifier_seregga_q_biceps = class({})

function modifier_seregga_q_biceps:IsHidden() return false end
function modifier_seregga_q_biceps:IsPurgable() return false end
function modifier_seregga_q_biceps:RemoveOnDeath() return false end
function modifier_seregga_q_biceps:GetTexture() return "seregga_q_biceps" end

function modifier_seregga_q_biceps:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    self.pseudoseed = RandomInt( 1, 100 )
    if not self.ability then return end
    self.crit_chance = self.ability:GetSpecialValueFor("biceps_crit_chance")
    self.crit_damage = self.ability:GetSpecialValueFor("biceps_crit_mult")
    self.range_bonus = self.ability:GetSpecialValueFor("biceps_attack_range")
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    local p2 = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_cast_crimson.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(p2, 0, self.parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p2)
end

function modifier_seregga_q_biceps:OnRefresh()
    self:OnCreated()
end

function modifier_seregga_q_biceps:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_seregga_q_biceps:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then return end
    local mul = _ShardMul(self.parent)
    local chance = self.crit_chance or 0
    if RollPseudoRandomPercentage(chance, self.pseudoseed, self.parent) then
        return (self.crit_damage or 0) * mul
    end
end

function modifier_seregga_q_biceps:GetModifierAttackRangeBonus()
    local mul = _ShardMul(self.parent)
    return (self.range_bonus or 0) * mul
end

function modifier_seregga_q_biceps:OnTooltip()
    local mul = _ShardMul(self.parent)
    return (self.crit_damage or 0) * mul
end


modifier_seregga_q_aegis = class({})

function modifier_seregga_q_aegis:IsHidden() return false end
function modifier_seregga_q_aegis:IsPurgable() return false end
function modifier_seregga_q_aegis:RemoveOnDeath() return false end
function modifier_seregga_q_aegis:GetTexture() return "seregga_q_aegis" end

function modifier_seregga_q_aegis:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()
    if not self.ability then return end

    self.bonus_armor   = self.ability:GetSpecialValueFor("aegis_armor")
    self.reflect_pct   = self.ability:GetSpecialValueFor("aegis_reflect_pct")
    self.status_resist = self.ability:GetSpecialValueFor("aegis_status_resist")

    if not IsServer() then return end

    if (not self.parent.aegis) or self.parent.aegis:IsNull() then
        local aegis = SpawnEntityFromTableSynchronous("prop_dynamic", {
            model = "models/creeps/roshan/aegis.vmdl",
        })
        if aegis then
            aegis:FollowEntity(self.parent, true)
            aegis:SetParent(self.parent, "attach_attack2")
            aegis:SetLocalOrigin(Vector(0, 0, 0))
            aegis:SetModelScale(0.5)
            self.parent.aegis = aegis
        end
    end

    local p = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(p, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, self.parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
end

function modifier_seregga_q_aegis:OnRefresh()
    self:OnCreated()
end

function modifier_seregga_q_aegis:OnDestroy()
    if not IsServer() then return end
    if self.parent and self.parent.aegis and not self.parent.aegis:IsNull() then
        self.parent.aegis:RemoveSelf()
        self.parent.aegis = nil
    end
end

function modifier_seregga_q_aegis:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_seregga_q_aegis:GetModifierPhysicalArmorBonus()
    local mul = _ShardMul(self.parent)
    return (self.bonus_armor or 0) * mul
end

function modifier_seregga_q_aegis:GetModifierStatusResistanceStacking()
    local mul = _ShardMul(self.parent)
    return (self.status_resist or 0) * mul
end

function modifier_seregga_q_aegis:OnTakeDamage(event)
    if not IsServer() then return end
    if not self.ability or self.ability:IsNull() then return end

    local parent   = self:GetParent()
    local attacker = event.attacker
    if event.unit ~= parent then return end
    if not attacker or attacker:IsNull() then return end
    if attacker:GetTeamNumber() == parent:GetTeamNumber() then return end
    if attacker:IsBuilding() then return end
    if event.original_damage <= 0 then return end

    local flags = event.damage_flags or 0
    if bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then
        return
    end

    local mul = _ShardMul(parent)
    local pct = math.max(0, (self.reflect_pct or 0) * mul) * 0.01
    if pct <= 0 then return end

    local dmg = event.original_damage * pct
    ApplyDamage({
        victim = attacker,
        attacker = parent,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
    })
end


modifier_seregga_q_shard_window = class({})

function modifier_seregga_q_shard_window:IsHidden() return false end
function modifier_seregga_q_shard_window:IsPurgable() return false end
function modifier_seregga_q_shard_window:RemoveOnDeath() return true end
function modifier_seregga_q_shard_window:GetEffectName() return "particles/seregga_q_shard.vpcf" end
function modifier_seregga_q_shard_window:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end