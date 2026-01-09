LinkLuaModifier( "modifier_silvername_w_facet_3", "heroes/silvername/silvername_w_facet_3", LUA_MODIFIER_MOTION_HORIZONTAL )

silvername_w_facet_3 = class({})

function silvername_w_facet_3:GetCastRange( vLocation, hTarget )
	if IsClient() then
		return self:GetSpecialValueFor( "cast_range" )
	end
end

function silvername_w_facet_3:OnAbilityUpgrade( hAbility )
	if not IsServer() then return end
	self.BaseClass.OnAbilityUpgrade( self, hAbility )
	self:EnableAbilityChargesOnTalentUpgrade( hAbility, "special_bonus_unique_silvername_8" )
end

function silvername_w_facet_3:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
    local origin = caster:GetAbsOrigin()
	local point = self:GetCursorPosition()
    local max_range = self:GetSpecialValueFor( "cast_range" )
	local direction = (point - origin)
    if direction:Length2D() > max_range then
		point = origin + direction:Normalized() * max_range
	end

	if caster:HasModifier( "modifier_silvername_w_facet_3" ) then
		self:RefundManaCost()
        self:SetCurrentAbilityCharges( self:GetCurrentAbilityCharges() + 1 )
		return
	end
	caster:AddNewModifier( caster, self, "modifier_silvername_w_facet_3", { x = point.x, y = point.y } )
end


modifier_silvername_w_facet_3 = class({})

function modifier_silvername_w_facet_3:IsHidden() return false end
function modifier_silvername_w_facet_3:IsDebuff() return false end
function modifier_silvername_w_facet_3:IsStunDebuff() return false end
function modifier_silvername_w_facet_3:IsPurgable() return false end

function modifier_silvername_w_facet_3:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.team = self.parent:GetTeamNumber()

	self.radius = self:GetAbility():GetSpecialValueFor( "ball_lightning_aoe" )
	self.vision = self:GetAbility():GetSpecialValueFor( "ball_lightning_vision_radius" )
	self.speed = self:GetAbility():GetSpecialValueFor( "ball_lightning_move_speed" )

	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	self.center = Vector( kv.x, kv.y, 0 )
	self.origin = self:GetParent():GetAbsOrigin()

	self.damageTable = { attacker = self.parent, damage = self.damage, damage_type = self.abilityDamageType, ability = self.ability }

	self.travel_total = 0
	self.tree = 100
	self.tick = 100
	self.enemies = {}

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

	self:PlayEffects()
end

function modifier_silvername_w_facet_3:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
	StopSoundOn( "Hero_StormSpirit.BallLightning.Loop", self.parent )
end

function modifier_silvername_w_facet_3:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

function modifier_silvername_w_facet_3:UpdateHorizontalMotion( me, dt )
	local origin = me:GetAbsOrigin()
	local direction = self.center - origin
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	local target = origin + direction*self.speed*dt
	me:SetAbsOrigin( target )

	local enemies = FindUnitsInRadius( self.team, origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,enemy in pairs(enemies) do
		if not self.enemies[enemy] then
			self.enemies[enemy] = true
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )
		end
	end

	GridNav:DestroyTreesAroundPoint( me:GetAbsOrigin(), self.tree, false )
	AddFOWViewer( self.team, origin, self.vision, 0.1, false)
	ParticleManager:SetParticleControl( self.effect_cast, 1, origin )
	if distance<100 then
		self:Destroy()
		return
	end

	local travel = (self.origin - me:GetAbsOrigin()):Length2D()
	if travel - self.travel_total<self.tick then return end
	self.travel_total = self.travel_total + self.tick
end

function modifier_silvername_w_facet_3:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_silvername_w_facet_3:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetAbsOrigin() )
	self:AddParticle( effect_cast, false, false, -1, false, false )
	self.effect_cast = effect_cast

    EmitSoundOn( "silvername_w_facet_3", self.parent )
	EmitSoundOn( "Hero_StormSpirit.Orchid_BallLightning", self.parent )
	EmitSoundOn( "Hero_StormSpirit.BallLightning.Loop", self.parent )
end