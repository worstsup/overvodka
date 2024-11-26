modifier_patriotizm_chance = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_patriotizm_chance:IsHidden()
	return true
end

function modifier_patriotizm_chance:IsDebuff()
	return false
end

function modifier_patriotizm_chance:IsStunDebuff()
	return false
end

function modifier_patriotizm_chance:IsPurgable()
	return false
end

-- Initializations
function modifier_patriotizm_chance:OnCreated( kv )
	-- load data
	self.duration = self:GetAbility():GetSpecialValueFor( "illusion_duration" )
	self.outgoing = self:GetAbility():GetSpecialValueFor( "illusion_outgoing_damage" )
	self.incoming = self:GetAbility():GetSpecialValueFor( "illusion_incoming_damage" )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.distance = 72
end

function modifier_patriotizm_chance:OnRefresh( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "illusion_duration" )
	self.outgoing = self:GetAbility():GetSpecialValueFor( "illusion_outgoing_damage" )
	self.incoming = self:GetAbility():GetSpecialValueFor( "illusion_incoming_damage" )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.distance = 72
end
function modifier_patriotizm_chance:OnRemoved()
end

function modifier_patriotizm_chance:OnDestroy()
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_patriotizm_chance:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_patriotizm_chance:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit:IsIllusion() then return end
	if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
	if RandomInt(1,100)>self.chance then return end
	if params.unit~=self:GetParent() then return end
	if self:GetParent():PassivesDisabled() then return end
	if params.attacker:IsIllusion() == false then
		self.illusions = CreateIllusions(
			self:GetParent(), -- hOwner
			params.attacker, -- hHeroToCopy
			{
				outgoing_damage = self.outgoing,
				incoming_damage = self.incoming,
				duration = self.duration,
			}, -- hModiiferKeys
			1, -- nNumIllusions
			self.distance, -- nPadding
			false, -- bScramblePosition
			true -- bFindClearSpace
			)
	end
	-- create illusion
	self.illusion = self.illusions[1]
	self.illusion:SetControllableByPlayer( -1, false )
	self:GetAbility():UseResources( false, false, false, true )
	self.illusion:AddNewModifier(
		self:GetParent(), -- player source
		self, -- ability source
		"modifier_patriotizm", -- modifier name
		{ duration = self.duration } -- kv
	)
	params.attacker:AddNewModifier(
		self:GetCaster(),
		self, 
		"modifier_generic_stunned_lua", 
		{duration = self.stun_duration}
	)
	local parent = self.illusion
	local origin = params.attacker:GetOrigin()
	local seen = self:GetCaster():CanEntityBeSeenByMyTeam( params.attacker )

	if not seen then
		if (parent:GetOrigin()-origin):Length2D()>self.distance/2 then
			-- move to position
			parent:MoveToPosition( origin )
		end
	else
		if parent:GetAggroTarget()~=params.attacker then
			-- command to attack target
			local order = {
				UnitIndex = parent:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = params.attacker:entindex(),
			}
			ExecuteOrderFromTable( order )
		end
	end
		-- Play effects
	local sound_cast = "gimn"
	EmitSoundOn( sound_cast, self.illusion )
end