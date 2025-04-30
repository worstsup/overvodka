golden_rain = class({})

LinkLuaModifier( "modifier_golden_rain_thinker", "abilities/golden_rain", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golden_rain_delay", "abilities/golden_rain", LUA_MODIFIER_MOTION_NONE )

function golden_rain:Precache(context)
    PrecacheResource( "soundfile", "soundevents/golden_rain.vsndevts", context )
    PrecacheResource( "particle", "particles/golden_rain_start.vpcf", context )
    PrecacheResource( "particle", "particles/golden_rain_wave.vpcf", context )
end

function golden_rain:OnAbilityPhaseStart()
    delay_done = false
    local ALL_TEAMS = {
    	DOTA_TEAM_CUSTOM_1,
    	DOTA_TEAM_CUSTOM_2,
    	DOTA_TEAM_CUSTOM_3,
    	DOTA_TEAM_CUSTOM_4,
    	DOTA_TEAM_CUSTOM_5,
    	DOTA_TEAM_CUSTOM_6,
    	DOTA_TEAM_CUSTOM_7,
    	DOTA_TEAM_CUSTOM_8,
    	DOTA_TEAM_GOODGUYS,
    	DOTA_TEAM_BADGUYS
	}
    self.random_point = self:RandomPointAroundCaster()
    self.random_point.z = 0
    for _, team in ipairs(ALL_TEAMS) do
        MinimapEvent(
            	team,
            	self:GetCaster(),
            	self.random_point.x,
            	self.random_point.y,
            	DOTA_MINIMAP_EVENT_HINT_LOCATION,
            	5
        	)
		AddFOWViewer( team, self.random_point, self:GetSpecialValueFor( "radius" ), self:GetSpecialValueFor( "duration" ) + 1, false )
	end
    EmitGlobalSound( "golden_rain" )
    StopGlobalSound( "5opka_r" )
    StopGlobalSound( "stray_scepter" )
    StopGlobalSound( "evelone_r_ambient" )
    self.delay_duration = 1.5
    CreateModifierThinker(
        self:GetCaster(),
        self,
        "modifier_golden_rain_delay",
        {duration = self.delay_duration},
        self.random_point,
        self:GetCaster():GetTeamNumber(),
        false
    )
    self:PlayEffects( self.random_point )
    return true
end

function golden_rain:OnSpellStart()
    if not IsServer() then return end
    if not delay_done then return end
    self:StopEffects()
    local caster = self:GetCaster()
    local random_point = self.random_point or self:RandomPointAroundCaster()
    CreateModifierThinker(
        caster,
        self,
        "modifier_golden_rain_thinker",
        {duration = self:GetSpecialValueFor( "duration" )},
        random_point,
        caster:GetTeamNumber(),
        false
    )
end

function golden_rain:RandomPointAroundCaster()
    if GetMapName() == "overvodka_5x5" then
        local points = {
            Vector(-576, -384, 0),
            Vector(-1600, 900, 0),
            Vector(1300, -1300, 0),
            Vector(-2400, 1600, 0),
            Vector(2300, -2300, 0)
        }
        return points[RandomInt(1, #points)]
    else
        local radius_min = 2000
        local radius_max = 2500
        local random_radius = RandomFloat(radius_min, radius_max)
        local random_angle = RandomFloat(0, 2 * math.pi)
        local offset = Vector(math.cos(random_angle) * random_radius, math.sin(random_angle) * random_radius, 0)
        return self:GetCaster():GetAbsOrigin() + offset
    end
end

function golden_rain:PlayEffects( point )
    local particle_cast = "particles/golden_rain_start.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( self.effect_cast, 0, point )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 2, 2, 2 ) )
end

function golden_rain:StopEffects()
    ParticleManager:DestroyParticle( self.effect_cast, true )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

modifier_golden_rain_thinker = class({})

function modifier_golden_rain_thinker:IsHidden()
    return true
end
function modifier_golden_rain_thinker:IsPurgable()
    return false
end

function modifier_golden_rain_thinker:OnCreated( kv )
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor( "radius" )
    self.xp = self.ability:GetSpecialValueFor("xp")
    self.gold = self.ability:GetSpecialValueFor("gold")
    if GetMapName() == "overvodka_5x5" then
        self.gold = self.gold - 25
        self.xp = self.xp - 25
    end
    local particle = ParticleManager:CreateParticle("particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_army_radius.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
    self:AddParticle(particle, false, false, -1, false, false)
    local particle1 = ParticleManager:CreateParticle("particles/mk_ti9_immortal_army_radius_b_new.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle1, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle1, 1, Vector(self.radius + 25, self.radius + 25, self.radius + 25))
    self:AddParticle(particle1, false, false, -1, false, false)
    self:StartIntervalThink( 0.55 )
end

function modifier_golden_rain_thinker:OnRefresh( kv )
end
function modifier_golden_rain_thinker:OnRemoved()
end

function modifier_golden_rain_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove( self:GetParent() )
end

function modifier_golden_rain_thinker:OnIntervalThink()
    local enemies = FindUnitsInRadius(
        DOTA_TEAM_NEUTRALS,
        self.parent:GetOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER,
        false
    )
    for _,enemy in pairs(enemies) do
        enemy:ModifyGold(self.gold, false, DOTA_ModifyGold_GameTick)
        enemy:AddExperience(self.xp, DOTA_ModifyXP_Unspecified, false, false)
    end
    self:PlayEffects()
end

function modifier_golden_rain_thinker:PlayEffects()
    local particle_cast = "particles/golden_rain_wave.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_golden_rain_delay = class({})

function modifier_golden_rain_delay:IsHidden()
    return true
end

function modifier_golden_rain_delay:IsPurgable()
    return false
end

function modifier_golden_rain_delay:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(kv.duration)
end

function modifier_golden_rain_delay:OnIntervalThink()
    if not IsServer() then return end
    delay_done = true
    self:GetAbility():OnSpellStart()
    self:Destroy()
end