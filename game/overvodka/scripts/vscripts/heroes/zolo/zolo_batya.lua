zolo_batya = class({})

function zolo_batya:Precache( context )
	PrecacheResource( "soundfile", "soundevents/sharik.vsndevts", context )
	PrecacheResource( "particle", "particles/alchemist_smooth_criminal_unstable_concoction_explosion_new.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot_gold.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruspunch_start.vpcf", context)
    PrecacheResource( "particle", "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruskick_tgt.vpcf", context)
end

function zolo_batya:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function zolo_batya:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function zolo_batya:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function zolo_batya:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function zolo_batya:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_hp = self:GetSpecialValueFor("hp")
    local gold = self:GetSpecialValueFor("gold")
    local radius = self:GetSpecialValueFor("radius")
    local xp = self:GetSpecialValueFor("xp")
	local level = self:GetLevel()
	local scale = 0.35 + level * 0.05
    if caster:HasTalent("special_bonus_unique_zolo_8") then
        level = level + 1
    end
    GridNav:DestroyTreesAroundPoint( point, radius, false )
    local batya = CreateUnitByName("npc_batya", point, true, caster, caster, caster:GetTeamNumber())
	local rot = batya:FindAbilityByName("batya_radiance")
	rot:SetLevel(level)
    FindClearSpaceForUnit(batya, point, true)
    batya:SetControllableByPlayer(caster:GetPlayerID(), true)
    batya:SetOwner(caster)
	batya:SetModelScale(scale)
    batya:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    batya:SetBaseMaxHealth(base_hp)
    batya:SetMaxHealth(base_hp)
    batya:SetHealth(base_hp)
    batya:SetMaximumGoldBounty(100)
    batya:SetMinimumGoldBounty(100)
    batya:SetDeathXP(200)
	local effect_cast = ParticleManager:CreateParticle( "particles/alchemist_smooth_criminal_unstable_concoction_explosion_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, batya )
	ParticleManager:ReleaseParticleIndex(effect_cast)
	local knockbackProperties =
    {
        center_x = 0,
    	center_y = 0,
        center_z = 0,
        duration = self:GetSpecialValueFor("stun_dur"),
        knockback_duration = self:GetSpecialValueFor("stun_dur"),
        knockback_distance = 0,
        knockback_height = 350,
    }
	local knock_enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(knock_enemies) do
		if unit:HasModifier("modifier_knockback") then
            unit:RemoveModifierByName("modifier_knockback")
        end
        unit:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockbackProperties)
		ApplyDamage({victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
        self:PlayEffects( unit )
	    self:PlayEffects1( unit )
	end
    EmitSoundOn("sharik", caster)
end

function zolo_batya:PlayEffects( target )
	local particle_cast = "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruspunch_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
end

function zolo_batya:PlayEffects1( target )
	local particle_cast = "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruskick_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
end
