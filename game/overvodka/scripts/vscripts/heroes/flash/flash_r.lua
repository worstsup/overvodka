LinkLuaModifier( "modifier_flash_r_buff", "heroes/flash/flash_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_r_thinker", "heroes/flash/flash_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_r_debuff", "heroes/flash/flash_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_r_after", "heroes/flash/flash_r", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_r_after_cooldown", "heroes/flash/flash_r", LUA_MODIFIER_MOTION_NONE )

flash_r = class({})

function flash_r:Precache(context)
	PrecacheResource( "soundfile", "soundevents/stopan.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_kez/kez_sai_afterimage_buff.vpcf", context )
	PrecacheResource( "particle", "particles/flash_r_speed.vpcf", context)
	PrecacheResource( "particle", "particles/flash_r_start.vpcf", context)
	PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active.vpcf", context)
	PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active_start.vpcf", context)
	PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_crimson_witness_2021/pa_crimson_witness_blur_start.vpcf", context)
	PrecacheResource( "particle", "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", context)
	PrecacheResource( "particle", "particles/units/heroes/hero_zuus/zuus_shard_slow.vpcf", context)
	PrecacheResource( "particle", "particles/flash_r_lightning.vpcf", context)
	PrecacheResource( "particle", "particles/flash_r_start_lightning.vpcf", context)
end

function flash_r:GetCooldown( level )
	return self.BaseClass.GetCooldown( self, level )
end

function flash_r:OnAbilityPhaseStart()
	EmitSoundOn( "flash_r_start", self:GetCaster() )
	if self.p then
		ParticleManager:DestroyParticle(self.p, true)
		ParticleManager:ReleaseParticleIndex(self.p)
		self.p = nil
	end
	self.p = ParticleManager:CreateParticle("particles/flash_r_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt( self.p, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( self.p, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
end

function flash_r:OnAbilityPhaseInterrupted()
	StopSoundOn( "flash_r_start", self:GetCaster() )
	if self.p then
		ParticleManager:DestroyParticle(self.p, true)
		ParticleManager:ReleaseParticleIndex(self.p)
		self.p = nil
	end
end

function flash_r:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	self.thinker = CreateModifierThinker(
		caster,
		self,
		"modifier_flash_r_thinker",
		{ duration = duration },
		caster:GetAbsOrigin(),
		caster:GetTeamNumber(),
		false
	)
	caster:AddNewModifier(caster, self, "modifier_flash_r_buff", {duration = self:GetSpecialValueFor("duration")})
	EmitGlobalSound( "flash_r" )
	StopGlobalSound( "5opka_r" )
    StopGlobalSound( "stray_scepter" )
    StopGlobalSound( "evelone_r_ambient" )
	StopGlobalSound( "golden_rain" )
	local p = ParticleManager:CreateParticle("particles/flash_r_start_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt( p, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( p, 4, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex(p)
	local p = ParticleManager:CreateParticle("particles/flash_r_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(p)
end

modifier_flash_r_buff = class({})

function modifier_flash_r_buff:IsHidden() return false end
function modifier_flash_r_buff:IsDebuff() return false end
function modifier_flash_r_buff:IsPurgable() return false end

function modifier_flash_r_buff:OnCreated()
	if not IsServer() then return end
	if self:GetAbility().p then
		ParticleManager:DestroyParticle(self:GetAbility().p, true)
		ParticleManager:ReleaseParticleIndex(self:GetAbility().p)
		self:GetAbility().p = nil
	end
	self.p = ParticleManager:CreateParticle("particles/flash_r_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.p, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.p, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	self:AddParticle(self.p, false, false, -1, false, false)
	self.saved_time = GameRules:GetTimeOfDay()
	GameRules:SetTimeOfDay(0)
	self:PlayEffects()
end

function modifier_flash_r_buff:OnRefresh()
	if not IsServer() then return end
	if self:GetAbility().p then
		ParticleManager:DestroyParticle(self:GetAbility().p, true)
		ParticleManager:ReleaseParticleIndex(self:GetAbility().p)
		self:GetAbility().p = nil
	end
end

function modifier_flash_r_buff:OnDestroy()
	if not IsServer() then return end
	local p = ParticleManager:CreateParticle("particles/flash_r_start_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt( p, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( p, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex(p)
	if self.saved_time then
		GameRules:SetTimeOfDay(self.saved_time)
	end
end

function modifier_flash_r_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_flash_r_buff:GetModifierMoveSpeedBonus_Percentage()
	return (self:GetAbility():GetSpecialValueFor("speed_mult") - 1.0) * 100 
end

function modifier_flash_r_buff:OnAttackLanded(params)
    if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
    if not params.target or params.target:IsNull() then return end
	if params.target:IsAttackImmune() then return end
	if self:GetParent():HasModifier("modifier_flash_r_after_cooldown") then return end
	self:SpawnAfterimage(params.target)
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_flash_r_after_cooldown", {duration = self:GetAbility():GetSpecialValueFor("after_cooldown")})
end

function modifier_flash_r_buff:SpawnAfterimage(target)
    if not IsServer() then return end
    if not target or target:IsNull() then return end

    local spawn_pos = self:GetParent():GetAbsOrigin() + RandomVector(20)
    local after = CreateUnitByName(self:GetParent():GetUnitName(), spawn_pos, false, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber())
    after:SetControllableByPlayer(self:GetParent():GetPlayerOwnerID(), false)
    after:SetOwner(self:GetParent())
	after:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_flash_r_after", {duration = 1.5, target = target:entindex()})
	after:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_kill", {duration = 1.55})
    if after.SetRenderColor then
		after:SetRenderColor(80, 255, 255)
	end
	
    ExecuteOrderFromTable({
        UnitIndex = after:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = target:entindex(),
        Queue = false
    })
end

function modifier_flash_r_buff:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/flash_r_speed.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(effect_cast, false, false, -1, false, false)
	local effect_cast_2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_kez/kez_sai_afterimage_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	self:AddParticle(effect_cast_2, false, false, -1, false, false)
end

modifier_flash_r_after = class({})

function modifier_flash_r_after:IsHidden() return true end
function modifier_flash_r_after:IsPurgable() return false end

function modifier_flash_r_after:OnCreated(kv)
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then
		self:Destroy()
		return
	end
	local caster = self:GetCaster()
	EmitSoundOn("flash_r_after", caster)
	if not ability or ability:IsNull() or not caster or caster:IsNull() then
		self:Destroy()
		return
	end
	self.damage = caster:GetAverageTrueAttackDamage(nil) * ability:GetSpecialValueFor("illusion_damage") * 0.01
	self.speed = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), true)
	if kv.target then
		self.target = EntIndexToHScript(tonumber(kv.target))
	end
	self:StartIntervalThink(0.03)
end

function modifier_flash_r_after:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then
		self:Destroy()
		return
	end
	local caster = self:GetCaster()
    if not caster or caster:IsNull() then
        self:Destroy()
        return
    end
	if not self.target or self.target:IsNull() then
		self:Destroy()
		return
	end
	if self.target:IsAttackImmune() or not self.target:IsAlive() then
		self:Destroy()
		return
	end
end

function modifier_flash_r_after:CheckState()
	return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE]      = true,
        [MODIFIER_STATE_INVULNERABLE]      = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]     = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

function modifier_flash_r_after:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end

function modifier_flash_r_after:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
	local mod = self
	Timers:CreateTimer(0.3, function()
		if mod and not mod:IsNull() then self:Destroy() end
	end)
end

function modifier_flash_r_after:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_flash_r_after:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_flash_r_after:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active.vpcf"
end

function modifier_flash_r_after:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_flash_r_after:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
	local parent = self:GetParent()
	if parent and not parent:IsNull() then
		local effect_cast = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_phantom_assassin_persona/pa_persona_phantom_blur_active_start.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			parent
		)
		ParticleManager:SetParticleControl(effect_cast, 0, parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(effect_cast, 3, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(effect_cast)
		UTIL_Remove(parent)
	end
end

modifier_flash_r_debuff = class({})

function modifier_flash_r_debuff:IsHidden() return false end
function modifier_flash_r_debuff:IsDebuff() return true end
function modifier_flash_r_debuff:IsPurgable() return false end

function modifier_flash_r_debuff:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
    if not ability or ability:IsNull() then
		self:Destroy()
		return
	end
	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(p, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(p, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(p)
end

function modifier_flash_r_debuff:GetEffectName()
	return "particles/units/heroes/hero_zuus/zuus_shard_slow.vpcf"
end

function modifier_flash_r_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_flash_r_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
end

function modifier_flash_r_debuff:GetModifierMoveSpeed_Limit()
	if not self:GetAbility() or self:GetAbility():IsNull() then
		self:Destroy()
		return 550
	end
    return self:GetAbility():GetSpecialValueFor("max_speed")
end

modifier_flash_r_thinker = class({})

function modifier_flash_r_thinker:OnSpellStart()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_flash_r_thinker:OnIntervalThink()
	if not self:GetAbility() then
		self:Destroy()
		return
	end
end

function modifier_flash_r_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_flash_r_thinker:IsAura() return true end
function modifier_flash_r_thinker:GetModifierAura() return "modifier_flash_r_debuff" end
function modifier_flash_r_thinker:GetAuraRadius() return 99999 end
function modifier_flash_r_thinker:GetAuraDuration() return 0.01 end
function modifier_flash_r_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_flash_r_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_flash_r_after_cooldown = class({})

function modifier_flash_r_after_cooldown:IsHidden() return true end
function modifier_flash_r_after_cooldown:IsPurgable() return false end