LinkLuaModifier("modifier_frisk_d", "heroes/frisk/frisk_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frisk_d_barrier", "heroes/frisk/frisk_d", LUA_MODIFIER_MOTION_NONE)

frisk_d = class({})

function frisk_d:Precache(context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/frisk_d.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", context)
    PrecacheResource("particle", "particles/frisk_d_heart.vpcf", context)
end

function frisk_d:CastFilterResultTarget(target)
    if not target then return UF_FAIL_CUSTOM end

    local caster = self:GetCaster()
    if target ~= caster and target:IsIllusion() then
        self._cast_err = "#dota_hud_error_cant_cast_on_illusion"
        return UF_FAIL_CUSTOM
    end

    return UnitFilter(
        target,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        caster:GetTeamNumber()
    )
end

function frisk_d:GetCustomCastErrorTarget()
    return self._cast_err
end

function frisk_d:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local target   = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local self_cast = target == caster

    target:AddNewModifier(caster, self, "modifier_frisk_d", {
        duration  = duration,
        self_cast = self_cast and 1 or 0
    })

    if self_cast then
        self:UseResources(false, false, false, true)
    else
        self:EndCooldown()
        self:SetActivated(false)
    end

    EmitSoundOn("frisk_d_cast_1", target)
end


modifier_frisk_d = class({})

function modifier_frisk_d:IsHidden() return false end
function modifier_frisk_d:IsPurgable() return false end

function modifier_frisk_d:OnCreated(kv)
    if not IsServer() then return end
    self.is_self = tonumber(kv.self_cast or 0) == 1

    local p = ParticleManager:CreateParticle("particles/frisk_d_heart.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(p, false, false, -1, false, false)
    local p1 = ParticleManager:CreateParticle("particles/frisk_d.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(p1, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(p1, false, false, -1, false, false)
    self.enemy = nil
    self:StartIntervalThink(FrameTime())
end

function modifier_frisk_d:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_frisk_d:GetMinHealth() return 1 end

function modifier_frisk_d:OnTakeDamage(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end
    if self:GetParent():GetHealth() > 1 then return end
    self.enemy = event.attacker
    self:Destroy()
end

function modifier_frisk_d:OnDestroy()
    if not IsServer() then return end
    local parent  = self:GetParent()
    local caster  = self:GetCaster()
    local ability = self:GetAbility()
    StopSoundOn("frisk_d_cast_1", parent)
    if not ability or ability:IsNull() then return end
    if not self.is_self then
        ability:SetActivated(true)
    end
    if parent and parent:IsAlive() and self.enemy and self.enemy:IsAlive() then
        local barrier_dur = ability:GetSpecialValueFor("barrier_duration")
        if self.is_self then
            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(p)
            EmitSoundOn("frisk_d_activate_1", parent)

            parent:AddNewModifier(caster, ability, "modifier_frisk_d_barrier", { duration = barrier_dur })
        else
            ability:UseResources(false, false, false, true)

            local max_loss   = caster:GetMaxHealth() * ability:GetSpecialValueFor("hp_loss_pct") / 100
            local hp_before  = caster:GetHealth()

            ApplyDamage({
                victim = caster,
                attacker = self.enemy,
                damage = max_loss,
                damage_type = DAMAGE_TYPE_PURE,
                ability = ability,
                damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
            })

            local actual_loss = math.max(0, hp_before - caster:GetHealth())
            local heal = actual_loss * ability:GetSpecialValueFor("heal_from_hp_loss") / 100

            parent:HealWithParams(heal, ability, false, true, caster, false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal, caster and caster:GetPlayerOwner())

            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(p)
            EmitSoundOn("frisk_d_activate_1", parent)

            parent:AddNewModifier(caster, ability, "modifier_frisk_d_barrier", { duration = barrier_dur })
        end
    end
end


modifier_frisk_d_barrier = class({})

function modifier_frisk_d_barrier:IsHidden() return false end
function modifier_frisk_d_barrier:IsPurgable() return true end

function modifier_frisk_d_barrier:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/econ/events/seasonal_reward_line_fall_2025/lotus_orb_fallrewardline_2025_shield_fallrewardline_2025.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
    self.barrier_max = self:GetAbility():GetSpecialValueFor("barrier_hp")
    self.barrier_block = self:GetAbility():GetSpecialValueFor("barrier_hp")
    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_frisk_d_barrier:AddCustomTransmitterData()
    return {
        barrier_max = self.barrier_max,
        barrier_block = self.barrier_block,
    }
end

function modifier_frisk_d_barrier:HandleCustomTransmitterData( data )
    self.barrier_max = data.barrier_max
    self.barrier_block = data.barrier_block
end

function modifier_frisk_d_barrier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_frisk_d_barrier:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_frisk_d_barrier:GetModifierIncomingDamageConstant(params)
    if IsClient() then
		if params.report_max then
			return self.barrier_max
		else
			return self.barrier_block
		end
	end
    if params.damage >= self.barrier_block then
		self:Destroy()
        return self.barrier_block * (-1)
	else
		self.barrier_block = self.barrier_block - params.damage
        self:SendBuffRefreshToClients()
		return params.damage * (-1)
	end
end
