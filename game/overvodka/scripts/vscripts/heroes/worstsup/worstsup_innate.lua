LinkLuaModifier("modifier_worstsup_innate", "heroes/worstsup/worstsup_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_worstsup_innate_aura", "heroes/worstsup/worstsup_innate", LUA_MODIFIER_MOTION_NONE)

worstsup_innate = class({})

function worstsup_innate:GetIntrinsicModifierName()
    return "modifier_worstsup_innate"
end

modifier_worstsup_innate = class({})

function modifier_worstsup_innate:IsHidden() return true end
function modifier_worstsup_innate:IsPurgable() return false end
function modifier_worstsup_innate:RemoveOnDeath() return false end

function modifier_worstsup_innate:IsAura()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return false end
    if parent:PassivesDisabled() then return false end
    if not parent:IsRealHero() or parent:IsIllusion() then return false end

    return true
end

function modifier_worstsup_innate:GetModifierAura() return "modifier_worstsup_innate_aura" end
function modifier_worstsup_innate:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_worstsup_innate:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_worstsup_innate:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_worstsup_innate:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_worstsup_innate:GetAuraEntityReject(target)
    if not target or target:IsNull() then return true end
    if not target:IsRealHero() or target:IsIllusion() then return true end

    return false
end

modifier_worstsup_innate_aura = class({})

function modifier_worstsup_innate_aura:IsHidden() return true end
function modifier_worstsup_innate_aura:IsPurgable() return false end

function modifier_worstsup_innate_aura:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_worstsup_innate_aura:OnAbilityExecuted(params)
    if not IsServer() then return end

    local enemy = self:GetParent()
    local rubick = self:GetCaster()
    local ability = self:GetAbility()
    local used_ability = params.ability

    if not enemy or enemy:IsNull() then return end
    if not rubick or rubick:IsNull() or not rubick:IsRealHero() or rubick:IsIllusion() then return end
    if rubick:PassivesDisabled() then return end
    if not ability or ability:IsNull() then return end
    if not used_ability or used_ability:IsNull() or used_ability:IsItem() then return end
    if used_ability:GetCaster() ~= enemy then return end
    if used_ability:IsToggle() or used_ability:ProcsMagicStick() == false then return 0 end

    local cd_reduction = ability:GetSpecialValueFor("cd_reduction")
    if cd_reduction <= 0 then return end
    
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_death_cdr.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
    ParticleManager:SetParticleControl(p, 0, enemy:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(p, 1, rubick, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)

    for slot = 0, 23 do
        local own_ability = rubick:GetAbilityByIndex(slot)
        if own_ability and not own_ability:IsNull() then
            local ability_name = own_ability:GetAbilityName()
            if ability_name ~= "worstsup_q" and ability_name ~= "worstsup_q_dota" then
                local remaining_cooldown = own_ability:GetCooldownTimeRemaining()
                if remaining_cooldown > 0 then
                    local new_cooldown = math.max(remaining_cooldown - cd_reduction, 0)
                    own_ability:EndCooldown()
                    if new_cooldown > 0 then
                        own_ability:StartCooldown(new_cooldown)
                    end
                end
            end
        end
    end
end
