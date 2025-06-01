LinkLuaModifier( "modifier_nix_semya_debuff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nix_semya_steal_debuff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_nix_semya_steal_buff", "heroes/nix/nix_semya", LUA_MODIFIER_MOTION_NONE)

nix_semya = class({}) 

function nix_semya:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function nix_semya:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function nix_semya:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function nix_semya:Precache(context)
	PrecacheResource("particle", "particles/nix_w.vpcf", context)
	PrecacheResource("soundfile", "soundevents/semya.vsndevts", context)
end

function nix_semya:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("semya")
    self.modifier = target:AddNewModifier( self:GetCaster(), self, "modifier_nix_semya_debuff", { duration = duration } )
end

modifier_nix_semya_debuff = class({})

function modifier_nix_semya_debuff:IsPurgable() return false end

function modifier_nix_semya_debuff:OnCreated()
    if not IsServer() then return end
    local interval = 1
    self:StartIntervalThink( interval )
	self:OnIntervalThink()
    local particle = ParticleManager:CreateParticle( "particles/nix_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    self:AddParticle( particle, false, false, -1, false, false )
end

function modifier_nix_semya_debuff:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("semya")
end

function modifier_nix_semya_debuff:OnIntervalThink()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("duration")
    local radius = self:GetAbility():GetSpecialValueFor("break_distance")

    local current_stack_buff = self:GetCaster():GetModifierStackCount( "modifier_nix_semya_steal_buff", self:GetCaster() )
    local current_stack_debuff = self:GetParent():GetModifierStackCount( "modifier_nix_semya_steal_debuff", self:GetCaster() )
    local damage = self:GetAbility():GetSpecialValueFor("dps")

    if self:GetParent():IsInvulnerable() or self:GetParent():IsIllusion() or ( not self:GetCaster():IsAlive()) then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end

    if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>radius then
        if not self:IsNull() then
            self:Destroy()
        end
        return
    end
	if damage > 0 then
		ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
	end
    if not self:GetParent():IsDebuffImmune() then
        if self:GetCaster():HasModifier("modifier_nix_semya_steal_buff") then
            local mod = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_buff", { duration = duration } )
            if mod then
                mod:AddStack(1)
            end
        else
            local mod = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_buff", { duration = duration } )
            if mod then
                mod:AddStack(1)
            end
        end
        
        if self:GetParent():HasModifier("modifier_nix_semya_steal_debuff") then
            local mod = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_debuff", { duration = duration } )
            if mod then
                mod:AddStack(1)
            end
        else
            local mod = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_nix_semya_steal_debuff", { duration = duration } )
            if mod then
                mod:AddStack(1)
            end
        end
    end
end

modifier_nix_semya_steal_buff = class ({})

function modifier_nix_semya_steal_buff:IsPurgable() return false end

function modifier_nix_semya_steal_buff:OnCreated()
    if not IsServer() then return end
    self.stack = 0
end

function modifier_nix_semya_steal_buff:AddStack(stack)
    if not IsServer() then return end
    self.stack = self.stack + stack
    self:SetStackCount(self.stack)
end

function modifier_nix_semya_steal_buff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return declfuncs
end

function modifier_nix_semya_steal_buff:GetModifierMagicalResistanceBonus()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magresist")
end

function modifier_nix_semya_steal_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_steal")
end

function modifier_nix_semya_steal_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms")
end

modifier_nix_semya_steal_debuff = class ({})

function modifier_nix_semya_steal_debuff:OnCreated()
    if not IsServer() then return end
    self.stack = 0
end

function modifier_nix_semya_steal_debuff:AddStack(stack)
    if not IsServer() then return end
    self.stack = self.stack + stack
    self:SetStackCount(self.stack)
end

function modifier_nix_semya_steal_debuff:IsPurgable() return false end

function modifier_nix_semya_steal_debuff:DeclareFunctions()
    local declfuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return declfuncs
end

function modifier_nix_semya_steal_debuff:GetModifierMagicalResistanceBonus()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magresist") * -1
end

function modifier_nix_semya_steal_debuff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_steal") * -1
end

function modifier_nix_semya_steal_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms") * -1
end