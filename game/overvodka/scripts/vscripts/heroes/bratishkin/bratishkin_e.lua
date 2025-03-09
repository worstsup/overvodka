LinkLuaModifier( "modifier_bratishkin_e_primary", "heroes/bratishkin/bratishkin_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bratishkin_e_primary_scepter", "heroes/bratishkin/bratishkin_e", LUA_MODIFIER_MOTION_NONE )

bratishkin_e = class({})

function bratishkin_e:Precache(context)
    PrecacheResource("particle", "particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_cast.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_end.vpcf", context)
    PrecacheResource("particle", "particles/bratishkin_e.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_riki.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/bratishkin_e.vsndevts", context)
    PrecacheResource("model", "models/bratishkin/box/cardboardbox_lp.vmdl", context)
end
    
function bratishkin_e:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function bratishkin_e:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function bratishkin_e:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function bratishkin_e:GetChannelTime()
    if self:GetCaster():HasScepter() then
        return 0
    else
        return self:GetSpecialValueFor("channel_duration")
    end
end

function bratishkin_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("channel_duration")
    if caster:HasScepter() then
        caster:AddNewModifier(caster, self, "modifier_bratishkin_e_primary_scepter", {duration = duration})
    else
        caster:AddNewModifier(caster, self, "modifier_bratishkin_e_primary", {duration = duration})
    end
    EmitSoundOnLocationWithCaster(origin, "bratishkin_e", caster)
end

function bratishkin_e:OnChannelFinish(interrupted)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster:HasScepter() then
        caster:RemoveModifierByName("modifier_bratishkin_e_primary")
    end
end

modifier_bratishkin_e_primary = class({})

function modifier_bratishkin_e_primary:OnCreated()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_bratishkin_q_knight") then
        self:GetCaster().weapon:RemoveSelf()
    end
    self.origin = self:GetCaster():GetAbsOrigin()
    self:GetParent():EmitSound("Hero_Riki.TricksOfTheTrade")
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local cast_particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_cast.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(cast_particle, 0, self:GetParent():GetAbsOrigin())

    local particle = ParticleManager:CreateParticle("particles/bratishkin_e.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, 0, radius))
    self:AddParticle(particle, false, false, -1, false, false)

    self:GetParent():AddNoDraw()

    local attack_per_second = self:GetParent():GetAttackSpeed(true) / self:GetParent():GetBaseAttackTime()
    local interval = 1 / attack_per_second
    self:StartIntervalThink(interval)
end

function modifier_bratishkin_e_primary:OnDestroy()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_bratishkin_q_knight") then
        self:GetCaster().weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sven/weapon_ruling_sword.vmdl"})
	    self:GetCaster().weapon:FollowEntityMerge(self:GetCaster(), "attach_sword")
    end
    FindClearSpaceForUnit(self:GetParent(), self.origin, true)
    self:GetParent():RemoveNoDraw()
    local particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_bratishkin_e_primary:IsPurgable() return false end

function modifier_bratishkin_e_primary:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
    return funcs
end

function modifier_bratishkin_e_primary:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_bratishkin_e_primary:CheckState()
    local state = 
    {   
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_UNSELECTABLE]   = true,
        [MODIFIER_STATE_OUT_OF_GAME]    = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_bratishkin_e_primary:OnIntervalThink()
    if IsServer() then
        self:GetCaster():SetAbsOrigin(self.origin)
        local caster = self:GetCaster()
        local origin = self:GetParent():GetAbsOrigin()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER, false)
        for _, unit in pairs(targets) do
            if unit:IsAlive() and not unit:IsAttackImmune() and caster:CanEntityBeSeenByMyTeam(unit) then
                if self:GetParent():IsRangedAttacker() then
                    self:GetParent():PerformAttack(unit, true, true, true, false, true, false, false)
                else
                    self:GetParent():PerformAttack(unit, true, true, true, false, false, false, true)
                end
            end
        end
    end
end

modifier_bratishkin_e_primary_scepter = class({})

function modifier_bratishkin_e_primary_scepter:OnCreated()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_bratishkin_q_knight") then
        self:GetCaster().weapon:RemoveSelf()
    end
    self.origin = self:GetCaster():GetAbsOrigin()
    self:GetParent():EmitSound("Hero_Riki.TricksOfTheTrade")

    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local cast_particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(cast_particle, 0, self:GetParent():GetAbsOrigin())

    local particle = ParticleManager:CreateParticle("particles/bratishkin_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, 0, radius))
    self:AddParticle(particle, false, false, -1, false, false)
    if self:GetCaster():HasAbility("bratishkin_q_knight") then
        self:GetCaster():FindAbilityByName("bratishkin_q_knight"):SetActivated(false)
    end
    if self:GetCaster():HasAbility("bratishkin_q_base") then
        self:GetCaster():FindAbilityByName("bratishkin_q_base"):SetActivated(false)
    end
    local attack_per_second = self:GetParent():GetAttackSpeed(true) / self:GetParent():GetBaseAttackTime()
    local interval = 1 / attack_per_second
    self:StartIntervalThink(interval)
end

function modifier_bratishkin_e_primary_scepter:OnDestroy()
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_bratishkin_q_knight") then
        self:GetCaster().weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sven/weapon_ruling_sword.vmdl"})
	    self:GetCaster().weapon:FollowEntityMerge(self:GetCaster(), "attach_sword")
    end
    if self:GetCaster():HasAbility("bratishkin_q_knight") then
        self:GetCaster():FindAbilityByName("bratishkin_q_knight"):SetActivated(true)
    end
    if self:GetCaster():HasAbility("bratishkin_q_base") then
        self:GetCaster():FindAbilityByName("bratishkin_q_base"):SetActivated(true)
    end
    local particle = ParticleManager:CreateParticle("particles/econ/items/riki/riki_crownfall_immortal_weapon/riki_crownfall_immortal_tricks_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_bratishkin_e_primary_scepter:IsPurgable() return false end

function modifier_bratishkin_e_primary_scepter:DeclareFunctions()
    local funcs = { 
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MODEL_CHANGE 
 }
    return funcs
end

function modifier_bratishkin_e_primary_scepter:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_bratishkin_e_primary_scepter:GetModifierModelChange()
    return "models/bratishkin/box/cardboardbox_lp.vmdl"
end

function modifier_bratishkin_e_primary_scepter:CheckState()
    return {   
        [MODIFIER_STATE_INVULNERABLE]   = true,
        [MODIFIER_STATE_UNSELECTABLE]   = true,
        [MODIFIER_STATE_OUT_OF_GAME]    = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_bratishkin_e_primary_scepter:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local origin = self:GetParent():GetAbsOrigin()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER, false)
        for _, unit in pairs(targets) do
            if unit:IsAlive() and not unit:IsAttackImmune() and caster:CanEntityBeSeenByMyTeam(unit) then
                if self:GetParent():IsRangedAttacker() then
                    self:GetParent():PerformAttack(unit, true, true, true, false, true, false, false)
                else
                    self:GetParent():PerformAttack(unit, true, true, true, false, false, false, true)
                end
            end
        end
    end
end
