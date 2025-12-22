LinkLuaModifier("modifier_item_suchiy",              "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_aura",         "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_aura_debuff",  "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_blast_slow",   "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_blast_amp",    "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_vision",       "items/suchiy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_suchiy_arctic_bind",  "items/suchiy", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_generic_ring_lua", "modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE)

item_suchiy = class({})

function item_suchiy:GetIntrinsicModifierName()
    return "modifier_item_suchiy"
end

function item_suchiy:OnSpellStart()

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local blast_radius = self:GetSpecialValueFor("blast_radius")
    local blast_speed  = self:GetSpecialValueFor("blast_speed")

    local damage               = self:GetSpecialValueFor("blast_damage")
    local slow_pct             = self:GetSpecialValueFor("blast_movement_speed")
    local slow_dur             = self:GetSpecialValueFor("blast_debuff_duration")
    local amp_dur              = self:GetSpecialValueFor("resist_debuff_duration")
    local illusion_mult_pct    = self:GetSpecialValueFor("illusion_multiplier_pct")
    local vision_range         = self:GetSpecialValueFor("vision_range")
    local travel_time = 0
    if blast_speed and blast_speed > 0 then
        travel_time = blast_radius / blast_speed
    end
    if not IsServer() then return end

    caster:AddNewModifier(caster, self, "modifier_item_suchiy_vision", {
        duration    = travel_time + 1.3,
        expand_time = travel_time - 0.7,
        max_radius  = vision_range,
    })

    local damageTable = {
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
        victim = nil,
    }

    caster:EmitSound("DOTA_Item.ShivasGuard.Activate")

    local blast_pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shivas_guard_ti9_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(blast_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, travel_time * 1.33, blast_speed))
	ParticleManager:ReleaseParticleIndex(blast_pfx)
    local blast_pfx2 = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(blast_pfx2, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(blast_pfx2, 1, Vector(blast_radius, travel_time * 1.33, blast_speed))
	ParticleManager:ReleaseParticleIndex(blast_pfx2)

    local ring = caster:AddNewModifier(
        caster, self, "modifier_generic_ring_lua",
        {
            start_radius = 0,
            end_radius   = blast_radius,
            speed        = blast_speed,
            width        = 50,
            target_team  = DOTA_UNIT_TARGET_TEAM_ENEMY,
            target_type  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            target_flags = DOTA_UNIT_TARGET_FLAG_NONE,
            IsCircle     = 0,
        }
    )

    if not ring or ring:IsNull() or not ring.SetCallback then return end

    ring:SetCallback(function(enemy, wave_radius)
        if not enemy or enemy:IsNull() then return end
        if not enemy:IsAlive() or enemy:IsOutOfGame() or enemy:IsInvulnerable() then return end

        local impact_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControl(impact_pfx, 0, enemy:GetAbsOrigin())
        ParticleManager:SetParticleControl(impact_pfx, 1, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(impact_pfx)
        local impact_pfx_2 = ParticleManager:CreateParticle("particles/econ/events/ti9/shivas_guard_ti9_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControl(impact_pfx_2, 0, enemy:GetAbsOrigin())
        ParticleManager:SetParticleControl(impact_pfx_2, 1, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(impact_pfx_2)
        local final_damage = damage
        if enemy:IsIllusion() and illusion_mult_pct and illusion_mult_pct > 0 then
            final_damage = damage * (illusion_mult_pct / 100)
        end

        damageTable.victim = enemy
        damageTable.damage = final_damage

        local Tmax = self:GetSpecialValueFor("arctic_bind_root_max") or 2.0
        local Tmin = self:GetSpecialValueFor("arctic_bind_root_min") or 1.0
        local Rmax = blast_radius or 0
        if Rmax <= 0 then Rmax = 1 end
        local r_hit = tonumber(wave_radius) or 0
        if r_hit < 0 then r_hit = 0 end
        local t = Tmax - (Tmax - Tmin) * (r_hit / Rmax)
        if t < Tmin then t = Tmin end
        if t > Tmax then t = Tmax end
        t = t * (1 - enemy:GetStatusResistance())

        if t > 0 then
            enemy:AddNewModifier(caster, self, "modifier_item_suchiy_arctic_bind", { duration = t })
        end

        if slow_dur and slow_dur > 0 then
            enemy:AddNewModifier(caster, self, "modifier_item_suchiy_blast_slow", {
                duration = slow_dur * (1 - enemy:GetStatusResistance()), slow_pct = slow_pct,
            })
        end

        if amp_dur and amp_dur > 0 then
            enemy:AddNewModifier(caster, self, "modifier_item_suchiy_blast_amp", {
                duration = amp_dur * (1 - enemy:GetStatusResistance()),
            })
        end

        ApplyDamage(damageTable)
    end)
end

modifier_item_suchiy = class({})

function modifier_item_suchiy:IsHidden() return true end
function modifier_item_suchiy:IsPurgable() return false end
function modifier_item_suchiy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_suchiy:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.bonus_intellect  = self.ability:GetSpecialValueFor("bonus_intellect")
    self.bonus_strength   = self.ability:GetSpecialValueFor("bonus_strength")
    self.bonus_agility    = self.ability:GetSpecialValueFor("bonus_agility")
    self.bonus_hp_regen   = self.ability:GetSpecialValueFor("bonus_hp_regen")
    self.bonus_armor      = self.ability:GetSpecialValueFor("bonus_armor")
    self.spell_amp        = self.ability:GetSpecialValueFor("spell_amp")
    self.bonus_health     = self.ability:GetSpecialValueFor("bonus_health")

    if not IsServer() then return end
    self:_EnsureAuraController()
end

function modifier_item_suchiy:OnDestroy()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    Timers:CreateTimer(0, function()
        if not self.parent or self.parent:IsNull() then return end
        if not self:_HasActiveSuchiyInInventory(self.parent) then
            self.parent:RemoveModifierByName("modifier_item_suchiy_aura")
        end
    end)
end

function modifier_item_suchiy:_HasActiveSuchiyInInventory(unit)
    if not unit or unit:IsNull() then return false end
    for i = 0, 8 do
        local it = unit:GetItemInSlot(i)
        if it and not it:IsNull() and it:GetName() == "item_suchiy" then
            if not it:IsInBackpack() then
                return true
            end
        end
    end
    return false
end

function modifier_item_suchiy:_EnsureAuraController()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    if self.ability:IsInBackpack() then return end

    if self.parent:HasItemInInventory("item_shivas_guard") then
        if self.parent:HasModifier("modifier_item_suchiy_aura") then
            self.parent:RemoveModifierByName("modifier_item_suchiy_aura")
        end
        return
    end

    if not self.parent:HasModifier("modifier_item_suchiy_aura") then
        self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_suchiy_aura", {})
    end
end


function modifier_item_suchiy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
end

function modifier_item_suchiy:_ItemReady()
    if not self.ability or self.ability:IsNull() then return false end
    if self.ability:IsInBackpack() then return false end
    return true
end

function modifier_item_suchiy:GetModifierBonusStats_Intellect() return self:_ItemReady() and (self.bonus_intellect or 0) or 0 end
function modifier_item_suchiy:GetModifierBonusStats_Strength()  return self:_ItemReady() and (self.bonus_strength or 0)  or 0 end
function modifier_item_suchiy:GetModifierBonusStats_Agility()   return self:_ItemReady() and (self.bonus_agility or 0)   or 0 end
function modifier_item_suchiy:GetModifierConstantHealthRegen()  return self:_ItemReady() and (self.bonus_hp_regen or 0)  or 0 end
function modifier_item_suchiy:GetModifierPhysicalArmorBonus()   return self:_ItemReady() and (self.bonus_armor or 0)     or 0 end
function modifier_item_suchiy:GetModifierHealthBonus()          return self:_ItemReady() and (self.bonus_health or 0)    or 0 end


modifier_item_suchiy_aura = class({})

function modifier_item_suchiy_aura:IsHidden() return true end
function modifier_item_suchiy_aura:IsPurgable() return false end
function modifier_item_suchiy_aura:IsAura() return true end
function modifier_item_suchiy_aura:GetModifierAura() return "modifier_item_suchiy_aura_debuff" end
function modifier_item_suchiy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_suchiy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_suchiy_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_suchiy_aura:GetAuraDuration() return 0.5 end

function modifier_item_suchiy_aura:OnCreated()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end
    self.aura_radius = self.ability:GetSpecialValueFor("aura_radius")

    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_item_suchiy_aura:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    if parent:HasItemInInventory("item_shivas_guard") then
        self:Destroy()
        return
    end

    if not self.ability or self.ability:IsNull() or self.ability:IsInBackpack() then
        self:Destroy()
        return
    end
end

function modifier_item_suchiy_aura:GetAuraRadius()
    if not self.ability or self.ability:IsNull() then return 0 end
    if self.ability:IsInBackpack() then return 0 end

    local parent = self:GetParent()
    if parent and not parent:IsNull() and parent:HasItemInInventory("item_shivas_guard") then
        return 0
    end

    return self.aura_radius or 0
end

function modifier_item_suchiy_aura:AuraEntityReject(target)
    if not target or target:IsNull() then return true end
    if target:IsInvulnerable() then return true end
    if target:IsOutOfGame() then return true end
    if target:IsDebuffImmune() then return true end
    return false
end

modifier_item_suchiy_aura_debuff = class({})

function modifier_item_suchiy_aura_debuff:IsHidden() return false end
function modifier_item_suchiy_aura_debuff:IsDebuff() return true end
function modifier_item_suchiy_aura_debuff:IsPurgable() return false end

function modifier_item_suchiy_aura_debuff:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end

    self.aura_attack_speed = self.ability:GetSpecialValueFor("aura_attack_speed")
    self.rest_red = self.ability:GetSpecialValueFor("restoration_reduction_aura")
end

function modifier_item_suchiy_aura_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_item_suchiy_aura_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.aura_attack_speed or 0
end

function modifier_item_suchiy_aura_debuff:GetModifierHealAmplify_PercentageTarget()
    return -(self.rest_red or 0)
end

function modifier_item_suchiy_aura_debuff:GetModifierHPRegenAmplify_Percentage()
    return -(self.rest_red or 0)
end

function modifier_item_suchiy_aura_debuff:GetModifierLifestealRegenAmplify_Percentage()
    return -(self.rest_red or 0)
end

function modifier_item_suchiy_aura_debuff:GetModifierSpellLifestealRegenAmplify_Percentage()
    return -(self.rest_red or 0)
end

modifier_item_suchiy_blast_slow = class({})

function modifier_item_suchiy_blast_slow:IsHidden() return false end
function modifier_item_suchiy_blast_slow:IsDebuff() return true end
function modifier_item_suchiy_blast_slow:IsPurgable() return true end

function modifier_item_suchiy_blast_slow:OnCreated(kv)
    self.slow_pct = 0
    if kv and kv.slow_pct ~= nil then
        self.slow_pct = tonumber(kv.slow_pct) or 0
    else
        local ab = self:GetAbility()
        if ab and not ab:IsNull() then
            self.slow_pct = ab:GetSpecialValueFor("blast_movement_speed")
        end
    end
end

function modifier_item_suchiy_blast_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_item_suchiy_blast_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow_pct or 0
end

modifier_item_suchiy_blast_amp = class({})

function modifier_item_suchiy_blast_amp:IsHidden() return false end
function modifier_item_suchiy_blast_amp:IsDebuff() return true end
function modifier_item_suchiy_blast_amp:IsPurgable() return true end

function modifier_item_suchiy_blast_amp:OnCreated()
    self.ability = self:GetAbility()
    if not self.ability or self.ability:IsNull() then return end
    self.amp = self.ability:GetSpecialValueFor("spell_amp") or 0
end

function modifier_item_suchiy_blast_amp:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
}
end

function modifier_item_suchiy_blast_amp:GetModifierIncomingDamage_Percentage(params)
    if not params then return 0 end
    if params.inflictor == nil then return 0 end
    return self.amp or 0
end

function modifier_item_suchiy_blast_amp:OnTooltip()
    return self.amp or 0
end

modifier_item_suchiy_vision = class({})

function modifier_item_suchiy_vision:IsHidden() return true end
function modifier_item_suchiy_vision:IsPurgable() return false end

function modifier_item_suchiy_vision:OnCreated(kv)
    if not IsServer() then return end

    self.parent = self:GetParent()
    self.team = self.parent:GetTeamNumber()

    self.max_radius  = tonumber(kv.max_radius)  or 800
    self.expand_time = tonumber(kv.expand_time) or 0

    self.locked = false
    self.lock_point = Vector(0,0,0)

    if self.expand_time <= 0 then
        self.locked = true
        self.lock_point = self.parent:GetAbsOrigin()
    end

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_item_suchiy_vision:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent or self.parent:IsNull() then return end

    local elapsed = self:GetElapsedTime()

    if (not self.locked) and (self.expand_time > 0) and (elapsed >= self.expand_time) then
        self.locked = true
        self.lock_point = self.parent:GetAbsOrigin()
    end

    local point
    if self.locked then
        point = self.lock_point
    else
        point = self.parent:GetAbsOrigin()
    end

    local radius
    if self.locked then
        radius = self.max_radius
    else
        radius = self.max_radius * (elapsed / self.expand_time)
        if radius < 1 then radius = 1 end
    end

    AddFOWViewer(self.team, point, radius, 0.15, false)
end

modifier_item_suchiy_arctic_bind = class({})

function modifier_item_suchiy_arctic_bind:IsHidden() return false end
function modifier_item_suchiy_arctic_bind:IsDebuff() return true end
function modifier_item_suchiy_arctic_bind:IsPurgable() return true end

function modifier_item_suchiy_arctic_bind:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end

function modifier_item_suchiy_arctic_bind:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_item_suchiy_arctic_bind:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }
end

function modifier_item_suchiy_arctic_bind:GetModifierInvisibilityLevel()
    return 0
end

function modifier_item_suchiy_arctic_bind:GetEffectName()
    return "particles/events/crownfall/survivors/abilities/crystal_maiden/crystal_maiden_frostbite.vpcf"
end

function modifier_item_suchiy_arctic_bind:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_suchiy_arctic_bind:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("hero_Crystal.frostbite")
end

function modifier_item_suchiy_arctic_bind:OnDestroy()
    if not IsServer() then return end
    if self:GetParent() and not self:GetParent():IsNull() then
        self:GetParent():StopSound("hero_Crystal.frostbite")
    end
end