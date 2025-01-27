LinkLuaModifier("modifier_peterka_q", "heroes/5opka/peterka_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_telka", "heroes/5opka/peterka_q", LUA_MODIFIER_MOTION_NONE)

peterka_q = class({})
function peterka_q:Precache(context)
	PrecacheResource("particle", "particles/peterka_q.vpcf", context)
	PrecacheResource("particle", "particles/econ/events/ti10/fountain_regen_ti10_golden_sparkles.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_golden_walruspunch_start.vpcf", context)
	PrecacheResource("soundfile", "soundevents/peterka_q.vsndevts", context)
end
function peterka_q:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
    local duration = self:GetSpecialValueFor("stun_duration")
    local damage = self:GetSpecialValueFor("damage")
	EmitSoundOn("peterka_q", caster)
    target:AddNewModifier(caster, self, "modifier_peterka_q", {duration = duration, damage = damage})
    local random_offset = RandomVector(100)
    local spawn_position = caster:GetAbsOrigin() + random_offset
    local telka = CreateUnitByName("npc_telka", spawn_position, true, caster, caster, caster:GetTeamNumber())
	FindClearSpaceForUnit(telka, telka:GetAbsOrigin(), true)
	telka:SetControllableByPlayer(-1, false)
    telka:AddNewModifier(caster, self, "modifier_telka", {duration = duration})
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), 100, 0.5, false)
    telka:SetForceAttackTarget(target)
end

modifier_peterka_q = class({})

function modifier_peterka_q:IsHidden() return false end
function modifier_peterka_q:IsDebuff() return true end
function modifier_peterka_q:IsStunDebuff() return true end
function modifier_peterka_q:IsPurgable() return true end

function modifier_peterka_q:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_peterka_q:OnCreated(kv)
    if not IsServer() then return end
    self.damage = kv.damage
end

function modifier_peterka_q:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    ApplyDamage({
        victim = parent,
        attacker = caster,
        damage = self.damage,
        damage_type = ability:GetAbilityDamageType(),
        ability = ability
    })
	self:PlayEffects()
end
function modifier_peterka_q:PlayEffects()
	local particle_cast = "particles/peterka_q.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end
function modifier_peterka_q:GetEffectName()
    return "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf"
end
function modifier_peterka_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_telka = class({})

function modifier_telka:IsHidden() return true end
function modifier_telka:IsDebuff() return true end
function modifier_telka:IsPurgable() return false end
function modifier_telka:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end

function modifier_telka:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
function modifier_telka:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if params.target == nil then return end
    self:PlayEffects(params.target)
end
function modifier_telka:OnCreated(kv)
	if not IsServer() then return end
end
function modifier_telka:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end
function modifier_telka:GetEffectName()
	return "particles/econ/events/ti10/fountain_regen_ti10_golden_sparkles.vpcf"
end
function modifier_telka:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_telka:PlayEffects(target)
    local particle_cast = "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_golden_walruspunch_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
end