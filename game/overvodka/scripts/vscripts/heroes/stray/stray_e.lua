LinkLuaModifier("modifier_stray_e", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_damage_buff", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_damage_debuff", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_damage_buff_stack", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_damage_debuff_stack", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_stray_e_attack_speed_buff", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_attack_speed_debuff", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_attack_speed_buff_stack", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_e_attack_speed_debuff_stack", "heroes/stray/stray_e", LUA_MODIFIER_MOTION_NONE)

stray_e = class({})

function stray_e:Precache(context)
    PrecacheResource("particle", "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf", context)
end

function stray_e:GetIntrinsicModifierName()
    return "modifier_stray_e"
end

modifier_stray_e = class ({})

function modifier_stray_e:IsHidden()
    return true
end

function modifier_stray_e:IsPurgable()
    return false
end

function modifier_stray_e:DeclareFunctions()
    local declfuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return declfuncs
end

function modifier_stray_e:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() and not params.attacker:HasModifier("modifier_stray_scepter") then return end
    if params.attacker:PassivesDisabled() then return end
    if params.target:IsWard() then return end

    local duration = self:GetAbility():GetSpecialValueFor("duration")

    local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target )
    ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_damage_buff_stack", { duration = duration } )
    self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_damage_buff", { duration = duration } )
    if self:GetParent():IsIllusion() then
        local original_hero = self:GetParent():GetOwner()
        if original_hero then
            original_hero:AddNewModifier( original_hero, self:GetAbility(), "modifier_stray_e_damage_buff_stack", { duration = duration } )
            original_hero:AddNewModifier( original_hero, self:GetAbility(), "modifier_stray_e_damage_buff", { duration = duration } )
        end
    end
    params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_damage_debuff_stack", { duration = duration * (1-params.target:GetStatusResistance()) } )
    params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_damage_debuff", { duration = duration * (1-params.target:GetStatusResistance()) } )

    if self:GetAbility():GetSpecialValueFor("as_steal") > 0 then
        self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_attack_speed_buff_stack", { duration = duration } )
        self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_attack_speed_buff", { duration = duration } )
        if self:GetParent():IsIllusion() then
            local original_hero = self:GetParent():GetOwner()
            if original_hero then
                original_hero:AddNewModifier( original_hero, self:GetAbility(), "modifier_stray_e_attack_speed_buff_stack", { duration = duration } )
                original_hero:AddNewModifier( original_hero, self:GetAbility(), "modifier_stray_e_attack_speed_buff", { duration = duration } )
            end
        end
        params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_attack_speed_debuff_stack", { duration = duration * (1-params.target:GetStatusResistance()) } )
        params.target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_stray_e_attack_speed_debuff", { duration = duration * (1-params.target:GetStatusResistance()) } )
    end
end

modifier_stray_e_damage_buff = class({})

function modifier_stray_e_damage_buff:IsPurgable() return false end
function modifier_stray_e_damage_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_stray_e_damage_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_stray_e_damage_buff:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_stray_e_damage_buff_stack")
    local damage_steal = ability:GetSpecialValueFor("damage_steal")
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_stray_e_damage_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_stray_e_damage_buff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

modifier_stray_e_damage_debuff = class({})

function modifier_stray_e_damage_debuff:IsPurgable() return false end
function modifier_stray_e_damage_debuff:IsHidden() return self:GetStackCount() == 0 end

function modifier_stray_e_damage_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_stray_e_damage_debuff:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if not ability then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_stray_e_damage_debuff_stack")
    local damage_steal = self:GetAbility():GetSpecialValueFor("damage_steal")
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_stray_e_damage_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_stray_e_damage_debuff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * -1
end

modifier_stray_e_damage_buff_stack = class({})

function modifier_stray_e_damage_buff_stack:IsHidden()
    return true
end
function modifier_stray_e_damage_buff_stack:IsPurgable() return false end

function modifier_stray_e_damage_buff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_stray_e_damage_debuff_stack = class({})

function modifier_stray_e_damage_debuff_stack:IsHidden()
    return true
end

function modifier_stray_e_damage_debuff_stack:IsPurgable() return false end

function modifier_stray_e_damage_debuff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_stray_e_attack_speed_buff = class({})

function modifier_stray_e_attack_speed_buff:IsPurgable() return false end
function modifier_stray_e_attack_speed_buff:IsHidden() return self:GetStackCount() == 0 end

function modifier_stray_e_attack_speed_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_stray_e_attack_speed_buff:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_stray_e_attack_speed_buff_stack")
    local damage_steal = self:GetAbility():GetSpecialValueFor("as_steal")
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_stray_e_attack_speed_buff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_stray_e_attack_speed_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end

modifier_stray_e_attack_speed_debuff = class({})

function modifier_stray_e_attack_speed_debuff:IsPurgable() return false end
function modifier_stray_e_attack_speed_debuff:IsHidden() return self:GetStackCount() == 0 end

function modifier_stray_e_attack_speed_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end

function modifier_stray_e_attack_speed_debuff:OnIntervalThink()
    if not IsServer() then return end
    local modifier = self:GetParent():FindAllModifiersByName("modifier_stray_e_attack_speed_debuff_stack")
    local damage_steal = self:GetAbility():GetSpecialValueFor("as_steal")
    self:SetStackCount(#modifier * damage_steal)
end

function modifier_stray_e_attack_speed_debuff:DeclareFunctions()
    return 
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_stray_e_attack_speed_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * -1
end

modifier_stray_e_attack_speed_buff_stack = class({})

function modifier_stray_e_attack_speed_buff_stack:IsHidden()
    return true
end
function modifier_stray_e_attack_speed_buff_stack:IsPurgable() return false end

function modifier_stray_e_attack_speed_buff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_stray_e_attack_speed_debuff_stack = class({})

function modifier_stray_e_attack_speed_debuff_stack:IsHidden()
    return true
end

function modifier_stray_e_attack_speed_debuff_stack:IsPurgable() return false end

function modifier_stray_e_attack_speed_debuff_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
