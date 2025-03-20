item_byebye = class({})

function item_byebye:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    EmitSoundOn("byebye_start", caster)
    ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
end

function item_byebye:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    local caster = self:GetCaster()
    StopSoundOn("byebye_start", caster)
    if not bInterrupted then
        ProjectileManager:ProjectileDodge(caster)
        ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
        EmitSoundOn("byebye", caster)
        
        local target_point = caster:GetAbsOrigin()
        local fountainEntities = Entities:FindAllByClassname("ent_dota_fountain")
        for _, fountainEnt in pairs(fountainEntities) do
            if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
                target_point = fountainEnt:GetAbsOrigin()
                break
            end
        end
        caster:SetAbsOrigin(target_point)
        FindClearSpaceForUnit(caster, target_point, false)
        ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
    end
    self:SpendCharge(1)
end

function item_byebye:GetAbilityTextureName()
    return "byebye"
end