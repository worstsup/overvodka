flash_q_facet_1 = class({})

function flash_q_facet_1:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_overvodka_store_skin_6") then
        return "flash_q_facet_1_immortal"
    end
    return "flash_q_facet_1"
end

function flash_q_facet_1:Precache(context)
    PrecacheResource("particle", "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", context)
    PrecacheResource("particle", "particles/zuus_lightning_bolt_immortal_lightning_blackflash.vpcf", context)
    PrecacheResource("particle", "particles/sven_warcry_cast_arc_lightning_blackflash.vpcf", context)
end

function flash_q_facet_1:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    damage = self:GetSpecialValueFor("damage") + self:GetSpecialValueFor("damage_speed") * caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), true) * 0.01
    ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType()})
    local name = "particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_immortal_lightning.vpcf"
    if caster:HasModifier("modifier_overvodka_store_skin_6") then
        name = "particles/zuus_lightning_bolt_immortal_lightning_blackflash.vpcf"
    end
    local particle = ParticleManager:CreateParticle(name, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    local name2 = "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf"
    if caster:HasModifier("modifier_overvodka_store_skin_6") then
        name2 = "particles/sven_warcry_cast_arc_lightning_blackflash.vpcf"
    end
    local particle2 = ParticleManager:CreateParticle(name2, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle2)
    target:EmitSound("flash_q_facet1")
    if not caster:HasModifier("modifier_overvodka_store_skin_6") then
        caster:EmitSound("flash_q_facet1_voice")
    else
        caster:EmitSound("flash_q_facet_1_immortal")
    end
end