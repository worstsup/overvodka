LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

item_lesh = class({})

function item_lesh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    local target_maxHealth = target:GetMaxHealth()

    local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
    ParticleManager:SetParticleControl(dagon_particle, 2, Vector(800))

    local damage = target_maxHealth * self:GetSpecialValueFor("damage_pct") / 100
 
    caster:EmitSound("ailesh")
    target:EmitSound("ailesh")

    if target:IsDebuffImmune() then return end

    target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor("stun_duration")})
    ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
    self:SpendCharge(1)
end