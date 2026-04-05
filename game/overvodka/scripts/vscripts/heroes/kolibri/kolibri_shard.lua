LinkLuaModifier("modifier_kolibri_shard_movement",        "heroes/kolibri/kolibri_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kolibri_shard_movement_damage", "heroes/kolibri/kolibri_shard", LUA_MODIFIER_MOTION_NONE)

local function _GetSideDir(caster, sign)
	local f = caster:GetForwardVector()
	f.z = 0
	if f:Length2D() < 0.001 then
		f = Vector(1, 0, 0)
	end
	f = f:Normalized()

	if sign < 0 then
		return Vector(-f.y, f.x, 0):Normalized()
	end
	return Vector(f.y, -f.x, 0):Normalized()
end

local function _DoSideDash(ability, sign)
	if not IsServer() then return end

	local caster = ability:GetCaster()
	if not caster or caster:IsNull() then return end

	local range = ability:GetSpecialValueFor("range")
	local speed = ability:GetSpecialValueFor("speed")
	if range <= 0 or speed <= 0 then return end

	local dir = _GetSideDir(caster, sign)
	local duration = range / speed

	EmitSoundOn("kolibri_d", caster)
	ProjectileManager:ProjectileDodge(caster)
	caster:AddNewModifier(caster, ability, "modifier_kolibri_shard_movement", { duration = duration })

	caster:AddNewModifier(
		caster, ability, "modifier_generic_knockback_lua",
		{
			direction_x = dir.x, direction_y = dir.y,
			distance = range, duration = duration,
		}
	)
end

kolibri_d = class({})

function kolibri_d:Precache(ctx)
	PrecacheResource("soundfile", "soundevents/kolibri_sounds.vsndevts", ctx)
	PrecacheResource("particle", "particles/econ/events/fall_2021/force_staff_fall_2021.vpcf", ctx)
	PrecacheResource("particle", "particles/shemelis_slash.vpcf", ctx)
end

function kolibri_d:OnSpellStart()
	_DoSideDash(self, -1)
end

kolibri_f = class({})

function kolibri_f:Precache(ctx)
	PrecacheResource("soundfile", "soundevents/kolibri_sounds.vsndevts", ctx)
	PrecacheResource("particle", "particles/econ/events/fall_2021/force_staff_fall_2021.vpcf", ctx)
	PrecacheResource("particle", "particles/shemelis_slash.vpcf", ctx)
end

function kolibri_f:OnSpellStart()
	_DoSideDash(self, 1)
end


modifier_kolibri_shard_movement = class({})

function modifier_kolibri_shard_movement:IsPurgable() return false end
function modifier_kolibri_shard_movement:IsHidden() return true end

function modifier_kolibri_shard_movement:IsAura() return true end
function modifier_kolibri_shard_movement:GetAuraDuration() return 0 end
function modifier_kolibri_shard_movement:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_kolibri_shard_movement:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_kolibri_shard_movement:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_kolibri_shard_movement:GetModifierAura() return "modifier_kolibri_shard_movement_damage" end
function modifier_kolibri_shard_movement:GetAuraRadius() return 100 end

function modifier_kolibri_shard_movement:OnCreated()
	if not IsServer() then return end

	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	local p = ParticleManager:CreateParticle(
		"particles/econ/events/fall_2021/force_staff_fall_2021.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		parent
	)
	ParticleManager:SetParticleControlEnt(p, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	self:AddParticle(p, false, false, -1, false, false)
end

function modifier_kolibri_shard_movement:OnDestroy()
	if not IsServer() then return end

	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	if parent:GetUnitName() ~= "npc_dota_hero_nyx_assassin" then
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	end
end


modifier_kolibri_shard_movement_damage = class({})

function modifier_kolibri_shard_movement_damage:IsPurgable() return false end
function modifier_kolibri_shard_movement_damage:IsHidden() return true end

function modifier_kolibri_shard_movement_damage:OnCreated()
	if not IsServer() then return end

	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	if not parent or parent:IsNull() then return end
	if not caster or caster:IsNull() then return end
	if not ability or ability:IsNull() then return end

	local hit_fx = ParticleManager:CreateParticle("particles/shemelis_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(hit_fx, 0, parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(hit_fx)

	ApplyDamage({victim = parent, attacker = caster, damage = ability:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability})
end
