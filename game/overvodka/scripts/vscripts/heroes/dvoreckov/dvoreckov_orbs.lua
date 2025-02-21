dvoreckov_q = class({})
LinkLuaModifier( "modifier_dvoreckov_q", "heroes/dvoreckov/dvoreckov_orbs", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_q:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf", context )
end

function dvoreckov_q:IsStealable()
	return false
end

function dvoreckov_q:OnSpellStart()
	local caster = self:GetCaster()
	if caster:GetUnitName() == "npc_dota_hero_invoker" then

		local modifier = caster:AddNewModifier(
			caster,
			self,
			"modifier_dvoreckov_q",
			{}
		)
		self.invoke:AddOrb( modifier, "particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf" )
	end
end

function dvoreckov_q:OnUpgrade()
	if not self.invoke then
		local invoke = self:GetCaster():FindAbilityByName( "dvoreckov_r" )
		if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
		self.invoke = invoke
	else
		self.invoke:UpdateOrb("modifier_dvoreckov_q", self:GetLevel())
	end
end

modifier_dvoreckov_q = class({})

function modifier_dvoreckov_q:IsHidden()
	return false
end
function modifier_dvoreckov_q:IsDebuff()
	return false
end

function modifier_dvoreckov_q:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end
function modifier_dvoreckov_q:IsPurgable()
	return false
end

function modifier_dvoreckov_q:OnCreated( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
	self.regen_sss = self.regen * 2
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_q:OnRefresh( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
	self.regen_sss = self.regen * 2
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_q:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_dvoreckov_qqw") then
		self.regen = self.regen_sss
	else
		self.regen = self:GetAbility():GetSpecialValueFor( "health_regen_per_instance" )
	end
end
function modifier_dvoreckov_q:OnDestroy( kv )
end
function modifier_dvoreckov_q:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}

	return funcs
end
function modifier_dvoreckov_q:GetModifierConstantHealthRegen()
	return self.regen
end

dvoreckov_w = class({})
LinkLuaModifier( "modifier_dvoreckov_w", "heroes/dvoreckov/dvoreckov_orbs", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_w:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_ti6_quas_orb.vpcf", context )
end

function dvoreckov_w:IsStealable()
	return false
end

function dvoreckov_w:OnSpellStart()
	local caster = self:GetCaster()
	if caster:GetUnitName() == "npc_dota_hero_invoker" then
		local modifier = caster:AddNewModifier(
			caster,
			self,
			"modifier_dvoreckov_w",
			{  }
		)
		self.invoke:AddOrb( modifier, "particles/econ/items/invoker/invoker_ti6/invoker_ti6_quas_orb.vpcf" )
	end
end

function dvoreckov_w:OnUpgrade()
	if not self.invoke then
		local invoke = self:GetCaster():FindAbilityByName( "dvoreckov_r" )
		if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
		self.invoke = invoke
	else
		self.invoke:UpdateOrb("modifier_dvoreckov_w", self:GetLevel())
	end
end

modifier_dvoreckov_w = class({})

function modifier_dvoreckov_w:IsHidden()
	return false
end

function modifier_dvoreckov_w:IsDebuff()
	return false
end

function modifier_dvoreckov_w:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_dvoreckov_w:IsPurgable()
	return false
end

function modifier_dvoreckov_w:OnCreated( kv )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.as_bonus_sss = self.as_bonus * 2
	self.ms_bonus_sss = self.ms_bonus * 2
	self.cdr_sss = self.cdr * 2
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_w:OnRefresh( kv )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
	self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.as_bonus_sss = self.as_bonus * 2
	self.ms_bonus_sss = self.ms_bonus * 2
	self.cdr_sss = self.cdr * 2
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_w:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_dvoreckov_qqw") then
		self.as_bonus = self.as_bonus_sss
		self.ms_bonus = self.ms_bonus_sss
		self.cdr = self.cdr_sss
	else
		self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_per_instance" )
		self.ms_bonus = self:GetAbility():GetSpecialValueFor( "move_speed_per_instance" )
		self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	end
end
function modifier_dvoreckov_w:OnDestroy( kv )

end

function modifier_dvoreckov_w:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}

	return funcs
end

function modifier_dvoreckov_w:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end
function modifier_dvoreckov_w:GetModifierPercentageCooldown()
	return self.cdr
end
function modifier_dvoreckov_w:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

dvoreckov_e = class({})
LinkLuaModifier( "modifier_dvoreckov_e", "heroes/dvoreckov/dvoreckov_orbs", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_e:IsStealable()
	return false
end

function dvoreckov_e:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_ti6_exort_orb.vpcf", context )
end

function dvoreckov_e:OnSpellStart()
	local caster = self:GetCaster()
	if caster:GetUnitName() == "npc_dota_hero_invoker" then
		local modifier = caster:AddNewModifier(
			caster,
			self,
			"modifier_dvoreckov_e",
			{  }
		)

		self.invoke:AddOrb( modifier, "particles/econ/items/invoker/invoker_ti6/invoker_ti6_exort_orb.vpcf" )
	end
end

function dvoreckov_e:OnUpgrade()
	if not self.invoke then
		local invoke = self:GetCaster():FindAbilityByName( "dvoreckov_r" )
		if invoke:GetLevel()<1 then invoke:UpgradeAbility(true) end
		self.invoke = invoke
	else
		self.invoke:UpdateOrb("modifier_dvoreckov_e", self:GetLevel())
	end
end

modifier_dvoreckov_e = class({})

function modifier_dvoreckov_e:IsHidden()
	return false
end

function modifier_dvoreckov_e:IsDebuff()
	return false
end

function modifier_dvoreckov_e:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_dvoreckov_e:IsPurgable()
	return false
end

function modifier_dvoreckov_e:OnCreated( kv )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
	self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	self.damage_sss = self.damage * 2
	self.dmg_sss = self.dmg * 2
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_e:OnRefresh( kv )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
	self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	self.damage_sss = self.damage * 2
	self.dmg_sss = self.dmg * 2
	self:StartIntervalThink(0.5)
end
function modifier_dvoreckov_e:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_dvoreckov_qqw") then
		self.damage = self.damage_sss
		self.dmg = self.dmg_sss
	else
		self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_per_instance" )
		self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
	end
end
function modifier_dvoreckov_e:OnDestroy( kv )

end

function modifier_dvoreckov_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}

	return funcs
end
function modifier_dvoreckov_e:GetModifierPreAttack_BonusDamage()
	return self.damage
end
function modifier_dvoreckov_e:GetModifierSpellAmplify_Percentage()
	return self.dmg
end

dvoreckov_r = class({})
dvoreckov_empty_1 = class({})
dvoreckov_empty_2 = class({})

function dvoreckov_r:IsStealable()
	return false
end

orb_manager = {}
ability_manager = {}

orb_manager.orb_order = "qwe"
orb_manager.invoke_list = {
	["qqq"] = "dvoreckov_qqq",
	["qqw"] = "dvoreckov_qqw",
	["qqe"] = "dvoreckov_qqe",
	["www"] = "dvoreckov_www",
	["qww"] = "dvoreckov_qww",
	["wwe"] = "dvoreckov_wwe",
	["eee"] = "dvoreckov_eee",
	["qee"] = "dvoreckov_qee",
	["wee"] = "dvoreckov_wee",
	["qwe"] = "dvoreckov_qwe",
}
orb_manager.modifier_list = {
	["q"] = "modifier_dvoreckov_q",
	["w"] = "modifier_dvoreckov_w",
	["e"] = "modifier_dvoreckov_e",

	["modifier_dvoreckov_q"] = "q",
	["modifier_dvoreckov_w"] = "w",
	["modifier_dvoreckov_e"] = "e",
}

function dvoreckov_r:OnSpellStart()
	local caster = self:GetCaster()
	local ability_name = self.orb_manager:GetInvokedAbility()
	self.ability_manager:Invoke( ability_name )
	self:PlayEffects()
end

function dvoreckov_r:OnUpgrade()
	self.orb_manager = orb_manager:init()
	self.ability_manager = ability_manager:init()
	self.ability_manager.caster = self:GetCaster()
	self.ability_manager.ability = self
	local empty1 = self:GetCaster():FindAbilityByName( "dvoreckov_empty_1" )
	local empty2 = self:GetCaster():FindAbilityByName( "dvoreckov_empty_2" )
	table.insert(self.ability_manager.ability_slot,empty1)
	table.insert(self.ability_manager.ability_slot,empty2)
end

function dvoreckov_r:AddOrb( modifier, particle )
	self.orb_manager:Add( modifier, particle )
end

function dvoreckov_r:UpdateOrb( modifer_name, level )
	updates = self.orb_manager:UpdateOrb( modifer_name, level )
	self.ability_manager:UpgradeAbilities()
end

function dvoreckov_r:GetOrbLevel( orb_name )
	if not self.orb_manager.status[orb_name] then return 0 end
	return self.orb_manager.status[orb_name].level
end

function dvoreckov_r:GetOrbInstances( orb_name )
	if not self.orb_manager.status[orb_name] then return 0 end
	return self.orb_manager.status[orb_name].instances
end

function dvoreckov_r:GetOrbs()
	local ret = {}
	for k,v in pairs(self.orb_manager.status) do
		ret[k] = v.level
	end
	return ret
end

function dvoreckov_r:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_invoke.vpcf"
	local sound_cast = "kipil"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function orb_manager:init()
	local ret = {}
	ret.MAX_ORB = 3
	ret.status = {}
	ret.modifiers = {}
	ret.names = {}
	for k,v in pairs(self) do
		ret[k] = v
	end
	return ret
end

function orb_manager:Add( modifier, particle )
	local orb_name = self.modifier_list[modifier:GetName()]
	if not self.status[orb_name] then
		self.status[orb_name] = {
			["instances"] = 0,
			["level"] = modifier:GetAbility():GetLevel(),
		}
	end
	if modifier:GetCaster().invoked_orbs_particle == nil then
        modifier:GetCaster().invoked_orbs_particle = {}
    end

    if modifier:GetCaster().invoked_orbs_particle_attach == nil then
        modifier:GetCaster().invoked_orbs_particle_attach = {}
        modifier:GetCaster().invoked_orbs_particle_attach[1] = "attach_orb1"
        modifier:GetCaster().invoked_orbs_particle_attach[2] = "attach_orb2"
        modifier:GetCaster().invoked_orbs_particle_attach[3] = "attach_orb3"
    end
	if modifier:GetCaster().invoked_orbs_particle[1] ~= nil then
        ParticleManager:DestroyParticle(modifier:GetCaster().invoked_orbs_particle[1], false)
        modifier:GetCaster().invoked_orbs_particle[1] = nil
    end

    modifier:GetCaster().invoked_orbs_particle[1] = modifier:GetCaster().invoked_orbs_particle[2]
    modifier:GetCaster().invoked_orbs_particle[2] = modifier:GetCaster().invoked_orbs_particle[3]
    modifier:GetCaster().invoked_orbs_particle[3] = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, modifier:GetCaster())
    ParticleManager:SetParticleControlEnt(modifier:GetCaster().invoked_orbs_particle[3], 1, modifier:GetCaster(), PATTACH_POINT_FOLLOW, modifier:GetCaster().invoked_orbs_particle_attach[1], modifier:GetCaster():GetAbsOrigin(), false)

    local temp_attachment_point = modifier:GetCaster().invoked_orbs_particle_attach[1]
    modifier:GetCaster().invoked_orbs_particle_attach[1] = modifier:GetCaster().invoked_orbs_particle_attach[2]
    modifier:GetCaster().invoked_orbs_particle_attach[2] = modifier:GetCaster().invoked_orbs_particle_attach[3]
    modifier:GetCaster().invoked_orbs_particle_attach[3] = temp_attachment_point

	table.insert(self.modifiers,modifier)
	table.insert(self.names,orb_name)
	self.status[orb_name].instances = self.status[orb_name].instances + 1
	if #self.modifiers>self.MAX_ORB then
		self.status[self.names[1]].instances = self.status[self.names[1]].instances - 1
		if not self.modifiers[1]:IsNull() then
            self.modifiers[1]:Destroy()
        end

		table.remove(self.modifiers,1)
		table.remove(self.names,1)
	end
end

function orb_manager:GetInvokedAbility()
	local key = ""
	for i=1,string.len(self.orb_order) do
		k = string.sub(self.orb_order,i,i)

		if self.status[k] then 
			for i=1,self.status[k].instances do
				key = key .. k
			end
		end
	end
	return self.invoke_list[key]
end

function orb_manager:UpdateOrb( modifer_name, level )
	for _,modifier in pairs(self.modifiers) do
		if modifier:GetName()==modifer_name then
			modifier:ForceRefresh()
		end
	end
	local orb_name = self.modifier_list[modifer_name]
	if not self.status[orb_name] then
		self.status[orb_name] = {
			["instances"] = 0,
			["level"] = level,
		}
	else
		self.status[orb_name].level = level
	end
end

function ability_manager:init()
	local ret = {}
	ret.abilities = {}
	ret.ability_slot = {}
	ret.MAX_ABILITY = 2
	for k,v in pairs(self) do
		ret[k] = v
	end
	return ret
end

function ability_manager:Invoke( ability_name )
	if not ability_name then return end

	local ability = self:GetAbilityHandle( ability_name )
	ability.orbs = self.ability:GetOrbs()
	if self.ability_slot[1] and self.ability_slot[1]==ability then
		self.ability:RefundManaCost()
		self.ability:EndCooldown()
		return
	end
	local exist = 0
	for i=1,#self.ability_slot do
		if self.ability_slot[i]==ability then
			exist = i
		end
	end
	if exist>0 then
		self:InvokeExist( exist )
		self.ability:RefundManaCost()
		self.ability:EndCooldown()
		return
	end
	self:InvokeNew( ability )
	if self.caster:HasScepter() then
		self.ability:EndCooldown()
	end
end

function ability_manager:InvokeExist( slot )
	for i=slot,2,-1 do
		self.caster:SwapAbilities( 
			self.ability_slot[slot-1]:GetAbilityName(),
			self.ability_slot[slot]:GetAbilityName(),
			true,
			true
		)

		self.ability_slot[slot], self.ability_slot[slot-1] = self.ability_slot[slot-1], self.ability_slot[slot]
	end
end

function ability_manager:InvokeNew( ability )
	if #self.ability_slot<self.MAX_ABILITY then
		table.insert(self.ability_slot,ability)
	else
		self.caster:SwapAbilities( 
			ability:GetAbilityName(),
			self.ability_slot[#self.ability_slot]:GetAbilityName(),
			true,
			false
		)
		self.ability_slot[#self.ability_slot] = ability
	end
	self:InvokeExist( #self.ability_slot )
end

function ability_manager:GetAbilityHandle( ability_name )
	local ability = self.abilities[ability_name]
	if not ability then
		ability = self.caster:FindAbilityByName( ability_name )
		self.abilities[ability_name] = ability
		if not ability then
			ability = self.caster:AddAbility( ability_name )
			self.abilities[ability_name] = ability
		end
		self:InitAbility( ability )
	end
	return ability
end

function ability_manager:InitAbility( ability )
	ability:SetLevel(1)
	ability.GetOrbSpecialValueFor = function( self, key_name, orb_name )
		if not IsServer() then return 0 end
		if not self.orbs[orb_name] then return 0 end
		return self:GetLevelSpecialValueFor( key_name, self.orbs[orb_name] )
	end
end 

function ability_manager:UpgradeAbilities()
	for _,ability in pairs(self.abilities) do
		ability.orbs = self.ability:GetOrbs()
	end
end