LinkLuaModifier("modifier_item_byebye_boots", "items/item_byebye_boots", LUA_MODIFIER_MOTION_NONE)

item_byebye_boots = class({})


function item_byebye_boots:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    EmitSoundOnLocationWithCaster( self.point, "byebye_start", caster )
    AddFOWViewer(caster:GetTeamNumber(), self.point, 300, 3, false)
    ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
    local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self.point)
    local particle_1 = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_blink_warmup.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_1, 0, self.point)
end

function item_byebye_boots:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not bInterrupted then
        ProjectileManager:ProjectileDodge(caster)
        ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
        caster:SetAbsOrigin(self.point)
        FindClearSpaceForUnit(caster, self.point, false)
        local particle = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, self.point)
        local particle_1 = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_blink_arrival.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_1, 0, self.point)
        EmitSoundOn("byebye", caster)
    end
end

function item_byebye_boots:GetIntrinsicModifierName()
    return "modifier_item_byebye_boots"
end

function item_byebye_boots:GetAbilityTextureName()
    return "byebye_boots"
end

modifier_item_byebye_boots = class({})

function modifier_item_byebye_boots:IsHidden() return true end
function modifier_item_byebye_boots:IsPurgable() return false end
function modifier_item_byebye_boots:IsPurgeException() return false end
function modifier_item_byebye_boots:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_byebye_boots:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
    }
end

function modifier_item_byebye_boots:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end