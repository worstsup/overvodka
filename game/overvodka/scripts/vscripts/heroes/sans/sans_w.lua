sans_w = class({})

LinkLuaModifier( "modifier_sans_w_thinker", "heroes/sans/sans_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sans_w_bone_thinker", "heroes/sans/sans_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_sans_w_walk", "heroes/sans/sans_w", LUA_MODIFIER_MOTION_NONE )

function sans_w:IsDualVectorDirection()
	local facet_square = self:GetSpecialValueFor("facet_square") or 0
	if facet_square > 0 then
		return false
	end
	return true
end

function sans_w:GetBehavior()
    if self:GetSpecialValueFor("facet_square") > 0 then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end

    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
end

function sans_w:GetAbilityTextureName()
	if self:GetCaster():HasArcana() then
		return "sans_w_arcana"
	end
	return "sans_w"
end

function sans_w:GetVectorTargetRange()
    return self:GetSpecialValueFor("fissure_range")
end

function sans_w:OnAbilityPhaseStart()
	EmitSoundOn("sans_encount", self:GetCaster())
	return true
end

function sans_w:CreateWallLine( start_pos, end_pos, damage, duration, radius, stun_duration, damagedUnits )
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local team = caster:GetTeamNumber()

    local block_width   = 24
    local block_delta   = 8.25
    local block_spacing = (block_delta + 2*block_width)
    local startingOffset = (block_delta + block_width) * 0.5

    local wall_vector = end_pos - start_pos
    wall_vector.z = 0
    local total_distance = wall_vector:Length2D()
    if total_distance <= 0 then return end

    local dir = wall_vector:Normalized()

    local blocks = math.floor( total_distance / block_spacing )
    local block_pos = startingOffset

    for i = 1, blocks do
        local block_vec = start_pos + dir * block_pos

        local blocker = CreateModifierThinker(
            caster,
            self,
            "modifier_sans_w_thinker",
            { duration = duration },
            block_vec,
            team,
            true
        )
        if blocker and not blocker:IsNull() then
            blocker:SetHullRadius( block_width )
        end

        block_pos = block_pos + block_spacing
    end

    local units = FindUnitsInLine(
        team,
        start_pos,
        end_pos,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0
    )

    local damageTable = {
        attacker    = caster,
        damage      = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability     = self,
    }

    for _, unit in pairs(units) do
        if unit and not unit:IsNull() then
            local entid = unit:entindex()
            if not damagedUnits[entid] then
                FindClearSpaceForUnit( unit, unit:GetAbsOrigin(), true )

                if unit:GetTeamNumber() ~= team then
                    damageTable.victim = unit

                    unit:AddNewModifier(
                        caster,
                        self,
                        "modifier_generic_stunned_lua",
                        { duration = stun_duration }
                    )

                    unit:AddNewModifier(
                        caster,
                        self,
                        "modifier_knockback",
                        {
                            center_x = caster:GetAbsOrigin().x,
                            center_y = caster:GetAbsOrigin().y,
                            center_z = caster:GetAbsOrigin().z,
                            duration = 0.3,
                            knockback_duration = 0.3,
                            knockback_distance = 50,
                            knockback_height = 50
                        }
                    )

                    EmitSoundOn("sans_damage", unit)
                    ApplyDamage(damageTable)
                end

                damagedUnits[entid] = true
            end
        end
    end

    self:PlayEffects( start_pos, end_pos, duration )

    if caster:HasModifier("modifier_sans_r") then
        CreateModifierThinker(
            caster,
            self,
            "modifier_sans_w_bone_thinker",
            {
                duration    = duration,
                start_pos_x = start_pos.x,
                start_pos_y = start_pos.y,
                start_pos_z = start_pos.z,
                end_pos_x   = end_pos.x,
                end_pos_y   = end_pos.y,
                end_pos_z   = end_pos.z,
                direction_x = dir.x,
                direction_y = dir.y,
            },
            start_pos,
            team,
            false
        )
    end
end

function sans_w:CastFacetSquare( caster, center )
    if not IsServer() then return end
    if not caster or caster:IsNull() then return end

    local damage        = self:GetSpecialValueFor("damage")
    local duration      = self:GetSpecialValueFor("fissure_duration")
    local radius        = self:GetSpecialValueFor("fissure_radius")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local square_size   = self:GetSpecialValueFor("square_size_facet")

    local damagedUnits = {}

    local caster_origin = caster:GetAbsOrigin()
    local main_dir = caster_origin - center
    main_dir.z = 0

    if main_dir:Length2D() < 1 then
        main_dir = caster:GetForwardVector()
        main_dir.z = 0
    end

    main_dir = main_dir:Normalized()
    local perp_dir = Vector(-main_dir.y, main_dir.x, 0):Normalized()

    local half_side = square_size * 0.5

    local extra_len = 64
    local half_len  = half_side + extra_len

    local side1_center = center + perp_dir * half_side
    local side2_center = center - perp_dir * half_side
    local side3_center = center + main_dir * half_side
    local side4_center = center - main_dir * half_side

    local s1_start = side1_center - main_dir * half_len
    local s1_end   = side1_center + main_dir * half_len
    self:CreateWallLine(s1_start, s1_end, damage, duration, radius, stun_duration, damagedUnits)

    local s2_start = side2_center - main_dir * half_len
    local s2_end   = side2_center + main_dir * half_len
    self:CreateWallLine(s2_start, s2_end, damage, duration, radius, stun_duration, damagedUnits)

    local s3_start = side3_center - perp_dir * half_len
    local s3_end   = side3_center + perp_dir * half_len
    self:CreateWallLine(s3_start, s3_end, damage, duration, radius, stun_duration, damagedUnits)

    local s4_start = side4_center - perp_dir * half_len
    local s4_end   = side4_center + perp_dir * half_len
    self:CreateWallLine(s4_start, s4_end, damage, duration, radius, stun_duration, damagedUnits)
end


function sans_w:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if not caster or caster:IsNull() then return end

	local facet_square = self:GetSpecialValueFor("facet_square") or 0
	if facet_square <= 0 then
		return
	end

	local center = self:GetCursorPosition()
	self:CastFacetSquare(caster, center)
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
end

function sans_w:OnVectorCastStart(vStartLocation, direction_new)
	local caster = self:GetCaster()
	local center = self:GetVectorPosition()
	if self:GetSpecialValueFor("facet_square") > 0 then
		return
	end
	local target_point = center + direction_new
	local direction = (target_point - center)
	direction.z = 0
	direction = direction:Normalized()
	local caster_origin = caster:GetAbsOrigin()
    if caster_origin.x == vStartLocation.x and caster_origin.y == vStartLocation.y then
        vStartLocation = caster_origin + caster:GetForwardVector() * 50
        direction = caster:GetForwardVector()
    end
	local damage = self:GetSpecialValueFor("damage")
	local total_distance = self:GetCastRange(center, caster)
	local half_distance = total_distance / 2
	local duration = self:GetSpecialValueFor("fissure_duration")
	local radius = self:GetSpecialValueFor("fissure_radius")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local block_width = 24
	local block_delta = 8.25
	local block_spacing = (block_delta + 2*block_width)
	local startingOffset = (block_delta + block_width) * 0.5
	local damagedUnits = {}
	local directions = { direction, -direction }
	for _, currDirection in ipairs(directions) do
		local block_pos = startingOffset
		local start_pos = center + currDirection * block_pos
		local wall_vector = currDirection * half_distance
		local blocks = math.floor( half_distance / block_spacing )
		for i = 1, blocks do
			local block_vec = center + currDirection * block_pos
			local blocker = CreateModifierThinker(
				caster, 
				self,
				"modifier_sans_w_thinker",
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

		for _, unit in pairs(units) do
			if not damagedUnits[unit:entindex()] then
				FindClearSpaceForUnit( unit, unit:GetOrigin(), true )
				if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
					damageTable.victim = unit
					unit:AddNewModifier(
						caster, 
						self,
						"modifier_generic_stunned_lua",
						{ duration = stun_duration }
					)
					unit:AddNewModifier(
						caster,
						self,
						"modifier_knockback",
						{
							center_x = caster:GetAbsOrigin().x,
							center_y = caster:GetAbsOrigin().y,
							center_z = caster:GetAbsOrigin().z,
							duration = 0.3,
							knockback_duration = 0.3,
							knockback_distance = 150,
							knockback_height = 50
						}
					)
					EmitSoundOn("sans_damage", unit)
					ApplyDamage(damageTable)
				end
				if unit and not unit:IsNull() then
					damagedUnits[unit:entindex()] = true
				end
			end
		end
		self:PlayEffects( start_pos, end_pos, duration )
		if caster:HasModifier("modifier_sans_r") then
			CreateModifierThinker(
				caster,
				self,
				"modifier_sans_w_bone_thinker",
				{
					duration = duration,
					start_pos_x = start_pos.x,
					start_pos_y = start_pos.y,
					start_pos_z = start_pos.z,
					end_pos_x = end_pos.x,
					end_pos_y = end_pos.y,
					end_pos_z = end_pos.z,
					direction_x = currDirection.x,
					direction_y = currDirection.y,
				},
				start_pos,
				caster:GetTeamNumber(),
				false
			)
		end
	end
end

function sans_w:PlayEffects( start_pos, end_pos, duration )
	local particle_cast = "particles/sans_wall.vpcf"
	if self:GetCaster():HasArcana() then
		particle_cast = "particles/sans_wall_arcana.vpcf"
	end
	local sound_cast_2 
	if self:GetCaster():HasArcana() then
		sound_cast_2 = "sans_w_wall_arcana"
	else
		sound_cast_2 = "sans_w_wall"
	end
	local caster = self:GetCaster()
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, start_pos )
	ParticleManager:SetParticleControl( effect_cast, 1, end_pos )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOnLocationWithCaster( start_pos, sound_cast_2, caster )
	EmitSoundOnLocationWithCaster( end_pos, sound_cast_2, caster )
end

modifier_sans_w_thinker = class({})

function modifier_sans_w_thinker:IsHidden()
	return true
end

function modifier_sans_w_thinker:IsPurgable()
	return false
end

function modifier_sans_w_thinker:OnCreated()
    if IsServer() then
        self.radius = 150
        self:StartIntervalThink(0.1)
    end
end
function modifier_sans_w_thinker:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        
        if caster and IsValidEntity(caster) and self:GetAbility():GetSpecialValueFor("facet_walk") == 1 then
            local distance = (caster:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
            
            if distance <= self.radius then
                caster:AddNewModifier(
                    caster,
                    self:GetAbility(),
                    "modifier_sans_w_walk",
                    {duration = 0.15} 
                )
            end
        end
    end
end
function modifier_sans_w_thinker:OnRefresh()
end

modifier_sans_w_bone_thinker = class({})

function modifier_sans_w_bone_thinker:IsHidden() return true end
function modifier_sans_w_bone_thinker:IsPurgable() return false end

function modifier_sans_w_bone_thinker:OnCreated(params)
    if IsServer() then
        self.start_pos = Vector(params.start_pos_x, params.start_pos_y, params.start_pos_z)
        self.end_pos = Vector(params.end_pos_x, params.end_pos_y, params.end_pos_z)
        self.wall_direction = Vector(params.direction_x, params.direction_y, 0):Normalized()
        self.perpendicular = Vector(-self.wall_direction.y, self.wall_direction.x, 0):Normalized()
		self.damage_mini = self:GetCaster():FindAbilityByName("sans_r"):GetSpecialValueFor("damage_mini")
		self.duration = self:GetCaster():FindAbilityByName("sans_r"):GetSpecialValueFor("ministun")
        self.radius = 200
		self.interval = 0.2
		if self:GetAbility():GetSpecialValueFor("facet_square") > 0 then
			self.interval = self.interval * 2
		end
        self:StartIntervalThink(self.interval)
    end
end

function modifier_sans_w_bone_thinker:OnIntervalThink()
    if IsServer() then
        local wall_length = (self.end_pos - self.start_pos):Length2D()
        local random_progress = RandomFloat(0, wall_length)
        local base_pos = self.start_pos + self.wall_direction * random_progress

        local offset_direction = self.perpendicular
        if RandomInt(0, 1) == 1 then
            offset_direction = -offset_direction
        end
        local offset_distance = RandomFloat(50, 250)
        local spawn_pos = base_pos + offset_direction * offset_distance
        spawn_pos = GetGroundPosition(spawn_pos, nil)

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            spawn_pos,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local damage_table = {
            attacker = caster,
            damage = self.damage_mini,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability
        }
        local stun_kv = { duration = self.duration }
        for _, enemy in pairs(enemies) do
			EmitSoundOn("sans_damage", enemy)
            damage_table.victim = enemy
            ApplyDamage(damage_table)
			if enemy and not enemy:IsNull() then
				enemy:AddNewModifier(caster, ability, "modifier_generic_stunned_lua", stun_kv)
			end
        end

        local particle_cast = "particles/sans_wall_w.vpcf"
		if self:GetCaster():HasArcana() then
			particle_cast = "particles/sans_wall_w_arcana.vpcf"
		end
		local effect_cast = assert(loadfile("rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( effect_cast, 0, spawn_pos + Vector(20,20,0) )
		ParticleManager:SetParticleControl( effect_cast, 1, spawn_pos + Vector(-20,-20,0) )
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end

modifier_sans_w_walk = class({})
function modifier_sans_w_walk:IsHidden() return true end
function modifier_sans_w_walk:IsPurgable() return false end
function modifier_sans_w_walk:CheckState()
	return {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end