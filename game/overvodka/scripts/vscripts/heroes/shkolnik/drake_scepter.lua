LinkLuaModifier("modifier_drake_scepter", "heroes/shkolnik/drake_scepter", LUA_MODIFIER_MOTION_NONE)

drake_scepter = class({})

function drake_scepter:Precache(context)
    PrecacheResource( "particle", "particles/step_effect.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/drake_scepter.vsndevts", context )
end

function drake_scepter:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function drake_scepter:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_drake_scepter", {duration = duration})
end

modifier_drake_scepter = class({})

function modifier_drake_scepter:IsPurgable() return false end

function modifier_drake_scepter:OnCreated()
    if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.bonus_radius = self:GetAbility():GetSpecialValueFor("bonus_radius")
    self.interval = self:GetAbility():GetSpecialValueFor("interval")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
	self:GetParent():EmitSound("drake_scepter_"..RandomInt(1,2))
	self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_drake_scepter:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_drake_scepter:OnDestroy()
	if not IsServer() then return end
end

function modifier_drake_scepter:OnIntervalThink()
	if not IsServer() then return end
	self:Pulse()
    self.radius = self.radius + self.bonus_radius
end

function modifier_drake_scepter:Pulse()
	local effect_cast = ParticleManager:CreateParticle( "particles/step_effect.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	self:GetParent():EmitSound("Hero_PrimalBeast.Trample")
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local parent_origin = parent:GetAbsOrigin()
    local caster_origin = caster:GetAbsOrigin()
	local enemies = FindUnitsInRadius( parent:GetTeamNumber(), parent_origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    local damage_table = {
        attacker = parent,
        damage = self.damage,
        ability = ability,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
	for _, target in pairs(enemies) do
        damage_table.victim = target
		ApplyDamage(damage_table)
        if target and not target:IsNull() then
            local target_origin = target:GetAbsOrigin()
            local distance = (caster_origin - target_origin):Length2D()
            local direction = (caster_origin - target_origin):Normalized()
            local bump_point = target_origin + direction * (distance + 20)
        
            local knockbackProperties =
            {
                should_stun = true,
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = self.stun_duration,
                knockback_duration = self.stun_duration,
                knockback_distance = 40,
                knockback_height = 40
            }
            target:AddNewModifier( caster, ability, "modifier_knockback", knockbackProperties )
        end
	end
end

function modifier_drake_scepter:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end