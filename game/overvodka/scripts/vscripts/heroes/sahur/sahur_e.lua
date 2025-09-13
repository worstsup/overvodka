LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sahur_e_thinker", "heroes/sahur/sahur_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sahur_e", "heroes/sahur/sahur_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sahur_e_jump", "heroes/sahur/sahur_e", LUA_MODIFIER_MOTION_BOTH )

sahur_e = class({})

function sahur_e:OnAbilityPhaseStart()
	EmitSoundOn("sahur_e_start", self:GetCaster())
	return true
end

function sahur_e:GetBehavior()
	local additive = self:GetSpecialValueFor("jump_end") == 1 and 1099511627776 or 0
    local behavior = self.BaseClass.GetBehavior(self)
    return tonumber(tostring(behavior)) + additive
end

function sahur_e:GetIntrinsicModifierName()
	return "modifier_sahur_e"
end


modifier_sahur_e = class({})

function modifier_sahur_e:IsHidden() return true end
function modifier_sahur_e:IsPurgable() return false end
function modifier_sahur_e:RemoveOnDeath() return false end

function modifier_sahur_e:OnCreated()
	if not IsServer() then return end
end

function modifier_sahur_e:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
	}
end


function modifier_sahur_e:OnOrder( params )
	if params.unit~=self:GetParent() then return end
	if params.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_ALT then
    	FireGameEvent("event_toggle_alt_cast", 
    	{
            ent_index = self:GetAbility():GetEntityIndex(),
            is_alted = not self:GetAbility().alt_casted
        })
        self:GetAbility().alt_casted = not self:GetAbility().alt_casted
	end
end

function sahur_e:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local damage = self:GetSpecialValueFor("damage")
	local distance = self:GetCastRange( point, caster )
	local duration = self:GetSpecialValueFor("fissure_duration")
	local radius = self:GetSpecialValueFor("fissure_radius")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local block_width = 24
	local block_delta = 8.25
	local direction = point-caster:GetOrigin()
    if point == caster:GetAbsOrigin() then
        direction = caster:GetForwardVector()
    end
	direction.z = 0
	direction = direction:Normalized()
	local wall_vector = direction * distance
	local block_spacing = (block_delta+2*block_width)
	local blocks = distance/block_spacing
	local block_pos = caster:GetHullRadius() + block_delta + block_width
	local start_pos = caster:GetOrigin() + direction*block_pos

	for i=1,blocks do
		local block_vec = caster:GetOrigin() + direction*block_pos
		local blocker = CreateModifierThinker(
			caster,
			self,
			"modifier_sahur_e_thinker",
			{ duration = duration },
			block_vec,
			caster:GetTeamNumber(),
			true
		)
		blocker:SetHullRadius( block_width )
		block_pos = block_pos + block_spacing
	end

	local end_pos = start_pos + wall_vector
	local units = FindUnitsInLine(
		caster:GetTeamNumber(),
		start_pos,
		end_pos,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0
	)

	local damageTable = {
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}
	for _,unit in pairs(units) do
		FindClearSpaceForUnit( unit, unit:GetOrigin(), true )
		if unit:GetTeamNumber()~=caster:GetTeamNumber() then
			damageTable.victim = unit
			ApplyDamage(damageTable)
			if unit and not unit:IsNull() then
				unit:AddNewModifier(
					caster,
					self,
					"modifier_generic_stunned_lua",
					{ duration = stun_duration }
				)
			end
		end
	end
	if self:GetSpecialValueFor("jump_end") == 1 and self:GetAltCastState() then
		local jump_duration = 0.5
		local jump_height = 150
		local jump_start = caster:GetOrigin()
		local jump_end = end_pos
		caster:AddNewModifier(caster, self, "modifier_sahur_e_jump", {
			duration = jump_duration,
			jump_duration = jump_duration,
			jump_height = jump_height,
			start_x = jump_start.x,
			start_y = jump_start.y,
			end_x = jump_end.x,
			end_y = jump_end.y
		})
	end
	self:PlayEffects( start_pos, end_pos, duration )
end

function sahur_e:PlayEffects( start_pos, end_pos, duration )
	local particle_cast = "particles/econ/items/earthshaker/deep_magma/deep_magma_default/deep_magma_default_fissure.vpcf"
	local sound_cast = "sahur_e"
	local caster = self:GetCaster()
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, start_pos )
	ParticleManager:SetParticleControl( effect_cast, 1, end_pos )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( start_pos, sound_cast, caster )
	EmitSoundOnLocationWithCaster( end_pos, sound_cast, caster )
end


modifier_sahur_e_jump = class({})

function modifier_sahur_e_jump:IsHidden() return true end
function modifier_sahur_e_jump:IsPurgable() return false end
function modifier_sahur_e_jump:GetMotionPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_sahur_e_jump:OnCreated(kv)
	if IsServer() then
		self.jump_duration = kv.jump_duration or 0.5
		self.jump_height = kv.jump_height or 150
		self.start_pos = Vector(tonumber(kv.start_x), tonumber(kv.start_y), GetGroundHeight(Vector(tonumber(kv.start_x), tonumber(kv.start_y), 0), self:GetParent()))
		self.end_pos = Vector(tonumber(kv.end_x), tonumber(kv.end_y), GetGroundHeight(Vector(tonumber(kv.end_x), tonumber(kv.end_y), 0), self:GetParent()))
		self.elapsed_time = 0
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
		if self:ApplyVerticalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_sahur_e_jump:UpdateHorizontalMotion(me, dt)
	if IsServer() then
		self.elapsed_time = self.elapsed_time + dt
		local progress = math.min(self.elapsed_time / self.jump_duration, 1)
		local newPos = self.start_pos + (self.end_pos - self.start_pos) * progress
		local currentPos = me:GetAbsOrigin()
		me:SetAbsOrigin(Vector(newPos.x, newPos.y, currentPos.z))
	end
end

function modifier_sahur_e_jump:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end
function modifier_sahur_e_jump:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_sahur_e_jump:UpdateVerticalMotion(me, dt)
	if IsServer() then
		local progress = math.min(self.elapsed_time / self.jump_duration, 1)
		local zOffset = self.jump_height * math.sin(math.pi * progress)
		local pos = me:GetAbsOrigin()
		pos.z = GetGroundHeight(pos, me) + zOffset
		me:SetAbsOrigin(pos)
		if progress >= 1 then
			self:Destroy()
		end
	end
end

function modifier_sahur_e_jump:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_sahur_e_jump:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_sahur_e_jump:OnDestroy()
	if IsServer() then
		me = self:GetParent()
		me:RemoveHorizontalMotionController(self)
		me:RemoveVerticalMotionController(self)
	end
end

modifier_sahur_e_thinker = class({})

function modifier_sahur_e_thinker:IsHidden() return true end
function modifier_sahur_e_thinker:IsPurgable() return false end

function modifier_sahur_e_thinker:OnDestroy( kv )
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_EarthShaker.FissureDestroy", self:GetCaster() )
		UTIL_Remove(self:GetParent())
	end
end