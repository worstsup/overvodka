LinkLuaModifier("modifier_royale_scepter", "heroes/royale/royale_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_inferno_tower_ai", "heroes/royale/royale_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_inferno_tower_beam", "heroes/royale/royale_scepter", LUA_MODIFIER_MOTION_NONE)

royale_scepter = class({})

function royale_scepter:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/royale_die.vpcf", context)
    PrecacheUnitByNameSync("npc_inferno", context)
end

function royale_scepter:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_scepter:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_scepter:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")

    local inferno = CreateUnitByName("npc_inferno", point, true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(inferno, point, true)
    inferno:SetControllableByPlayer(caster:GetPlayerID(), false)
    inferno:SetOwner(caster)
    inferno:SetMaximumGoldBounty(gold)
    inferno:SetMinimumGoldBounty(gold)
    inferno:SetDeathXP(xp)

    inferno:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    inferno:AddNewModifier(self:GetCaster(), self, "modifier_royale_scepter", {duration = duration})
    inferno:AddNewModifier(caster, self, "modifier_inferno_tower_ai", {})
    EmitSoundOnLocationWithCaster(point, "InfernoTower.Spawn", caster)
end

modifier_inferno_tower_ai = class({})
function modifier_inferno_tower_ai:IsHidden() return true end
function modifier_inferno_tower_ai:IsPurgable() return false end

function modifier_inferno_tower_ai:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()

    self.base_dmg     = ability:GetSpecialValueFor("base_dmg")
    self.max_dmg      = ability:GetSpecialValueFor("max_dmg")
    self.ramp_time    = ability:GetSpecialValueFor("ramp_time")
    self.attack_rate  = ability:GetSpecialValueFor("attack_rate")
    self.range        = ability:GetSpecialValueFor("attack_range")

    self.current_target = nil
    self:StartIntervalThink(0.1)
end

function modifier_inferno_tower_ai:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent:IsAlive() then return end
    if self.current_target then
        if not self.current_target:IsAlive() or (self.current_target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > (self.range + 25) then
            parent:RemoveModifierByName("modifier_inferno_tower_beam")
            self.current_target = nil
        end
    end
    if not self.current_target then
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            self.range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false
        )
        if #enemies > 0 then
            self.current_target = enemies[1]
            if not parent:HasModifier("modifier_inferno_tower_beam") then
                parent:AddNewModifier(parent, self:GetAbility(), "modifier_inferno_tower_beam", {})
            end
        end
    end
end


modifier_inferno_tower_beam = class({})
function modifier_inferno_tower_beam:IsHidden() return true end
function modifier_inferno_tower_beam:IsPurgable() return false end

function modifier_inferno_tower_beam:OnCreated()
    if not IsServer() then return end
    local parent  = self:GetParent()
    local ability = self:GetAbility()
    EmitSoundOn("InfernoTower.Loop", parent)
    self.base_dmg    = ability:GetSpecialValueFor("base_dmg")
    self.max_dmg     = ability:GetSpecialValueFor("max_dmg")
    self.ramp_time   = ability:GetSpecialValueFor("ramp_time")
    self.attack_rate = ability:GetSpecialValueFor("attack_rate")

    self.elapsed = 0
    self:StartIntervalThink(self.attack_rate)

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
end

function modifier_inferno_tower_beam:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local mod = parent:FindModifierByName("modifier_inferno_tower_ai")
    local target = mod.current_target or nil
    
    if not target or not target:IsAlive() then
        self:Destroy()
        return
    end

    self.elapsed = math.min(self.elapsed + self.attack_rate, self.ramp_time)
    if parent:HasModifier("modifier_royale_e_rage") then
        self.elapsed = math.min(self.elapsed + self.attack_rate * 2, self.ramp_time)
    end
    local pct = self.elapsed / self.ramp_time
    local damage = self.base_dmg + (self.max_dmg - self.base_dmg) * pct

    ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

    ApplyDamage({victim = target, attacker = parent, damage = damage * self.attack_rate, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function modifier_inferno_tower_beam:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("InfernoTower.Loop", self:GetParent())
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end


modifier_royale_scepter = class({})

function modifier_royale_scepter:IsHidden() return true end
function modifier_royale_scepter:IsPurgable() return false end

function modifier_royale_scepter:OnCreated()
    if not IsServer() then return end
    local base_hp = self:GetAbility():GetSpecialValueFor("base_hp")
    self:GetParent():SetBaseMaxHealth(base_hp)
    self:GetParent():SetMaxHealth(base_hp)
    self:GetParent():SetHealth(base_hp)
end

function modifier_royale_scepter:OnDestroy()
    if not IsServer() then return end
    EmitSoundOn("Royale.Death", self:GetParent())
    local p = ParticleManager:CreateParticle("particles/royale_die.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(p, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    UTIL_Remove(self:GetParent())
end

function modifier_royale_scepter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
end

function modifier_royale_scepter:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - 1
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_royale_scepter:GetDisableHealing()
    return 1
end

function modifier_royale_scepter:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_royale_scepter:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_royale_scepter:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_royale_scepter:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_royale_scepter:GetAbsoluteNoDamagePure()
    return 1
end