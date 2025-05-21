zhenya_r = class({})

LinkLuaModifier( "modifier_zhenya_r_caster", "heroes/zhenya/zhenya_r",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_r_target", "heroes/zhenya/zhenya_r",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zhenya_r_start", "heroes/zhenya/zhenya_r",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silence_item", "heroes/zhenya/zhenya_r",LUA_MODIFIER_MOTION_NONE )

function zhenya_r:Precache(context)
    PrecacheResource("particle", "particles/zhenya_r_stack.vpcf", context)
    PrecacheResource("particle", "particles/pudge/pudgerage.vpcf", context)
    PrecacheResource("particle", "particles/zhenya_r_start.vpcf", context)
    PrecacheResource("particle", "particles/zhenya_r_eat.vpcf", context)
    PrecacheResource("soundfile", "soundevents/zhenya_r.vsndevts", context)
end

function zhenya_r:OnSpellStart()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/zhenya_r_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    self:GetCaster():EmitSound("zhenya_r")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_zhenya_r_start", { duration = self:GetSpecialValueFor("start_time") })
end

modifier_zhenya_r_start = class ({})

function modifier_zhenya_r_start:IsPurgable()
    return false
end

function modifier_zhenya_r_start:IsBuff()
    return true
end

function modifier_zhenya_r_start:IsHidden()
    return true
end

function modifier_zhenya_r_start:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_zhenya_r_start:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true
    }
end

function modifier_zhenya_r_start:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_zhenya_r_caster", { duration = self:GetAbility():GetSpecialValueFor("duration")} )
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence_item", { duration = self:GetAbility():GetSpecialValueFor("duration")} )
end

function zhenya_r:DealDamage(caster, target, tick)
    if not IsServer() then return end
    self.base_damage = self:GetSpecialValueFor("base_damage")
    if self:GetCaster():HasTalent("special_bonus_unique_zhenya_6") then
        self.base_damage = self.base_damage + self:GetCaster():GetAverageTrueAttackDamage(nil)
    end
    self.strength_damage = self:GetSpecialValueFor("strength_damage") / 100
    self.strength_damage =  self.strength_damage * caster:GetStrength()
    self.damage = (self.base_damage + self.strength_damage) * tick
    local damageTable = { victim = target, attacker = caster, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self}
    ApplyDamage(damageTable)
    caster:Heal(self.damage, self)
    SendOverheadEventMessage(caster, 10, caster, self.damage, nil)
end

modifier_zhenya_r_caster = class({})

function modifier_zhenya_r_caster:IsHidden()
    return false
end

function modifier_zhenya_r_caster:IsPurgable()
    return false
end

function modifier_zhenya_r_caster:OnCreated()
    if not IsServer() then return end
    self:GetAbility():SetActivated(false)
    self.eat_bool = true
    self.fly = false
    if self:GetAbility():GetSpecialValueFor("fly") == 1 then
        self.fly = true
    end
    self:GetCaster():SetModelScale(self:GetCaster():GetModelScale() + 0.2)
    self.stack_particle = ParticleManager:CreateParticle("particles/zhenya_r_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl( self.stack_particle, 1, Vector(0, 0, 0))
    self:AddParticle( self.stack_particle, false, false, -1, false, false)
    self.victims = 0
end

function modifier_zhenya_r_caster:OnDestroy()
    if not IsServer() then return end
    self.model_scale = 1
    self:GetAbility():SetActivated(true)
    self:GetCaster():SetModelScale(self.model_scale)
    self:GetCaster():SetRenderColor(255, 255, 255)
    local caster_pos = self:GetCaster():GetAbsOrigin()
    self.victims = nil
    EmitSoundOn("zhenya_r_end", self:GetCaster())
    ParticleManager:DestroyParticle(self.stack_particle, true)
end

function modifier_zhenya_r_caster:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_zhenya_r_caster:CheckState()
    return {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = self.fly,
    }
end

function modifier_zhenya_r_caster:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_zhenya_r_caster:GetActivityTranslationModifiers()
    return "haste"
end

function modifier_zhenya_r_caster:OnAttackStart( params )
    if not IsServer() then return end
    if params.target == nil then return end
    if params.attacker ~= self:GetParent() then return end
    if params.attacker:IsIllusion() then return end
    if params.target:IsWard() then return end
    if params.target:HasModifier("modifier_zhenya_r_caster") then return end
    if params.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    if not params.target:IsHero() then return end
    
    self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
    local duration = self:GetRemainingTime()
    self:GetCaster():SetModelScale(self:GetCaster():GetModelScale() + 0.2)
    local particle = ParticleManager:CreateParticle("particles/zhenya_r_eat.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())
    ParticleManager:SetParticleControl( particle, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
    ParticleManager:ReleaseParticleIndex(particle)
    params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_zhenya_r_target", { duration = duration } )

    self:ChecKTargets(1)
    self:GetCaster():Stop()
end

function modifier_zhenya_r_caster:ChecKTargets(new)
    if self.stack_particle then
        ParticleManager:DestroyParticle(self.stack_particle, true)
    end
    self.stack_particle = ParticleManager:CreateParticle("particles/zhenya_r_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())            
    self.victims = self.victims + new
    self:GetCaster():SetModifierStackCount("modifier_zhenya_r_caster", self:GetAbility(), self.victims)
    ParticleManager:SetParticleControl( self.stack_particle, 1, Vector(0, self.victims, 0))
    self:AddParticle( self.stack_particle, false, false, -1, false, true )
end

modifier_silence_item = class({})

function modifier_silence_item:CheckState()
    if self:GetParent():HasShard() then return end
    local state =
    {
        [MODIFIER_STATE_MUTED] = true
    }
    return state
end

function modifier_silence_item:OnCreated()
    if not IsServer() then return end
    if self:GetParent():HasShard() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_silence_item:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_teleporting") then
        self:GetParent():Stop()
    end
end

function modifier_silence_item:IsPurgable()
    return false
end

function modifier_silence_item:IsHidden()
    return true
end

modifier_zhenya_r_target = class({})

function modifier_zhenya_r_target:IsPurgable()
    return false
end

function modifier_zhenya_r_target:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():AddEffects( EF_NODRAW )
    self:GetParent():AddNoDraw()
    self.particle = ParticleManager:CreateParticleForPlayer("particles/pudge/pudgerage.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
    self:AddParticle( self.particle, false, false, -1, false, true )

    local tick = 6
    self.max = tick
    self.count = 0
    self.standard_tick_interval = self:GetDuration() / tick
    self.tick_interval = 0 

    self:StartIntervalThink(FrameTime())      
end

function modifier_zhenya_r_target:OnIntervalThink()
    if not IsServer() then return end
    if self:GetCaster():IsNull() then self:Destroy() return end
    if not self:GetCaster():IsAlive() then self:Destroy() return end
    self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
    if self.count >= self.max then return end
    self.tick_interval = self.tick_interval + FrameTime()
    if self.tick_interval >= self.standard_tick_interval then
        self.tick_interval = 0
        self.count = self.count + 1
        self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.standard_tick_interval)
    end
end

function modifier_zhenya_r_target:OnDestroy( kv )
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), true)
    self:GetParent():RemoveEffects( EF_NODRAW )
    self:GetParent():RemoveNoDraw()
    local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    local bump_point = self:GetCaster():GetAbsOrigin() - direction * distance
    local knockbackProperties =
    {
        center_x = bump_point.x,
        center_y = bump_point.y,
        center_z = bump_point.z,
        duration = 0.5,
        knockback_duration = 0.5,
        knockback_distance = 400,
        knockback_height = 350
    }
    self:GetParent():RemoveModifierByName("modifier_knockback")
    self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    local modifier_zhenya_r_caster = self:GetCaster():FindModifierByName("modifier_zhenya_r_caster")
    if modifier_zhenya_r_caster then
        modifier_zhenya_r_caster:ChecKTargets(-1)
    end
end

function modifier_zhenya_r_target:CheckState()
    local state = 
    {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true, 
    }
    return state
end

function modifier_zhenya_r_target:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_zhenya_r_target:GetModifierAvoidDamage(params)
    if params.attacker ~= self:GetCaster() then
        return 1
    end
    return 0
end