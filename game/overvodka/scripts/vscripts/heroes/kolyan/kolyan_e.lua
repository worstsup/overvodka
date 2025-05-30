kolyan_e = class({})
LinkLuaModifier( "modifier_kolyan_e", "heroes/kolyan/kolyan_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kolyan_e_debuff", "heroes/kolyan/kolyan_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kolyan_e_stack", "heroes/kolyan/kolyan_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kolyan_e_abilities", "heroes/kolyan/kolyan_e", LUA_MODIFIER_MOTION_NONE )

function kolyan_e:GetIntrinsicModifierName()
	return "modifier_kolyan_e"
end

function kolyan_e:Precache(context)
	PrecacheResource("particle", "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf", context)
	PrecacheResource("soundfile", "soundevents/kolyan_e.vsndevts", context)
end

modifier_kolyan_e = class({})

function modifier_kolyan_e:IsHidden() return (self:GetStackCount() == 0) end
function modifier_kolyan_e:IsDebuff() return false end
function modifier_kolyan_e:IsPurgable() return false end

function modifier_kolyan_e:OnCreated( kv )
	self.all_gain = self:GetAbility():GetSpecialValueFor( "all_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_kolyan_e:OnRefresh( kv )
	self.all_gain = self:GetAbility():GetSpecialValueFor( "all_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_kolyan_e:OnDestroy( kv )
end

function modifier_kolyan_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_kolyan_e:GetModifierProcAttack_Feedback( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		local target = params.target
		if (not target:IsHero()) or target:IsIllusion() then
			return
		end
		local debuff = params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kolyan_e_debuff",{stack_duration = self.duration})
        local random_chance = RandomInt(1, 100)
        if random_chance <= self:GetAbility():GetSpecialValueFor("swap_chance") and not target:HasModifier("modifier_kolyan_e_abilities") then
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kolyan_e_abilities", {duration = self:GetAbility():GetSpecialValueFor("swap_duration")})
			EmitSoundOn("kolyan_e_"..RandomInt(1,2), self:GetParent())
        end
		self:AddStack( duration )
		self:PlayEffects( params.target )
	end
end

function modifier_kolyan_e:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self.all_gain
end

function modifier_kolyan_e:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self.all_gain
end

function modifier_kolyan_e:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self.all_gain
end

function modifier_kolyan_e:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_kolyan_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_kolyan_e:RemoveStack()
	self:DecrementStackCount()
end

function modifier_kolyan_e:PlayEffects( target )
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_kolyan_e_debuff = class({})

function modifier_kolyan_e_debuff:IsHidden() return false end
function modifier_kolyan_e_debuff:IsDebuff() return true end
function modifier_kolyan_e_debuff:IsPurgable() return false end

function modifier_kolyan_e_debuff:OnCreated( kv )
	self.int_loss = self:GetAbility():GetSpecialValueFor( "int_loss" )
	self.duration = kv.stack_duration

	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_kolyan_e_debuff:OnRefresh( kv )
	self.int_loss = self:GetAbility():GetSpecialValueFor( "int_loss" )
	self.duration = kv.stack_duration

	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_kolyan_e_debuff:OnDestroy( kv )
end

function modifier_kolyan_e_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_kolyan_e_debuff:GetModifierBonusStats_Intellect()
	return self:GetStackCount() * -self.int_loss
end

function modifier_kolyan_e_debuff:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_kolyan_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_kolyan_e_debuff:RemoveStack()
	self:DecrementStackCount()

	if self:GetStackCount()<=0 then
		self:Destroy()
	end
end

modifier_kolyan_e_stack = class({})

function modifier_kolyan_e_stack:IsHidden() return true end
function modifier_kolyan_e_stack:IsPurgable() return false end
function modifier_kolyan_e_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_kolyan_e_stack:OnCreated( kv )
end

function modifier_kolyan_e_stack:OnRemoved()
	if IsServer() then
		self.modifier:RemoveStack()
	end
end

modifier_kolyan_e_abilities = class({})
function modifier_kolyan_e_abilities:IsHidden() return false end
function modifier_kolyan_e_abilities:IsPurgable() return false end

function modifier_kolyan_e_abilities:OnCreated( kv )
    if IsServer() then
        local target = self:GetParent()
        local possible_values = {0, 1, 2, 5}
        self.abil1 = possible_values[RandomInt(1, #possible_values)]
        self.abil2 = possible_values[RandomInt(1, #possible_values)]
        while self.abil1 == self.abil2 do
            self.abil2 = possible_values[RandomInt(1, #possible_values)]
        end
        local target_ability_1 = target:GetAbilityByIndex(self.abil1)
        local target_ability_2 = target:GetAbilityByIndex(self.abil2)
        target:SwapAbilities(
            target_ability_1:GetAbilityName(),
            target_ability_2:GetAbilityName(),
            true, true
        )
    end
end

function modifier_kolyan_e_abilities:OnDestroy()
    if IsServer() then
        local target = self:GetParent()
        local target_ability_1 = target:GetAbilityByIndex(self.abil1)
        local target_ability_2 = target:GetAbilityByIndex(self.abil2)
        target:SwapAbilities(
            target_ability_1:GetAbilityName(),
            target_ability_2:GetAbilityName(),
            true, true
        )
    end
end