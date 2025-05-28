LinkLuaModifier("modifier_kolyan_q", "heroes/kolyan/kolyan_q", LUA_MODIFIER_MOTION_NONE)

kolyan_q = class({})

function kolyan_q:Precache(context)
    PrecacheResource("particle", "particles/kolyan_q.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", context)
end

function kolyan_q:GetCastRange(location, target)
	local caster = self:GetCaster()
	local cast_range = caster:Script_GetAttackRange()
    if not caster:HasModifier("modifier_kolyan_q") then
        local bonus_range = self:GetSpecialValueFor("bonus_attack_range")
        cast_range = cast_range + bonus_range
    end
	return cast_range
end

function kolyan_q:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kolyan_q", {duration = duration})
end

function kolyan_q:OnChannelFinish(interrupted)
    if not IsServer() then return end
    local caster = self:GetCaster()

    if interrupted then
        caster:RemoveModifierByName("modifier_kolyan_q")
        return
    end

    if caster:HasModifier("modifier_kolyan_q") then
        caster:FindModifierByName("modifier_kolyan_q"):OnDestroy()
    end
end

modifier_kolyan_q = class({})

function modifier_kolyan_q:IsPurgable()
	return false
end

function modifier_kolyan_q:IsHidden()
    return true
end

function modifier_kolyan_q:OnCreated( kv )
	self.attack_interval = self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.bonus_attack_range = self:GetAbility():GetSpecialValueFor( "bonus_attack_range" )
    self.attack_damage = self:GetAbility():GetSpecialValueFor("attack_damage")
	if not IsServer() then return end
	local particle = ParticleManager:CreateParticle("particles/kolyan_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle( particle, false, false, -1, false, false  )
	self:StartIntervalThink(self.attack_interval)
    self:OnIntervalThink()
end

function modifier_kolyan_q:OnIntervalThink()
	if not IsServer() then return end
	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
	if #enemies <= 0 then return end
    local particle = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    for _, enemy in pairs(enemies) do
        self:GetParent():PerformAttack(enemy, false, true, true, false, false, false, false)
    end
end

function modifier_kolyan_q:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function modifier_kolyan_q:GetModifierDamageOutgoing_Percentage()
	if IsServer() then
		return self.attack_damage
	end
end

function modifier_kolyan_q:GetModifierFixedAttackRate()
	return self.attack_interval
end

function modifier_kolyan_q:GetModifierAttackRangeBonus()
	return self.bonus_attack_range
end

function modifier_kolyan_q:CheckState()
	return 
	{
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_kolyan_q:OnRefresh( kv )
	if not IsServer() then return end
	self:OnCreated()
end

function modifier_kolyan_q:OnDestroy()
	if not IsServer() then return end
end