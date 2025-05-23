stariy_zveri = class({})
LinkLuaModifier( "modifier_stariy_disarmed", "heroes/stariy/stariy_zveri", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stariy_silenced", "heroes/stariy/stariy_zveri", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function stariy_zveri:Precache(context)
	PrecacheResource("soundfile", "soundevents/borsh.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/veter.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/kitaec.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/ptichki.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_rod_of_atos_projectile.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf", context)
end

function stariy_zveri:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.chance = RandomInt(1,4)
	if self.chance == 1 then
		EmitSoundOn( "borsh", caster )
	elseif self.chance == 2 then
		EmitSoundOn( "veter", caster )
	elseif self.chance == 3 then
		EmitSoundOn( "kitaec", caster )
	elseif self.chance == 4 then
		EmitSoundOn( "ptichki", caster )
	end
	local info = {
		Target = target,
		Source = caster,
		Ability = self,
		EffectName = "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_rod_of_atos_projectile.vpcf",
		iMoveSpeed = 600,
		bDodgeable = true,
		bProvidesVision = false,
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function stariy_zveri:OnProjectileHit(target, location)
	if not target then return end
	if target:TriggerSpellAbsorb(self) then return end
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local disarm_duration = self:GetSpecialValueFor("disarm_duration")
	local hex_duration = self:GetSpecialValueFor("hex_duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local silence_duration = self:GetSpecialValueFor("silence_duration")
	if self.chance == 1 then
		target:AddNewModifier( target, self, "modifier_stariy_disarmed", { duration = disarm_duration * (1 - target:GetStatusResistance()) })
	elseif self.chance == 2 then
		target:AddNewModifier( target, self, "modifier_stariy_silenced", { duration = silence_duration * (1 - target:GetStatusResistance()) })
	elseif self.chance == 3 then
		target:AddNewModifier( target, self, "modifier_generic_stunned_lua", { duration = stun_duration })	
	elseif self.chance == 4 then
		target:AddNewModifier( target, self, "modifier_shadow_shaman_voodoo", { duration = hex_duration * (1 - target:GetStatusResistance()) })
	end
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
end

modifier_stariy_disarmed = class({})
function modifier_stariy_disarmed:IsHidden() return false end
function modifier_stariy_disarmed:IsDebuff() return true end
function modifier_stariy_disarmed:IsPurgable() return true end
function modifier_stariy_disarmed:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_stariy_disarmed:GetEffectName()
	return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf"
end
function modifier_stariy_disarmed:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_stariy_silenced = class({})
function modifier_stariy_silenced:IsHidden() return false end
function modifier_stariy_silenced:IsDebuff() return true end
function modifier_stariy_silenced:IsPurgable() return true end
function modifier_stariy_silenced:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end
function modifier_stariy_silenced:GetEffectName()
	return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf"
end
function modifier_stariy_silenced:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
