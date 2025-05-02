LinkLuaModifier("modifier_chef_w_active_regeneration", "heroes/lev/chef_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chef_w", "heroes/lev/chef_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chef_w_2", "heroes/lev/chef_w", LUA_MODIFIER_MOTION_NONE)

chef_w = class ({})

function chef_w:Precache(context)
    PrecacheResource("particle", "particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl3.vpcf", context)
    PrecacheResource( "soundfile", "soundevents/chef_w.vsndevts", context )
end

function chef_w:GetIntrinsicModifierName()
    return "modifier_chef_w"
end

function chef_w:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function chef_w:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function chef_w:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function chef_w:OnAbilityPhaseStart()
    EmitSoundOn("chef_w", self:GetCaster())
    return true
end

function chef_w:OnAbilityPhaseInterrupted()
    StopSoundOn("chef_w", self:GetCaster())
end

function chef_w:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local caster_team = caster:GetTeamNumber()
	local radius = self:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius( caster_team, caster_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, unit in ipairs(targets) do
		unit:AddNewModifier(caster, self, "modifier_chef_w_active_regeneration", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_chef_w_active_regeneration = class ({})

function modifier_chef_w_active_regeneration:IsPurgable() return false end
function modifier_chef_w_active_regeneration:IsHidden() return true end

function modifier_chef_w_active_regeneration:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
	}
	return funcs
end

function modifier_chef_w_active_regeneration:GetModifierTotalPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen_active")
end

function modifier_chef_w_active_regeneration:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle("particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(self.particle, false, false, -1, false, false)
end

modifier_chef_w = class ({})

function modifier_chef_w:IsAura() return true end
function modifier_chef_w:IsAuraActiveOnDeath() return false end
function modifier_chef_w:IsBuff() return true end
function modifier_chef_w:IsHidden() return true end
function modifier_chef_w:IsPermanent() return true end
function modifier_chef_w:IsPurgable() return false end

function modifier_chef_w:GetAuraRadius()
    return 20000
end

function modifier_chef_w:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_chef_w:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_chef_w:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_chef_w:GetModifierAura()
    return "modifier_chef_w_2"
end

modifier_chef_w_2 = class ({})

function modifier_chef_w_2:IsHidden() return false end
function modifier_chef_w_2:IsPurgable() return false end

function modifier_chef_w_2:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_chef_w_2:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen_passive")
end

function modifier_chef_w_2:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_damage")
end