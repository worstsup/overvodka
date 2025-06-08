LinkLuaModifier( "modifier_t2x2_w_buff", "heroes/t2x2/t2x2_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_t2x2_w_debuff", "heroes/t2x2/t2x2_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_t2x2_w", "heroes/t2x2/t2x2_w", LUA_MODIFIER_MOTION_NONE )

t2x2_w = class({})

function t2x2_w:Precache( context )
    PrecacheResource( "soundfile", "soundevents/t2x2_sounds.vsndevts", context)
    PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_aoe_heal.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_slow_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/t2x2_w_bad.vpcf", context )
end

function t2x2_w:GetIntrinsicModifierName()
	return "modifier_t2x2_w"
end

function t2x2_w:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    local team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local effect = "modifier_t2x2_w_buff"
    local sound = "t2x2_w_buff_"..RandomInt(1,2)
    local particle = "particles/units/heroes/hero_huskar/huskar_aoe_heal.vpcf"
    if self:GetAltCastState() then
        team = DOTA_UNIT_TARGET_TEAM_ENEMY
        effect = "modifier_t2x2_w_debuff"
        sound = "t2x2_w_debuff"
        particle = "particles/t2x2_w_bad.vpcf"
    end
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, team, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in ipairs(units) do
        unit:AddNewModifier(caster, self, effect, { duration = duration })
    end
    local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius + 50, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
    EmitSoundOn(sound, caster)
end

modifier_t2x2_w = class({})
function modifier_t2x2_w:IsHidden() return true end
function modifier_t2x2_w:IsPurgable() return false end
function modifier_t2x2_w:RemoveOnDeath() return false end
function modifier_t2x2_w:OnCreated()
	if not IsServer() then return end
end
function modifier_t2x2_w:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end

function modifier_t2x2_w:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if params.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_ALT then
    	FireGameEvent("event_toggle_alt_cast", 
    	{
            ent_index = self:GetAbility():GetEntityIndex(),
            is_alted = not self:GetAbility().alt_casted
        })
        self:GetAbility().alt_casted = not self:GetAbility().alt_casted
	end
end

modifier_t2x2_w_buff = class({})
function modifier_t2x2_w_buff:IsHidden() return false end
function modifier_t2x2_w_buff:IsPurgable() return true end
function modifier_t2x2_w_buff:IsDebuff() return false end
function modifier_t2x2_w_buff:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_w_buff:OnDestroy()
end

function modifier_t2x2_w_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_t2x2_w_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_t2x2_w_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_t2x2_w_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_t2x2_w_buff:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf"
end

function modifier_t2x2_w_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_t2x2_w_debuff = class({})
function modifier_t2x2_w_debuff:IsHidden() return false end
function modifier_t2x2_w_debuff:IsPurgable() return true end
function modifier_t2x2_w_debuff:IsDebuff() return true end

function modifier_t2x2_w_debuff:OnCreated()
    if not IsServer() then return end
end

function modifier_t2x2_w_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_t2x2_w_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_t2x2_w_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_t2x2_w_debuff:GetEffectName()
    return "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_slow_debuff.vpcf"
end

function modifier_t2x2_w_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end