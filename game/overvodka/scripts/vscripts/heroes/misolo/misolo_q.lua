LinkLuaModifier("modifier_misolo_q_debuff", "heroes/misolo/misolo_q", LUA_MODIFIER_MOTION_NONE)

misolo_q = class({})

modifier_misolo_q_debuff = class({})

function misolo_q:Precache(context)
    PrecacheResource("particle", "particles/misolo_q.vpcf", context)
    PrecacheResource("soundfile", "soundevents/misolo_sounds.vsndevts", context)
end

function misolo_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not IsValid(caster, target) then return end
    if target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(caster, self, "modifier_misolo_q_debuff", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})

    EmitSoundOn("DOTA_Item.Bloodthorn.Activate", target)
end

function modifier_misolo_q_debuff:IsHidden() return false end
function modifier_misolo_q_debuff:IsDebuff() return true end
function modifier_misolo_q_debuff:IsPurgable() return true end

function modifier_misolo_q_debuff:OnCreated()
    self.bonus_magic_damage = self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
    self.damage_received = 0

    if not IsServer() then return end

    CustomGameEventManager:Send_ServerToAllClients("misolo_q_marker_start", {
        entindex = self:GetParent():entindex()
    })
end

function modifier_misolo_q_debuff:OnRefresh()
    self.bonus_magic_damage = self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
end

function modifier_misolo_q_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_misolo_q_debuff:GetModifierProvidesFOWVision()
    return 1
end

function modifier_misolo_q_debuff:CheckState()
    return {
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

function modifier_misolo_q_debuff:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local attacker = params.attacker

    if not IsValid(parent, caster, ability, attacker) then return end
    if params.target ~= parent or attacker:GetTeamNumber() ~= caster:GetTeamNumber() then return end
    if attacker:IsBuilding() or attacker:IsWard() or attacker:IsOther() then return end
    if self.bonus_magic_damage <= 0 then return end

    EmitSoundOn("DOTA_Item.MKB.melee", parent)

    ApplyDamage({victim = parent, attacker = attacker, damage = self.bonus_magic_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function modifier_misolo_q_debuff:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    if not IsValid(parent, caster) or params.unit ~= parent then return end

    local attacker = params.attacker
    if not IsValid(attacker) or attacker:GetTeamNumber() ~= caster:GetTeamNumber() then return end

    local damage_flags = params.damage_flags or 0
    if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
    if bit.band(damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end

    self.damage_received = self.damage_received + (params.damage or 0)
end

function modifier_misolo_q_debuff:OnDestroy()
    if not IsServer() then return end

    CustomGameEventManager:Send_ServerToAllClients("misolo_q_marker_end", {
        entindex = self:GetParent():entindex()
    })

    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    if not IsValid(caster, ability, parent) or not parent:IsAlive() then return end

    if not caster:HasTalent("special_bonus_unique_misolo_5") or self.damage_received <= 0 then return end
    local p = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(p, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(p, 1, Vector(150, 0, 0))
    ParticleManager:SetParticleControl(p, 2, Vector(100, 0, 0))
	ParticleManager:ReleaseParticleIndex(p)
    ApplyDamage({victim = parent, attacker = caster, damage = self.damage_received * ability:GetSpecialValueFor("post_damage_pct") * 0.01, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function modifier_misolo_q_debuff:GetEffectName() return "particles/misolo_q.vpcf" end
function modifier_misolo_q_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_misolo_q_debuff:GetTexture() return "misolo_q" end
