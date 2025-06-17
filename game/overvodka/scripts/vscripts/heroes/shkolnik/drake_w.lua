drake_w = class({})

LinkLuaModifier( "modifier_drake_w_petrified", "heroes/shkolnik/drake_w", LUA_MODIFIER_MOTION_NONE )

function drake_w:Precache( context )
    PrecacheResource( "particle", "particles/drake_w.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context)
    PrecacheResource( "soundfile", "soundevents/drake_w.vsndevts", context)
    PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", context)
end

function drake_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor( "radius" )
    local damage = self:GetSpecialValueFor( "damage" )
    local stone_angle = self:GetSpecialValueFor( "stone_angle" )
    local stone_duration = self:GetSpecialValueFor( "stone_duration" )
    local physical_bonus = self:GetSpecialValueFor( "bonus_physical_damage" )
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        0,
        false
    )
    local p = ParticleManager:CreateParticle("particles/drake_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    EmitSoundOn( "drake_w", caster )
    for _, enemy in pairs(enemies) do
        local to_caster = caster:GetOrigin() - enemy:GetOrigin()
        local angle = math.abs( AngleDiff( VectorToAngles( to_caster ).y, VectorToAngles( enemy:GetForwardVector() ).y ) )
        if angle < stone_angle then
            enemy:AddNewModifier(caster, self, "modifier_drake_w_petrified", {duration = stone_duration * (1-enemy:GetStatusResistance()), physical_bonus = physical_bonus, caster_entindex = caster:entindex()})
            ApplyDamage({ victim = enemy, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
        end
    end
end

modifier_drake_w_petrified = class({})

function modifier_drake_w_petrified:IsHidden() return false end
function modifier_drake_w_petrified:IsDebuff() return true end
function modifier_drake_w_petrified:IsStunDebuff() return true end
function modifier_drake_w_petrified:IsPurgable() return true end

function modifier_drake_w_petrified:OnCreated( kv )
    self.physical_bonus = kv.physical_bonus
    if not IsServer() then return end
    self.caster_unit = EntIndexToHScript( kv.caster_entindex )
    self:PlayEffects()
end

function modifier_drake_w_petrified:OnRefresh( kv )
    self.physical_bonus = kv.physical_bonus
    if not IsServer() then return end
    self.caster_unit = EntIndexToHScript( kv.caster_entindex )
    self:PlayEffects()
end

function modifier_drake_w_petrified:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_drake_w_petrified:GetModifierIncomingDamage_Percentage( params )
    if params.damage_type == DAMAGE_TYPE_PHYSICAL and params.attacker:GetTeamNumber() == self:GetCaster():GetTeamNumber() and not params.attacker:IsRealHero() and params.attacker:GetOwner() == self:GetCaster() then
        return self.physical_bonus
    end
    return 0
end

function modifier_drake_w_petrified:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }
    return state
end

function modifier_drake_w_petrified:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_drake_w_petrified:StatusEffectPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_drake_w_petrified:PlayEffects()
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    if self.caster_unit then
        ParticleManager:SetParticleControlEnt(effect_cast, 1, self.caster_unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector( 0,0,0 ), true)
    end
    self:AddParticle(effect_cast, false, false, -1, false, false)
    EmitSoundOn( "Hero_Medusa.StoneGaze.Stun", self:GetParent() )
end