LinkLuaModifier("modifier_vihor_q_slow", "heroes/vihor/vihor_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_vihor_q_fly", "heroes/vihor/vihor_q", LUA_MODIFIER_MOTION_NONE )

vihor_q = class({})

function vihor_q:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_projectile.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_thinker.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly_mount_trail.vpcf", context)
	PrecacheResource("particle", "particles/vihor_innate.vpcf", context)
    PrecacheResource("soundfile", "soundevents/vihor_q.vsndevts", context)
end

function vihor_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local range = self:GetSpecialValueFor("range")
    local duration_fly = self:GetSpecialValueFor("duration_fly")
    local targets_count = self:GetSpecialValueFor("targets")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetAbsOrigin(),
        nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, FIND_CLOSEST, false
    )

    local chosen = {}
    local used = {}

    if enemies and #enemies > 0 then
        for _, enemy in ipairs(enemies) do
            if enemy and not enemy:IsNull() and enemy:IsAlive() then
                local idx = enemy:entindex()
                if not used[idx] then
                    used[idx] = true
                    table.insert(chosen, enemy)
                    if #chosen >= targets_count then
                        break
                    end
                end
            end
        end
    end

    while #chosen < targets_count do
        table.insert(chosen, caster)
    end

    local blast_speed = self:GetSpecialValueFor("blast_speed")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")
    for _, target in ipairs(chosen) do
        local info = {
            EffectName = "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_projectile.vpcf",
            Ability = self,
            iMoveSpeed = blast_speed,
            Source = caster,
            Target = target,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
            ExtraData = {
                radius = radius,
                damage = damage,
                duration = duration,
            }
        }
        ProjectileManager:CreateTrackingProjectile(info)
    end

    caster:AddNewModifier(caster, self, "modifier_vihor_q_fly", { duration = duration_fly })
    EmitSoundOn("vihor_q", self:GetCaster())
end

function vihor_q:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then return true end
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return true end
    if not vLocation then return true end

    local radius = (ExtraData and tonumber(ExtraData.radius)) or self:GetSpecialValueFor("radius")
    local damage = (ExtraData and tonumber(ExtraData.damage)) or self:GetSpecialValueFor("damage")
    local duration = (ExtraData and tonumber(ExtraData.duration)) or self:GetSpecialValueFor("duration")

    local units = FindUnitsInRadius(
        caster:GetTeamNumber(), vLocation,
        nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    local damage_table = {attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self}
    for _, enemy in ipairs(units) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            enemy:AddNewModifier(caster, self, "modifier_vihor_q_slow", { duration = duration * (1 - enemy:GetStatusResistance()) })
            damage_table.victim = enemy
            ApplyDamage(damage_table)
        end
    end

    if hTarget and not hTarget:IsNull() then
        self:PlayEffects(hTarget)
    end

    return true
end

function vihor_q:PlayEffects( target )
	local particle_radius = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_tar_bomb_thinker.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_radius, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_radius)
end

modifier_vihor_q_slow = class({})

function modifier_vihor_q_slow:IsDebuff() return true end

function modifier_vihor_q_slow:OnCreated()
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
end

function modifier_vihor_q_slow:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_vihor_q_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.dot_slow
end

function modifier_vihor_q_slow:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_tar_bomb_debuff.vpcf"
end

function modifier_vihor_q_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_vihor_q_fly = class({})

function modifier_vihor_q_fly:OnCreated()
    self.bonus_speed = self:GetAbility():GetSpecialValueFor("bonus_speed")
end

function modifier_vihor_q_fly:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StartGesture(ACT_DOTA_ECHO_SLAM)
end

function modifier_vihor_q_fly:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true,
	}
end

function modifier_vihor_q_fly:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_vihor_q_fly:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_speed
end

function modifier_vihor_q_fly:GetOverrideAnimation()
	return ACT_DOTA_FLEE
end

function modifier_vihor_q_fly:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly_mount_trail.vpcf"
end

function modifier_vihor_q_fly:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end