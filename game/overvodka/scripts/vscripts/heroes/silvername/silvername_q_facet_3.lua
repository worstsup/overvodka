LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

silvername_q_facet_3 = class({})

function silvername_q_facet_3:OnAbilityPhaseStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound( "silvername_q_facet_3" )
    return true
end

function silvername_q_facet_3:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    self:GetCaster():StopSound( "silvername_q_facet_3" )
end

function silvername_q_facet_3:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local primary = self:GetCursorTarget()
    if not caster or caster:IsNull() or not primary or primary:IsNull() then return end
    local damage = self:GetSpecialValueFor( "damage" )
    local duration = self:GetSpecialValueFor( "stun_duration" )

    EmitSoundOn( "DOTA_Item.Dagon.Activate", primary )

    local p = ParticleManager:CreateParticle( "particles/econ/events/ti5/dagon_lvl2_ti5.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControlEnt( p, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false )
    ParticleManager:SetParticleControlEnt( p, 1, primary, PATTACH_POINT_FOLLOW, "attach_hitloc", primary:GetAbsOrigin(), false )
    ParticleManager:SetParticleControl( p, 2, Vector(800) )

    primary:AddNewModifier( caster, self, "modifier_generic_stunned_lua", { duration = duration } )
    ApplyDamage( { victim = primary, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
end