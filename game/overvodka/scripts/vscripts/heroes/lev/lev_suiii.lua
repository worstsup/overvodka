lev_suiii = class({})

LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function lev_suiii:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function lev_suiii:OnAbilityPhaseStart()
    local sounds = {"chef_q_1", "chef_q_2", "chef_q_3"}
    self.playedSoundIndex = RandomInt(1, #sounds)
    EmitSoundOn(sounds[self.playedSoundIndex], self:GetCaster())
    return true
end

function lev_suiii:OnAbilityPhaseInterrupted()
    local sounds = {"chef_q_1", "chef_q_2", "chef_q_3"}
    if self.playedSoundIndex then
        StopSoundOn(sounds[self.playedSoundIndex], self:GetCaster())
    end
end

function lev_suiii:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb( self ) then return end
	self:PlayEffects( target )
	local damage = self:GetSpecialValueFor( "damage" )
    local maxmana = caster:GetMaxMana()
    local nowmana = caster:GetMana() + self:GetManaCost(self:GetLevel() - 1)
    local pctmana = self:GetSpecialValueFor( "pctmana" )
    local dmgfinal = damage + maxmana * pctmana / 100
    if self:GetSpecialValueFor( "facet_dmg" ) > 0 then
        if nowmana >= self:GetSpecialValueFor( "facet_pct" ) * maxmana / 100 then
            dmgfinal = dmgfinal * (1 + self:GetSpecialValueFor( "facet_dmg" ) / 100)
        end
    end
    local damage_table = {}
    local target_location = target:GetAbsOrigin()
    local target_teams = self:GetAbilityTargetTeam()
    local target_types = self:GetAbilityTargetType()
    local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, self:GetSpecialValueFor( "radius" ), target_teams, target_types, 0, 0, false)
    damage_table.damage = dmgfinal
    damage_table.attacker = caster
    damage_table.damage_type = self:GetAbilityDamageType()
    if caster:HasScepter() then
        damage_table.damage_type = DAMAGE_TYPE_PURE
    end
    damage_table.ability = self
    if caster:GetUnitName() == "npc_dota_hero_lion" then
        local Talent = caster:FindAbilityByName("special_bonus_unique_lev_8")
        if Talent:GetLevel() == 1 then
            for i,unit in ipairs(units) do
                damage_table.victim = unit
                ApplyDamage(damage_table)
                unit:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor( "duration" )})
            end
        else
            damage_table.victim = target
            ApplyDamage(damage_table)
            target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor( "duration" )})
        end
    else
        damage_table.victim = target
        ApplyDamage(damage_table)
        target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor( "duration" )})
    end
end

function lev_suiii:PlayEffects( target )
	local particle_cast = "particles/econ/items/beastmaster/bm_shoulder_ti7/bm_shoulder_ti7_roar.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_mouth",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end