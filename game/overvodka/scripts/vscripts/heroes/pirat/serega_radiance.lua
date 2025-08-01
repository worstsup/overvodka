serega_radiance = class({})
LinkLuaModifier( "modifier_serega_radiance", "heroes/pirat/serega_radiance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_radiance_debuff", "heroes/pirat/serega_radiance", LUA_MODIFIER_MOTION_NONE )

function serega_radiance:Precache(context)
	PrecacheResource( "particle", "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf", context )
	PrecacheResource( "particle", "particles/radiance_owner_fall2022_new.vpcf", context )
end
function serega_radiance:GetIntrinsicModifierName()
	return "modifier_serega_radiance"
end

modifier_serega_radiance = class({})

function modifier_serega_radiance:IsHidden() return true end
function modifier_serega_radiance:IsDebuff() return false end
function modifier_serega_radiance:IsPurgable() return false end

function modifier_serega_radiance:OnCreated( kv )
	if not IsServer() then return end
	self:PlayEffects( self:GetParent() )
end

function modifier_serega_radiance:PlayEffects( target )
	local particle_cast = "particles/radiance_owner_fall2022_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_serega_radiance:IsAura() return true end
function modifier_serega_radiance:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_serega_radiance:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_serega_radiance:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_serega_radiance:GetModifierAura() return "modifier_serega_radiance_debuff" end
function modifier_serega_radiance:GetAuraDuration() return 0.5 end

modifier_serega_radiance_debuff = class({})

function modifier_serega_radiance_debuff:IsHidden() return false end
function modifier_serega_radiance_debuff:IsDebuff() return true end
function modifier_serega_radiance_debuff:IsPurgable() return false end

function modifier_serega_radiance_debuff:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle("particles/econ/events/fall_2022/radiance_target_fall2022.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())
	self.interval = self:GetAbility():GetSpecialValueFor("interval")
	self:StartIntervalThink(self.interval)
end

function modifier_serega_radiance_debuff:OnIntervalThink()
	if not self:GetAbility() then return end
	if not self:GetCaster():IsAlive() then return end
	self.dmg = self:GetCaster():GetLevel() * self:GetAbility():GetSpecialValueFor("base_damage") * self.interval
	if self:GetCaster():IsIllusion() then
		self.dmg = self.dmg / 2
	end
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.dmg,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
	ApplyDamage( self.damageTable )
end

function modifier_serega_radiance_debuff:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_serega_radiance_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
end

function modifier_serega_radiance_debuff:GetModifierMiss_Percentage()
	return self:GetAbility():GetSpecialValueFor( "base_miss" ) + self:GetCaster():GetLevel() * self:GetAbility():GetSpecialValueFor( "level_miss" )
end