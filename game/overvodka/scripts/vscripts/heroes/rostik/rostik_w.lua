LinkLuaModifier("modifier_rostik_w_casting", "heroes/rostik/rostik_w", LUA_MODIFIER_MOTION_NONE)

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
