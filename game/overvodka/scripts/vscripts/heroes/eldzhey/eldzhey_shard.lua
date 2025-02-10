eldzhey_shard = class({})

LinkLuaModifier("modifier_eldzhey_shard", "heroes/eldzhey/eldzhey_shard", LUA_MODIFIER_MOTION_NONE)

function eldzhey_shard:Precache(context)
    PrecacheResource("particle", "particles/items_fx/drum_of_endurance_buff.vpcf", context)
    PrecacheResource("soundfile", "soundevents/vivo.vsndevts", context )
end

function eldzhey_shard:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    EmitSoundOn("vivo", caster)
    caster:AddNewModifier(caster, self, "modifier_eldzhey_shard", {duration = duration})
    
    local allies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        12000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
        FIND_ANY_ORDER,
        false
    )

    for _, unit in ipairs(allies) do
        if unit:IsIllusion() then
            unit:AddNewModifier(caster, self, "modifier_eldzhey_shard", {duration = duration})
        end
    end
end

modifier_eldzhey_shard = class({})

function modifier_eldzhey_shard:IsPurgable()
    return false
end

function modifier_eldzhey_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_eldzhey_shard:OnCreated()
    local ability = self:GetAbility()
    if ability then
        self.bonus_range = ability:GetSpecialValueFor("bonus_range")
        self.bonus_ms = ability:GetSpecialValueFor("bonus_ms")
    end
end

function modifier_eldzhey_shard:GetModifierAttackRangeBonus()
    return self.bonus_range or 0
end

function modifier_eldzhey_shard:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms or 0
end

function modifier_eldzhey_shard:GetEffectName()
    return "particles/items_fx/drum_of_endurance_buff.vpcf"
end

function modifier_eldzhey_shard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end