speed_cr7 = class({})

LinkLuaModifier("modifier_speed_cr7_buff", "heroes/speed/speed_cr7", LUA_MODIFIER_MOTION_NONE)

function speed_cr7:Precache(context)
    PrecacheResource("particle", "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf", context)
    PrecacheResource( "particle", "particles/golmy_2.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/speed_cr7.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )
end

function speed_cr7:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_overvodka_store_skin_5") then
        return "twenty_skin"
    end
    return "twenty"
end

function speed_cr7:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster:HasModifier("modifier_overvodka_store_skin_5") then
        EmitSoundOn("speed_cr7", caster)
        local particle_cast = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_projectile_flame_child_blue.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(effect_cast, 3, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
    local cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction")
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability and ability ~= self then
            local remaining_cd = ability:GetCooldownTimeRemaining()
            local new_cd = math.max(remaining_cd - cooldown_reduction, 0)
            ability:EndCooldown()
            ability:StartCooldown(new_cd)
        end
    end
    caster:AddNewModifier(caster, self, "modifier_speed_cr7_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_speed_cr7_buff = class({})

function modifier_speed_cr7_buff:IsPurgable()
    return true
end

function modifier_speed_cr7_buff:OnCreated()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_overvodka_store_skin_5") then
        local p = ParticleManager:CreateParticle("particles/golmy_2.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        self:AddParticle(p, false, false, -1, false, false)
    end
end

function modifier_speed_cr7_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
end

function modifier_speed_cr7_buff:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor("mana_hp_regen")
end
function modifier_speed_cr7_buff:GetModifierTotalPercentageManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_hp_regen")
end

function modifier_speed_cr7_buff:GetEffectName()
    return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf"
end

function modifier_speed_cr7_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end