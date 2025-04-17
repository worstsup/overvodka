tartar = {}
local function RotateVector2D(vec, degrees)
    local rad = math.rad(degrees)
    local c = math.cos(rad)
    local s = math.sin(rad)
    return Vector(
        vec.x * c - vec.y * s,
        vec.x * s + vec.y * c,
        0
    )
end
function Meteor(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = caster:GetCursorPosition() + 5
	local dir0
	if target == caster:GetAbsOrigin() then
        dir0 = caster:GetForwardVector()
    end
	dir0 = (target - caster:GetAbsOrigin()):Normalized()
	dir0.z = 0
	local dist  = 1050
    local speed = 1000
	caster:EmitSound("penal")
	tartar = {}
	local baseInfo = {
        Ability             = ability,
        EffectName          = "particles/invoker_chaos_meteor_new.vpcf",
        vSpawnOrigin        = caster:GetAbsOrigin(),
        fDistance           = dist,
        fStartRadius        = 115,
        fEndRadius          = 120,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit        = true,
        bProvidesVision     = true,
        iVisionRadius       = 200,
        iVisionTeamNumber   = caster:GetTeamNumber(),
    }
    local angles = { 0 }
    local talent = caster:FindAbilityByName("special_bonus_unique_golmiy_7")
    if talent and talent:GetLevel() > 0 then
        table.insert(angles,  30)
        table.insert(angles, -30)
    end
    for _, ang in ipairs(angles) do
        local dir = RotateVector2D(dir0, ang)
        local info = shallowcopy(baseInfo)
        info.vVelocity = dir * speed
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function MeteorHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local stun_time = ability:GetLevelSpecialValueFor("meteor_stun", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local gold = ability:GetLevelSpecialValueFor("gold", ability_level)
	for _,v in ipairs(tartar) do  
		if v == target then return end
	end
	target:EmitSound("Hero_WarlockGolem.Attack")
	if target:IsRealHero() then
		caster:ModifyGold(gold, false, 0)
	end
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_time * (1 - target:GetStatusResistance())})
	ability:ApplyDataDrivenModifier( caster, target, "modifier_golmiy_penaltiy", { Duration = 5 * (1 - target:GetStatusResistance()) } )
	table.insert(tartar, target)
end

function MeteorHitDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("think_damage", ability_level)
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end