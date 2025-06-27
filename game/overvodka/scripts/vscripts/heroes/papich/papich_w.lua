LinkLuaModifier("modifier_papich_w_thinker_attack_speed", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_thinker_evasion", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_attack_speed", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_w_evasion", "heroes/papich/papich_w", LUA_MODIFIER_MOTION_NONE)

papich_w									= papich_w or class({})
modifier_papich_w_thinker_attack_speed	= modifier_papich_w_thinker_attack_speed or class({})
modifier_papich_w_thinker_evasion			= modifier_papich_w_thinker_evasion or class({})
modifier_papich_w_attack_speed			= modifier_papich_w_attack_speed or class({})
modifier_papich_w_evasion					= modifier_papich_w_evasion or class({})

function papich_w:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function papich_w:OnSpellStart()
	self:GetCaster():EmitSound("papich_w")
	
	local cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_magnetic_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(cast_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(cast_particle)
	
	CreateModifierThinker(self:GetCaster(), self, "modifier_papich_w_thinker_attack_speed", {
		duration = self:GetSpecialValueFor("duration")
	}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	CreateModifierThinker(self:GetCaster(), self, "modifier_papich_w_thinker_evasion", {
		duration = self:GetSpecialValueFor("duration")
	}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end

function modifier_papich_w_thinker_attack_speed:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.attack_speed_bonus	= self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.steal 				= self:GetAbility():GetSpecialValueFor("intellect_steal_pct")
	if not IsServer() then return end
	k = 0
	
	self.magnetic_particle = ParticleManager:CreateParticle("particles/papich_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.magnetic_particle, 1, Vector(self.radius, 1, 1))
	self:AddParticle(self.magnetic_particle, false, false, 1, false, false)
end

function modifier_papich_w_thinker_attack_speed:OnDestroy()
	if not IsServer() then return end
end

function modifier_papich_w_thinker_attack_speed:IsAura()						return true end
function modifier_papich_w_thinker_attack_speed:IsAuraActiveOnDeath() 		return false end

function modifier_papich_w_thinker_attack_speed:GetAuraDuration()				return 1.0 end
function modifier_papich_w_thinker_attack_speed:GetAuraRadius()				return self.radius end
function modifier_papich_w_thinker_attack_speed:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_papich_w_thinker_attack_speed:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_papich_w_thinker_attack_speed:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO end
function modifier_papich_w_thinker_attack_speed:GetModifierAura()				return "modifier_papich_w_attack_speed" end


function modifier_papich_w_thinker_evasion:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.evasion_chance		= self:GetAbility():GetSpecialValueFor("evasion_chance")
end

function modifier_papich_w_thinker_evasion:IsAura()						return true end
function modifier_papich_w_thinker_evasion:IsAuraActiveOnDeath() 			return false end

function modifier_papich_w_thinker_evasion:GetAuraDuration()				return 0.1 end
function modifier_papich_w_thinker_evasion:GetAuraRadius()				return self.radius end
function modifier_papich_w_thinker_evasion:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_papich_w_thinker_evasion:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_papich_w_thinker_evasion:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO end
function modifier_papich_w_thinker_evasion:GetModifierAura()				return "modifier_papich_w_evasion" end


function modifier_papich_w_attack_speed:OnCreated()
	if self:GetAbility() then
		self.attack_speed_bonus	= self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
		self.steal = self:GetAbility():GetSpecialValueFor("intellect_steal_pct")
		self.movespeed = self:GetAbility():GetSpecialValueFor("slow")
		self.stolen = self:GetParent():GetStrength() * self.steal * 0.01
		if self:GetParent():IsRealHero() and self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			k = k + 1
			if self:GetCaster():HasScepter() then
				k = k + 0.5
			end
		end
	elseif self:GetAuraOwner() and self:GetAuraOwner():HasModifier("modifier_papich_w_thinker_attack_speed") then
		self.attack_speed_bonus	= self:GetAuraOwner():FindModifierByName("modifier_papich_w_thinker_attack_speed").attack_speed_bonus
		self.steal	= self:GetAuraOwner():FindModifierByName("modifier_papich_w_thinker_attack_speed").steal
		self.stolen = self:GetParent():GetStrength() * self.steal * 0.01
		if self:GetParent():IsRealHero() and self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and not self:GetParent():IsIllusion() then
			k = k + 1
			if self:GetCaster():HasScepter() then
				k = k + 0.5
			end
		end
	else
		self:Destroy()
	end
end
function modifier_papich_w_attack_speed:OnDestroy()
	if self:GetParent():IsRealHero() and self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and not self:GetParent():IsIllusion() then
		k = k - 1
		if self:GetCaster():HasScepter() then
			k = k - 0.5
		end
	end
end
function modifier_papich_w_attack_speed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_papich_w_attack_speed:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return -self.attack_speed_bonus
	end
	return self.attack_speed_bonus
end
function modifier_papich_w_attack_speed:GetModifierBonusStats_Strength()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():HasScepter() then
		return -self.stolen
	end
end
function modifier_papich_w_attack_speed:GetModifierBonusStats_Intellect()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return -self.stolen
	end
	return k * self.stolen
end
function modifier_papich_w_attack_speed:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return -self.movespeed
	end
	return self.movespeed
end

function modifier_papich_w_evasion:IsHidden() return true end
function modifier_papich_w_evasion:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_papich_w_evasion:OnCreated()
	if self:GetAbility() then
		self.evasion_chance	= self:GetAbility():GetSpecialValueFor("evasion_chance")
	elseif self:GetAuraOwner() and self:GetAuraOwner():HasModifier("modifier_papich_w_thinker_evasion") then
		self.evasion_chance	= self:GetAuraOwner():FindModifierByName("modifier_papich_w_thinker_evasion").evasion_chance
	else
		self:Destroy()
	end
end

function modifier_papich_w_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_papich_w_evasion:GetModifierEvasion_Constant(keys)
	if keys.attacker and self:GetAuraOwner() and self:GetAuraOwner():HasModifier("modifier_papich_w_thinker_evasion") and self:GetAuraOwner():FindModifierByName("modifier_papich_w_thinker_evasion").radius and (keys.attacker:GetAbsOrigin() - self:GetAuraOwner():GetAbsOrigin()):Length2D() > self:GetAuraOwner():FindModifierByName("modifier_papich_w_thinker_evasion").radius then
		return self.evasion_chance
	end
end