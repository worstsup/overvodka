nix_rus = class({})
LinkLuaModifier( "modifier_nix_rus", "heroes/nix/nix_rus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nix_rus_debuff", "heroes/nix/nix_rus", LUA_MODIFIER_MOTION_NONE )

function nix_rus:Precache(context)
	PrecacheResource("particle", "particles/nix_r.vpcf", context)
	PrecacheResource("particle", "particles/pravin_nix_r.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", context)
	PrecacheResource("soundfile", "soundevents/nix_rus.vsndevts", context )
	PrecacheResource("particle", "particles/units/heroes/hero_oracle/oracle_fatesedict_disarm_ovrhead.vpcf", context)
end

function nix_rus:OnSpellStart()
	if not IsServer() then return end
	if not global_sounds_muted then
		EmitSoundOn( "nix_rus", self:GetCaster() )
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_nix_rus", { duration = self:GetSpecialValueFor( "duration" ) } )
end

modifier_nix_rus = class({})

function modifier_nix_rus:IsPurgable() return false end

function modifier_nix_rus:GetCurrentParticleName()
	local caster = self:GetCaster()
	if caster and not caster:IsNull() and caster:HasModifier("modifier_nix_swap_pravin") then
		return "particles/pravin_nix_r.vpcf"
	end

	return "particles/nix_r.vpcf"
end

function modifier_nix_rus:RefreshParticle()
	if not IsServer() then return end

	local particle_name = self:GetCurrentParticleName()
	if self.current_particle_name == particle_name then return end

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
	end

	self.particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
	self.current_particle_name = particle_name
end

function modifier_nix_rus:ApplyRusTick()
	local damage = self:GetAbility():GetSpecialValueFor("dps") * self.logic_interval
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local damage_table = {
        attacker = parent,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
    }
	for _, unit in pairs(enemies) do
		if damage > 0 then
            damage_table.victim = unit
			ApplyDamage(damage_table)
		end
	end
end

function modifier_nix_rus:OnCreated()
	self.model_scale = self:GetAbility():GetSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.logic_interval = 0.5
	if not IsServer() then return end
	self.next_logic_time = GameRules:GetGameTime() + self.logic_interval
	self:ApplyRusTick()
	self:RefreshParticle()
	self:StartIntervalThink(0.1)
end

function modifier_nix_rus:OnDestroy()
	if not IsServer() then return end
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.particle = nil
	end
end

function modifier_nix_rus:OnIntervalThink()
	if IsServer() then
		self:RefreshParticle()
		if not self:GetParent():IsAlive() then
			self:Destroy()
			return
		end

		local game_time = GameRules:GetGameTime()
		while game_time >= (self.next_logic_time or 0) do
			self:ApplyRusTick()
			self.next_logic_time = (self.next_logic_time or game_time) + self.logic_interval
		end
	end
end

function modifier_nix_rus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_nix_rus:GetModifierModelScale()
	return self.model_scale
end

function modifier_nix_rus:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_nix_rus:IsAura() return true end
function modifier_nix_rus:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_nix_rus:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_nix_rus:GetModifierAura() return "modifier_nix_rus_debuff" end
function modifier_nix_rus:GetAuraDuration() return 0.5 end

function modifier_nix_rus:GetAuraRadius()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("radius")
    end
end

modifier_nix_rus_debuff = class({})

function modifier_nix_rus_debuff:IsHidden() return false end
function modifier_nix_rus_debuff:IsDebuff() return true end
function modifier_nix_rus_debuff:IsStunDebuff() return false end
function modifier_nix_rus_debuff:IsPurgable() return false end

function modifier_nix_rus_debuff:OnCreated()
	if not IsServer() then return end
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
	self.scepter = self:GetCaster():HasScepter()
	if self.scepter then
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_oracle/oracle_fatesedict_disarm_ovrhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddParticle( effect_cast, false, false, -1, false, false )
	end
end

function modifier_nix_rus_debuff:OnRefresh()
	self.lose_strength = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_loss") * 0.01
	self.scepter = self:GetCaster():HasScepter()
end

function modifier_nix_rus_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_nix_rus_debuff:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = self.scepter,
	}
end

function modifier_nix_rus_debuff:GetModifierBonusStats_Strength()
	return self.lose_strength
end

function modifier_nix_rus_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("as_loss")
end

function modifier_nix_rus_debuff:GetModifierModelScale()
	return -30
end

function modifier_nix_rus_debuff:GetEffectName()
	local caster = self:GetCaster()
	if caster and not caster:IsNull() and caster:HasModifier("modifier_nix_swap_pravin") then
		return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf"
	end

	return "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf"
end

function modifier_nix_rus_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end