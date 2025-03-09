LinkLuaModifier("modifier_bratishkin_q_knight", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_knight_upgrade", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_base", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_base_root", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bratishkin_q_base_haste", "heroes/bratishkin/bratishkin_q_knight", LUA_MODIFIER_MOTION_NONE)
k = 0
bratishkin_q_knight = class({})

function bratishkin_q_knight:Precache( context )
    PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_sven/sven_spell_great_cleave_crit.vpcf", context )
    PrecacheResource( "model", "models/bratishkin/knight/base.vmdl", context )
	PrecacheResource( "model", "models/items/sven/weapon_ruling_sword.vmdl", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_knight_attack.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_knight.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_knight_1.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_knight_2.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/bratishkin_q_knight_3.vsndevts", context )
end

function bratishkin_q_knight:GetIntrinsicModifierName()
    return "modifier_bratishkin_q_base"
end

function bratishkin_q_knight:GetManaCost(iLevel)
    local base_cost = self:GetSpecialValueFor("base_manacost")
    local manacost_from_current_mana = self:GetSpecialValueFor("manacost_from_current_mana")
    return base_cost + (self:GetCaster():GetMana() / 100 * manacost_from_current_mana)
end

function bratishkin_q_knight:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight_upgrade", {})
    local modifier_bratishkin_q_knight = self:GetCaster():FindModifierByName("modifier_bratishkin_q_knight")
    if modifier_bratishkin_q_knight then
        modifier_bratishkin_q_knight:Destroy()
    else
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bratishkin_q_knight", {})
    end
    self:GetCaster():EmitSound("bratishkin_q_knight")
    if k == 0 then
        self:GetCaster():EmitSound("bratishkin_q_knight_1")
        k = 1
    elseif k == 1 then
        self:GetCaster():EmitSound("bratishkin_q_knight_2")
        k = 2
    elseif k == 2 then
        self:GetCaster():EmitSound("bratishkin_q_knight_3")
        k = 0
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(particle)
end

modifier_bratishkin_q_knight = class({})
function modifier_bratishkin_q_knight:IsHidden() return false end
function modifier_bratishkin_q_knight:IsPurgable() return false end
function modifier_bratishkin_q_knight:IsPurgeException() return false end
function modifier_bratishkin_q_knight:RemoveOnDeath() return false end

function modifier_bratishkin_q_knight:OnCreated()
    if not IsServer() then return end
    self.abilities_list = 
    {
        {"bratishkin_q_knight", "bratishkin_q_base"}
    }
    self.model = self:GetParent():GetModelName()
    self:GetParent():SetModel("models/bratishkin/knight/base.vmdl")
    self:GetParent():SetOriginalModel("models/bratishkin/knight/base.vmdl")
    self:GetParent().weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/sven/weapon_ruling_sword.vmdl"})
	self:GetParent().weapon:FollowEntityMerge(self:GetParent(), "attach_sword")
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[1], info[2], false, true)
    end
    self:GetParent():FindAbilityByName("bratishkin_q_base"):UseResources(false, false, false, true)
end

function modifier_bratishkin_q_knight:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_bratishkin_q_knight:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor_knight")
end

function modifier_bratishkin_q_knight:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.attacker == self:GetParent() then
        EmitSoundOn("bratishkin_knight_attack", keys.target)
        if self:GetAbility():GetSpecialValueFor("cleave") > 0 and not self:GetParent():PassivesDisabled() then
            self.cleave_radius = self:GetAbility():GetSpecialValueFor("cleave_radius")
            DoCleaveAttack(self:GetParent(), keys.target, self:GetAbility(), self:GetAbility():GetSpecialValueFor("cleave"), self.cleave_radius, self.cleave_radius, self.cleave_radius, "particles/units/heroes/hero_sven/sven_spell_great_cleave_crit.vpcf")
        end
    end
end

function modifier_bratishkin_q_knight:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("bat_knight")
end

function modifier_bratishkin_q_knight:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range_knight")
end

function modifier_bratishkin_q_knight:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_knight")
end

function modifier_bratishkin_q_knight:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetModel(self.model)
    self:GetParent():SetOriginalModel(self.model)
    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
    self:GetParent().weapon:RemoveSelf()
    for _, info in pairs(self.abilities_list) do
        self:GetCaster():SwapAbilities(info[2], info[1], false, true)
    end
    self:GetParent():FindAbilityByName("bratishkin_q_knight"):UseResources(false, false, false, true)
end

modifier_bratishkin_q_knight_upgrade = class({})
function modifier_bratishkin_q_knight_upgrade:IsHidden() return true end
function modifier_bratishkin_q_knight_upgrade:IsPurgable() return false end
function modifier_bratishkin_q_knight_upgrade:IsPurgeException() return false end
function modifier_bratishkin_q_knight_upgrade:RemoveOnDeath() return false end

modifier_bratishkin_q_base = class({})
function modifier_bratishkin_q_base:IsHidden() return true end
function modifier_bratishkin_q_base:IsPurgable() return false end
function modifier_bratishkin_q_base:IsPurgeException() return false end
function modifier_bratishkin_q_base:RemoveOnDeath() return false end

function modifier_bratishkin_q_base:OnCreated()
    if not IsServer() then return end
    self.critProc = false
end

function modifier_bratishkin_q_base:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function modifier_bratishkin_q_base:OnAttackStart(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if RollPercentage( self:GetAbility():GetSpecialValueFor("minibash_chance") ) then
		self.critProc = true
	else
		self.critProc = false
	end
end

function modifier_bratishkin_q_base:OnAttackLanded(params)
    if self:GetParent():PassivesDisabled() then return end
    if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if not params.attacker:IsIllusion() and self.critProc and not params.attacker:HasModifier("modifier_bratishkin_q_knight") then
		local duration = self:GetAbility():GetSpecialValueFor("root_duration")
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bratishkin_q_base_root", {duration = duration})
        if self:GetAbility():GetSpecialValueFor("double_attack") > 0 then
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bratishkin_q_base_haste", {duration = 2})
            self:GetParent():AttackNoEarlierThan(0, 100)
        end
    end
end

modifier_bratishkin_q_base_root = class({})
function modifier_bratishkin_q_base_root:IsHidden() return false end
function modifier_bratishkin_q_base_root:IsPurgable() return true end
function modifier_bratishkin_q_base_root:GetTexture()
    return "bratishkin_q_base"
end
function modifier_bratishkin_q_base_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }
    return state
end

function modifier_bratishkin_q_base_root:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
end

function modifier_bratishkin_q_base_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_bratishkin_q_base_haste = class({})

function modifier_bratishkin_q_base_haste:IsHidden()
    return true
end

function modifier_bratishkin_q_base_haste:IsPurgable() return false end

function modifier_bratishkin_q_base_haste:DeclareFunctions()
    local decFuns =
        {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_EVENT_ON_ATTACK
        }
    return decFuns
end

function modifier_bratishkin_q_base_haste:GetModifierAttackSpeedBonus_Constant()
    if IsClient() then return 0 end
    return 1000
end

function modifier_bratishkin_q_base_haste:OnAttack(params)
    if params.attacker == self:GetParent() then
        self:Destroy()
    end
end