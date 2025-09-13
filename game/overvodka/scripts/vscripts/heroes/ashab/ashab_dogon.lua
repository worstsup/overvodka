ashab_dogon = class({})
LinkLuaModifier( "modifier_ashab_dogon", "heroes/ashab/ashab_dogon", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_ashab_dogon_debuff", "heroes/ashab/ashab_dogon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_magresist_ashab", "heroes/ashab/ashab_dogon", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_BOTH )

function ashab_dogon:Precache( context )
	PrecacheResource( "particle", "particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_mesh.vpcf", context )
	PrecacheResource( "particle", "particles/spirit_breaker_charge_target_new.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/dogon.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/ashab_oi.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/razgrom.vsndevts", context )
end

function ashab_dogon:Spawn()
	if not IsServer() then return end
end

function ashab_dogon:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	caster:AddNewModifier(
		caster,
		self,
		"modifier_ashab_dogon",
		{ target = target:entindex() }
	)
end

modifier_ashab_dogon = class({})

function modifier_ashab_dogon:IsHidden()
	return false
end
function modifier_ashab_dogon:IsDebuff()
	return false
end
function modifier_ashab_dogon:IsPurgable()
	return false
end

function modifier_ashab_dogon:OnCreated( kv )
	self.parent = self:GetParent()
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed" )
	self.duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.magresist_duration = self:GetAbility():GetSpecialValueFor( "magresist_duration" )
	if not IsServer() then return end
	self.target = EntIndexToHScript( kv.target )
	self.direction = self:GetParent():GetForwardVector()
	self.targets = {}
	self.search_radius = 4000
	self.tree_radius = 150
	self.min_dist = 150
	self.offset = 20
	self.interrupted = false

	if not self:ApplyHorizontalMotionController() then
		self.interrupted = true
		self:Destroy()
	end
	self:SetTarget( self.target )
	self:GetAbility():SetActivated( false )
	local sound_cast = "dogon"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function modifier_ashab_dogon:OnDestroy()
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree_radius, true )
	self:GetParent():RemoveHorizontalMotionController( self )
	if self.debuff and (not self.debuff:IsNull()) then
		self.debuff:Destroy()
	end
	self:GetAbility():SetActivated( true )
	self:GetAbility():UseResources( false, false, false, true )
	if self.interrupted then return end
	self.parent:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_magresist_ashab",
		{ duration = self.magresist_duration }
	)
	self.target:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_generic_stunned_lua",
		{ duration = self.duration }
	)
	ApplyDamage({attacker = self:GetParent(), victim = self.target, ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
	if self.target:IsAlive() then
		local order = {
			UnitIndex = self.parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self.target:entindex(),
		}
		ExecuteOrderFromTable( order )
	end
	local sound_cast = "razgrom"
	local particle_cast = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.target )
	EmitSoundOn( sound_cast, self.target )
end

function modifier_ashab_dogon:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_ashab_dogon:GetOverrideAnimation()
	return ACT_DOTA_POOF_END
end 

function modifier_ashab_dogon:OnOrder( params )
	if params.unit~=self.parent then return end
	if
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION or
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET or
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION or
		params.order_type==DOTA_UNIT_ORDER_CAST_POSITION or
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET or
		params.order_type==DOTA_UNIT_ORDER_CAST_TARGET_TREE or
		params.order_type==DOTA_UNIT_ORDER_CAST_RUNE or
		params.order_type==DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION
	then
		self.interrupted = true
		EmitSoundOn( "ashab_oi", self.parent)
		self:Destroy()
	end
end

function modifier_ashab_dogon:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_ashab_dogon:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_ashab_dogon:UpdateHorizontalMotion( me, dt )
	self:CancelLogic()
	local direction = self.target:GetOrigin()-me:GetOrigin()
	local dist = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()
	if dist<self.min_dist then
		self:Destroy()
		return
	end
	local pos = me:GetOrigin() + direction * me:GetIdealSpeed() * dt
	pos = GetGroundPosition( pos, me )
	me:SetOrigin( pos )
	self.direction = direction
	self.parent:FaceTowards( self.target:GetOrigin() )
end

function modifier_ashab_dogon:OnHorizontalMotionInterrupted()
	self.interrupted = true
	self:Destroy()
end

function modifier_ashab_dogon:CancelLogic()
	local check = self.parent:IsHexed() or self.parent:IsStunned() or self.parent:IsRooted()
	if check then
		EmitSoundOn( "ashab_oi", self.parent)
		self.interrupted = true
		self:Destroy()
	end
	if not self.target:IsAlive() then
		local enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(),
			self.target:GetOrigin(),
			nil,
			self.search_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_CLOSEST,
			false
		)
		if #enemies<1 then
			self.interrupted = true
			self:Destroy()
			return
		else
			self:SetTarget( enemies[1] )
		end
	end
end

function modifier_ashab_dogon:SetTarget( target )
	if self.debuff and (not self.debuff:IsNull()) then
		self.debuff:Destroy()
	end
	self.debuff = target:AddNewModifier(
		self.parent,
		self:GetAbility(),
		"modifier_ashab_dogon_debuff",
		{}
	)
	self.target = target
	self.targets[target] = true
end

function modifier_ashab_dogon:GetEffectName()
	return "particles/econ/items/primal_beast/primal_beast_2022_prestige/primal_beast_2022_prestige_onslaught_charge_mesh.vpcf"
end

function modifier_ashab_dogon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_ashab_dogon_debuff = class({})

function modifier_ashab_dogon_debuff:IsHidden()
	if IsClient() then
		return GetLocalPlayerTeam()~=self:GetCaster():GetTeamNumber()
	end

	return true
end

function modifier_ashab_dogon_debuff:IsDebuff()
	return true
end
function modifier_ashab_dogon_debuff:IsHidden()
	return true
end
function modifier_ashab_dogon_debuff:IsPurgable()
	return false
end

function modifier_ashab_dogon_debuff:OnCreated( kv )
	if not IsServer() then return end
	self:PlayEffects()
end

function modifier_ashab_dogon_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end

function modifier_ashab_dogon_debuff:GetModifierProvidesFOWVision()
	return 1
end

function modifier_ashab_dogon_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
	return state
end

function modifier_ashab_dogon_debuff:PlayEffects()
	local particle_cast = "particles/spirit_breaker_charge_target_new.vpcf"
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber() )
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

modifier_magresist_ashab = class({})

function modifier_magresist_ashab:IsPurgable()
	return false
end

function modifier_magresist_ashab:CheckState()
	local state = {
		[MODIFIER_STATE_DEBUFF_IMMUNE] = true,
	}

	return state
end
function modifier_magresist_ashab:GetEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf"
end

function modifier_magresist_ashab:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end