modifier_papich_e_charge = class({})

function modifier_papich_e_charge:IsHidden()
	return false
end
function modifier_papich_e_charge:IsDebuff()
	return false
end
function modifier_papich_e_charge:IsPurgable()
	return false
end

function modifier_papich_e_charge:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	EmitSoundOn( "papich_e_start", self.parent )
	local sound_cast = "papich_e_plane_start"
	EmitSoundOn( sound_cast, self.parent )
	self.speed = self:GetAbility():GetSpecialValueFor( "charge_speed" )
	self.turn_speed = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	if not IsServer() then return end
	self.origin = self.parent:GetOrigin()
	self.charge_finish = false
	self.target_angle = self.parent:GetAnglesAsVector().y
	self.current_angle = self.target_angle
	self.face_target = true
	local caster = self:GetParent()
    local team = caster:GetTeam()
    self.point = 0
    local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
    for _,fountainEnt in pairs( fountainEntities ) do
        if fountainEnt:GetTeamNumber() == caster:GetTeamNumber() then
            self.point = fountainEnt:GetAbsOrigin()
            break
        end
    end
    caster:FaceTowards(self.point)
	self:StartIntervalThink( FrameTime() )
	self.filter = FilterManager:AddExecuteOrderFilter( self.OrderFilter, self )
	self:PlayEffects1()
	self:PlayEffects2()
end

function modifier_papich_e_charge:OnRefresh( kv )
end

function modifier_papich_e_charge:OnRemoved()
	if not IsServer() then return end
	if not self.charge_finish then
		self.ability:OnChargeFinish( false )
	end
	FilterManager:RemoveExecuteOrderFilter( self.filter )
end

function modifier_papich_e_charge:OnDestroy()
end

function modifier_papich_e_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end
function modifier_papich_e_charge:GetMinHealth()
    return 1
end
function modifier_papich_e_charge:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	then
		self:SetDirection( self.point )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetDirection( self.point )
	end	
end

function modifier_papich_e_charge:SetDirection( location )
	local dir = ((location-self.parent:GetOrigin())*Vector(1,1,0)):Normalized()
	self.target_angle = VectorToAngles( dir ).y
	self.face_target = false
end

function modifier_papich_e_charge:GetModifierMoveSpeed_Limit()
	return 0.1
end

function modifier_papich_e_charge:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	return state
end

function modifier_papich_e_charge:OrderFilter( data )
	if data.order_type~=DOTA_UNIT_ORDER_MOVE_TO_POSITION and
		data.order_type~=DOTA_UNIT_ORDER_MOVE_TO_TARGET and
		data.order_type~=DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		return true
	end
	local found = false
	for _,entindex in pairs(data.units) do
		local entunit = EntIndexToHScript( entindex )
		if entunit==self.parent then
			found = true
		end
	end
	if not found then return true end
	data.order_type = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	if data.entindex_target~=0 then
		local pos = EntIndexToHScript( data.entindex_target ):GetOrigin()
		data.position_x = pos.x
		data.position_y = pos.y
		data.position_z = pos.z
	end
	return true
end

function modifier_papich_e_charge:OnIntervalThink()
	self:TurnLogic( FrameTime() )
	self:SetEffects()
end

function modifier_papich_e_charge:TurnLogic( dt )
	if self.face_target then return end

	local angle_diff = AngleDiff( self.current_angle, self.target_angle )
	local turn_speed = self.turn_speed*dt

	local sign = -1
	if angle_diff<0 then sign = 1 end

	if math.abs( angle_diff )<1.1*turn_speed then
		self.current_angle = self.target_angle
		self.face_target = true
	else
		self.current_angle = self.current_angle + sign*turn_speed
	end
	local angles = self.parent:GetAnglesAsVector()
	self.parent:SetLocalAngles( angles.x, self.current_angle, angles.z )
end

function modifier_papich_e_charge:PlayEffects1()
	local particle_cast = "particles/primal_beast_onslaught_range_finder_new.vpcf"
	local effect_cast = ParticleManager:CreateParticleForPlayer( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetPlayerOwner() )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
	self.effect_cast = effect_cast
	self:SetEffects()
end

function modifier_papich_e_charge:SetEffects()
	local target_pos = self.origin + self.parent:GetForwardVector() * self.speed * self:GetElapsedTime()
	ParticleManager:SetParticleControl( self.effect_cast, 1, target_pos )
end

function modifier_papich_e_charge:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_primal_beast/primal_beast_onslaught_chargeup.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
