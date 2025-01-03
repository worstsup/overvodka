modifier_golovach_hidden = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_golovach_hidden:IsHidden()
	return true
end

function modifier_golovach_hidden:IsDebuff()
	return true
end

function modifier_golovach_hidden:IsStunDebuff()
	return false
end

function modifier_golovach_hidden:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_golovach_hidden:OnCreated( kv )
	if IsServer() then
		-- references
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 900
		self.damage = 100

		self.origin = self:GetParent():GetOrigin()

		-- apply motion controller
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_golovach_hidden:OnRefresh( kv )
	if IsServer() then
		-- references
		self.distance = kv.r
		self.direction = Vector(kv.x,kv.y,0):Normalized()
		self.speed = 900
		self.damage = 100

		self.origin = self:GetParent():GetOrigin()

		-- apply motion controller
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end	
end

function modifier_golovach_hidden:OnDestroy( kv )
	if IsServer() then
		self:GetParent():InterruptMotionControllers( true )
	end
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_golovach_hidden:UpdateHorizontalMotion( me, dt )
	local pos = self:GetParent():GetOrigin()
	
	-- stop if already past distance
	if (pos-self.origin):Length2D()>=self.distance then
		self:Destroy()
		return
	end

	-- set position
	local target = pos + self.direction * (self.speed*dt)

	-- change position
	self:GetParent():SetOrigin( target )
end

function modifier_golovach_hidden:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_golovach_hidden:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_golovach_hidden:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Interval Effects
-- function modifier_golovach_hidden:OnIntervalThink()
-- end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_golovach_hidden:GetEffectName()
-- 	return "particles/string/here.vpcf"
-- end

-- function modifier_golovach_hidden:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

-- function modifier_golovach_hidden:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "string"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		nFXIndex,
-- 		bDestroyImmediately,
-- 		bStatusEffect,
-- 		iPriority,
-- 		bHeroEffect,
-- 		bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end