sans_shard = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_gaster_blaster_shard", "heroes/sans/sans_shard", LUA_MODIFIER_MOTION_NONE)

function sans_shard:Precache(context)
	PrecacheResource("particle", "particles/sans_shard.vpcf", context)
    PrecacheResource("particle", "particles/sans_shard_arcana.vpcf", context)
    PrecacheResource("particle", "particles/sans_laser_2.vpcf", context)
    PrecacheResource("particle", "particles/sans_laser_2_arcana.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", context)
    PrecacheResource("particle", "particles/gaster_blaster_spawn_arcana.vpcf", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_start.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/gaster_blaster_shoot.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/sans_shard.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/sans_shard_hit.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/sans_arcana.vsndevts", context)
end

function sans_shard:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "sans_shard_arcana"
    end
    return "sans_shard"
end

function sans_shard:OnSpellStart()
	local target = self:GetCursorTarget()
	local projectile_speed = self:GetSpecialValueFor("blast_speed")
	local projectile_name = "particles/sans_shard.vpcf"
    if self:GetCaster():HasArcana() then
        projectile_name = "particles/sans_shard_arcana.vpcf"
    end
	local info = {
		EffectName = projectile_name,
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = self:GetCaster(),
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}
	ProjectileManager:CreateTrackingProjectile( info )
	self:PlayEffects1()
end
function sans_shard:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		local caster = self:GetCaster()
		local target = hTarget
		local stun_duration = self:GetSpecialValueFor( "blast_stun_duration" )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_generic_stunned_lua", { duration = stun_duration } )
		local function RotateVector2D(vec, angle)
			local x = vec.x
			local y = vec.y
			local cos = math.cos(angle)
			local sin = math.sin(angle)
			return Vector(x * cos - y * sin, x * sin + y * cos, 0)
		end
        local unit_name = "npc_gaster_blaster"
        if caster:HasArcana() then
            unit_name = "npc_gaster_blaster_arcana"
        end
		local target_origin = target:GetAbsOrigin()
		local backward_dir = -target:GetForwardVector():Normalized()
		local angle_offset = math.rad(30)
		local dir1 = RotateVector2D(backward_dir, angle_offset) * 600
		local dir2 = RotateVector2D(backward_dir, -angle_offset) * 600
		local target_point = target_origin + dir1
		local target_point_2 = target_origin + dir2
    	local delay = self:GetSpecialValueFor("blast_delay")
    	local blaster_radius = self:GetSpecialValueFor("blaster_radius")
    	local laser_width = self:GetSpecialValueFor("laser_width")
		local blaster = CreateUnitByName(unit_name, target_point, false, caster, caster, caster:GetTeamNumber())
		local blaster_2 = CreateUnitByName(unit_name, target_point_2, false, caster, caster, caster:GetTeamNumber())
		blaster:AddNewModifier(caster, self, "modifier_gaster_blaster_shard", {duration = delay + 0.5})
		blaster_2:AddNewModifier(caster, self, "modifier_gaster_blaster_shard", {duration = delay + 0.5})
        if caster:HasArcana() then
            local arcana_particle = ParticleManager:CreateParticle("particles/gaster_blaster_spawn_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster)
            ParticleManager:SetParticleControl(arcana_particle, 0, blaster:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(arcana_particle)
            local arcana_particle_2 = ParticleManager:CreateParticle("particles/gaster_blaster_spawn_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, blaster_2)
            ParticleManager:SetParticleControl(arcana_particle_2, 0, blaster_2:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(arcana_particle_2)
        end
		AddFOWViewer(caster:GetTeamNumber(), target_point, self:GetSpecialValueFor("blaster_vision"), 2, false)
		AddFOWViewer(caster:GetTeamNumber(), target_point_2, self:GetSpecialValueFor("blaster_vision"), 2, false)
		local vDirection = (target:GetAbsOrigin() - blaster:GetAbsOrigin()):Normalized()
		local vDirection_2 = (target:GetAbsOrigin() - blaster_2:GetAbsOrigin()):Normalized()
        blaster:SetForwardVector(vDirection)
		blaster_2:SetForwardVector(vDirection_2)
        Timers:CreateTimer(delay, function()
            if not blaster:IsNull() and blaster:IsAlive() and not blaster_2:IsNull() and blaster_2:IsAlive() then
                local laser_end = target:GetAbsOrigin()
                local units = FindUnitsInLine(
                    caster:GetTeamNumber(),
                    target_point,
                    laser_end,
                    nil,
                    laser_width,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    0
                )
				local units_2 = FindUnitsInLine(
                    caster:GetTeamNumber(),
                    target_point_2,
                    laser_end,
                    nil,
                    laser_width,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    0
                )
                local particle_name
                if caster:HasArcana() then
                    particle_name = "particles/sans_laser_2_arcana.vpcf"
                else
                    particle_name = "particles/sans_laser_2.vpcf"
                end
                local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, blaster)
				local particle_2 = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, blaster_2)
                ParticleManager:SetParticleControl(particle, 9, blaster:GetAbsOrigin() + Vector(0, 0, 75))
                ParticleManager:SetParticleControl(particle, 1, laser_end)
                ParticleManager:ReleaseParticleIndex(particle)
				ParticleManager:SetParticleControl(particle_2, 9, blaster_2:GetAbsOrigin() + Vector(0, 0, 75))
                ParticleManager:SetParticleControl(particle_2, 1, laser_end)
                ParticleManager:ReleaseParticleIndex(particle_2)
                if caster:HasArcana() then
                    blaster:EmitSound("gaster_blaster_shoot_arcana")
                    blaster_2:EmitSound("gaster_blaster_shoot_arcana")
                else
                    blaster:EmitSound("gaster_blaster_shoot")
                    blaster_2:EmitSound("gaster_blaster_shoot")
                end
                for _,unit in pairs(units) do
                    ApplyDamage({
                        victim = unit,
                        attacker = caster,
                        damage = self:GetSpecialValueFor("damage"),
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    })
                end
				for _,unit in pairs(units_2) do
                    ApplyDamage({
                        victim = unit,
                        attacker = caster,
                        damage = self:GetSpecialValueFor("damage"),
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    })
                end
            blaster:ForceKill(false)
			blaster_2:ForceKill(false)
            end
        end)
		self:PlayEffects2( hTarget )
	end
	return true
end

function sans_shard:PlayEffects1()
	local sound_cast = "sans_shard"
	EmitSoundOn( sound_cast, self:GetCaster() )
end
function sans_shard:PlayEffects2( target )
	local sound_impact = "sans_shard_hit"
	EmitSoundOn( sound_impact, target )
end

modifier_gaster_blaster_shard = class({})

function modifier_gaster_blaster_shard:IsHidden() return true end
function modifier_gaster_blaster_shard:IsPurgable() return false end

function modifier_gaster_blaster_shard:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()
    if self:GetCaster():HasArcana() then
        parent:EmitSound("gaster_blaster_start_arcana")
    else
        parent:EmitSound("gaster_blaster_start")
    end
end
function modifier_gaster_blaster_shard:CheckState()
    return {
            [MODIFIER_STATE_UNSELECTABLE]=true,
            [MODIFIER_STATE_NO_HEALTH_BAR]=true,
            [MODIFIER_STATE_INVULNERABLE]=true,
            [MODIFIER_STATE_OUT_OF_GAME]=true,
            [MODIFIER_STATE_NO_UNIT_COLLISION]=true,
            [MODIFIER_STATE_NOT_ON_MINIMAP]=true,
        }
end
function modifier_gaster_blaster_shard:OnDestroy()
    if not IsServer() then return end
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

function modifier_gaster_blaster_shard:GetEffectName()
    return "particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf"
end

function modifier_gaster_blaster_shard:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end