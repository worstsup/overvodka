dvoreckov_q = class({})
LinkLuaModifier( "modifier_dvoreckov_q", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_q:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf", context )
end

function dvoreckov_q:IsStealable()
	return false
end

function dvoreckov_q:ProcsMagicStick()
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
LinkLuaModifier( "modifier_dvoreckov_w", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_w:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_ti6_quas_orb.vpcf", context )
end

function dvoreckov_w:IsStealable()
	return false
end

function dvoreckov_w:ProcsMagicStick()
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
LinkLuaModifier( "modifier_dvoreckov_e", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_e:IsStealable()
	return false
end

function dvoreckov_e:ProcsMagicStick()
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

function dvoreckov_r:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_invoker/invoker_invoke.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/kipil.vsndevts", context )
end

function dvoreckov_r:IsStealable()
	return false
end

function dvoreckov_r:ProcsMagicStick()
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

function ability_manager:GetValueQuas(ability, caster, value)
    local quas = caster:FindAbilityByName("dvoreckov_q")
    if quas then
        local level = quas:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueWex(ability, caster, value)
    local wex = caster:FindAbilityByName("dvoreckov_w")
    if wex then
        local level = wex:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

function ability_manager:GetValueExort(ability, caster, value)
    local exort = caster:FindAbilityByName("dvoreckov_e")
    if exort then
        local level = exort:GetLevel() - 1
        return ability:GetLevelSpecialValueFor(value, level)
    end
    return 0
end

dvoreckov_qqq = class({})
LinkLuaModifier( "modifier_dvoreckov_qqq", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qqq:Precache(context)
	PrecacheResource("soundfile", "soundevents/hehe.vsndevts", context )
	PrecacheResource("particle", "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", context)
end

dvoreckov_qqq.modifiers = {}
function dvoreckov_qqq:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then
		return
	end
	local duration = self:GetSpecialValueFor("duration") + 0.1
	local modifier = target:AddNewModifier(
		caster,
		self,
		"modifier_dvoreckov_qqq",
		{ duration = duration }
	)
	self.modifiers[modifier] = true
	self.sound_cast = "hehe"
	EmitSoundOn(self.sound_cast, caster)

	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		local additional_targets = self:FindAdditionalTargets()
		local count = 0
		for _, additional_target in pairs(additional_targets) do
			if additional_target ~= target then
				local additional_modifier = additional_target:AddNewModifier(
					caster,
					self,
					"modifier_dvoreckov_qqq",
					{ duration = duration }
				)
				self.modifiers[additional_modifier] = true
				count = count + 1
				if count >= 2 then
					break
				end
			end
		end
	end
end

function dvoreckov_qqq:Unregister( modifier )
	self.modifiers[modifier] = nil
	local counter = 0
	for modifier,_ in pairs(self.modifiers) do
		if not modifier:IsNull() then
			counter = counter+1
		end
	end
end

function dvoreckov_qqq:FindAdditionalTargets()
	local caster = self:GetCaster()
	local break_distance = self:GetSpecialValueFor("break_distance")
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		break_distance,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_CLOSEST,
		false
	)
	return targets
end

modifier_dvoreckov_qqq = class({})

function modifier_dvoreckov_qqq:IsHidden()
	return false
end
function modifier_dvoreckov_qqq:IsDebuff()
	return true
end
function modifier_dvoreckov_qqq:IsStunDebuff()
	return false
end
function modifier_dvoreckov_qqq:IsPurgable()
	return false
end

function modifier_dvoreckov_qqq:OnCreated( kv )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.mana = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "mana_per_second")
		self.slow = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "movespeed")
	else
		self.mana = 120
		self.slow = -20
	end
	self.radius = self:GetAbility():GetSpecialValueFor( "break_distance" )
	local interval = self:GetAbility():GetSpecialValueFor( "tick_interval" )

	self.mana = self.mana * interval

	if IsServer() then
		self.parent = self:GetParent()
		self:StartIntervalThink( interval )
		self:PlayEffects()
	end
end

function modifier_dvoreckov_qqq:OnRefresh( kv )
end
function modifier_dvoreckov_qqq:OnRemoved()
end

function modifier_dvoreckov_qqq:OnDestroy()
	if not IsServer() then return end
	if not self.forceDestroy then
		self:GetAbility():Unregister( self )
	end
	if self.parent:IsIllusion() then
		self.parent:Kill( self:GetAbility(), self:GetCaster() )
	end
end

function modifier_dvoreckov_qqq:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_dvoreckov_qqq:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dvoreckov_qqq:OnIntervalThink()
	if self.parent:IsMagicImmune() or self.parent:IsInvulnerable() or self.parent:IsIllusion() then
		self:Destroy()
		return
	end
	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end
	if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>self.radius then
		self:Destroy()
		return
	end
	local mana = self:GetParent():GetMana()
	local empty = false
	if mana<self.mana then
		empty = true
		self.mana = mana
	end
	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.mana,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	self:GetParent():Script_ReduceMana( self.mana, self:GetAbility() )
	self:GetCaster():GiveMana( self.mana )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_dvoreckov_1")
		if Talented:GetLevel() == 1 then
			ApplyDamage(damageTable)
		end
	end
	if empty then
		self:Destroy()
	end
end

function modifier_dvoreckov_qqq:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0,0,0),
		true
	)

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

dvoreckov_qqw = class({})
LinkLuaModifier( "modifier_dvoreckov_qqw", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qqw:Precache(context)
	PrecacheResource("soundfile", "soundevents/sasi.vsndevts", context )
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf", context)
end

function dvoreckov_qqw:OnSpellStart()
	local caster = self:GetCaster()
	local duration =  ability_manager:GetValueQuas(self, self:GetCaster(), "duration")
	
	caster:AddNewModifier(
		caster,
		self,
		"modifier_dvoreckov_qqw",
		{ duration = duration }
	)
	self:PlayEffects()
end

function dvoreckov_qqw:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf"
	local sound_cast = "sasi"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end

modifier_dvoreckov_qqw = class({})
function modifier_dvoreckov_qqw:IsHidden()
	return false
end

function modifier_dvoreckov_qqw:IsDebuff()
	return false
end

function modifier_dvoreckov_qqw:IsPurgable()
	return false
end


function modifier_dvoreckov_qqw:OnCreated( kv )
end

function modifier_dvoreckov_qqw:OnRefresh( kv )
end

function modifier_dvoreckov_qqw:OnDestroy( kv )
end

function modifier_dvoreckov_qqw:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_dvoreckov_qqw:GetModifierInvisibilityLevel()
	return 2
end

function modifier_dvoreckov_qqw:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		if params.ability:GetAbilityName() == "dvoreckov_w" then return end
		if params.ability:GetAbilityName() == "dvoreckov_q" then return end
		if params.ability:GetAbilityName() == "dvoreckov_e" then return end
		if params.ability:GetAbilityName() == "dvoreckov_r" then return end
		self:Destroy()
	end
end

function modifier_dvoreckov_qqw:OnAttack( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end

		self:Destroy()
	end
end

function modifier_dvoreckov_qqw:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
	return state
end

dvoreckov_qqe = class({})
LinkLuaModifier( "modifier_dvoreckov_qqe", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dvoreckov_qqe_leap", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qqe:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/suda.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_damage.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_healing_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf", context )
	PrecacheResource( "particle", "particles/dvoreckov_qqe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/dvoreckov_qqe.vpcf", context )
end

function dvoreckov_qqe:FindValidPoint( point )
	local caster = self:GetCaster()
	local offset = self:GetSpecialValueFor( "max_offset_distance" )
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	local target = caster
	local distance = (caster:GetAbsOrigin()-point):Length2D()
	for _,ally in pairs(allies) do
		local d = (ally:GetAbsOrigin()-point):Length2D()
		if d<distance then
			distance = d
			target = ally
		end
	end
	local direction = point-target:GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	point = target:GetAbsOrigin() + direction*offset
	point = GetGroundPosition( point, caster )
	return target,point
end

function dvoreckov_qqe:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function dvoreckov_qqe:CastFilterResultLocation( vLoc )
	if IsClient() then
		if self.custom_indicator then
			self.custom_indicator:Register( vLoc )
		end
	end
	if not IsServer() then return end
	if self:GetSpecialValueFor("talent") == 1 then
		return UF_SUCCESS
	end
	local caster = self:GetCaster()
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		vLoc,
		nil,
		300,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	if #allies<1 then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function dvoreckov_qqe:GetCustomCastErrorLocation( vLoc )
	if not IsServer() then return "" end
	local caster = self:GetCaster()
	if self:GetSpecialValueFor("talent") == 1 then
		return ""
	end
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		vLoc,
		nil,
		300,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	if #allies<1 then
		return "Ты еблан наведись на героя вражеского блядь"
	end

	return ""
end

function dvoreckov_qqe:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = nil
	if not self:GetSpecialValueFor("talent") == 1 then
		target,point = self:FindValidPoint( point )
	end
	local radius = self:GetSpecialValueFor( "radius" )
	local channel = self:GetChannelTime()
	local leaptime = self:GetSpecialValueFor( "airtime_duration" )
	AddFOWViewer( caster:GetTeamNumber(), point, radius, channel+leaptime, false )
	caster:AddNewModifier(
		caster,
		self,
		"modifier_dvoreckov_qqe",
		{
			duration = channel+leaptime,
			x = point.x,
			y = point.y,
		}
	)

	self.point = point
end

function dvoreckov_qqe:OnChannelFinish( interrupted )
	local caster = self:GetCaster()

	if interrupted then
		local mod = caster:FindModifierByName( "modifier_dvoreckov_qqe" )
		if mod and (not mod:IsNull()) then
			mod:Destroy()
		end
		return
	end
	local duration = self:GetSpecialValueFor( "airtime_duration" )
	caster:AddNewModifier(
		caster,
		self,
		"modifier_dvoreckov_qqe_leap",
		{
			duration = duration,
			x = self.point.x,
			y = self.point.y,
		}
	)
end

modifier_dvoreckov_qqe = class({})

function modifier_dvoreckov_qqe:IsHidden()
	return false
end

function modifier_dvoreckov_qqe:IsDebuff()
	return false
end

function modifier_dvoreckov_qqe:IsPurgable()
	return false
end

function modifier_dvoreckov_qqe:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "base_damage")
	else
		self.damage = 100
	end
	self.heal = self:GetAbility():GetSpecialValueFor( "base_heal" )
	self.interval = self:GetAbility():GetSpecialValueFor( "pulse_interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	self.point = Vector( kv.x, kv.y, 0 )
	self.damageTable = {
		attacker = self.parent,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(),
	}
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
	self:PlayEffects1()
	self:PlayEffects2( self.point, self.radius )
end

function modifier_dvoreckov_qqe:OnRefresh( kv )	
end

function modifier_dvoreckov_qqe:OnRemoved()
end

function modifier_dvoreckov_qqe:OnDestroy()
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint( self.point, self.radius, false )
	FindClearSpaceForUnit( self.parent, self.parent:GetOrigin(), false )
	local sound_cast1 = "Hero_Dawnbreaker.Solar_Guardian.Channel"
	local sound_cast2 = "suda"
	StopSoundOn( sound_cast1, self.parent )
	StopSoundOn( sound_cast2, self.parent )
end

function modifier_dvoreckov_qqe:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

function modifier_dvoreckov_qqe:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.point,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end
	local allies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.point,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,ally in pairs(allies) do
		ally:Heal( self.heal, self.ability )
		self:PlayEffects4( ally )
		SendOverheadEventMessage(
			nil,
			OVERHEAD_ALERT_HEAL,
			ally,
			self.heal,
			self.parent:GetPlayerOwner()
		)
	end
	self:PlayEffects3( self.point, self.radius )
end

function modifier_dvoreckov_qqe:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.Channel"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_dvoreckov_qqe:PlayEffects2( point, radius )
	local particle_cast = "particles/dvoreckov_qqe.vpcf"
	local sound_cast = "suda"
	point = GetGroundPosition( point, self.parent )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOnLocationWithCaster( point, sound_cast, self.parent )
end

function modifier_dvoreckov_qqe:PlayEffects3( point, radius )
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_damage.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.Damage"
	point = GetGroundPosition( point, self.parent )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self.parent )
end

function modifier_dvoreckov_qqe:PlayEffects4( target )
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_healing_buff.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_dvoreckov_qqe_leap = class({})

function modifier_dvoreckov_qqe_leap:IsHidden()
	return false
end

function modifier_dvoreckov_qqe_leap:IsDebuff()
	return false
end

function modifier_dvoreckov_qqe_leap:IsPurgable()
	return false
end

function modifier_dvoreckov_qqe_leap:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "land_damage")
		self.duration = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "land_stun_duration")
	else
		self.damage = 300
		self.duration = 2.0
	end

	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	local arc_height = 2000
	self.point = Vector( kv.x, kv.y, 0 )
	self.interrupted = false
	local arc = self.parent:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_generic_arc_lua",
		{
			duration = kv.duration,
			height = arc_height,
			isStun = false,
			isForward = true,
		}
	)
	arc:SetEndCallback(function( interrupted )
		if interrupted then
			self.interrupted = interrupted
			self:Destroy()
		end
	end)

	self:StartIntervalThink( kv.duration/2 )
	self:PlayEffects1()
end

function modifier_dvoreckov_qqe_leap:OnRefresh( kv )
end

function modifier_dvoreckov_qqe_leap:OnRemoved()
end

function modifier_dvoreckov_qqe_leap:OnDestroy()
	if not IsServer() then return end
	if self.interrupted then return end
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.point,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	local damageTable = {
		attacker = self.parent,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self.ability,
	}

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage( damageTable )
		enemy:AddNewModifier(
			self.parent,
			self.ability,
			"modifier_generic_stunned_lua",
			{ duration = self.duration }
		)
	end
	GridNav:DestroyTreesAroundPoint( self.point, self.radius/2, false )
	self:PlayEffects2( self.point, self.radius )
end

function modifier_dvoreckov_qqe_leap:OnIntervalThink()
	self.point.z = self.parent:GetOrigin().z
	self.parent:SetOrigin( self.point )
end

function modifier_dvoreckov_qqe_leap:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_airtime_buff.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.BlastOff"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	EmitSoundOn( sound_cast, self.parent )
end

function modifier_dvoreckov_qqe_leap:PlayEffects2( point, radius )
	local particle_cast = "particles/dvoreckov_qqe_impact.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Solar_Guardian.Impact"
	point = GetGroundPosition( point, self.parent )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self.parent )
end

dvoreckov_www = class({})
LinkLuaModifier( "modifier_dvoreckov_www", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_HORIZONTAL )

function dvoreckov_www:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/unitazik.vsndevts", context )
end

function dvoreckov_www:GetAOERadius()
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
        return ability_manager:GetValueWex(self, self:GetCaster(), "radius")
    end
    return 700
end

function dvoreckov_www:GetCooldown( level )
	return self.BaseClass.GetCooldown( self, level )
end

function dvoreckov_www:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		radius = ability_manager:GetValueWex(self, self:GetCaster(), "radius")
	else
		radius = 700
	end
	local tree = self:GetSpecialValueFor( "radius_tree" )
	local duration = self:GetSpecialValueFor( "duration" )
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_dvoreckov_www",
			{
				duration = duration,
				x = point.x,
				y = point.y,
			}
		)
	end
	GridNav:DestroyTreesAroundPoint( point, tree, false )
	self:PlayEffects( point, radius )
end
function dvoreckov_www:PlayEffects( point, radius )
	local particle_cast = "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf"
	local sound_cast = "unitazik"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end

modifier_dvoreckov_www = class({})

function modifier_dvoreckov_www:IsHidden()
	return false
end
function modifier_dvoreckov_www:IsDebuff()
	return true
end
function modifier_dvoreckov_www:IsStunDebuff()
	return true
end
function modifier_dvoreckov_www:IsPurgable()
	return true
end

function modifier_dvoreckov_www:OnCreated( kv )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "damage")
	else
		self.damage = 300
	end
	if not IsServer() then return end
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function modifier_dvoreckov_www:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_dvoreckov_www:OnRemoved()
end

function modifier_dvoreckov_www:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	local damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(),
	}
	ApplyDamage(damageTable)
end

function modifier_dvoreckov_www:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_dvoreckov_www:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_dvoreckov_www:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_dvoreckov_www:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function modifier_dvoreckov_www:OnHorizontalMotionInterrupted()
	self:Destroy()
end

dvoreckov_qww = class({})
LinkLuaModifier( "modifier_dvoreckov_qww", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qww:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/drunk.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/razbil.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf", context )
end

function dvoreckov_qww:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local projectile_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,
	}
	ProjectileManager:CreateTrackingProjectile(info)
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		self:GetCastRange( target:GetOrigin(), target ),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		0,
		false
	)

	local target_2 = nil
	for _,enemy in pairs(enemies) do
		if enemy~=target and ( not enemy:HasModifier("modifier_dvoreckov_qww") ) then
			target_2 = enemy
			break
		end
	end
	if target_2 then
		info.Target = target_2
		ProjectileManager:CreateTrackingProjectile(info)
	end
	local sound_cast = "drunk"
	EmitSoundOn( sound_cast, caster )
end

function dvoreckov_qww:OnProjectileHit( target, location )
	if not target then return end
	if target:TriggerSpellAbsorb( self ) then return end
	local duration = self:GetSpecialValueFor( "duration" )
	local stun_duration = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		stun_duration = ability_manager:GetValueWex(self, self:GetCaster(), "stun_duration")
	else
		stun_duration = 2.0
	end
	target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_dvoreckov_qww",
		{ duration = duration }
	)
	target:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_generic_stunned_lua", 
		{duration = stun_duration}
	)
	local sound_cast = "razbil"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

modifier_dvoreckov_qww = class({})

function modifier_dvoreckov_qww:IsHidden()
	return false
end

function modifier_dvoreckov_qww:IsDebuff()
	return true
end

function modifier_dvoreckov_qww:IsStunDebuff()
	return false
end

function modifier_dvoreckov_qww:IsPurgable()
	return true
end

function modifier_dvoreckov_qww:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed_pct" )
	local damage = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		damage = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "burn_damage")
	else
		damage = 40 + (10 * self:GetCaster():GetLevel() / 3)
	end
	if not IsServer() then return end
	local interval = 0.5
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self,
	}
	self:StartIntervalThink( interval )
end

function modifier_dvoreckov_qww:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed_pct" )
	local damage = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		damage = ability_manager:GetValueQuas(self:GetAbility(), self:GetCaster(), "burn_damage")
	else
		damage = 40 + (10 * self:GetCaster():GetLevel() / 3)
	end
	
	if not IsServer() then return end
	self.damageTable.damage = damage
end

function modifier_dvoreckov_qww:OnRemoved()
end

function modifier_dvoreckov_qww:OnDestroy()
end

function modifier_dvoreckov_qww:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_dvoreckov_qww:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dvoreckov_qww:OnIntervalThink()
	ApplyDamage( self.damageTable )
	local sound_cast = "Hero_OgreMagi.Ignite.Damage"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_dvoreckov_qww:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf"
end

function modifier_dvoreckov_qww:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

dvoreckov_wwe = class({})
LinkLuaModifier( "modifier_dvoreckov_wwe", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )


function dvoreckov_wwe:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/rotik.vsndevts", context )
end

function dvoreckov_wwe:ProcsMagicStick()
	return false
end

function dvoreckov_wwe:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_dvoreckov_wwe", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_dvoreckov_wwe" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

modifier_dvoreckov_wwe = class({})

function modifier_dvoreckov_wwe:IsDebuff()
	return true
end

function modifier_dvoreckov_wwe:IsAura()
	if self:GetCaster() == self:GetParent() then
		return true
	end
	
	return false
end

function modifier_dvoreckov_wwe:GetModifierAura()
	return "modifier_dvoreckov_wwe"
end

function modifier_dvoreckov_wwe:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_dvoreckov_wwe:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_dvoreckov_wwe:GetAuraRadius()
	return self.rot_radius
end

function modifier_dvoreckov_wwe:OnCreated( kv )
	self.rot_radius = self:GetAbility():GetSpecialValueFor( "rot_radius" )
    if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.rot_slow = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "rot_slow")
		self.rot_damage = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "rot_damaged")
	else
		self.rot_slow = -21
		self.rot_damage = 40
	end
	self.manacost = self:GetAbility():GetSpecialValueFor( "mana_cost_per_secondd" )
	self.rot_tick = self:GetAbility():GetSpecialValueFor( "rot_tick" )
	self.manacost = self.manacost * self:GetParent():GetMaxMana() * 0.01
	self.parent = self:GetParent()
	self:Burn()
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			EmitSoundOn( "rotik", self:GetCaster() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.rot_radius, 1, self.rot_radius ) )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		else
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		end

		self:StartIntervalThink( self.rot_tick )
	end
end

function modifier_dvoreckov_wwe:OnDestroy()
	if IsServer() then
		StopSoundOn( "rotik", self:GetCaster() )
	end
end

function modifier_dvoreckov_wwe:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_dvoreckov_wwe:GetModifierMoveSpeedBonus_Percentage( params )
	if self:GetParent() == self:GetCaster() then
		return 0
	end

	return self.rot_slow
end

function modifier_dvoreckov_wwe:OnIntervalThink()
	if IsServer() then
		if self:GetParent() ~= self:GetCaster() then
		    return 0
	    end
		local flDamagePerTick = self.rot_tick * self.rot_damage
		local mana = self.parent:GetMana()
	    if mana < self.manacost or (self.parent:GetAbilityByIndex( 3 ) ~= self:GetAbility() and self.parent:GetAbilityByIndex( 4 ) ~= self:GetAbility()) then
		    if self:GetAbility():GetToggleState() then
		    	self:GetAbility():ToggleAbility()
		    end
		    return
	    end
	    self:Burn()
	end
end

function modifier_dvoreckov_wwe:Burn()
	self:GetCaster():SpendMana( self.manacost, self:GetAbility() )
	if self:GetParent() ~= self:GetCaster() then
		return 0
	end
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetOrigin(),
		nil,
		self.rot_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)
	for _,enemy in pairs(enemies) do
		self.dmg = self.rot_damage + enemy:GetMaxHealth() * 0.004
		self.damageTable = {
			attacker = self:GetParent(),
			damage = self.dmg,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end
end

dvoreckov_eee = class({})
LinkLuaModifier( "modifier_dvoreckov_eee", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dvoreckov_eee_debuff", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_eee:Precache( context )
	PrecacheResource("particle", "particles/econ/items/snapfire/snapfire_fall20_immortal/snapfire_fall20_immortal_lil_projectile.vpcf", context )
	PrecacheResource("particle", "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_snapfire.vsndevts", context)
	PrecacheResource( "soundfile", "soundevents/dimon.vsndevts", context )
end

function dvoreckov_eee:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetDuration()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_dvoreckov_eee",
		{ duration = duration }
	)
end

modifier_dvoreckov_eee = class({})

function modifier_dvoreckov_eee:IsHidden()
	return false
end
function modifier_dvoreckov_eee:IsDebuff()
	return false
end
function modifier_dvoreckov_eee:IsStunDebuff()
	return false
end
function modifier_dvoreckov_eee:IsPurgable()
	return true
end

function modifier_dvoreckov_eee:OnCreated( kv )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.attacks = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "buffed_attacks")
		self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
		self.range_bonus = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "attack_range_bonus")
	else
		self.attacks = 6
		self.damage = 105
		self.range_bonus = 275
	end
	self.hastalent = self:GetAbility():GetSpecialValueFor("hastalent")
	if self.hastalent == 1 then
		self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) * 0.6 + self.damage
	end
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	if not IsServer() then return end
	self:SetStackCount( self.attacks )
	self.records = {}
	self:PlayEffects()
	local sound_cast = "dimon"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_dvoreckov_eee:OnRefresh( kv )
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.attacks = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "buffed_attacks")
		self.damage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "damage")
		self.range_bonus = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "attack_range_bonus")
	else
		self.attacks = 6
		self.damage = 105
		self.range_bonus = 275
	end
	self.hastalent = self:GetAbility():GetSpecialValueFor("hastalent")
	if self.hastalent == 1 then
		self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) * self:GetAbility():GetSpecialValueFor("damage_percent") * 0.01 + self.damage
	end
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	if not IsServer() then return end
	self:SetStackCount( self.attacks )
	local sound_cast = "dimon"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_dvoreckov_eee:OnRemoved()
end

function modifier_dvoreckov_eee:OnDestroy()
	if not IsServer() then return end
	local sound_cast = "dimon"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_dvoreckov_eee:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_dvoreckov_eee:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=0 then return end
	self.records[params.record] = true
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
	EmitSoundOn( sound_cast, self:GetParent() )
	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end

function modifier_dvoreckov_eee:OnAttackLanded( params )
	if self.records[params.record] then
		params.target:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_dvoreckov_eee_debuff",
			{ duration = self.slow }
		)
	end
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Target"
	EmitSoundOn( sound_cast, params.target )
end

function modifier_dvoreckov_eee:OnAttackRecordDestroy( params )
	if self.records[params.record] then
		self.records[params.record] = nil
		if next(self.records)==nil and self:GetStackCount()<=0 then
			self:Destroy()
		end
	end
end

function modifier_dvoreckov_eee:GetModifierProjectileName()
	if self:GetStackCount()<=0 then return end
	return "particles/econ/items/snapfire/snapfire_fall20_immortal/snapfire_fall20_immortal_lil_projectile.vpcf"
end

function modifier_dvoreckov_eee:GetModifierOverrideAttackDamage()
	if self:GetStackCount()<=0 then return end
	return self.damage
end

function modifier_dvoreckov_eee:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function modifier_dvoreckov_eee:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return self.as_bonus
end

function modifier_dvoreckov_eee:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount()<=0 then return end
	return self.bat
end

function modifier_dvoreckov_eee:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

modifier_dvoreckov_eee_debuff = class({})

function modifier_dvoreckov_eee_debuff:IsHidden()
	return false
end

function modifier_dvoreckov_eee_debuff:IsDebuff()
	return true
end

function modifier_dvoreckov_eee_debuff:IsStunDebuff()
	return false
end

function modifier_dvoreckov_eee_debuff:IsPurgable()
	return true
end

function modifier_dvoreckov_eee_debuff:OnCreated( kv )
	if not IsServer() then return end
	if self:GetAbility() and self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.slow = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "attack_speed_slow_per_stack")
	else
		self.slow = 3
	end
	self:SetStackCount( 1 )
end

function modifier_dvoreckov_eee_debuff:OnRefresh( kv )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_dvoreckov_eee_debuff:OnRemoved()
end

function modifier_dvoreckov_eee_debuff:OnDestroy()
end

function modifier_dvoreckov_eee_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_dvoreckov_eee_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self:GetStackCount() * 3
end
function modifier_dvoreckov_eee_debuff:GetModifierMagicalResistanceBonus()
	return -self:GetStackCount() * 3
end

function modifier_dvoreckov_eee_debuff:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_dvoreckov_eee_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

dvoreckov_qee = class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_silenced_lua", "modifier_generic_silenced_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_muted_lua", "modifier_generic_muted_lua.lua", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qee:Precache(context)
	PrecacheResource("soundfile", "soundevents/ebalo.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silence_wave.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silence_impact_dust.vpcf", context)
end

function dvoreckov_qee:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_dvoreckov_7") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
    end
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function dvoreckov_qee:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition() + Vector(2, 2, 0)
	local speed = self:GetSpecialValueFor( "wave_speed" )
	local width = self:GetSpecialValueFor( "wave_width" )
	local projectile_name = "particles/econ/items/drow/drow_arcana/drow_arcana_silence_wave.vpcf"
	local projectile_distance = self:GetCastRange( point, nil )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()
	local xx = projectile_direction.x
	local yy = projectile_direction.y
	tartar = {}
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info2 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local zam = projectile_direction.x
	projectile_direction.x = -projectile_direction.y
	projectile_direction.y = zam
	local info3 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	projectile_direction.x = -projectile_direction.x
	projectile_direction.y = -projectile_direction.y
	local info4 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	projectile_direction.x = xx * (2 ^ 0.5) / 2 - yy * (2 ^ 0.5) / 2
	projectile_direction.y = xx * (2 ^ 0.5) / 2 + yy * (2 ^ 0.5) / 2

	local info5 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info6 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local zamzam = projectile_direction.x
	projectile_direction.x = -projectile_direction.y
	projectile_direction.y = zamzam
	local info7 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	local info8 = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = -projectile_direction  * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
			local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_dvoreckov_7")
			if Talented:GetLevel() == 1 then
        		ProjectileManager:CreateLinearProjectile(info2)
				ProjectileManager:CreateLinearProjectile(info3)
				ProjectileManager:CreateLinearProjectile(info4)
				ProjectileManager:CreateLinearProjectile(info5)
				ProjectileManager:CreateLinearProjectile(info6)
				ProjectileManager:CreateLinearProjectile(info7)
				ProjectileManager:CreateLinearProjectile(info8)
    		end
    	end
	local sound_cast = "ebalo"
	EmitSoundOn( sound_cast, caster )
end
tartar = {}
function dvoreckov_qee:OnProjectileHit_ExtraData( target, location, data )
	for _,v in ipairs(tartar) do  
		if v == target then return end
	end
	if not target then return end
	local silence = 0
	local damage = 0
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		silence = ability_manager:GetValueQuas(self, self:GetCaster(), "silence_duration")
		damage = ability_manager:GetValueExort(self, self:GetCaster(), "damage")
	else
		silence = 3.0
		damage = 300
	end
	local duration = self:GetSpecialValueFor( "knockback_duration" )
	local max_dist = self:GetSpecialValueFor( "knockback_distance_max" )
	local vec = target:GetOrigin()-Vector(data.x,data.y,0)
	vec.z = 0
	local distance = vec:Length2D()
	distance = (1-distance/self:GetCastRange( Vector(0,0,0), nil ))*max_dist
	if max_dist<0 then distance = 0 end
	vec = vec:Normalized()
	target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_generic_knockback_lua",
		{
			duration = duration,
			distance = distance,
			direction_x = vec.x,
			direction_y = vec.y,
		}
	)
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		local Talented = self:GetCaster():FindAbilityByName("special_bonus_unique_dvoreckov_6")
		if Talented:GetLevel() == 1 then
        	target:AddNewModifier(
				self:GetCaster(),
				self,
				"modifier_generic_muted_lua",
				{ duration = silence }
			)
    	end
	end
	target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_generic_silenced_lua",
		{ duration = silence }
	)
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	table.insert(tartar, target)
	self:PlayEffects( target )
end

function dvoreckov_qee:PlayEffects( target )
	local particle_cast = "particles/econ/items/drow/drow_arcana/drow_arcana_silence_impact_dust.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

dvoreckov_wee = dvoreckov_wee or class({})
LinkLuaModifier( "modifier_dvoreckov_wee", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_wee:Precache(context)
	PrecacheResource("soundfile", "soundevents/pubg.vsndevts", context )
	PrecacheResource("particle", "particles/units/heroes/hero_undying/undying_fg_aura.vpcf", context)
end

function dvoreckov_wee:OnSpellStart()
	self:GetCaster():EmitSound("pubg")
	self:GetCaster():StartGesture(ACT_DOTA_SPAWN)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dvoreckov_wee", {duration = self:GetSpecialValueFor("duration")})
end

modifier_dvoreckov_wee = modifier_dvoreckov_wee or class({})

function modifier_dvoreckov_wee:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

function modifier_dvoreckov_wee:OnCreated()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
		self.str_percentage = ability_manager:GetValueExort(self:GetAbility(), self:GetCaster(), "str_percentage")
		self.duration       = ability_manager:GetValueWex(self:GetAbility(), self:GetCaster(), "duration")
	else
		self.str_percentage = 70
		self.duration       = 15
	end
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end

function modifier_dvoreckov_wee:OnIntervalThink()
	self.strength   = 0
	self.strength   = self:GetParent():GetStrength() * self.str_percentage * 0.01
	self:GetParent():CalculateStatBonus(true)
end

function modifier_dvoreckov_wee:OnDestroy()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_Undying.FleshGolem.End")
end

function modifier_dvoreckov_wee:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_dvoreckov_wee:OnTooltip()
	return self.str_percentage
end

function modifier_dvoreckov_wee:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_dvoreckov_wee:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_dvoreckov_wee:OnDeath(keys)
	if keys.unit == self:GetParent() and (not self:GetAbility() or not self:GetAbility():IsStolen()) then
		self:Destroy()
	end
end

dvoreckov_qwe = class({})
LinkLuaModifier( "modifier_dvoreckov_qwe", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dvoreckov_qwe_debuff", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dvoreckov_qwe_nonchanneled", "heroes/dvoreckov/dvoreckov_abilities", LUA_MODIFIER_MOTION_NONE )

function dvoreckov_qwe:Precache(context)
	PrecacheResource( "soundfile", "soundevents/vpis.vsndevts", context )
	PrecacheResource( "particle_folder", "particles/booom", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", context )
end

function dvoreckov_qwe:GetChannelAnimation()
    if self:GetCaster():HasScepter() then
        return ACT_DOTA_IDLE
    end
    return ACT_DOTA_CHANNEL_ABILITY_4
end

function dvoreckov_qwe:GetChannelTime()
    if self:GetCaster():HasScepter() then
        return 0
    end
    return self:GetSpecialValueFor("channel_duration")
end
function dvoreckov_qwe:GetCastPoint()
	return self:GetSpecialValueFor( "total_cast_time_tooltip" )
end

function dvoreckov_qwe:OnAbilityPhaseStart()
    if IsServer() then
        self.channel_duration = self:GetSpecialValueFor("channel_duration")
        self.immune_duration = self:GetCaster():HasScepter() and self.channel_duration or (self.channel_duration + self:GetCastPoint())
        

        self.nPreviewFX = ParticleManager:CreateParticle("particles/booom/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true)
        ParticleManager:SetParticleControl(self.nPreviewFX, 1, Vector(250, 250, 250))
        ParticleManager:SetParticleControl(self.nPreviewFX, 15, Vector(176, 224, 230))
    end
    return true
end

function dvoreckov_qwe:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle(self.nPreviewFX, false)
        EmitSoundOn("vpis", self:GetCaster())
        self.lastExplosionTime = GameRules:GetGameTime()
        self.effect_radius = self:GetSpecialValueFor("effect_radius")
        self.interval = self:GetSpecialValueFor("interval")
        if self:GetCaster():HasScepter() then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dvoreckov_qwe_nonchanneled", {
                duration = self:GetSpecialValueFor("channel_duration")
            })
        end
    end
end

function dvoreckov_qwe:OnChannelThink(flInterval)
    if IsServer() and not self:GetCaster():HasScepter() then
        self:HandleExplosionEffects()
    end
end
function dvoreckov_qwe:OnChannelFinish()
	StopSoundOn("vpis", self:GetCaster())
end
function dvoreckov_qwe:HandleExplosionEffects()
    local currentTime = GameRules:GetGameTime()
    if currentTime - self.lastExplosionTime >= self:GetSpecialValueFor("interval") then
        local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), 
            self:GetCaster():GetAbsOrigin(), 
            nil, 
            300, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
            FIND_ANY_ORDER, 
            false)
        
        for _, unit in pairs(targets) do
            local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
            local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
            local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 250)
            local knockbackProperties = {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = 0.2,
                knockback_duration = 0.2,
                knockback_distance = 100,
                knockback_height = 0
            }
            if not unit:HasModifier("modifier_knockback") and not unit:IsMagicImmune() and not unit:IsDebuffImmune() then
                unit:AddNewModifier(unit, nil, "modifier_knockback", knockbackProperties)
                unit:AddNewModifier(self:GetCaster(), nil, "modifier_dvoreckov_qwe_debuff", { duration = 1 })
                ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_CUSTOMORIGIN, nil)
            end
        end
        local vPos = self:GetCaster():GetOrigin() + RandomVector(RandomInt(50, self.effect_radius))
        CreateModifierThinker(self:GetCaster(), self, "modifier_dvoreckov_qwe", {}, vPos, self:GetCaster():GetTeamNumber(), false)
        self.lastExplosionTime = currentTime
    end
end

modifier_dvoreckov_qwe_nonchanneled = class({})
function modifier_dvoreckov_qwe_nonchanneled:IsHidden() return false end
function modifier_dvoreckov_qwe_nonchanneled:IsPurgable() return false end

function modifier_dvoreckov_qwe_nonchanneled:GetTexture()
    return "vpiska"
end
function modifier_dvoreckov_qwe_nonchanneled:OnCreated(params)
    if IsServer() then
        self.ability = self:GetAbility()
        self.interval = self.ability:GetSpecialValueFor("interval")
        self.effect_radius = self.ability:GetSpecialValueFor("effect_radius")
        self:StartIntervalThink(self.interval)
        self.lastExplosionTime = GameRules:GetGameTime()
    end
end
function modifier_dvoreckov_qwe_nonchanneled:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }
end
function modifier_dvoreckov_qwe_nonchanneled:GetModifierMoveSpeed_Absolute()
    return 300
end

function modifier_dvoreckov_qwe_nonchanneled:OnIntervalThink()
    if IsServer() then
		if self:GetCaster():IsStunned() or self:GetCaster():IsSilenced() then
			self:Destroy()
		end
        self.ability:HandleExplosionEffects()
    end
end

function modifier_dvoreckov_qwe_nonchanneled:OnDestroy()
    if IsServer() then
        self:GetParent():StopSound("vpis")
    end
end

function modifier_dvoreckov_qwe_nonchanneled:IsHidden() return true end
function modifier_dvoreckov_qwe_nonchanneled:IsPurgable() return false end

modifier_dvoreckov_qwe = class({})

function modifier_dvoreckov_qwe:OnCreated( kv )
	if IsServer() then
		self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    	local ability_level = 0
    	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
			ability_level = self:GetCaster():FindAbilityByName("dvoreckov_w"):GetLevel() + self:GetCaster():FindAbilityByName("dvoreckov_q"):GetLevel() + self:GetCaster():FindAbilityByName("dvoreckov_e"):GetLevel() - 1
		else
			ability_level = self:GetCaster():GetLevel() / 3
		end
		self.blast_damage = self:GetAbility():GetLevelSpecialValueFor("blast_damage", ability_level)
		
		self:StartIntervalThink( self.delay )

		local nFXIndex = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.delay, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function modifier_dvoreckov_qwe:OnIntervalThink()
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( self.radius, self.radius, self.radius ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn( "Hero_Techies.Suicide", self:GetParent() )
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false then
				local damageInfo =
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.blast_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self:GetAbility(),
				}
				
				ApplyDamage( damageInfo )
				local knockbackProperties =
				{
					center_x = 0,
					center_y = 0,
					center_z = 0,
					duration = 0.2,
					knockback_duration = 0.2,
					knockback_distance = 200,
					knockback_height = 200
				}
				if not enemy:HasModifier("modifier_knockback") and not enemy:IsDebuffImmune() and not enemy:IsMagicImmune() then
					enemy:AddNewModifier( enemy, nil, "modifier_knockback", knockbackProperties )
				end
			end
		end

		UTIL_Remove( self:GetParent() )
	end
end


modifier_dvoreckov_qwe_debuff = class({})

function modifier_dvoreckov_qwe_debuff:IsHidden()
	return false
end

function modifier_dvoreckov_qwe_debuff:IsPurgable()
	return true
end

function modifier_dvoreckov_qwe_debuff:CheckState()
return {[MODIFIER_STATE_DISARMED] = true,}
end