LinkLuaModifier("modifier_chef_d_debuff", "heroes/chef/chef_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chef_d_buff", "heroes/chef/chef_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chef_d_buff_facet", "heroes/chef/chef_d", LUA_MODIFIER_MOTION_NONE)

chef_d = class({})

function chef_d:Precache(context)
    PrecacheResource("particle", "particles/chef_d_proj.vpcf", context)
    PrecacheResource("particle", "particles/chef_d_aoe.vpcf", context)
    PrecacheResource("particle", "particles/items3_fx/fish_bones_active.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf", context)
    PrecacheResource("soundfile", "soundevents/chef_d_hit.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/chef_d.vsndevts", context)
end

function chef_d:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function chef_d:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
	local point = self:GetCursorPosition()
    local attack_position = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2"))
    if point == attack_position then
        point = attack_position + caster:GetForwardVector()
    end
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    local direction = point - attack_position
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    EmitSoundOn("chef_d", caster)

    local flamebreak_particle = ParticleManager:CreateParticle("particles/chef_d_proj.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(flamebreak_particle, 0, attack_position)
	ParticleManager:SetParticleControl(flamebreak_particle, 1, Vector(projectile_speed, projectile_speed, projectile_speed))
	ParticleManager:SetParticleControl(flamebreak_particle, 5, point)

    local info =
    {
		Source = caster,
		Ability = self,
		vSpawnOrigin = attack_position,
	    bDeleteOnHit = true,
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO,
	    EffectName = "",
	    fDistance = distance,
	    fStartRadius = 0,
	    fEndRadius =0,
		vVelocity = direction * projectile_speed,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
        ExtraData = 
        {
            particle_fx = flamebreak_particle,
            current_team = current_team,
        }
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function chef_d:OnProjectileHit_ExtraData(htarget, vLocation, table)
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")
    local heal = self:GetSpecialValueFor("heal")
    local radius = self:GetSpecialValueFor("radius")
    if table.particle_fx then
        ParticleManager:DestroyParticle(table.particle_fx, true)
    end
    vLocation = GetGroundPosition(vLocation, nil)
    EmitSoundOnLocationWithCaster(vLocation, "chef_d_hit", self:GetCaster())
    local explosion_fx = ParticleManager:CreateParticle("particles/chef_d_aoe.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(explosion_fx, 0, vLocation)
    ParticleManager:SetParticleControl(explosion_fx, 1, Vector(radius, 0, 1))

    local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    for _, ally in pairs(allies) do
        ally:HealWithParams(heal, self, false, true, self:GetCaster(), false)
        ally:AddNewModifier(self:GetCaster(), self, "modifier_chef_d_buff", {duration = duration})
        if self:GetSpecialValueFor("burn_dur") > 0 then
            ally:AddNewModifier(self:GetCaster(), self, "modifier_chef_d_buff_facet", {duration = self:GetSpecialValueFor("burn_dur")})
        end
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal, self:GetCaster():GetPlayerOwner())
        local particle = ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
        ParticleManager:ReleaseParticleIndex(particle)
    end
    if self:GetCaster():HasShard() then
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        for _, enemy in pairs(enemies) do
            ApplyDamage({
                attacker = self:GetCaster(),
                victim = enemy,
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self,
                damage_flags = DOTA_DAMAGE_FLAG_NONE
            })
            enemy:AddNewModifier(self:GetCaster(), self, "modifier_chef_d_debuff", {duration = duration * (1-enemy:GetStatusResistance())})
        end
    end
end

modifier_chef_d_debuff = class({})

function modifier_chef_d_debuff:OnCreated()
    self.slow_as = self:GetAbility():GetSpecialValueFor("slow_as")
    if not IsServer() then return end
    self:IncrementStackCount()
    Timers:CreateTimer(self:GetDuration(), function()
        if self and not self:IsNull() then
            self:DecrementStackCount()
        end
    end)
end

function modifier_chef_d_debuff:OnRefresh()
    self.slow_as = self:GetAbility():GetSpecialValueFor("slow_as")
    if not IsServer() then return end
    self:IncrementStackCount()
    Timers:CreateTimer(self:GetDuration(), function()
        if self and not self:IsNull() then
            self:DecrementStackCount()
        end
    end)
end

function modifier_chef_d_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_chef_d_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.slow_as * self:GetStackCount()
end

function modifier_chef_d_debuff:GetEffectName()
    return "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_debuff.vpcf"
end

function modifier_chef_d_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_chef_d_buff = class({})

function modifier_chef_d_buff:OnCreated()
    self.bonus_as = self:GetAbility():GetSpecialValueFor("bonus_as")
    if not IsServer() then return end
    self:IncrementStackCount()
    Timers:CreateTimer(self:GetDuration(), function()
        if self and not self:IsNull() then
            self:DecrementStackCount()
        end
    end)
end

function modifier_chef_d_buff:OnRefresh()
    self.bonus_as = self:GetAbility():GetSpecialValueFor("bonus_as")
    if not IsServer() then return end
    self:IncrementStackCount()
    Timers:CreateTimer(self:GetDuration(), function()
        if self and not self:IsNull() then
            self:DecrementStackCount()
        end
    end)
end

function modifier_chef_d_buff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_chef_d_buff:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as * self:GetStackCount()
end

function modifier_chef_d_buff:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end

function modifier_chef_d_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_chef_d_buff_facet = class({})
function modifier_chef_d_buff_facet:IsHidden() return true end
function modifier_chef_d_buff_facet:IsPurgable() return true end
function modifier_chef_d_buff_facet:OnCreated()
    if not IsServer() then return end
    self.heal_burn = self:GetAbility():GetSpecialValueFor("heal_burn")
    self:StartIntervalThink(1)
end

function modifier_chef_d_buff_facet:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():HealWithParams(self.heal_burn, self:GetAbility(), false, true, self:GetCaster(), false)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal_burn, self:GetCaster():GetPlayerOwner())
end