LinkLuaModifier("modifier_item_byebye_boots", "item_byebye_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_byebye_boots_phase", "item_byebye_boots", LUA_MODIFIER_MOTION_NONE)

item_byebye_boots = class({})
function item_byebye_boots:OnAbilityPhaseStart()
    EmitSoundOn("byebye_start", self:GetCaster())
    ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_byebye_boots_phase", {duration = 3})
    return true
end
function item_byebye_boots:OnAbilityPhaseInterrupted()
    StopSoundOn("byebye_start", self:GetCaster())
    self:GetCaster():RemoveModifierByName("modifier_item_byebye_boots_phase")
end
function item_byebye_boots:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    ProjectileManager:ProjectileDodge(caster)
	
	ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn( "byebye", caster )
	local team = caster:GetTeam()
	local target_point = 0
	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
			target_point = fountainEnt:GetAbsOrigin()
			break
		end
    end
	local origin_point = caster:GetAbsOrigin()
	local difference_vector = target_point - origin_point
	
	caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(caster, target_point, false)
	
	ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
end

function item_byebye_boots:GetIntrinsicModifierName()
    return "modifier_item_byebye_boots"
end

modifier_item_byebye_boots = class({})

function modifier_item_byebye_boots:IsHidden() return true end
function modifier_item_byebye_boots:IsPurgable() return false end
function modifier_item_byebye_boots:IsPurgeException() return false end
function modifier_item_byebye_boots:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_byebye_boots:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
    }
    return funcs
end

function modifier_item_byebye_boots:GetModifierMoveSpeedBonus_Special_Boots()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    end
end

modifier_item_byebye_boots_phase = class({})
function modifier_item_byebye_boots_phase:IsHidden() return true end
function modifier_item_byebye_boots_phase:IsPurgable() return false end

function modifier_item_byebye_boots_phase:OnCreated()
    if not IsServer() then return end
end