local function PermanentIsHidden() return true end
local function PermanentIsPurgable() return false end
local function PermanentIsPurgeException() return false end
local function PermanentRemoveOnDeath() return false end
local function PermanentIsPermanent() return true end
local function PermanentGetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

modifier_chaos_reflect = class({})
modifier_chaos_reflect.IsHidden = PermanentIsHidden
modifier_chaos_reflect.IsPurgable = PermanentIsPurgable
modifier_chaos_reflect.IsPurgeException = PermanentIsPurgeException
modifier_chaos_reflect.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_reflect.IsPermanent = PermanentIsPermanent
modifier_chaos_reflect.GetAttributes = PermanentGetAttributes

function modifier_chaos_reflect:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_chaos_reflect:OnTakeDamage(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetParent() then return end
    if not keys.attacker or keys.attacker:IsNull() then return end
    if keys.attacker == self:GetParent() then return end
    if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    if keys.attacker:IsBuilding() then return end

    local damageFlags = keys.damage_flags or 0
    if bit.band(damageFlags, DOTA_DAMAGE_FLAG_HPLOSS) ~= 0 then return end
    if bit.band(damageFlags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then return end

    local reflectedDamage = (keys.original_damage or 0) * 0.4
    if reflectedDamage <= 0 then return end

    ApplyDamage({
        victim = keys.attacker,
        attacker = self:GetParent(),
        damage = reflectedDamage,
        damage_type = keys.damage_type,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
        ability = nil,
    })
end

modifier_chaos_cooldown = class({})
modifier_chaos_cooldown.IsHidden = PermanentIsHidden
modifier_chaos_cooldown.IsPurgable = PermanentIsPurgable
modifier_chaos_cooldown.IsPurgeException = PermanentIsPurgeException
modifier_chaos_cooldown.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_cooldown.IsPermanent = PermanentIsPermanent
modifier_chaos_cooldown.GetAttributes = PermanentGetAttributes

function modifier_chaos_cooldown:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_chaos_cooldown:GetModifierPercentageCooldown()
    return 20
end

modifier_chaos_spell_surge = class({})
modifier_chaos_spell_surge.IsHidden = PermanentIsHidden
modifier_chaos_spell_surge.IsPurgable = PermanentIsPurgable
modifier_chaos_spell_surge.IsPurgeException = PermanentIsPurgeException
modifier_chaos_spell_surge.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_spell_surge.IsPermanent = PermanentIsPermanent
modifier_chaos_spell_surge.GetAttributes = PermanentGetAttributes

function modifier_chaos_spell_surge:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_chaos_spell_surge:GetModifierPercentageManacostStacking()
    return -100
end

function modifier_chaos_spell_surge:GetModifierSpellAmplify_Percentage()
    return 40
end

modifier_chaos_gold_steal = class({})
modifier_chaos_gold_steal.IsHidden = PermanentIsHidden
modifier_chaos_gold_steal.IsPurgable = PermanentIsPurgable
modifier_chaos_gold_steal.IsPurgeException = PermanentIsPurgeException
modifier_chaos_gold_steal.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_gold_steal.IsPermanent = PermanentIsPermanent
modifier_chaos_gold_steal.GetAttributes = PermanentGetAttributes

function modifier_chaos_gold_steal:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_chaos_gold_steal:OnAttackLanded(params)
    if not IsServer() then return end

    local attacker = params.attacker
    local target = params.target
    local parent = self:GetParent()

    if attacker ~= parent then return end
    if not IsRealHero(attacker) then return end
    if not target or target:IsNull() or not IsRealHero(target) then return end
    if attacker == target then return end
    if attacker:GetTeamNumber() == target:GetTeamNumber() then return end

    local victimPlayerID = target:GetPlayerID()
    if victimPlayerID == nil or victimPlayerID < 0 or not PlayerResource:IsValidPlayerID(victimPlayerID) then
        return
    end

    local victimGold = PlayerResource:GetGold(victimPlayerID) or 0
    local stealAmount = math.floor(victimGold * 0.02)

    if stealAmount <= 0 then
        return
    end

    PlayerResource:SpendGold(victimPlayerID, stealAmount, DOTA_ModifyGold_Unspecified)
    attacker:ModifyGoldFiltered(stealAmount, false, DOTA_ModifyGold_Unspecified)
end

modifier_chaos_attack_range = class({})
modifier_chaos_attack_range.IsHidden = PermanentIsHidden
modifier_chaos_attack_range.IsPurgable = PermanentIsPurgable
modifier_chaos_attack_range.IsPurgeException = PermanentIsPurgeException
modifier_chaos_attack_range.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_attack_range.IsPermanent = PermanentIsPermanent
modifier_chaos_attack_range.GetAttributes = PermanentGetAttributes

function modifier_chaos_attack_range:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end

function modifier_chaos_attack_range:GetModifierAttackRangeBonus()
    return 200
end

modifier_chaos_backpack = class({})
modifier_chaos_backpack.IsHidden = PermanentIsHidden
modifier_chaos_backpack.IsPurgable = PermanentIsPurgable
modifier_chaos_backpack.IsPurgeException = PermanentIsPurgeException
modifier_chaos_backpack.RemoveOnDeath = PermanentRemoveOnDeath
modifier_chaos_backpack.IsPermanent = PermanentIsPermanent
modifier_chaos_backpack.GetAttributes = PermanentGetAttributes

function modifier_chaos_backpack:CheckState()
    return {
        [MODIFIER_STATE_CAN_USE_BACKPACK_ITEMS] = true,
    }
end

modifier_chaos_global_doom = class({})

function modifier_chaos_global_doom:IsDebuff() return true end
function modifier_chaos_global_doom:IsPurgable() return false end
function modifier_chaos_global_doom:IsPurgeException() return false end
function modifier_chaos_global_doom:IgnoreTenacity() return true end

function modifier_chaos_global_doom:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
end

function modifier_chaos_global_doom:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_chaos_global_doom:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_chaos_global_doom:GetTexture()
    return "doom_bringer_doom"
end
