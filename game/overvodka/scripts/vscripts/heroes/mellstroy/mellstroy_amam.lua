LinkLuaModifier("modifier_mell_amam", "heroes/mellstroy/mellstroy_amam", LUA_MODIFIER_MOTION_NONE)

mellstroy_amam = class({})

function mellstroy_amam:Precache(context)
    PrecacheResource( "particle", "particles/earthshaker_arcana_echoslam_start_v2_new.vpcf", context)
    PrecacheResource( "soundfile", "soundevents/amamam.vsndevts", context )
end

function mellstroy_amam:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    self:GetCaster():EmitSound("amamam")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mell_amam", {duration = duration}) 
end

modifier_mell_amam = class({})

function modifier_mell_amam:IsPurgable() return false end

function modifier_mell_amam:OnDestroy()
    if not IsServer() then return end
end

function modifier_mell_amam:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink( self:GetAbility():GetSpecialValueFor("interv") )
	self:OnIntervalThink()
end

function modifier_mell_amam:OnIntervalThink()
    if not IsServer() then return end
    self:Knock()
end

function modifier_mell_amam:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_mell_amam:GetModifierModelScale()
	return 40
end

function modifier_mell_amam:Knock()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
	local bonus_gold = self:GetAbility():GetSpecialValueFor("bonus_gold")
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/earthshaker_arcana_echoslam_start_v2_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, 1))
    ParticleManager:ReleaseParticleIndex(particle)
    local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)
    for _,unit in pairs(targets) do
		if unit:IsRealHero() then 
			self:GetParent():ModifyGold(bonus_gold, true, 0)
		end
        ApplyDamage({victim = unit, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
        local knockbackProperties =
        {
             center_x = 0,
             center_y = 0,
             center_z = 0,
             duration = self:GetAbility():GetSpecialValueFor("stun_dur"),
             knockback_duration = self:GetAbility():GetSpecialValueFor("stun_dur"),
             knockback_distance = 0,
             knockback_height = 300,
        }
        if unit:HasModifier("modifier_knockback") then
            unit:RemoveModifierByName("modifier_knockback")
        end
        unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", knockbackProperties)
    end
end