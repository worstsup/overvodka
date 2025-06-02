LinkLuaModifier("modifier_golmiy_golbet", "heroes/golmiy/golmiy_golbet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golmiy_golbet_reveal", "heroes/golmiy/golmiy_golbet", LUA_MODIFIER_MOTION_NONE)

golmiy_golbet = class({})

function golmiy_golbet:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    target:AddNewModifier(caster, self, "modifier_golmiy_golbet", { duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance()) })
    target:AddNewModifier(caster, self, "modifier_golmiy_golbet_reveal", { duration = 0.5 })
    target:EmitSound("stavka")

    local p = ParticleManager:CreateParticle("particles/speed_shard_start.vpcf", PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControlEnt(p, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
end


modifier_golmiy_golbet = class({})

function modifier_golmiy_golbet:IsDebuff() return true end
function modifier_golmiy_golbet:IsHidden() return false end
function modifier_golmiy_golbet:IsPurgable() return false end

function modifier_golmiy_golbet:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    local p1 = ParticleManager:CreateParticle("particles/speed_shard_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(p1, false, false, -1, false, false)
    local p2 = ParticleManager:CreateParticle("particles/speed_shard_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(p2, false, false, -1, false, false)
end

function modifier_golmiy_golbet:OnIntervalThink()
    local parent = self:GetParent()
    parent:RemoveModifierByName("modifier_golmiy_golbet_reveal")
    parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_golmiy_golbet_reveal", { duration = 0.5 })
end

function modifier_golmiy_golbet:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetParent()
    local ability = self:GetAbility()
    local targetLocation = target:GetAbsOrigin()
    local radius = ability:GetSpecialValueFor("bonus_gold_radius")
    local gold_self = ability:GetSpecialValueFor("bonus_gold_self")
    local gold_allies = ability:GetSpecialValueFor("bonus_gold")
    local player_id = caster:GetPlayerOwnerID()
    if not target:IsAlive() then
        caster:ModifyGold(gold_self, true, 0)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold_allies, nil)
    else
        PlayerResource:SpendGold(player_id, gold_allies, DOTA_ModifyGold_Unspecified)
    end
end

function modifier_golmiy_golbet:CheckState()
    return {
        [MODIFIER_STATE_PROVIDES_VISION] = true,
    }
end

modifier_golmiy_golbet_reveal = class({})

function modifier_golmiy_golbet_reveal:IsHidden() return true end
function modifier_golmiy_golbet_reveal:IsPurgable() return false end
function modifier_golmiy_golbet_reveal:GetPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_golmiy_golbet_reveal:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end
