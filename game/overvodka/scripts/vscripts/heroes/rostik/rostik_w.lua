LinkLuaModifier("modifier_rostik_w_casting", "heroes/rostik/rostik_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_zuus_arc_lightning", "heroes/rostik/rostik_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

rostik_w = class ({})

function rostik_w:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function rostik_w:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function rostik_w:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function rostik_w:GetAOERadius()
	return self:GetSpecialValueFor("target_radius")
end

function rostik_w:OnAbilityPhaseStart()
	if not IsServer() then return end
	self.point = self:GetCursorPosition()
	return true
end
function rostik_w:OnSpellStart()
	if not IsServer() then return end
	self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rostik_w_casting", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("rostik_w", self:GetCaster())
end

modifier_rostik_w_casting = class ({})
function modifier_rostik_w_casting:IsPurgable() return false end
function modifier_rostik_w_casting:IsHidden() return true end

function modifier_rostik_w_casting:OnCreated(kv)
	if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/mk_ti9_immortal_army_radius_b_rostik.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetAbility().point)
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetAbility():GetSpecialValueFor("target_radius") + 25, self:GetAbility():GetSpecialValueFor("target_radius") + 25, self:GetAbility():GetSpecialValueFor("target_radius") + 25))
    self:AddParticle(particle, false, false, -1, false, false)
	self:OnIntervalThink()
	self:StartIntervalThink(self.interval)
end

function modifier_rostik_w_casting:OnDestroy()
	if not IsServer() then return end
end

function modifier_rostik_w_casting:OnIntervalThink()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target_radius = self:GetAbility():GetSpecialValueFor("target_radius")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.multi = self:GetAbility():GetSpecialValueFor("int_multi")
	self.blasts = self:GetAbility():GetSpecialValueFor("blasts")
	self.interval = self:GetAbility():GetSpecialValueFor("duration") / self.blasts
	self.max_offset = self.target_radius - self.radius
	local _x = RandomInt(-self.max_offset, self.max_offset)
	local _y = RandomInt(-self.max_offset, self.max_offset)
	local point = self:GetAbility().point + Vector(_x, _y, 0)

	local particle = ParticleManager:CreateParticle("particles/rostik_w.vpcf", PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
	
	local units = FindUnitsInRadius(self.caster:GetTeamNumber(), point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				
	for _,unit in pairs(units) do
		local damageTable = { victim = unit, attacker = self.caster, damage = self.damage + (self.caster:GetIntellect(false) / 100 * self.multi), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()}
		if RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("chance") then
			self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ability_zuus_arc_lightning", {starting_unit_entindex  = unit:entindex()})
			unit:AddNewModifier(self.caster, self:GetAbility(), "modifier_generic_stunned_lua", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
        end
        ApplyDamage(damageTable)
	end

	EmitSoundOnLocationWithCaster(point, "rostik_w_bolt", self.caster)	
end

function modifier_rostik_w_casting:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_rostik_w_casting:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end
--------------------------------------------------------------------------------


modifier_ability_zuus_arc_lightning = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})


--------------------------------------------------------------------------------

function modifier_ability_zuus_arc_lightning:OnCreated(kv)
    self.delay = self:GetAbility():GetSpecialValueFor("jump_delay")
    self.jump_count = self:GetAbility():GetSpecialValueFor("jump_count")
    self.radius = self:GetAbility():GetSpecialValueFor("radius_jump")
	self.damage_percent = self:GetAbility():GetSpecialValueFor("arc_damage_percent")
    self.count = 0
    if kv.starting_unit_entindex and EntIndexToHScript(kv.starting_unit_entindex) then
        self.actual_unit = EntIndexToHScript(kv.starting_unit_entindex)
    else
        self:Destroy()
        return
    end
    self.affected_units = {}

    self:CreateArcLightning(self.actual_unit)

    self:StartIntervalThink(self.delay)
end

function modifier_ability_zuus_arc_lightning:OnIntervalThink()
    local caster = self:GetCaster()

    local all = FindUnitsInRadius(caster:GetTeam(), 
    self.actual_unit:GetOrigin(), 
    nil, 
    self.radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, 
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
    DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
    FIND_ANY_ORDER, 
    false)

    local old_actual_unit = self.actual_unit

    for _, unit in ipairs(all) do
        if not HasAffected(self.affected_units, unit) then
            unit:EmitSound("Hero_Zuus.ArcLightning.Target")
            self:CreateArcLightning(unit)

            break
        end
    end
    if old_actual_unit == self.actual_unit or self.count >= self.jump_count then
        self:Destroy()
    end
end

function modifier_ability_zuus_arc_lightning:CreateArcLightning(target)
    self.count = self.count + 1
    local caster = self:GetCaster()
    local OldTarget = self.actual_unit
    if self.count == 1 then
        OldTarget = caster
    end
	self.dmg = self.damage_percent * target:GetMaxHealth() * 0.01
	ApplyDamage({
        victim = target,
        attacker = caster,
        damage = self.dmg,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility()
    })
    local fx = ParticleManager:CreateParticle("particles/rostik_q_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, OldTarget)
    ParticleManager:SetParticleControlEnt(fx, 0, OldTarget, PATTACH_POINT_FOLLOW, "attach_attack1", OldTarget:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(fx)
    self.actual_unit = target
    table.insert(self.affected_units, target)
end

function HasAffected(Table, unit)
    for k,v in pairs(Table) do
        if v == unit then
            return true
        end
    end
    return false
end