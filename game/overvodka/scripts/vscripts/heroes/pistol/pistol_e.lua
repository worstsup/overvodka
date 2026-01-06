LinkLuaModifier("modifier_pango_bonus", "heroes/pistol/pistol_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_e_swap", "heroes/pistol/pistol_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_e_damage", "heroes/pistol/pistol_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pistol_mute", "heroes/pistol/pistol_r", LUA_MODIFIER_MOTION_NONE)

pistol_e = class({})

function pistol_e:Precache(ctx)
    PrecacheResource("model", "models/heroes/pangolier/pangolier_gyroshell2.vmdl", ctx)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_pangolier", ctx)
	PrecacheResource("soundfile", "soundevents/pistol_sounds.vsndevts", ctx)
end

function pistol_e:GetIntrinsicModifierName()
    return "modifier_pango_bonus"
end

function pistol_e:OnAbilityPhaseStart()
	if not self:GetCaster():HasModifier("modifier_pistol_mute") then
        self:GetCaster():EmitSound("pistol_e")
    end
    return true
end

function pistol_e:OnAbilityPhaseInterrupted()
    self:GetCaster():StopSound("pistol_e")
end

function pistol_e:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local caster = self:GetCaster()
	self:GetCaster():StopSound("pistol_w")
	local vDir = caster:GetForwardVector()
	local vTargetPos = caster:GetAbsOrigin() + vDir
	local kv = {}
	kv[ "duration" ] = duration
	kv[ "vTargetX" ] = vTargetPos.x
	kv[ "vTargetY" ] = vTargetPos.y
	kv[ "vTargetZ" ] = vTargetPos.z

	caster:AddNewModifier(caster, self, "modifier_pangolier_gyroshell", kv)
	caster:AddNewModifier(caster, self, "modifier_pistol_e_swap", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_pistol_mute", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_pistol_e_damage", {duration = duration})
end


pistol_e_stop = class({})

function pistol_e_stop:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():StopSound("pistol_e")
	self:GetCaster():RemoveModifierByName("modifier_pangolier_gyroshell")
	self:GetCaster():RemoveModifierByName("modifier_pistol_e_swap")
	self:GetCaster():RemoveModifierByName("modifier_pistol_mute")
end


modifier_pistol_e_swap = class({})

function modifier_pistol_e_swap:IsPurgable() return false end
function modifier_pistol_e_swap:IsHidden() return true end

function modifier_pistol_e_swap:OnCreated()
	if not IsServer() then return end
	self:GetParent():SwapAbilities("pistol_e", "pistol_e_stop", false, true)
	self:StartIntervalThink(FrameTime())
end

function modifier_pistol_e_swap:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_pangolier_gyroshell") then
		self:Destroy()
	end
end

function modifier_pistol_e_swap:OnDestroy()
	if not IsServer() then return end
	self:GetParent():SwapAbilities("pistol_e_stop", "pistol_e", false, true)
end


modifier_pango_bonus = class({})
function modifier_pango_bonus:IsHidden() return true end
function modifier_pango_bonus:IsPurgable() return false end
function modifier_pango_bonus:GetPriority() return MODIFIER_PRIORITY_ULTRA + 10001 end


modifier_pistol_e_damage = class({})

function modifier_pistol_e_damage:IsHidden() return true end
function modifier_pistol_e_damage:IsPurgable() return false end

function modifier_pistol_e_damage:OnCreated()
	self.parent = self:GetParent()
	self.radius = self:GetAbility():GetSpecialValueFor("hit_radius")
	self.interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self.duration = self:GetAbility():GetSpecialValueFor("stun_duration")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self:StartIntervalThink(self.interval)
end

function modifier_pistol_e_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_pistol_e_damage:GetModifierIncomingDamage_Percentage()
	return -self.damage_reduction
end

function modifier_pistol_e_damage:OnIntervalThink()
	if not IsServer() then return end
	self.damage = self.parent:GetAverageTrueAttackDamage(nil) * self.damage_pct * 0.01
	local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for _, enemy in pairs(enemies) do
		if not enemy or enemy:IsNull() then return end
		if not enemy:IsAlive() then return end
		if enemy:HasModifier("modifier_pangolier_gyroshell_timeout") then return end
		ApplyDamage({victim = enemy, attacker = self.parent, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
	end
end