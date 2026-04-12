LinkLuaModifier( "modifier_rostik_e", "heroes/rostik/rostik_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rostik_e_buff", "heroes/rostik/rostik_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rostik_e_debuff", "heroes/rostik/rostik_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rostik_e_spirits", "heroes/rostik/rostik_e", LUA_MODIFIER_MOTION_NONE )

rostik_e = class({})

function rostik_e:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/rostik_e.vsndevts", context )
	PrecacheResource( "particle", "particles/rostik_e_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/rostik_e_discharge.vpcf", context )
	PrecacheResource( "particle", "particles/rostik_e_overhead.vpcf", context )
	PrecacheResource( "particle_folder",  "particles/units/heroes/hero_wisp", context )
end

function rostik_e:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn( "rostik_e", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rostik_e", { duration = self:GetSpecialValueFor( "buff_duration" ) } )
	if self:GetCaster():HasScepter() then
		local abil = self:GetCaster():FindAbilityByName( "wisp_spirits" )
		abil:SetLevel( self:GetLevel() )
		self:GetCaster():CastAbilityNoTarget( abil, self:GetCaster():GetPlayerOwnerID() )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rostik_e_spirits", { duration = self:GetSpecialValueFor( "spirits_duration" ) } )
	end
end


modifier_rostik_e = class({})

function modifier_rostik_e:IsHidden() return false end
function modifier_rostik_e:IsDebuff() return false end
function modifier_rostik_e:IsStunDebuff() return false end
function modifier_rostik_e:IsPurgable() return true end
function modifier_rostik_e:GetEffectName() return "particles/rostik_e_overhead.vpcf" end
function modifier_rostik_e:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_rostik_e:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.radius = self.ability:GetSpecialValueFor( "overload_aoe" )
	self.bonus_as = self.ability:GetSpecialValueFor( "bonus_as" )
	local damage = self.ability:GetSpecialValueFor( "overload_damage" )
	if not IsServer() then return end
	self.duration = self.ability:GetSpecialValueFor( "duration" )
	self.damageTable = { attacker = self.parent, damage = damage, damage_type = self.ability:GetAbilityDamageType(), ability = self.ability }
	self.records = {}
	self.parent:AddNewModifier( self.parent,  self.ability,  "modifier_rostik_e_buff",  {} )
end

function modifier_rostik_e:OnRefresh()
	self.radius = self.ability:GetSpecialValueFor( "overload_aoe" )
	local damage = self.ability:GetSpecialValueFor( "overload_damage" )
	self.duration = self.ability:GetSpecialValueFor( "duration" )
	self.damageTable.damage = damage
end

function modifier_rostik_e:OnDestroy()
	if not IsServer() then return end
	self.parent:RemoveModifierByName( "modifier_rostik_e_buff" )
end

function modifier_rostik_e:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_rostik_e:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_rostik_e:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end

	local enemies = FindUnitsInRadius( self.parent:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
		if enemy and not enemy:IsNull() then
			enemy:AddNewModifier( self.parent, self.ability, "modifier_rostik_e_debuff", { duration = self.duration } )
		end
	end
	if self:GetRemainingTime() > 0 then
		self.parent:AddNewModifier( self.parent,  self.ability,  "modifier_rostik_e_buff",  {} )
	end
	self:PlayEffects( params.target )
end

function modifier_rostik_e:PlayEffects( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/rostik_e_discharge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	self:AddParticle( effect_cast, false,  false, -1, false, false )
	EmitSoundOn( "Hero_StormSpirit.Overload", target )
end


modifier_rostik_e_spirits = class({})

function modifier_rostik_e_spirits:IsHidden() return true end
function modifier_rostik_e_spirits:IsDebuff() return false end
function modifier_rostik_e_spirits:IsStunDebuff() return false end
function modifier_rostik_e_spirits:IsPurgable() return true end

function modifier_rostik_e_spirits:OnRemoved()
	self:GetParent():RemoveModifierByName( "modifier_wisp_spirits" )
end

function modifier_rostik_e_spirits:OnDestroy()
	self:GetParent():RemoveModifierByName( "modifier_wisp_spirits" )
end


modifier_rostik_e_buff = class({})

function modifier_rostik_e_buff:IsHidden() return true end
function modifier_rostik_e_buff:IsDebuff() return false end
function modifier_rostik_e_buff:IsStunDebuff() return false end
function modifier_rostik_e_buff:IsPurgable() return true end

function modifier_rostik_e_buff:OnCreated()
	local effect_cast = ParticleManager:CreateParticle( "particles/rostik_e_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false,  false, -1, false, false )
end


modifier_rostik_e_debuff = class({})

function modifier_rostik_e_debuff:IsHidden() return false end
function modifier_rostik_e_debuff:IsDebuff() return true end
function modifier_rostik_e_debuff:IsStunDebuff() return false end
function modifier_rostik_e_debuff:IsPurgable() return true end

function modifier_rostik_e_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_rostik_e_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor( "overload_attack_slow" )
end

function modifier_rostik_e_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "overload_move_slow" )
end