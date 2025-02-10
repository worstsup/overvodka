shkolnik_shard = class({})

LinkLuaModifier("modifier_shkolnik_shard_buff", "heroes/shkolnik/shkolnik_shard", LUA_MODIFIER_MOTION_NONE)

function shkolnik_shard:Precache(context)
    PrecacheResource("particle", "particles/econ/events/ti9/ti9_drums_musicnotes.vpcf", context)
    PrecacheResource("particle", "particles/invoker_kid_book_new.vpcf", context)
    PrecacheResource( "soundfile", "soundevents/shkola.vsndevts", context )
end

function shkolnik_shard:OnSpellStart()
    local caster = self:GetCaster()
    EmitSoundOn("shkola", caster)
    local particle_cast = "particles/invoker_kid_book_new.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    local duration = self:GetSpecialValueFor("duration")
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability and ability ~= self then
            local remaining_cd = ability:GetCooldownTimeRemaining()
            local new_cd = math.max(remaining_cd - duration, 0)
            ability:EndCooldown()
            ability:StartCooldown(new_cd)
        end
    end

    local allies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        12000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, ally in ipairs(allies) do
        if ally == caster or (not ally:IsHero() and ally:GetTeam() == caster:GetTeam()) then
            ally:AddNewModifier(caster, self, "modifier_shkolnik_shard_buff", {duration = duration})
        end
    end
end

modifier_shkolnik_shard_buff = class({})

function modifier_shkolnik_shard_buff:IsPurgable()
    return false
end

function modifier_shkolnik_shard_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_shkolnik_shard_buff:GetModifierIncomingDamage_Percentage()
    return -self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_shkolnik_shard_buff:GetEffectName()
    return "particles/econ/events/ti9/ti9_drums_musicnotes.vpcf"
end

function modifier_shkolnik_shard_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end