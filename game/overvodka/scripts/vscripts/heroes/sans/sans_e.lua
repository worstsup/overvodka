LinkLuaModifier("modifier_sans_e", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_sans_e_stun", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_e_root", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_e_caster", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_pathing", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_e_thinker_orange", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_e_thinker_blue", "heroes/sans/sans_e", LUA_MODIFIER_MOTION_NONE)

sans_e = class({})

function sans_e:IsHiddenWhenStolen() return false end
function sans_e:IsRefreshable() return true end
function sans_e:IsStealable() return true end
function sans_e:IsNetherWardStealable() return true end

function sans_e:CastFilterResultTarget(target)
	if target == self:GetCaster() and self:GetCaster():IsRooted() then
		return UF_FAIL_CUSTOM
	else
		if self:GetSpecialValueFor("both_teams") == 0 then
			return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
		else
			return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
		end
	end
end

function sans_e:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() and self:GetCaster():IsRooted() then
		return "dota_hud_error_ability_disabled_by_root"
	end
end

function sans_e:OnSpellStart( params )
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_sans_e_caster") then
		EmitSoundOn("sans_e_start", self:GetCaster())
		local target_loc = self:GetCursorPosition()
		local maximum_distance
		if self.target:GetTeam() == caster:GetTeam() then
			maximum_distance = self:GetSpecialValueFor("ally_range") + self:GetCaster():GetCastRangeBonus()
		else
			maximum_distance = self:GetSpecialValueFor("enemy_range") + self:GetCaster():GetCastRangeBonus()
		end

		if self.telekinesis_marker_pfx then
			ParticleManager:DestroyParticle(self.telekinesis_marker_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.telekinesis_marker_pfx)
		end

		local marked_distance = (target_loc - self.target_origin):Length2D()
		if marked_distance > maximum_distance then
			target_loc = self.target_origin + (target_loc - self.target_origin):Normalized() * maximum_distance
		end

		self.telekinesis_marker_pfx = ParticleManager:CreateParticleForTeam("particles/sans_e_marker.vpcf", PATTACH_CUSTOMORIGIN, caster, caster:GetTeam())
		ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 0, target_loc)
		ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 1, Vector(3, 0, 0))
		ParticleManager:SetParticleControl(self.telekinesis_marker_pfx, 2, self.target_origin)
		ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 1, target_loc)

		self.target_modifier.final_loc = target_loc
		self.target_modifier.changed_target = true
		self:EndCooldown()
	else
		self.target = self:GetCursorTarget()
		self.target_origin = self.target:GetAbsOrigin()

		local duration
		local is_ally = true
		if self.target:GetTeam() ~= caster:GetTeam() then
			if self.target:TriggerSpellAbsorb(self) then
				return nil
			end

			duration = self:GetSpecialValueFor("enemy_lift_duration") * (1 - self.target:GetStatusResistance())
			self.target:AddNewModifier(caster, self, "modifier_sans_e_stun", { duration = duration })
			is_ally = false
		else
			duration = self:GetSpecialValueFor("ally_lift_duration")
			self.target:AddNewModifier(caster, self, "modifier_sans_e_root", { duration = duration})
		end

		self.target_modifier = self.target:AddNewModifier(caster, self, "modifier_sans_e", { duration = duration })

		if is_ally then
			self.target_modifier.is_ally = true
		end
		self.target_modifier.tele_pfx = ParticleManager:CreateParticle("particles/sans_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 2, Vector(duration,0,0))
		self.target_modifier:AddParticle(self.target_modifier.tele_pfx, false, false, 1, false, false)
		caster:EmitSound("sans_e_up")
		self.target_modifier.final_loc = self.target_origin
		self.target_modifier.changed_target = false
		caster:AddNewModifier(caster, self, "modifier_sans_e_caster", { duration = duration + FrameTime()})
		self:EndCooldown()
	end
end

function sans_e:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_sans_e_caster") then
		return "sans_e_2"
	end
	return "sans_e"
end

function sans_e:GetBehavior()
	if self:GetCaster():HasModifier("modifier_sans_e_caster") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function sans_e:GetManaCost( target )
	if self:GetCaster():HasModifier("modifier_sans_e_caster") then
		return 0
	else
		return self.BaseClass.GetManaCost(self, target)
	end
end

function sans_e:GetCastRange( location , target)
	if self:GetCaster():HasModifier("modifier_sans_e_caster") then
		return 25000
	end
	return self:GetSpecialValueFor("cast_range")
end

-------------------------------------------
modifier_sans_e_caster = class({})
function modifier_sans_e_caster:IsDebuff() return false end
function modifier_sans_e_caster:IsHidden() return true end
function modifier_sans_e_caster:IsPurgable() return false end
function modifier_sans_e_caster:IsPurgeException() return false end
function modifier_sans_e_caster:IsStunDebuff() return false end
-------------------------------------------

function modifier_sans_e_caster:OnDestroy()
	local ability = self:GetAbility()
	if ability.telekinesis_marker_pfx then
		ParticleManager:DestroyParticle(ability.telekinesis_marker_pfx, false)
		ParticleManager:ReleaseParticleIndex(ability.telekinesis_marker_pfx)
	end
end

-------------------------------------------
modifier_sans_e = class({})
function modifier_sans_e:IsDebuff()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return true end
	return false
end
function modifier_sans_e:IsHidden() return false end
function modifier_sans_e:IsPurgable() return false end
function modifier_sans_e:IsPurgeException() return false end
function modifier_sans_e:IsStunDebuff() return false end
function modifier_sans_e:IsMotionController() return true end
function modifier_sans_e:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_sans_e:OnCreated( params )
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.parent = self:GetParent()
		self.z_height = 0
		self.duration = params.duration
		self.lift_animation = ability:GetSpecialValueFor("lift_animation")
		self.fall_animation = ability:GetSpecialValueFor("fall_animation")
		self.current_time = 0

		self.frametime = FrameTime()
		self:StartIntervalThink(FrameTime())
		
		Timers:CreateTimer(FrameTime(), function()
			self.duration = self:GetRemainingTime()
		end)
	end
end

function modifier_sans_e:OnIntervalThink()
	if IsServer() then
		self:VerticalMotion(self.parent, self.frametime)
		self:HorizontalMotion(self.parent, self.frametime)
	end
end

function modifier_sans_e:EndTransition()
	if IsServer() then
		if self.transition_end_commenced then
			return nil
		end

		self.transition_end_commenced = true

		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local ally_cooldown_reduction = ability:GetSpecialValueFor("ally_cooldown")
		
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		ResolveNPCPositions(parent:GetAbsOrigin(), 150)

		parent:RemoveModifierByName("modifier_sans_e_stun")
		parent:RemoveModifierByName("modifier_sans_e_root")

		local parent_pos = parent:GetAbsOrigin()

		local ability = self:GetAbility()
		local impact_radius = ability:GetSpecialValueFor("impact_radius")
		GridNav:DestroyTreesAroundPoint(parent_pos, impact_radius, true)

		local damage = ability:GetSpecialValueFor("damage")
		local impact_stun_duration = ability:GetSpecialValueFor("impact_stun_duration")
		local impact_radius = ability:GetSpecialValueFor("impact_radius")
		parent:EmitSound("sans_e_down")
		ParticleManager:ReleaseParticleIndex(self.tele_pfx)
		local landing_pfx = ParticleManager:CreateParticle("particles/sans_e_land.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(landing_pfx, 0, parent_pos)
		ParticleManager:SetParticleControl(landing_pfx, 1, parent_pos)
		ParticleManager:ReleaseParticleIndex(landing_pfx)
		self:GetParent():AddNewModifier(caster, self:GetAbility(), "modifier_sans_pathing", { duration = 0.2})
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), parent_pos, nil, impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in ipairs(enemies) do
			if enemy ~= parent then
				enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = impact_stun_duration * (1 - enemy:GetStatusResistance())})
				enemy:AddNewModifier(caster, ability, "modifier_phased", { duration = 2})
				FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
			end
			ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
		end
		if caster:HasModifier("modifier_sans_r") then
			if self:GetAbility():GetSpecialValueFor("facet_blue") == 1 then
				CreateModifierThinker(
	    			caster,
	    			ability,
	    			"modifier_sans_e_thinker_blue",
	    			{ duration = 3 },
	    			parent_pos,
	    			caster:GetTeamNumber(),
	   				false
				)
				self:PlayEffects2(self:GetParent())
			else
				CreateModifierThinker(
    				caster,
    				ability,
    				"modifier_sans_e_thinker_orange",
    				{ duration = 3 },
    				parent_pos,
    				caster:GetTeamNumber(),
   					false
				)
				self:PlayEffects1(self:GetParent())
			end
		else
			self:PlayEffects(self:GetParent())
		end
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		ability:UseResources(true, false, false, true)
		if self.is_ally then
			local current_cooldown = ability:GetCooldownTime()
			ability:EndCooldown()
			ability:StartCooldown(current_cooldown * ally_cooldown_reduction)
		end
	end
end

function modifier_sans_e:PlayEffects(target)
	local particle_cast = "particles/sans_wall_e.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() + Vector(20,20,0) )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetAbsOrigin() + Vector(-20,-20,0) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_sans_e:PlayEffects1(target)
	local particle_cast = "particles/sans_wall_e_orange.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() + Vector(20,20,0) )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetAbsOrigin() + Vector(-20,-20,0) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 3, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_sans_e:PlayEffects2(target)
	local particle_cast = "particles/sans_wall_e_blue.vpcf"
	local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetAbsOrigin() + Vector(20,20,0) )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetAbsOrigin() + Vector(-20,-20,0) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 3, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_sans_e:VerticalMotion(unit, dt)
	if IsServer() then
		self.current_time = self.current_time + dt

		local max_height = self:GetAbility():GetSpecialValueFor("max_height")
		-- Check if it shall lift up
		if self.current_time <= self.lift_animation  then
			self.z_height = self.z_height + ((dt / self.lift_animation) * max_height)
			unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
		elseif self.current_time > (self.duration - self.fall_animation) then
			self.z_height = self.z_height - ((dt / self.fall_animation) * max_height)
			if self.z_height < 0 then self.z_height = 0 end
			unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
		else
			max_height = self.z_height
		end

		if self.current_time >= self.duration then
			self:EndTransition()
			self:Destroy()
		end
	end
end

function modifier_sans_e:HorizontalMotion(unit, dt)
	if IsServer() then

		self.distance = self.distance or 0
		if (self.current_time > (self.duration - self.fall_animation)) then
			if self.changed_target then
				local frames_to_end = math.ceil((self.duration - self.current_time) / dt)
				self.distance = (unit:GetAbsOrigin() - self.final_loc):Length2D() / frames_to_end
				self.changed_target = false
			end
			if (self.current_time + dt) >= self.duration then
				unit:SetAbsOrigin(self.final_loc)
				self:EndTransition()
			else
				unit:SetAbsOrigin( unit:GetAbsOrigin() + ((self.final_loc - unit:GetAbsOrigin()):Normalized() * self.distance))
			end
		end
	end
end

function modifier_sans_e:GetTexture()
	return "sans_e"
end

function modifier_sans_e:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sans_pathing", { duration = 0.2})
	end
end

modifier_sans_e_stun = class({})
function modifier_sans_e_stun:IsDebuff() return true end
function modifier_sans_e_stun:IsHidden() return true end
function modifier_sans_e_stun:IsPurgable() return false end
function modifier_sans_e_stun:IsPurgeException() return false end
function modifier_sans_e_stun:IsStunDebuff() return true end

function modifier_sans_e_stun:DeclareFunctions()
	local decFuns =
		{
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		}
	return decFuns
end

function modifier_sans_e_stun:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_sans_e_stun:OnCreated()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end
function modifier_sans_e_stun:onDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end	
function modifier_sans_e_stun:CheckState()
	local state =
		{
			[MODIFIER_STATE_STUNNED] = true,
		}
	return state
end

modifier_sans_e_root = class({})
function modifier_sans_e_root:IsDebuff() return false end
function modifier_sans_e_root:IsHidden() return true end
function modifier_sans_e_root:IsPurgable() return false end
function modifier_sans_e_root:IsPurgeException() return false end

-------------------------------------------

function modifier_sans_e_root:CheckState()
	local state =
		{
			[MODIFIER_STATE_ROOTED] = true,
		}
	return state
end

modifier_sans_pathing = class({})
function modifier_sans_pathing:IsDebuff() return false end
function modifier_sans_pathing:IsHidden() return true end
function modifier_sans_pathing:IsPurgable() return false end
function modifier_sans_pathing:IsPurgeException() return false end

function modifier_sans_pathing:CheckState()
	local state =
		{
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES ] = true,
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS ] = true,
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE ] = true,
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS ] = true,
			[MODIFIER_STATE_ALLOW_PATHING_THROUGH_BASE_BLOCKER ] = true,
		}
	return state
end
function modifier_sans_pathing:OnCreated()
	if not IsServer() then return end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end
function modifier_sans_pathing:OnDestroy()
	if not IsServer() then return end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end

modifier_sans_e_thinker_orange = class({})

function modifier_sans_e_thinker_orange:IsHidden() return true end
function modifier_sans_e_thinker_orange:IsPurgable() return false end

function modifier_sans_e_thinker_orange:OnCreated()
    if IsServer() then
        self.radius = self:GetAbility():GetSpecialValueFor("impact_radius")
        self.dps_pct = self:GetAbility():GetSpecialValueFor("dps_pct")
        self.interval = 0.25 
        self:StartIntervalThink(self.interval)
        self.enemy_data = {}
    end
end

function modifier_sans_e_thinker_orange:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        local current_pos = enemy:GetAbsOrigin()
        if not self.enemy_data[enemy] then
            self.enemy_data[enemy] = {
                last_pos = current_pos,
                stationary_time = 0
            }
        else
            local data = self.enemy_data[enemy]
            local distance = (current_pos - data.last_pos):Length2D()
            if distance < 50 then
                data.stationary_time = data.stationary_time + self.interval
                if data.stationary_time >= 0.5 then
                    ApplyDamage({
                        victim = enemy,
                        attacker = caster,
                        damage = enemy:GetMaxHealth() * self.dps_pct * 0.01,
                        damage_type = ability:GetAbilityDamageType(),
                        ability = ability
                    })
					EmitSoundOn("sans_damage", enemy)
                    data.stationary_time = data.stationary_time - 0.5
                end
            else
                data.stationary_time = 0
                data.last_pos = current_pos
            end
        end
    end

    for enemy, _ in pairs(self.enemy_data) do
        if not enemy:IsAlive() or (enemy:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > self.radius then
            self.enemy_data[enemy] = nil
        end
    end
end

modifier_sans_e_thinker_blue = class({})

function modifier_sans_e_thinker_blue:IsHidden() return true end
function modifier_sans_e_thinker_blue:IsPurgable() return false end

function modifier_sans_e_thinker_blue:OnCreated()
    if IsServer() then
        self.radius = self:GetAbility():GetSpecialValueFor("impact_radius")
        self.dps_pct = self:GetAbility():GetSpecialValueFor("dps_pct")
        self.interval = 0.5
        self:StartIntervalThink(self.interval)
    end
end

function modifier_sans_e_thinker_blue:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
		if enemy:IsMoving() then
        	ApplyDamage({
            	victim = enemy,
            	attacker = caster,
            	damage = enemy:GetMaxHealth() * self.dps_pct * 0.01,
            	damage_type = ability:GetAbilityDamageType(),
            	ability = ability
        	})
			EmitSoundOn("sans_damage", enemy)
		end
    end
end