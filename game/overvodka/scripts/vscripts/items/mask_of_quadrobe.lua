LinkLuaModifier("modifier_item_mask_of_quadrobe",              "items/mask_of_quadrobe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mask_of_quadrobe_berserk",      "items/mask_of_quadrobe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mask_of_quadrobe_aura_emitter", "items/mask_of_quadrobe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mask_of_quadrobe_aura_armor",   "items/mask_of_quadrobe", LUA_MODIFIER_MOTION_NONE)

item_mask_of_quadrobe = class({})

function item_mask_of_quadrobe:GetIntrinsicModifierName()
    return "modifier_item_mask_of_quadrobe"
end

function item_mask_of_quadrobe:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster then return end

    local dur = self:GetSpecialValueFor("berserk_duration")

    caster:AddNewModifier(caster, self, "modifier_item_mask_of_quadrobe_berserk", { duration = dur })
    caster:AddNewModifier(caster, self, "modifier_item_mask_of_quadrobe_aura_emitter", { duration = dur })

    caster:EmitSound("kittymeow")
end


modifier_item_mask_of_quadrobe = class({})

function modifier_item_mask_of_quadrobe:IsHidden() return true end
function modifier_item_mask_of_quadrobe:IsPurgable() return false end
function modifier_item_mask_of_quadrobe:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mask_of_quadrobe:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.lifesteal = self.ability:GetSpecialValueFor( "lifesteal_percent" )/100
	if not IsServer() then return end
end

function modifier_item_mask_of_quadrobe:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_mask_of_quadrobe:GetModifierBaseAttack_BonusDamage()
    if not self.ability then return 0 end
    return self.ability:GetSpecialValueFor("bonus_damage")
end

function modifier_item_mask_of_quadrobe:GetModifierAttackSpeedBonus_Constant()
    if not self.ability then return 0 end
    return self.ability:GetSpecialValueFor("bonus_as")
end

function modifier_item_mask_of_quadrobe:GetModifierProcAttack_Feedback( params )
	if not IsServer() then return end
	if params.target:GetTeamNumber()==self.parent:GetTeamNumber() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end
	self.attack_record = params.record
end

function modifier_item_mask_of_quadrobe:OnTakeDamage( params )
	if not IsServer() then return end
	if self.attack_record ~= params.record then return end
	local heal = params.damage * self.lifesteal
	if params.unit:IsCreep() then
		heal = heal * 0.6
	end
	self.parent:HealWithParams(heal, self.ability, true, true, self.parent, false)
	self:PlayEffects2()
end

function modifier_item_mask_of_quadrobe:PlayEffects2()
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_item_mask_of_quadrobe_berserk = class({})

function modifier_item_mask_of_quadrobe_berserk:IsHidden() return false end
function modifier_item_mask_of_quadrobe_berserk:IsPurgable() return true end

function modifier_item_mask_of_quadrobe_berserk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
end

function modifier_item_mask_of_quadrobe_berserk:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("berserk_bonus_movement_speed_percentage")
end

function modifier_item_mask_of_quadrobe_berserk:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("berserk_bonus_attack_speed")
end

function modifier_item_mask_of_quadrobe_berserk:GetModifierIncomingDamage_Percentage()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("berserk_extra_incoming_damage_percentage")
end

function modifier_item_mask_of_quadrobe_berserk:GetModifierEvasion_Constant()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("berserk_evasion")
end

function modifier_item_mask_of_quadrobe_berserk:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_item_mask_of_quadrobe_berserk:GetEffectName()
    return "particles/quadrobe_buff.vpcf"
end

function modifier_item_mask_of_quadrobe_berserk:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_item_mask_of_quadrobe_aura_emitter = class({})

function modifier_item_mask_of_quadrobe_aura_emitter:IsHidden() return true end
function modifier_item_mask_of_quadrobe_aura_emitter:IsPurgable() return false end

function modifier_item_mask_of_quadrobe_aura_emitter:IsAura() return true end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraRadius()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("aura_radius")
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraSearchType()
    return bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_BUILDING)
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetModifierAura()
    return "modifier_item_mask_of_quadrobe_aura_armor"
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraDuration()
    return 0.1
end
function modifier_item_mask_of_quadrobe_aura_emitter:GetAuraEntityReject(target)
    if target == self:GetParent() then return true end
    return false
end


modifier_item_mask_of_quadrobe_aura_armor = class({})

function modifier_item_mask_of_quadrobe_aura_armor:IsHidden() return false end
function modifier_item_mask_of_quadrobe_aura_armor:IsDebuff() return true end
function modifier_item_mask_of_quadrobe_aura_armor:IsPurgable() return false end

function modifier_item_mask_of_quadrobe_aura_armor:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_item_mask_of_quadrobe_aura_armor:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    if not ability then return 0 end
    return ability:GetSpecialValueFor("aura_negative_armor")
end