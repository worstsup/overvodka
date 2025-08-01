LinkLuaModifier( "modifier_dave_e", "heroes/dave/dave_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dave_e_barrier", "heroes/dave/dave_e", LUA_MODIFIER_MOTION_NONE )

dave_e = class({})

function dave_e:Precache(context)
    PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield_buff.vpcf", context )
    PrecacheResource( "particle", "particles/dave_e_scepter.vpcf", context)
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context )
end

function dave_e:GetIntrinsicModifierName()
    return "modifier_dave_e"
end

function dave_e:IsStealable()
    return false
end

function dave_e:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
end

function dave_e:GetManaCost( lvl )
    if self:GetCaster():HasScepter() then
        local m = self:GetCaster():GetMana()
        return math.ceil( m * 0.30 )
    end
    return 0
end

function dave_e:GetCooldown( lvl )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "cooldown" )
    end
    return 0
end

function dave_e:GetCastRange( location, target )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor( "radius" )
    end
    return 0
end

function dave_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster:HasScepter() then return end
    local cost = math.ceil( caster:GetMana() * 0.30 )
    local allies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        self:GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _,ally in ipairs(allies) do
        ally:AddNewModifier( caster, self, "modifier_dave_e_barrier", { duration = self:GetSpecialValueFor("barrier_duration"), shield = cost } )
    end
    local effect_cast = ParticleManager:CreateParticle( "particles/dave_e_scepter.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, caster:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn( "Hero_Medusa.ManaShield.On", caster )
end

modifier_dave_e = class({})

function modifier_dave_e:IsPurgable() return false end
function modifier_dave_e:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_dave_e:OnCreated()
    if not IsServer() then return end
    self.damage_per_mana = self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
    self.absorb_pct = self:GetAbility():GetSpecialValueFor( "absorption_pct" ) / 100
end

function modifier_dave_e:OnRefresh()
    self:OnCreated()
end

function modifier_dave_e:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_dave_e:GetModifierIncomingDamage_Percentage( params )
    local parent = self:GetParent()
    local dmg = params.original_damage
    local mana_shield = math.min( parent:GetMana(), dmg * self.absorb_pct / self.damage_per_mana )
    local absorbed = mana_shield * self.damage_per_mana
    local pct_return = -100 * (absorbed / dmg)

    parent:SpendMana( mana_shield, self:GetAbility() )
    self:PlayEffects( absorbed )

    return pct_return
end

function modifier_dave_e:GetEffectName()       return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf" end
function modifier_dave_e:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_dave_e:PlayEffects( damage )
    local p = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControl( p, 1, Vector(damage,0,0) )
    ParticleManager:ReleaseParticleIndex( p )
    EmitSoundOn( "Hero_Medusa.ManaShield.Proc", self:GetParent() )
end

modifier_dave_e_barrier = class({})

function modifier_dave_e_barrier:IsPurgable() return true end
function modifier_dave_e_barrier:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_dave_e_barrier:OnCreated( kv )
    if not IsServer() then return end
    self.shield = kv.shield
    self:SetStackCount( math.floor(self.shield) )
end

function modifier_dave_e_barrier:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_dave_e_barrier:GetModifierIncomingDamageConstant( params )
    if IsClient() then
        if params.report_max then
            return self.shield or self:GetStackCount()
        else
            return self:GetStackCount()
        end
    end
    if params.damage>=self:GetStackCount() then
        self:Destroy()
        return -self:GetStackCount()
    else
        self:SetStackCount(self:GetStackCount()-params.damage)
        return -params.damage
    end
end

function modifier_dave_e_barrier:GetEffectName() return "particles/units/heroes/hero_medusa/medusa_mana_shield_buff.vpcf" end
function modifier_dave_e_barrier:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end