sans_scepter = class({})
LinkLuaModifier("modifier_gaster_blaster_scepter", "heroes/sans/sans_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_scepter_thinker", "heroes/sans/sans_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sans_field", "heroes/sans/sans_scepter", LUA_MODIFIER_MOTION_NONE )
function sans_scepter:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function sans_scepter:GetAOERadius()
    return self:GetSpecialValueFor("radius") + 50
end

function sans_scepter:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", context)
    PrecacheResource("particle", "particles/sans_laser_2.vpcf", context)
    PrecacheResource("particle", "particles/sans_field_formation.vpcf", context)
    PrecacheResource("particle", "particles/sans_field.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_start.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_shoot.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/sans_encount.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/sans_scepter.vsndevts", context)
end
function sans_scepter:OnAbilityPhaseStart()
	EmitSoundOn("sans_encount", self:GetCaster())
end
function sans_scepter:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function sans_scepter:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function sans_scepter:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function sans_scepter:OnSpellStart()
    if not IsServer() then return end
    local cursor_pos = self:GetCaster():GetCursorPosition()
    local num = self:GetSpecialValueFor("count")
    local radius = self:GetSpecialValueFor("radius")
	local random_chance = RandomInt(1, 4)
    local duration = self:GetSpecialValueFor("duration")
    local hero_vector = GetGroundPosition(cursor_pos + Vector(0, radius, 0), nil)
	if random_chance == 2 then
		hero_vector = GetGroundPosition(cursor_pos + Vector(0, -radius, 0), nil)
	end
	if random_chance == 3 then
		hero_vector = GetGroundPosition(cursor_pos + Vector(radius, 0, 0), nil)
	end
	if random_chance == 4 then
		hero_vector = GetGroundPosition(cursor_pos + Vector(-radius, 0, 0), nil)
	end
    local ability = self
    local caster = self:GetCaster()
    local delay = self:GetSpecialValueFor("blast_delay")
    local blaster_radius = self:GetSpecialValueFor("blaster_radius")
    local laser_length = self:GetSpecialValueFor("laser_length")
    local laser_width = self:GetSpecialValueFor("laser_width")
	GridNav:DestroyTreesAroundPoint(cursor_pos, radius, true)
    AddFOWViewer(caster:GetTeamNumber(), cursor_pos, radius + 50, duration, false)
    self:GetCaster():EmitSound("sans_scepter")
    CreateModifierThinker(
		caster,
		self,
		"modifier_sans_field",
		{},
		cursor_pos,
		caster:GetTeamNumber(),
		false
	)
    for hero = 1, num*2 do
        Timers:CreateTimer(0.15 * hero, function()
            local blaster = CreateUnitByName("npc_gaster_blaster", hero_vector, false, caster, caster, caster:GetTeamNumber())
            blaster:SetAbsOrigin(hero_vector)
            blaster:AddNewModifier(caster, self, "modifier_gaster_blaster_scepter", {duration = delay + 1})
            local vDirection = (cursor_pos - blaster:GetAbsOrigin()):Normalized()
            blaster:SetForwardVector(vDirection)
            Timers:CreateTimer(delay, function()
                if not blaster:IsNull() and blaster:IsAlive() then
                    local laser_end = blaster:GetAbsOrigin() + vDirection * laser_length
                    local units = FindUnitsInLine(
                        caster:GetTeamNumber(),
                        blaster:GetAbsOrigin(),
                        laser_end,
                        nil,
                        laser_width,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        0
                    )
                    local particle = ParticleManager:CreateParticle("particles/sans_laser_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster)
                    ParticleManager:SetParticleControl(particle, 9, blaster:GetAbsOrigin())
                    ParticleManager:SetParticleControl(particle, 1, laser_end)
                    ParticleManager:ReleaseParticleIndex(particle)
                    blaster:EmitSound("gaster_blaster_shoot")
                    for _,unit in pairs(units) do
                        ApplyDamage({
                            victim = unit,
                            attacker = caster,
                            damage = self:GetSpecialValueFor("damage"),
                            damage_type = self:GetAbilityDamageType(),
                            ability = self,
                        })
                    end
				Timers:CreateTimer(0.5, function()
					UTIL_Remove(blaster)
				end)
                end
            end)
            hero_vector = RotatePosition(cursor_pos, QAngle(0, 360 / num, 0), hero_vector)
            hero_vector = GetGroundPosition(hero_vector, nil)
        end)
    end
    CreateModifierThinker(self:GetCaster(), self, "modifier_sans_scepter_thinker", {duration = duration, radius = radius}, cursor_pos, self:GetCaster():GetTeamNumber(), false)
end

modifier_sans_scepter_thinker = class({})

function modifier_sans_scepter_thinker:OnCreated(kv)
    if not IsServer() then return end
    local radius = kv.radius
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_ring.vpcf", PATTACH_POINT, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius+50,1,1))
    self:AddParticle(particle, false, false, -1, false, false)
end

modifier_gaster_blaster_scepter = class({})

function modifier_gaster_blaster_scepter:IsHidden() return true end
function modifier_gaster_blaster_scepter:IsPurgable() return false end

function modifier_gaster_blaster_scepter:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()
    parent:EmitSound("gaster_blaster_start")
end
function modifier_gaster_blaster_scepter:CheckState()
    return {
            [MODIFIER_STATE_UNSELECTABLE]=true,
            [MODIFIER_STATE_NO_HEALTH_BAR]=true,
            [MODIFIER_STATE_INVULNERABLE]=true,
            [MODIFIER_STATE_OUT_OF_GAME]=true,
            [MODIFIER_STATE_NO_UNIT_COLLISION]=true,
            [MODIFIER_STATE_NOT_ON_MINIMAP]=true,
        }
end
function modifier_gaster_blaster_scepter:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

function modifier_gaster_blaster_scepter:GetEffectName()
    return "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf"
end

function modifier_gaster_blaster_scepter:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_sans_field = class({})

function modifier_sans_field:IsHidden()
	return true
end
function modifier_sans_field:IsDebuff()
	return true
end
function modifier_sans_field:IsPurgable()
	return false
end
function modifier_sans_field:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_sans_field:OnCreated( kv )
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + 50

	self.owner = kv.isProvidedByAura~=1

	if self.owner then
		self.delay = self:GetAbility():GetSpecialValueFor( "formation_time" )
		self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
		self:SetDuration( self.delay + self.duration, false )
		self.formed = false
		self:StartIntervalThink( self.delay )
		self:PlayEffects1()
	else
		self.aura_origin = Vector( kv.aura_origin_x, kv.aura_origin_y, 0 )
		self.parent = self:GetParent()
		self.width = 100
		self.max_speed = 550
		self.min_speed = 0.1
		self.max_min = self.max_speed-self.min_speed
		self.inside = (self.parent:GetOrigin()-self.aura_origin):Length2D() < self.radius
	end
end

function modifier_sans_field:OnRefresh( kv )
	
end

function modifier_sans_field:OnRemoved()
end

function modifier_sans_field:OnDestroy()
	if not IsServer() then return end
	if self.owner then
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_sans_field:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function modifier_sans_field:GetModifierMoveSpeed_Limit( params )
	if not IsServer() then return end
	if self.owner then return 0 end
	local parent_vector = self.parent:GetOrigin()-self.aura_origin
	local parent_direction = parent_vector:Normalized()
	local actual_distance = parent_vector:Length2D()
	local wall_distance = actual_distance-self.radius
	local over_walls = false
	if self.inside ~= (wall_distance<0) then
		if math.abs( wall_distance )>self.width then
			self.inside = not self.inside
		else
			over_walls = true
		end
	end	

	wall_distance = math.abs(wall_distance)
	if wall_distance>self.width then return 0 end

	local parent_angle = 0
	if self.inside then
		parent_angle = VectorToAngles(parent_direction).y
	else
		parent_angle = VectorToAngles(-parent_direction).y
	end
	local unit_angle = self:GetParent():GetAnglesAsVector().y
	local wall_angle = math.abs( AngleDiff( parent_angle, unit_angle ) )

	local limit = 0
	if wall_angle<=90 then
		if over_walls then
			limit = self.min_speed
			self:RemoveMotions()
		else
			limit = (wall_distance/self.width)*self.max_min + self.min_speed
		end
	else
		limit = 0
	end

	return limit
end

function modifier_sans_field:RemoveMotions()
	local modifiers = self.parent:FindAllModifiers(  )

	for _,modifier in pairs(modifiers) do
		-- print("modifier:",modifier,modifier:GetName())
	end
end

function modifier_sans_field:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self.formed = true

	self:PlayEffects2()
end

function modifier_sans_field:IsAura()
	return self.owner and self.formed
end

function modifier_sans_field:GetModifierAura()
	return "modifier_sans_field"
end

function modifier_sans_field:GetAuraRadius()
	return self.radius
end

function modifier_sans_field:GetAuraDuration()
	return 0.3
end

function modifier_sans_field:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sans_field:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_sans_field:GetAuraSearchFlags()
	return 0
end

function modifier_sans_field:GetAuraEntityReject( hEntity )
	if IsServer() then
	end
	return false
end

function modifier_sans_field:PlayEffects1()
	local particle_cast = "particles/sans_field_formation.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_sans_field:PlayEffects2()
	local particle_cast = "particles/sans_field.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end