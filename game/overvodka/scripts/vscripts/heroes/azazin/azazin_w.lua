LinkLuaModifier( "modifier_azazin_w", "heroes/azazin/azazin_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azazin_w_target", "heroes/azazin/azazin_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azazin_w_root", "heroes/azazin/azazin_w", LUA_MODIFIER_MOTION_NONE )

azazin_w = class({})

function azazin_w:Precache(context)
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", context)
    PrecacheResource("particle", "particles/azazin_w_radius.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_death.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/hoodwink/hoodwink_2022_taunt/hoodwink_2022_taunt_blossom_music_notes.vpcf", context)
    PrecacheResource("particle", "particles/azazin_w_root.vpcf", context)
    PrecacheResource("soundfile", "soundevents/azazin_w.vsndevts", context)
end

function azazin_w:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function azazin_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local point = self:GetCursorPosition()
    local taunt = CreateUnitByName("npc_dota_azazin_clone", point, false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    taunt:SetControllableByPlayer(playerID, true)
    taunt:SetOwner(caster)
    taunt:AddNewModifier( self:GetCaster(), self, "modifier_azazin_w", {} )
    taunt:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})

    local particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, taunt)
    ParticleManager:SetParticleControl(particle, 0, taunt:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    if not global_sounds_muted then
        taunt:EmitSound("azazin_w")
    end
    local radius = self:GetSpecialValueFor("radius")
    local root_duration = self:GetSpecialValueFor( "root_duration" )
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _,unit in pairs(targets) do
        unit:AddNewModifier( caster, self, "modifier_azazin_w_root", { duration = root_duration * (1 - unit:GetStatusResistance()) } )
    end
end

modifier_azazin_w = class({})

function modifier_azazin_w:IsHidden() return true end
function modifier_azazin_w:IsPurgable() return false end

function modifier_azazin_w:OnCreated()
    if not IsServer() then return end
    self.time = 0
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_azazin_w:CheckState()
    return 
    {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_azazin_w:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,        
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
    }
end

function modifier_azazin_w:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_azazin_w:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_azazin_w:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_azazin_w:GetDisableHealing()
    return 1
end

function modifier_azazin_w:OnIntervalThink()
    if not IsServer() then return end
    self.time = self.time + 0.5
    if self.time == 1.0 then
        self:GetParent():StartGesture(ACT_DOTA_TAUNT)
    end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    local caster_particle = ParticleManager:CreateParticle( "particles/azazin_w_radius.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(caster_particle)
    local targets = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    local damage_table = {
        attacker = self:GetCaster(),
        damage = ability:GetSpecialValueFor("damage") * 0.5,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
    }
    local target_kv = {duration = 1}
    for _,unit in pairs(targets) do
        unit:AddNewModifier(parent, ability, "modifier_azazin_w_target", target_kv)
        damage_table.victim = unit
        ApplyDamage(damage_table)
    end
end

function modifier_azazin_w:OnDestroy()
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    self.tauntdeath = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.tauntdeath, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.tauntdeath, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(self.tauntdeath)
end

function modifier_azazin_w:GetEffectName()
    return "particles/econ/items/hoodwink/hoodwink_2022_taunt/hoodwink_2022_taunt_blossom_music_notes.vpcf"
end

function modifier_azazin_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_azazin_w_target = class({})

function modifier_azazin_w_target:IsHidden() return true end
function modifier_azazin_w_target:IsPurgable() return false end

function modifier_azazin_w_target:OnCreated()
    self.heal_reduction = self:GetAbility():GetSpecialValueFor("heal_reduction")
    self.talent = self:GetAbility():GetSpecialValueFor("disarm") == 1
    self:StartIntervalThink(FrameTime())
end

function modifier_azazin_w_target:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetParent():IsDebuffImmune() or self:GetParent():IsMagicImmune() then return end
    local parent = self:GetParent()
    for i = 0, 5 do
        for j = 0, 5 do
            parent:SwapItems(i, j)
        end
    end
    --for i = 0, parent:GetAbilityCount() - 1 do
    --    local ability = parent:GetAbilityByIndex(i)
     --   if ability and not ability:IsCooldownReady() then
     --       local current_cooldown = ability:GetCooldownTimeRemaining()
     --       ability:EndCooldown()
     --       ability:StartCooldown(current_cooldown + FrameTime())
     --   end
    --end
end

function modifier_azazin_w_target:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_azazin_w_target:GetModifierHealAmplify_PercentageTarget()
    return -self.heal_reduction
end

function modifier_azazin_w_target:GetModifierHPRegenAmplify_Percentage()
    return -self.heal_reduction
end

function modifier_azazin_w_target:GetModifierLifestealRegenAmplify_Percentage()
    return -self.heal_reduction
end

function modifier_azazin_w_target:GetModifierSpellLifestealRegenAmplify_Percentage()
    return -self.heal_reduction
end

function modifier_azazin_w_target:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = self.talent
    }
end

modifier_azazin_w_root = class({})

function modifier_azazin_w_root:IsHidden() return false end
function modifier_azazin_w_root:IsPurgable() return true end

function modifier_azazin_w_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_azazin_w_root:GetEffectName()
    return "particles/azazin_w_root.vpcf"
end

function modifier_azazin_w_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end