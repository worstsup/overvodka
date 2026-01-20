LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_chillguy_q_slow", "heroes/chillguy/chillguy_q", LUA_MODIFIER_MOTION_NONE )

chillguy_q = class({})

function chillguy_q:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local info = {
		EffectName = "particles/skeletonking_hellfireblast_new.vpcf",
		Ability = self,
		iMoveSpeed = self:GetSpecialValueFor("blast_speed"),
		Source = self:GetCaster(),
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "vibes", self:GetCaster() )
end

function chillguy_q:OnProjectileHit( hTarget, vLocation )
	if not IsServer() then return end
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		local stun_duration = self:GetSpecialValueFor( "blast_stun_duration" )
		local stun_damage = self:GetAbilityDamage()
		local dot_duration = self:GetSpecialValueFor( "blast_dot_duration" )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun_duration } )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_chillguy_q_slow", { duration = dot_duration * (1 - hTarget:GetStatusResistance()) } )
		EmitSoundOn( "klonk", hTarget )
		ApplyDamage( { victim = hTarget, attacker = self:GetCaster(), damage = stun_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self } )
	end
	return true
end


modifier_chillguy_q_slow = class({})

function modifier_chillguy_q_slow:IsPurgable() return true end
function modifier_chillguy_q_slow:IsDebuff() return true end

function modifier_chillguy_q_slow:OnCreated( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor( "blast_dot_damage" )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration
	self.duration = kv.duration
	self:StartIntervalThink( self.interval )
end

function modifier_chillguy_q_slow:OnRefresh( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor( "blast_dot_damage" )
	self.dot_slow = self:GetAbility():GetSpecialValueFor( "blast_slow" )
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration 
	self.duration = kv.duration
	self:StartIntervalThink( self.interval )
end

function modifier_chillguy_q_slow:OnDestroy()
	if IsServer() then
		if self.tick < self.duration then
			self:OnIntervalThink()
		end
	end
end

function modifier_chillguy_q_slow:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_chillguy_q_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.dot_slow
end

function modifier_chillguy_q_slow:OnIntervalThink()
	if IsServer() then
		ApplyDamage( { victim = self:GetParent(), attacker = self:GetCaster(), damage = self.dot_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() } )
	end
	self.tick = self.tick + 1
end

function modifier_chillguy_q_slow:GetEffectName()
	return "particles/skeletonking_hellfireblast_debuff_new.vpcf"
end

function modifier_chillguy_q_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end