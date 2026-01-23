chillguy_w = class({})
LinkLuaModifier( "modifier_chillguy_w", "heroes/chillguy/chillguy_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_w_debuff", "heroes/chillguy/chillguy_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chillguy_w_shard", "heroes/chillguy/chillguy_w", LUA_MODIFIER_MOTION_NONE )

function chillguy_w:OnSpellStart()
	local caster = self:GetCaster()
end

function chillguy_w:OnToggle()
	local caster = self:GetCaster()
	local toggle = self:GetToggleState()
	if toggle then
		self.modifier = caster:AddNewModifier( caster, self, "modifier_chillguy_w", {} )
	else
		if self.modifier and not self.modifier:IsNull() then
			self.modifier:Destroy()
		end
		self.modifier = nil
	end
end

modifier_chillguy_w = class({})

function modifier_chillguy_w:IsHidden() return true end
function modifier_chillguy_w:IsDebuff() return false end
function modifier_chillguy_w:IsPurgable() return false end
function modifier_chillguy_w:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_chillguy_w:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_second" )
	self.manacost_percent = self:GetAbility():GetSpecialValueFor( "mana_cost_percent" )
	self.parent = self:GetParent()
	if not IsServer() then return end
	self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_chillguy_w_debuff", {})
	self:Burn()
	self:StartIntervalThink( 1.0 )
	EmitSoundOn( "chillguy_music", self.parent )
end

function modifier_chillguy_w:OnDestroy()
	if not IsServer() then return end
	self.parent:RemoveModifierByName("modifier_chillguy_w_debuff")
	StopSoundOn( "chillguy_music", self.parent )
end

function modifier_chillguy_w:OnIntervalThink()
	local mana = self.parent:GetMana()
	self.mp = self.manacost + self.manacost_percent * self.parent:GetMaxMana() * 0.01
	if mana < self.mp then
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
		return
	end
	self:Burn()
end

function modifier_chillguy_w:Burn()
	self.mp = self.manacost + self.manacost_percent * self.parent:GetMaxMana() * 0.01
	self.parent:SpendMana( self.mp, self:GetAbility() )
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetOrigin(), nil,
		self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	local damage_pct = self:GetAbility():GetSpecialValueFor( "damage_pct" )
	for _,enemy in pairs(enemies) do
		local damage_new = damage_pct * enemy:GetMaxHealth() * 0.01 + damage
		self.damageTable = {
			attacker = self:GetParent(),
			damage = damage_new,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		self:PlayEffects( enemy )
	end
	local friends = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetOrigin(), nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER, false
	)
	for _,ally in pairs(friends) do
		if ally ~= self.parent then
			local heal = (self:GetAbility():GetSpecialValueFor( "damage_pct" ) * ally:GetMaxHealth() * 0.01 + damage) * self:GetAbility():GetSpecialValueFor("heal") * 0.01
			ally:HealWithParams(heal, self:GetAbility(), false, true, self.parent, false)
			SendOverheadEventMessage( ally, OVERHEAD_ALERT_HEAL, ally, heal, nil )
		end
	end
end

function modifier_chillguy_w:GetEffectName()
	return "particles/treant_eyesintheforest_new.vpcf"
end

function modifier_chillguy_w:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_chillguy_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf"
	local sound_cast = "Hero_Leshrac.Pulse_Nova_Strike"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(100, 0, 0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, target )
end
function modifier_chillguy_w:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(self.radius,0,0) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


modifier_chillguy_w_debuff = class({})

function modifier_chillguy_w_debuff:IsHidden() return true end
function modifier_chillguy_w_debuff:IsDebuff() return false end
function modifier_chillguy_w_debuff:IsPurgable() return false end

function modifier_chillguy_w_debuff:OnCreated()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_chillguy_w_debuff:OnRefresh()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_chillguy_w_debuff:IsAura() return true end
function modifier_chillguy_w_debuff:GetAuraRadius() return self.radius end
function modifier_chillguy_w_debuff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_chillguy_w_debuff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_chillguy_w_debuff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_chillguy_w_debuff:GetModifierAura() return "modifier_chillguy_w_shard" end


modifier_chillguy_w_shard = class({})

function modifier_chillguy_w_shard:IsDebuff() return true end
function modifier_chillguy_w_shard:IsStunDebuff() return true end

function modifier_chillguy_w_shard:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.shard = self:GetCaster():HasScepter()
	self.slow_as = self:GetAbility():GetSpecialValueFor("slow_as")
	self.slow_proj = self:GetAbility():GetSpecialValueFor("slow_proj")
end

function modifier_chillguy_w_shard:OnRefresh()
	self:OnCreated()
end

function modifier_chillguy_w_shard:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_chillguy_w_shard:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_chillguy_w_shard:GetModifierAttackSpeedBonus_Constant()
	return self.slow_as
end

function modifier_chillguy_w_shard:GetEffectName()
	return "particles/econ/events/fall_2021/bottle_fall_2021_ring_green.vpcf"
end

function modifier_chillguy_w_shard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end