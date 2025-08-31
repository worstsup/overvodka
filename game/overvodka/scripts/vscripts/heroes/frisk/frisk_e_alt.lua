LinkLuaModifier("modifier_frisk_e_alt_slow", "heroes/frisk/frisk_e_alt", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_frisk_e_alt_buff", "heroes/frisk/frisk_e_alt", LUA_MODIFIER_MOTION_NONE )

frisk_e_alt = class({})

function frisk_e_alt:Precache(context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/frisk_e_alt.vpcf", context)
    PrecacheResource("particle", "particles/frisk_e_alt_proj.vpcf", context)
    PrecacheResource("particle", "particles/frisk_e_alt_debuff.vpcf", context)
end

function frisk_e_alt:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    EmitSoundOn("frisk_dog_start", caster)
	local projectile_speed = self:GetSpecialValueFor("blast_speed")
	local projectile_name = "particles/frisk_e_alt_proj.vpcf"
	
	local info = {
		EffectName = projectile_name,
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

function frisk_e_alt:OnProjectileHit( hTarget, vLocation )
    if not IsServer() then return end
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		local dot_duration = self:GetSpecialValueFor( "blast_dot_duration" )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_frisk_e_alt_slow", { duration = dot_duration * (1 - hTarget:GetStatusResistance()) } )
        EmitSoundOn( "klonk", hTarget )
        EmitSoundOn( "frisk_dog_hit", hTarget )
	end
	return true
end


modifier_frisk_e_alt_slow = class({})

function modifier_frisk_e_alt_slow:IsHidden() return false end
function modifier_frisk_e_alt_slow:IsPurgable() return true end

function modifier_frisk_e_alt_slow:OnCreated( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.duration = kv.duration
	self:StartIntervalThink( self.interval )
    self:OnIntervalThink()
end

function modifier_frisk_e_alt_slow:DeclareFunctions()	
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_START,
	}
	return funcs
end

function modifier_frisk_e_alt_slow:GetModifierMoveSpeedBonus_Percentage( params )
	return self.dot_slow
end

function modifier_frisk_e_alt_slow:OnAttackStart( params )
	if IsServer() then
		if params.target~=self:GetParent() then return end
        if params.attacker:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return end
		if params.attacker:IsBuilding() then return end
		params.attacker:AddNewModifier(
			self:GetParent(), 
			self:GetAbility(),
			"modifier_frisk_e_alt_buff",
			{}
		)
	end
end

function modifier_frisk_e_alt_slow:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dot_damage * self.interval,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end
end

function modifier_frisk_e_alt_slow:GetEffectName()
	return "particles/frisk_e_alt_debuff.vpcf"
end

function modifier_frisk_e_alt_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_frisk_e_alt_buff = class({})

function modifier_frisk_e_alt_buff:IsHidden() return false end
function modifier_frisk_e_alt_buff:IsDebuff() return false end
function modifier_frisk_e_alt_buff:IsStunDebuff() return false end
function modifier_frisk_e_alt_buff:IsPurgable() return true end

function modifier_frisk_e_alt_buff:OnCreated( kv )
	self.as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.duration = self:GetAbility():GetSpecialValueFor( "as_duration" )
end

function modifier_frisk_e_alt_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FINISHED,

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_frisk_e_alt_buff:GetModifierPreAttack( params )
	if IsServer() then
		if not self.HasAttacked then
			self.record = params.record
		end
		if params.target~=self:GetCaster() then
			self.attackOther = true
		end
	end
end

function modifier_frisk_e_alt_buff:OnAttack( params )
	if IsServer() then
		if params.record~=self.record then return end
		self:SetDuration(self.duration, true)
		self.HasAttacked = true
	end
end

function modifier_frisk_e_alt_buff:OnAttackFinished( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		if not self.HasAttacked then
			self:Destroy()
		end
		if self.attackOther then
			self:Destroy()
		end
	end
end

function modifier_frisk_e_alt_buff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		if self:GetParent():GetAggroTarget()==self:GetCaster() then
			return self.as
		else
			return 0
		end
	end

	return self.as
end

function modifier_frisk_e_alt_buff:GetEffectName()
	return "particles/frisk_e_alt.vpcf"
end

function modifier_frisk_e_alt_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end