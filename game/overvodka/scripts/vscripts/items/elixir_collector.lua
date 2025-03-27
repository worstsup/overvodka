LinkLuaModifier("modifier_elixir_collector_buff", "items/elixir_collector", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elixir_collector_debuff", "items/elixir_collector", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elixir_collector_buff_hero", "items/elixir_collector", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_elixir_collector", "items/elixir_collector", LUA_MODIFIER_MOTION_NONE)

item_elixir_collector = class({})

function item_elixir_collector:GetIntrinsicModifierName()
    return "modifier_item_elixir_collector"
end

function item_elixir_collector:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local point = self:GetCursorPosition()
	local collector = CreateUnitByName("npc_dota_elixir_collector", point, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam())
	collector:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	collector:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	collector:AddNewModifier(self:GetCaster(), self, "modifier_elixir_collector_buff", {duration = duration})
    ResolveNPCPositions( collector:GetAbsOrigin(), 150 )
	self:GetCaster():EmitSound("elixir_collector_place")
end

modifier_item_elixir_collector = class({})

function modifier_item_elixir_collector:IsHidden() return true end
function modifier_item_elixir_collector:IsPurgable() return false end
function modifier_item_elixir_collector:IsPurgeException() return false end

function modifier_item_elixir_collector:OnCreated()
    if not IsServer() then return end
    self.spell_lifesteal = self:GetAbility():GetSpecialValueFor("spell_lifesteal")
end

function modifier_item_elixir_collector:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_item_elixir_collector:GetModifierCastRangeBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('cast_range')
    end
end

function modifier_item_elixir_collector:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mp')
    end
end

function modifier_item_elixir_collector:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('hp')
    end
end

function modifier_item_elixir_collector:OnTakeDamage(params)
    if not IsServer() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetParent() == params.unit then return end
    if params.unit:IsBuilding() then return end
    if params.inflictor ~= nil and not self:GetParent():IsIllusion() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then 
        local bonus_percentage = 0
        for _, mod in pairs(self:GetParent():FindAllModifiers()) do
            if mod.GetModifierSpellLifestealRegenAmplify_Percentage and mod:GetModifierSpellLifestealRegenAmplify_Percentage() then
                bonus_percentage = bonus_percentage + mod:GetModifierSpellLifestealRegenAmplify_Percentage()
            end
        end
        local heal = self.spell_lifesteal / 100 * params.damage
        heal = heal * (bonus_percentage / 100 + 1)
        self:GetParent():Heal(heal, params.inflictor)
        if self:GetParent():HasModifier("modifier_elixir_collector_buff_hero") then
            self:GetParent():Heal(heal * 3, params.inflictor)
        end
        local octarine = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker )
        ParticleManager:ReleaseParticleIndex( octarine )
    end
end

function modifier_item_elixir_collector:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('mana_regen')
    end
end

modifier_elixir_collector_buff = class({})

function modifier_elixir_collector_buff:IsPurgable() return false end
function modifier_elixir_collector_buff:IsHidden() return true end

function modifier_elixir_collector_buff:OnCreated()
	if not IsServer() then return end
    self.destroy_attacks            = self:GetAbility():GetSpecialValueFor("attack_destroy")
    self:GetParent():SetBaseMaxHealth(10)
    self:GetParent():SetHealth(10)
    self.hero_attack_multiplier     = 2
    self.health_increments          = self:GetParent():GetMaxHealth() / self.destroy_attacks
    self:StartIntervalThink(FrameTime())

    local particle = ParticleManager:CreateParticle("particles/elixir_collector_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_elixir_collector_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
	}
	return decFuncs
end

function modifier_elixir_collector_buff:GetDisableHealing()
    return 1
end

function modifier_elixir_collector_buff:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_elixir_collector_buff:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_elixir_collector_buff:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_elixir_collector_buff:GetOverrideAnimation()
    return ACT_DOTA_IDLE
end

function modifier_elixir_collector_buff:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_elixir_collector_buff:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_elixir_collector_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - (self.health_increments * self.hero_attack_multiplier)
        end
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_elixir_collector_buff:OnIntervalThink()
	if not IsServer() then return end
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local caster_origin = self:GetCaster():GetAbsOrigin()
	local parent_origin = self:GetParent():GetAbsOrigin()

	if (caster_origin - parent_origin):Length2D() > (radius + 100) then
		self:GetCaster():RemoveModifierByName("modifier_elixir_collector_buff_hero")
		return
	end
	local flag = 0
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, flag, 0, false)

	if #targets <= 0 then
		self:GetCaster():RemoveModifierByName("modifier_elixir_collector_buff_hero")
		return
	end

    for _,target in pairs(targets) do
        if not target:IsIllusion() then
    	    target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_elixir_collector_debuff", {})
        end
    end

    self:GetCaster():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_elixir_collector_buff_hero", {})
end

modifier_elixir_collector_debuff = class({})

function modifier_elixir_collector_debuff:IsPurgable() return true end

function modifier_elixir_collector_debuff:OnCreated()
	if not IsServer() then return end

	self.cooldown = 0
    self.sound = 0
	self:GetParent():EmitSound("elixir_collector")

	local particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self:StartIntervalThink(FrameTime())
end
function modifier_elixir_collector_debuff:GetTexture()
    return "elixir_collector"
end
function modifier_elixir_collector_debuff:OnIntervalThink()
	if not IsServer() then return end

	local radius = self:GetAbility():GetSpecialValueFor("radius") + 100

	if self:GetCaster():IsNull() then
		self:Destroy()
		return
	end

	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end

	if (self:GetCaster():GetAbsOrigin() - self:GetCaster():GetOwner():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end

	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end

	self.cooldown = self.cooldown + FrameTime()

	if self.cooldown >= 0.25 then
        self.sound = self.sound + 1
		local damage_perc = self:GetAbility():GetSpecialValueFor("damage")
		local damage = self:GetParent():GetMaxMana() / 100 * damage_perc
        self:GetParent():Script_ReduceMana(damage, self:GetAbility())
		self:GetCaster():GetOwner():GiveMana(damage)
		self.cooldown = 0
        if self.sound % 4 == 0 then
            self:GetParent():EmitSound("elixir_collector")
        end
	end
end

modifier_elixir_collector_buff_hero = class({})

function modifier_elixir_collector_buff_hero:IsPurgable() return true end

function modifier_elixir_collector_buff_hero:OnCreated()
	if not IsServer() then return end

	local particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_shard.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)

	self:GetParent():EmitSound("elixir_collector")

	
	self:StartIntervalThink(FrameTime())
end

function modifier_elixir_collector_buff_hero:OnDestroy()
	if not IsServer() then return end
end

function modifier_elixir_collector_buff_hero:OnIntervalThink()
	if not IsServer() then return end

	local radius = self:GetAbility():GetSpecialValueFor("radius") + 100

	if self:GetCaster():IsNull() then
		self:Destroy()
		return
	end

	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end

	if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > radius then
		self:Destroy()
		return
	end
end

function modifier_elixir_collector_buff_hero:GetTexture()
    return "elixir_collector"
end