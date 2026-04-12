LinkLuaModifier( "modifier_leon_r", "heroes/leon/leon_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_leon_r_cd_reduce", "heroes/leon/leon_r", LUA_MODIFIER_MOTION_NONE)

leon_r = class({})

function leon_r:GetIntrinsicModifierName()
    return "modifier_leon_r_cd_reduce"
end

function leon_r:Precache(context)
	PrecacheResource( "soundfile", "soundevents/leon_sounds.vsndevts", context )
	PrecacheResource( "particle", "particles/leon_r_start.vpcf", context )
    PrecacheResource( "particle", "particles/glimmer_cape_embers_n.vpcf", context )
    PrecacheResource( "particle", "particles/leon_r_ready.vpcf", context )
    PrecacheResource( "particle", "particles/leon_r_cast.vpcf", context )
end

function leon_r:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("Leon.Invis."..RandomInt(1,4))
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_leon_r", { duration = self:GetSpecialValueFor("duration") } )
end

modifier_leon_r_cd_reduce = class({})

function modifier_leon_r_cd_reduce:IsHidden() return true end
function modifier_leon_r_cd_reduce:IsPurgable() return false end
function modifier_leon_r_cd_reduce:RemoveOnDeath() return false end

function modifier_leon_r_cd_reduce:OnCreated()
    if not IsServer() then return end
    self._fx = nil
    self.was_on_cooldown = false
    self:StartIntervalThink(0.05)
    self:_UpdateReadyFx()
end

function modifier_leon_r_cd_reduce:OnDestroy()
    if not IsServer() then return end
    self:_DestroyReadyFx()
end

function modifier_leon_r_cd_reduce:OnIntervalThink()
    if not IsServer() then return end
    self:_UpdateReadyFx()
    if self.was_on_cooldown and self:GetAbility():IsCooldownReady() and not self:GetParent():IsIllusion() then
        self.was_on_cooldown = false
        self:GetParent():EmitSound("Leon.Invis.Ready")
    elseif not self.was_on_cooldown and not self:GetAbility():IsCooldownReady() then
        self.was_on_cooldown = true
    end
end

function modifier_leon_r_cd_reduce:_UpdateReadyFx()
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end

    local should_show = self:GetAbility():IsCooldownReady()

    if should_show then
        if not self._fx then
            self._fx = ParticleManager:CreateParticle(
                "particles/leon_r_ready.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                parent
            )
        end
        ParticleManager:SetParticleControl(self._fx, 0, parent:GetAbsOrigin())
    else
        self:_DestroyReadyFx()
    end
end

function modifier_leon_r_cd_reduce:_DestroyReadyFx()
    if not self._fx then return end
    ParticleManager:DestroyParticle(self._fx, false)
    ParticleManager:ReleaseParticleIndex(self._fx)
    self._fx = nil
end

function modifier_leon_r_cd_reduce:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_leon_r_cd_reduce:OnAttackLanded(params)
    if not IsServer() then return end
    
    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if params.attacker ~= parent then return end

    local target = params.target
    if not target or target:IsNull() then return end
    if not target:IsRealHero() then return end

    if target:GetTeamNumber() == parent:GetTeamNumber() then return end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end

    local minus = ability:GetSpecialValueFor("minus_cd") or 0
    if minus <= 0 then return end

    local remaining = ability:GetCooldownTimeRemaining()
    if remaining <= 0 then return end

    ability:EndCooldown()

    local new_cd = math.max(0, remaining - minus)
    if new_cd > 0 then
        ability:StartCooldown(new_cd)
    end
end


modifier_leon_r = class({})

function modifier_leon_r:IsPurgable() return true end
function modifier_leon_r:RemoveOnDeath() return true end

function modifier_leon_r:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    if parent:HasTalent("special_bonus_unique_leon_7") then
        parent:Purge( false, true, false, false, false )
    end
	local p = ParticleManager:CreateParticle( "particles/leon_r_start.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( p, 0, parent:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( p )
    self.effect_cast = ParticleManager:CreateParticle("particles/glimmer_cape_embers_n.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(self.effect_cast, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 1, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 2, parent:GetAbsOrigin())
    local p2 = ParticleManager:CreateParticle("particles/leon_r_cast.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p2, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p2)
end

function modifier_leon_r:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end

function modifier_leon_r:OnDestroy()
	if not IsServer() then return end
    if self.effect_cast then
        ParticleManager:DestroyParticle( self.effect_cast, false )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )
    end
end

function modifier_leon_r:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_leon_r:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
        if self:GetParent():HasScepter() then return end
		self:Destroy()
	end
end

function modifier_leon_r:OnAttack( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
        if self:GetParent():HasScepter() then return end
		self:Destroy()
	end
end

function modifier_leon_r:GetModifierInvisibilityLevel()
    return 1
end

function modifier_leon_r:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end
