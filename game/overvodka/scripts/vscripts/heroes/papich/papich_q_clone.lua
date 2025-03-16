papich_q_clone = class({})
LinkLuaModifier( "modifier_papich_q_clone", "heroes/papich/modifier_papich_q_clone", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_papich_q_clone_debuff", "heroes/papich/modifier_papich_q_clone_debuff", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_arc_lua", "modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_generic_leashed_lua", "modifier_generic_leashed_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_papich_q_clone_blood", "heroes/papich/papich_q_clone", LUA_MODIFIER_MOTION_NONE)

function papich_q_clone:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf", context )
	PrecacheResource( "particle", "particles/slark_ti6_pounce_trail_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_start_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_ground_new.vpcf", context)
	PrecacheResource( "particle", "particles/slark_ti6_pounce_leash_new.vpcf", context)
	PrecacheResource( "particle", "particles/pa_persona_shard_fan_of_knives_blades_new.vpcf", context)
end

function papich_q_clone:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_papich_q_clone",
		{}
	)
	local sound_cast = "papich_q_clone"
	EmitSoundOn( sound_cast, caster )
end

modifier_papich_q_clone_blood = class({})
function modifier_papich_q_clone_blood:IsDebuff() return true end
function modifier_papich_q_clone_blood:IsHidden() return false end
function modifier_papich_q_clone_blood:IsPurgable() return true end
function modifier_papich_q_clone_blood:IsPurgeException() return false end
function modifier_papich_q_clone_blood:IsStunDebuff() return false end
function modifier_papich_q_clone_blood:RemoveOnDeath() return true end

function modifier_papich_q_clone_blood:OnCreated(params)
	self.blood_damage = self:GetAbility():GetSpecialValueFor("blood_damage")
	self:StartIntervalThink(1)
end
function modifier_papich_q_clone_blood:OnIntervalThink()
	if not IsServer() then return end
	self.dmg = self:GetParent():GetHealth() * self.blood_damage * 0.01
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = self.dmg, damage_type = DAMAGE_TYPE_PURE })
end

function modifier_papich_q_clone_blood:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_papich_q_clone_blood:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf"
end

function modifier_papich_q_clone_blood:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end