k = 0
function ItsNotNormalStart( keys )
	local target = keys.target
	if target:HasModifier("modifier_black_king_bar_immune") then return end
end

function ItsNotNormal(keys)
	local caster = keys.caster
	if (k % 2 == 0) then
		EmitSoundOn("zima_holoda", caster)
	end
	if (k % 2 == 1) then
		EmitSoundOn("ebanul_moroz", caster)
	end
	k = k + 1
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor( "radius" )
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),
	caster:GetAbsOrigin(),
	nil,
	radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
	FIND_ANY_ORDER,
	false)

	for _,unit in pairs(targets) do
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_V1lat_ItsNotNormal", {} )
	end
end