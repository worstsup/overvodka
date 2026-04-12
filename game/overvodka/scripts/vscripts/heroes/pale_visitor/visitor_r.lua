LinkLuaModifier("modifier_visitor_r",           "heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_r_cooldown",  "heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_r_aura",      "heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_r_night_buff","heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_burn",        "heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_visitor_r_permanent", "heroes/pale_visitor/visitor_r", LUA_MODIFIER_MOTION_NONE)

visitor_r = class({})

function visitor_r:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/visitor_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/econ/items/phoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf", ctx)
	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf", ctx)
	PrecacheResource("particle", "particles/econ/items/batrider/crownfall_immortal/batrider_crownfall_immortal_stickynapalm_debuff.vpcf", ctx)
	PrecacheResource("particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_debuff.vpcf", ctx)
end

function visitor_r:GetIntrinsicModifierName()
    return "modifier_visitor_r_permanent"
end

function visitor_r:GetManaCost(level)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_perc_per_sec") * 0.01
end

function visitor_r:OnAbilityUpgrade( hAbility )
    if not IsServer() then return end
    local result = self.BaseClass.OnAbilityUpgrade( self, hAbility )
    if hAbility == self then
        local ability = self:GetCaster():FindAbilityByName("visitor_d")
        if ability then
            ability:SetLevel(ability:GetLevel() + 1)
        end
    end
    return result
end

function visitor_r:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local toggle = self:GetToggleState()

	if toggle then
		self.modifier = caster:AddNewModifier(caster, self, "modifier_visitor_r", {})
		self:EndCooldown()
	else
		if self.modifier and not self.modifier:IsNull() then
			self.modifier:Destroy()
		end
		self.modifier = nil
		caster:AddNewModifier(caster, self, "modifier_visitor_r_cooldown", {duration = self:GetEffectiveCooldown(self:GetLevel())}) -- needs checking
		self:UseResources(false, false, false, true)
	end
end

modifier_visitor_r_cooldown = class({})

function modifier_visitor_r_cooldown:IsHidden() return true end
function modifier_visitor_r_cooldown:IsPurgable() return false end
function modifier_visitor_r_cooldown:RemoveOnDeath() return false end

modifier_visitor_r = class({})

function modifier_visitor_r:IsHidden() return true end
function modifier_visitor_r:IsPurgable() return false end
function modifier_visitor_r:RemoveOnDeath() return true end

function modifier_visitor_r:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
    self.base_dmg = self.ability:GetSpecialValueFor("damage_base")
    self.hp_dmg_pct = self.ability:GetSpecialValueFor("hp_damage_pct")

    if not IsServer() then return end
    local fountainEntities = Entities:FindAllByClassname("ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == self.parent:GetTeamNumber() then
            self.fountain = fountainEnt
            self.fountain:AddNewModifier(self.parent, self.ability, "modifier_generic_disarmed_lua", {duration = 999})
			break
		end
    end

    self.aura = self.parent:AddNewModifier(self.parent, self.ability, "modifier_visitor_r_aura", {})
	self.is_day = GameRules:IsDaytime()
	if self.is_day then
		EmitGlobalSound("visitor_day")
	else
		EmitGlobalSound("visitor_night")
	end
	self.first = true
	self:StartIntervalThink(1.0)
	self:OnIntervalThink()
end

function modifier_visitor_r:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	if not caster or caster:IsNull() then
		self:Destroy()
		return
	end
	if not caster:IsAlive() then
		self:Destroy()
		return
	end
	local mana_cost = caster:GetMaxMana() * self.ability:GetSpecialValueFor("mana_perc_per_sec") * 0.01
	if caster:GetMana() < mana_cost then
		self.ability:ToggleAbility()
		return
	end
	if not self.first then
		caster:Script_ReduceMana(mana_cost, self.ability)
	end
	local is_day = GameRules:IsDaytime()
	if is_day ~= self.is_day then
		self.is_day = is_day
	end

	if is_day then
		local enable_bonus = self.ability:GetSpecialValueFor("kill_bonuses_enable")
		local burn_enemy_hp   = self.ability:GetSpecialValueFor("bonus_hp_regen_enemy")
		local burn_enemy_mana = self.ability:GetSpecialValueFor("bonus_mana_regen_enemy")
		local burn_ally_hp    = self.ability:GetSpecialValueFor("penalty_hp_regen_ally")
		local burn_ally_mana  = self.ability:GetSpecialValueFor("penalty_mana_regen_ally")

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),
			Vector(0,0,0),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_ANY_ORDER,
			false
		)
		for _,u in pairs(units) do
            if u and not u:IsNull() then
                if u:IsAlive() then
					if self.first then
						local p = ParticleManager:CreateParticle("particles/econ/items/phoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, u)
						ParticleManager:SetParticleControl(p, 0, u:GetAbsOrigin())
						ParticleManager:SetParticleControl(p, 3, u:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(p)
					end
					u:AddNewModifier(caster, self.ability, "modifier_visitor_burn", {duration = 1.1})
                    local dmg = self.base_dmg + u:GetMaxHealth() * self.hp_dmg_pct * 0.01
                    ApplyDamage({
                        victim = u,
                        attacker = caster,
                        damage = dmg,
                        damage_type = DAMAGE_TYPE_PURE,
                        damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                        ability = self.ability
                    })
                end
            end
		end
	end
	if self.first then
		self.first = false
	end
end

function modifier_visitor_r:OnDestroy()
	if not IsServer() then return end
	StopGlobalSound("visitor_day")
	StopGlobalSound("visitor_night")
	if self.aura and not self.aura:IsNull() then
		self.aura:Destroy()
        self.aura = nil
	end
    Timers:CreateTimer(self.ability:GetEffectiveCooldown(self.ability:GetLevel()), function()
        if self.fountain then
            self.fountain:RemoveModifierByName("modifier_generic_disarmed_lua")
        end
    end)
end


modifier_visitor_r_permanent = class({})

function modifier_visitor_r_permanent:IsPurgable()    return false end
function modifier_visitor_r_permanent:RemoveOnDeath() return false end

function modifier_visitor_r_permanent:IsHidden()
    local ability = self:GetAbility()
    if not ability then return true end
    return ability:GetSpecialValueFor("kill_bonuses_enable") == 0
end

function modifier_visitor_r_permanent:OnCreated()
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()

    self.hp_regen_bonus   = 0
    self.mana_regen_bonus = 0

    if not IsServer() then return end

    self:SetHasCustomTransmitterData(true)
end

function modifier_visitor_r_permanent:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.hp = self.hp_regen_bonus or 0
    self._txData.mana = self.mana_regen_bonus or 0
    return self._txData
end

function modifier_visitor_r_permanent:HandleCustomTransmitterData(data)
    self.hp_regen_bonus = data.hp or 0
    self.mana_regen_bonus = data.mana or 0
end

function modifier_visitor_r_permanent:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_visitor_r_permanent:GetModifierConstantHealthRegen()
    return self.hp_regen_bonus or 0
end

function modifier_visitor_r_permanent:GetModifierConstantManaRegen()
    return self.mana_regen_bonus or 0
end

function modifier_visitor_r_permanent:OnDeath(params)
    if not IsServer() then return end
    if not self.ability then return end
    if self.ability:GetSpecialValueFor("kill_bonuses_enable") <= 0 then return end

    if not params.unit or params.unit:IsNull() then return end
    if not params.unit:IsRealHero() or params.unit:IsIllusion() then return end

    if not self.parent or self.parent:IsNull() then return end
    if params.attacker ~= self.parent then return end
    if params.inflictor ~= self.ability then return end

    if params.unit == self.parent then
        StopGlobalSound("visitor_day")
	    StopGlobalSound("visitor_night")
    end
    --print(params.unit:GetUnitName(), params.attacker:GetUnitName(), params.inflictor:GetAbilityName())

    if params.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
        self.hp_regen_bonus   = self.hp_regen_bonus   + self.ability:GetSpecialValueFor("bonus_hp_regen_enemy")
        self.mana_regen_bonus = self.mana_regen_bonus + self.ability:GetSpecialValueFor("bonus_mana_regen_enemy")
    else
        self.hp_regen_bonus   = self.hp_regen_bonus   - self.ability:GetSpecialValueFor("penalty_hp_regen_ally")
        self.mana_regen_bonus = self.mana_regen_bonus - self.ability:GetSpecialValueFor("penalty_mana_regen_ally")
    end

    self:SetStackCount(math.floor(self.hp_regen_bonus or 0))
    self:SendBuffRefreshToClients()
end



modifier_visitor_burn = class({})

function modifier_visitor_burn:IsPurgable() return false end
function modifier_visitor_burn:IsHidden() return true end

function modifier_visitor_burn:OnCreated()
	if not IsServer() then return end
	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(p, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(p, 1, self:GetCaster():GetAbsOrigin())
	self:AddParticle(p, false, false, -1, false, false)
end

modifier_visitor_r_aura = class({})

function modifier_visitor_r_aura:IsHidden() return true end
function modifier_visitor_r_aura:IsPurgable() return false end
function modifier_visitor_r_aura:IsAura() return true end

function modifier_visitor_r_aura:GetAuraRadius()
    if not IsServer() then return 0 end
    if GameRules:IsDaytime() then
        return 0
    end
    return 99999
end

function modifier_visitor_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_visitor_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_visitor_r_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_visitor_r_aura:GetModifierAura()
    return "modifier_visitor_r_night_buff"
end

function modifier_visitor_r_aura:GetAuraEntityReject( unit )
	if not IsServer() then return false end
	if GameRules:IsDaytime() then
		return true
	end
	return false
end

modifier_visitor_r_night_buff = class({})

function modifier_visitor_r_night_buff:IsPurgable() return false end

function modifier_visitor_r_night_buff:OnCreated()
    self.ability = self:GetAbility()
    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()

    if not self.ability then return end

    self.vision_bonus   = self.ability:GetSpecialValueFor("vision_bonus")
    self.hp_regen_bonus = self.ability:GetSpecialValueFor("hp_regen_bonus")
    self.ms_bonus       = self.ability:GetSpecialValueFor("ms_bonus")

    self.mult = 1
    if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
        self.mult = -1
    end
end

function modifier_visitor_r_night_buff:OnRefresh()
    self:OnCreated()
end

function modifier_visitor_r_night_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_visitor_r_night_buff:GetBonusNightVision()
    return self.vision_bonus * self.mult
end

function modifier_visitor_r_night_buff:GetModifierHPRegenAmplify_Percentage()
    return self.hp_regen_bonus * self.mult
end

function modifier_visitor_r_night_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_bonus * self.mult
end

function modifier_visitor_r_night_buff:GetEffectName()
	if self.mult < 0 then
		return "particles/econ/items/batrider/crownfall_immortal/batrider_crownfall_immortal_stickynapalm_debuff.vpcf"
	end
    return "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_debuff.vpcf"
end

function modifier_visitor_r_night_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end