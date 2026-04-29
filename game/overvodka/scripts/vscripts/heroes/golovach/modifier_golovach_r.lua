modifier_golovach_r = class({})

function modifier_golovach_r:IsHidden() return false end
function modifier_golovach_r:IsDebuff() return false end
function modifier_golovach_r:IsPurgable() return false end

function modifier_golovach_r:OnCreated()
	self.parent = self:GetParent()
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
	if not IsServer() then return end
	self.parent:Purge( false, true, false, false, false )
	self.parent:AddNewModifier( self.parent, self:GetAbility(), "modifier_golovach_r_fury", {} )
	self:PlayEffects()
end

function modifier_golovach_r:OnRefresh()
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )	
	if not IsServer() then return end
	self.parent:Purge( false, true, false, false, false )
	self:PlayEffects()
end

function modifier_golovach_r:OnDestroy()
	if not IsServer() then return end
	local fury = self.parent:FindModifierByNameAndCaster( "modifier_golovach_r_fury", self.parent )
	if fury then
		fury:ForceDestroy()
	end

	local recovery = self.parent:FindModifierByNameAndCaster( "modifier_golovach_r_recovery", self.parent )
	if recovery then
		recovery:ForceDestroy()
	end
end

function modifier_golovach_r:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_golovach_r:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	local cleave_damage = self:GetAbility():GetSpecialValueFor("cleave_percent")
    local cleave_radius = self:GetAbility():GetSpecialValueFor("cleave_radius")
	if not params.attacker:IsRangedAttacker() then
		local cleaveDamage = ( cleave_damage * params.damage ) / 100.0
		DoCleaveAttack( self:GetParent(), params.target, self:GetAbility(), cleaveDamage, cleave_radius, cleave_radius, cleave_radius, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf" )
	end
end

function modifier_golovach_r:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_golovach_r:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "golovach_r", self:GetParent() )
end