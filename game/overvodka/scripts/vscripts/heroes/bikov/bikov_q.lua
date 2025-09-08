LinkLuaModifier( "modifier_bikov_q", "heroes/bikov/bikov_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bikov_q_as_aura", "heroes/bikov/bikov_q", LUA_MODIFIER_MOTION_NONE )

bikov_q = class({})

function bikov_q:Precache(ctx)
    PrecacheUnitByNameSync("npc_igor", ctx)
    PrecacheResource("soundfile", "soundevents/bikov_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_viper/viper_nose_dive_aoe.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_furion/furion_curse_of_forest_debuff_magic.vpcf", ctx)
end

function bikov_q:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function bikov_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")
    local igor = CreateUnitByName("npc_igor", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    igor:SetControllableByPlayer(playerID, true)
    igor:SetOwner(caster)
    igor:AddNewModifier( self:GetCaster(), self, "modifier_bikov_q", {duration = duration} )
    igor:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    igor:SetMaximumGoldBounty(gold)
    igor:SetMinimumGoldBounty(gold)
    igor:SetDeathXP(xp)
    EmitSoundOnLocationWithCaster(igor:GetAbsOrigin(), "bikov_q_"..RandomInt(1,2), caster)
end


modifier_bikov_q = class({})

function modifier_bikov_q:IsAura() return true end
function modifier_bikov_q:GetAuraRadius() return self.radius or self:GetAbility():GetSpecialValueFor("radius") end
function modifier_bikov_q:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_bikov_q:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_bikov_q:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_bikov_q:GetAuraDuration() return 0.3 end
function modifier_bikov_q:GetModifierAura() return "modifier_bikov_q_as_aura" end

function modifier_bikov_q:OnCreated()
    if not IsServer() then return end
    local ability = self:GetAbility()
    self.hit_destroy = ability:GetSpecialValueFor("hit_destroy")
    self:GetParent():SetBaseMaxHealth(self.hit_destroy)
    self:GetParent():SetMaxHealth(self.hit_destroy)
    self:GetParent():SetHealth(self.hit_destroy)

    self.interval       = ability:GetSpecialValueFor("interval")
    self.radius         = ability:GetSpecialValueFor("radius")
    self.push_distance  = ability:GetSpecialValueFor("push_distance")
    self.damage         = ability:GetSpecialValueFor("damage")
    self.heal_per_pulse = ability:GetSpecialValueFor("hp_regen")
    self.mana_per_pulse = ability:GetSpecialValueFor("mana_regen")

    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_bikov_q:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then self:Destroy() return end

    local igor   = self:GetParent()
    if not igor:IsAlive() then return end
    local caster = self:GetCaster()
    local origin = igor:GetAbsOrigin()

    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nose_dive_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, igor)
    ParticleManager:SetParticleControl(p, 0, origin)
    ParticleManager:SetParticleControl(p, 1, Vector(self.radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), origin, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0,
        FIND_ANY_ORDER, false
    )
    for _,e in ipairs(enemies) do
        if e and not e:IsNull() and e:IsAlive() then
            local held_by_ult = e:HasModifier("modifier_bikov_r_hold") or e:HasModifier("modifier_bikov_r_throw_timer")

            if not held_by_ult then
                local kb = {
                    knockback_duration = 0.3,
                    duration = 0.3,
                    knockback_distance = self.push_distance,
                    knockback_height = 50,
                    center_x = origin.x, center_y = origin.y, center_z = origin.z,
                }
                e:RemoveModifierByName("modifier_knockback")
                e:AddNewModifier(caster, ability, "modifier_knockback", kb)
            end
            ApplyDamage({
                victim      = e,
                attacker    = caster,
                damage      = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability     = ability,
            })
        end
    end

    local allies = FindUnitsInRadius(
        caster:GetTeamNumber(), origin, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )
    for _,u in ipairs(allies) do
        if u and not u:IsNull() and u:IsAlive() and u ~= igor then
            if self.heal_per_pulse > 0 then
                u:Heal(self.heal_per_pulse, ability)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, u, self.heal_per_pulse, nil)
            end
            if self.mana_per_pulse > 0 then
                u:GiveMana(self.mana_per_pulse)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, u, self.mana_per_pulse, nil)
            end
        end
    end
end


function modifier_bikov_q:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end

function modifier_bikov_q:IsHidden() return true end
function modifier_bikov_q:IsPurgable() return false end

function modifier_bikov_q:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
    }
end

function modifier_bikov_q:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return decFuncs
end

function modifier_bikov_q:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local new_health = self:GetParent():GetHealth() - 1
    if new_health <= 0 then
        self:GetParent():Kill(nil, params.attacker)
    else
        self:GetParent():SetHealth(new_health)
    end
end

function modifier_bikov_q:GetDisableHealing()
    return 1
end

function modifier_bikov_q:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_bikov_q:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_bikov_q:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_bikov_q:GetAbsoluteNoDamagePure()
    return 1
end


modifier_bikov_q_as_aura = class({})

function modifier_bikov_q_as_aura:IsHidden() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") == 0 end
function modifier_bikov_q_as_aura:IsPurgable() return false end

function modifier_bikov_q_as_aura:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_bikov_q_as_aura:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    return ability:GetSpecialValueFor("bonus_attack_speed") or 0
end

function modifier_bikov_q_as_aura:GetEffectName()
	return "particles/units/heroes/hero_furion/furion_curse_of_forest_debuff_magic.vpcf"
end

function modifier_bikov_q_as_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end