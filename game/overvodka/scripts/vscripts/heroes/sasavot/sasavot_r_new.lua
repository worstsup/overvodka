LinkLuaModifier("modifier_sasavot_r_new", "heroes/sasavot/sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_r_new_secondary", "heroes/sasavot/sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sasavot_r_new_secondary_self", "heroes/sasavot/sasavot_r_new.lua", LUA_MODIFIER_MOTION_NONE)
sasavot_r_new = class({})

function sasavot_r_new:OnSpellStart()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    if target:TriggerSpellAbsorb(self) then return end
    EmitSoundOnClient("sasavot_r_new_start", self:GetCaster():GetPlayerOwner())
    target:AddNewModifier(caster, self, "modifier_sasavot_r_new", {duration = -1})
end

modifier_sasavot_r_new = class({})

function modifier_sasavot_r_new:IsDebuff() return true end
function modifier_sasavot_r_new:IsPurgable() return false end
function modifier_sasavot_r_new:IsHidden()
    return true
end
function modifier_sasavot_r_new:OnCreated()
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self:PlayEffects()
    self:StartIntervalThink(0.5)
end

function modifier_sasavot_r_new:OnIntervalThink()
    if not IsServer() then return end

    if self.target:IsAlive() and self.caster:IsAlive() then
        AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), 300, 0.5, false)
        if self.target:HasModifier("modifier_sasavot_shard") then
            self.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary", {duration = 15})
            self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary_self", {duration = 15})
            self:Destroy()
        end
    else
        self:Destroy()
    end
end

function modifier_sasavot_r_new:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_sasavot_r_new:OnTakeDamage(params)
    if params.attacker == self.target and params.unit ~= self.caster and params.unit:IsRealHero() then
        self.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary", {duration = 15})
        self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_sasavot_r_new_secondary_self", {duration = 15})
        self:Destroy()
    end
end

function modifier_sasavot_r_new:PlayEffects()
    local particle_cast = "particles/venomancer_noxious_contagion_buff_overhead_virus_new.vpcf"
    local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )

    self:AddParticle(
        effect_cast,
        false,
        false,
        -1,
        false,
        false
    )
end
modifier_sasavot_r_new_secondary_self = class({})

function modifier_sasavot_r_new_secondary_self:IsHidden()
	return false
end
function modifier_sasavot_r_new_secondary_self:IsPurgable()
	return false
end

function modifier_sasavot_r_new_secondary_self:OnCreated( kv )
end

function modifier_sasavot_r_new_secondary_self:OnDestroy( kv )
end

function modifier_sasavot_r_new_secondary_self:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
	return funcs
end

function modifier_sasavot_r_new_secondary_self:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		if params.target:HasModifier("modifier_sasavot_r_new_secondary") then
			self.record = params.record
			return self:GetAbility():GetSpecialValueFor( "damage_bonus" )
		end
	end
end

function modifier_sasavot_r_new_secondary_self:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self.record then
			self.record = nil
			self:PlayEffects( params.target )
		end
	end
end


function modifier_sasavot_r_new_secondary_self:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(),
		true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 1, (self:GetParent():GetOrigin()-target:GetOrigin()):Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_sasavot_r_new_secondary = class({})

function modifier_sasavot_r_new_secondary:IsDebuff() return true end
function modifier_sasavot_r_new_secondary:IsPurgable() return false end

function modifier_sasavot_r_new_secondary:OnCreated()
    self.Pct = 0
    self.t = 0
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.damage_needed = self:GetAbility():GetSpecialValueFor("damage_needed")
    self:SetStackCount(self.damage_needed)
    self:StartIntervalThink(0.5)

    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.durationPassed = 0
    self.damageDealt = false
    EmitSoundOn("sasavot_r_tick", self.target)
end
function modifier_sasavot_r_new_secondary:OnRefresh()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_sasavot_r_new_secondary:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_sasavot_r_new_secondary:GetModifierDamageOutgoing_Percentage()
    return self.Pct
end

function modifier_sasavot_r_new_secondary:GetBonusVisionPercentage( params )
    return self.Pct
end

function modifier_sasavot_r_new_secondary:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker == self.target and params.unit == self.caster then
        self.damage_needed = self.damage_needed - params.damage
        if self.damage_needed <= 0 then
            self.damageDealt = true
            self:Destroy()
        end
        self:SetStackCount(self.damage_needed)
    end
end

function modifier_sasavot_r_new_secondary:OnIntervalThink()
    self.t = self.t + 1
    if self.t == 8 then
        self.Pct = self.Pct - 30
        self.t = 0
    end
    if not IsServer() then return end
    if not self.target:IsAlive() or not self.caster:IsAlive() then
        self:Destroy()
        return
    end
    if self.damage_needed <= 0 then
        self:Destroy()
        return
    end
    AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), 300 + self.durationPassed * 15, 0.5, false)
    self.durationPassed = self.durationPassed + 0.5
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if distance > self.radius then
        self:Destroy()
    end
end

function modifier_sasavot_r_new_secondary:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():RemoveModifierByName("modifier_sasavor_r_new_secondary_self")
    StopSoundOn("sasavot_r_tick", self.target)
    local distance = (self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    if self.durationPassed >= 14 and distance <= self.radius and not self.damageDealt then
        self.damage_needed = self.target:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("dmg_pct") * 0.01
        ApplyDamage({victim = self.target, attacker = self.caster, damage = self.damage_needed, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
        EmitGlobalSound("sasavot_r_success")
    end
end
function modifier_sasavot_r_new_secondary:GetEffectName()
    return "particles/units/heroes/hero_demonartist/hero_demonartist_track_shield.vpcf"
end

function modifier_sasavot_r_new_secondary:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end