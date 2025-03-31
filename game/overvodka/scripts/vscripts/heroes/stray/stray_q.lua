LinkLuaModifier("modifier_stray_q_asu", "heroes/stray/stray_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stray_q_nemec", "heroes/stray/stray_q", LUA_MODIFIER_MOTION_NONE)

stray_q = class({})

function stray_q:Precache(context)
    PrecacheResource("particle", "particles/econ/items/naga/naga_ti8_immortal_tail/naga_ti8_immortal_riptide.vpcf", context)
    PrecacheResource("particle", "particles/stray_q_2.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_ambient_v2.vpcf", context)
    PrecacheResource("particle", "particles/stray_q_3.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_cast_crimson.vpcf", context)
    PrecacheResource("soundfile", "soundevents/stray_q_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_q_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_q_3.vsndevts", context)
end

function stray_q:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stray_q:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    gold = self:GetSpecialValueFor("gold_per_donate")
    if gold > 0 then
        self:GetCaster():ModifyGold(gold, false, 0)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self:GetCaster(), gold, nil)
    end
    local random_chance = RandomInt(1,3)
    if random_chance == 1 then
        local image_count = self:GetSpecialValueFor("illusion_count")
        local image_out_dmg = self:GetSpecialValueFor("outgoing_damage")
        local incoming_damage = self:GetSpecialValueFor("incoming_damage")

        local vRandomSpawnPos = {
            Vector(108, 0, 0),
            Vector(108, 108, 0),
            Vector(108, 0, 0),
            Vector(0, 108, 0),
            Vector(-108, 0, 0),
            Vector(-108, 108, 0),
            Vector(-108, -108, 0),
            Vector(0, -108, 0),
        }

        for i = 1, image_count do
            local illusions = CreateIllusions(
                self:GetCaster(),
                self:GetCaster(),
                {
                    outgoing_damage = image_out_dmg,
                    incoming_damage = incoming_damage,
                    duration = duration,
                },
                1,
                108,
                false,
                true
            )
            for k, illusion in pairs(illusions) do
                local pos = self:GetCaster():GetAbsOrigin() + vRandomSpawnPos[i]
                FindClearSpaceForUnit(illusion, pos, true)
                local particle_2 = ParticleManager:CreateParticle("particles/econ/items/naga/naga_ti8_immortal_tail/naga_ti8_immortal_riptide.vpcf", PATTACH_ABSORIGIN, illusion)
                ParticleManager:ReleaseParticleIndex(particle_2)
            end
        end
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = duration})
        self:GetCaster():Stop()
        self:GetCaster():EmitSound("stray_q_1")
    elseif random_chance == 2 then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_q_asu", {duration = duration})
        self:GetCaster():EmitSound("stray_q_2")
        local effect_cast = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_2022_immortal/centaur_2022_immortal_stampede_cast_crimson.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( effect_cast )
    elseif random_chance == 3 then
        local modifier_stray_q_nemec = self:GetCaster():FindModifierByName("modifier_stray_q_nemec")
        if modifier_stray_q_nemec then
            modifier_stray_q_nemec:Destroy()
        end
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_q_nemec", {duration = duration})
        self:GetCaster():EmitSound("stray_q_3")
    end
end

modifier_stray_q_asu = class({})

function modifier_stray_q_asu:IsPurgable() return true end
function modifier_stray_q_asu:IsHidden() return false end

function modifier_stray_q_asu:OnCreated()
    if not IsServer() then return end
end

function modifier_stray_q_asu:DeclareFunctions()
    return 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_EVASION_CONSTANT 
    }
end

function modifier_stray_q_asu:OnAttackLanded( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsWard() then return end
    local duration = self:GetAbility():GetSpecialValueFor("bashduration")
    local chance = self:GetAbility():GetSpecialValueFor("bashchance")
    if RollPercentage(chance) then 
        params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_generic_stunned_lua", {duration = duration})
        local effect_cast = ParticleManager:CreateParticle("particles/stray_q_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
            ParticleManager:SetParticleControlEnt(
                effect_cast,
                1,
                params.target,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                Vector(0,0,0),
                true
            )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

function modifier_stray_q_asu:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor( "evasion" )
end

function modifier_stray_q_asu:OnDestroy()
    if not IsServer() then return end
end

function modifier_stray_q_asu:GetEffectName()
    return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_ambient_v2.vpcf"
end

function modifier_stray_q_asu:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_stray_q_nemec = class({})

function modifier_stray_q_nemec:IsPurgable() return true end

function modifier_stray_q_nemec:OnCreated()
    self.effect_cast = ParticleManager:CreateParticle(
        "particles/stray_q_3.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent())
    ParticleManager:SetParticleControlEnt(
        self.effect_cast,
        0,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_origin",
        self:GetParent():GetAbsOrigin(),
        true
    )
    ParticleManager:SetParticleControlEnt(
        self.effect_cast,
        1,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_origin",
        self:GetParent():GetAbsOrigin(),
        true
    )
	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		true
	)
    self.shield_from_hp = self:GetAbility():GetSpecialValueFor("shield_from_hp")
    self.max_shield  = self:GetParent():GetHealth() / 100 * self.shield_from_hp
    if not IsServer() then return end
    self:SetStackCount(self.max_shield)
end

function modifier_stray_q_nemec:OnRefresh()
    self.shield_from_hp = self:GetAbility():GetSpecialValueFor("shield_from_hp")
    self.max_shield  = self:GetParent():GetHealth() / 100 * self.shield_from_hp
    if not IsServer() then return end
    self:SetStackCount(self.max_shield)
end

function modifier_stray_q_nemec:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_stray_q_nemec:GetModifierIncomingDamageConstant( params )
    if IsClient() then 
        if params.report_max then 
            return self.max_shield 
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

function modifier_stray_q_nemec:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hpregen")
end