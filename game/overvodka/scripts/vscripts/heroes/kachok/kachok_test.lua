LinkLuaModifier( "modifier_kachok_test", "heroes/kachok/kachok_test", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kachok_test_damage", "heroes/kachok/kachok_test", LUA_MODIFIER_MOTION_NONE )

kachok_test = class({})

function kachok_test:Precache(context)
    PrecacheResource("particle", "particles/duel/legion_duel_ring_arcana.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
end

function kachok_test:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function kachok_test:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function kachok_test:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function kachok_test:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local target_origin = target:GetAbsOrigin()
    local caster_origin = self:GetCaster():GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())
    if target:TriggerSpellAbsorb( self ) then return end
    if target:IsIllusion() then
        target:Kill( self, self:GetCaster() )
        return
    end
    self:GetCaster():EmitSound("kachok_duel")
    if self:GetCaster().particle_duel then
        ParticleManager:DestroyParticle(self:GetCaster().particle_duel, false)
    end
    self:GetCaster().particle_duel = ParticleManager:CreateParticle("particles/duel/legion_duel_ring_arcana.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    local center_point = (target_origin + caster_origin) * 0.5
    ParticleManager:SetParticleControl(self:GetCaster().particle_duel, 0, center_point - Vector(75,0,0))
    ParticleManager:SetParticleControl(self:GetCaster().particle_duel, 7, center_point - Vector(75,0,0))

    target:AddNewModifier( self:GetCaster(), self, "modifier_kachok_test", { duration = duration, target = self:GetCaster():entindex() } )
    self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_kachok_test", { duration = duration, target = target:entindex() } )
end


modifier_kachok_test = class({})

function modifier_kachok_test:IsPurgable()
    return false
end

function modifier_kachok_test:OnCreated(params)
    if IsServer() then
        self.target = EntIndexToHScript(params.target)
        self:GetParent():SetForceAttackTarget(self.target)
        self:GetParent():MoveToTargetToAttack(self.target)
        self:StartIntervalThink(0.1)
    end
end

function modifier_kachok_test:OnIntervalThink()
    if IsServer() then
        self:GetParent():SetForceAttackTarget(self.target)
        self:GetParent():MoveToTargetToAttack(self.target)
    end
end

function modifier_kachok_test:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_kachok_test:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():StopSound("kachok_duel")   
    if self:GetCaster().particle_duel ~= nil then
        ParticleManager:DestroyParticle(self:GetCaster().particle_duel, false)
    end
    self:GetParent():SetForceAttackTarget(nil)
end

function modifier_kachok_test:CheckState()
local state =
    {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_TAUNTED] = true,
    }
    return state
end

function modifier_kachok_test:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_DEATH,
    }

    return decFuncs
end

function modifier_kachok_test:OnDeath( params )
    local damage = self:GetAbility():GetSpecialValueFor("reward_damage")
    if params.unit == self:GetParent() then
        if params.unit == self:GetCaster() then
            if not self.target:HasModifier("modifier_kachok_test_damage") then
                self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kachok_test_damage", {} )
            end
            local duel_stacks = self.target:GetModifierStackCount("modifier_kachok_test_damage", self:GetAbility()) + damage
            self.target:SetModifierStackCount("modifier_kachok_test_damage", self:GetAbility(), duel_stacks)
            self.target:RemoveModifierByName("modifier_kachok_test")
            self.target:EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
        else
            if not self:GetCaster():HasModifier("modifier_kachok_test_damage") then
                self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kachok_test_damage", {} )
            end
            local duel_stacks = self:GetCaster():GetModifierStackCount("modifier_kachok_test_damage", self:GetAbility()) + damage
            self:GetCaster():SetModifierStackCount("modifier_kachok_test_damage", self:GetAbility(), duel_stacks)
            self:GetCaster():RemoveModifierByName("modifier_kachok_test")
            self:GetCaster():EmitSound("Hero_LegionCommander.Duel.Victory")
            local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
        end
    end
end

modifier_kachok_test_damage = class({})

function modifier_kachok_test_damage:IsPurgable()
    return false
end

function modifier_kachok_test_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_kachok_test_damage:IsDebuff()
    return false
end

function modifier_kachok_test_damage:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

    }

    return decFuncs
end

function modifier_kachok_test_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end