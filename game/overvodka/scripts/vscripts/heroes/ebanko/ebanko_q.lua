k = 0
function ebanko_q_start( keys )
	local target = keys.target
	if target:IsDebuffImmune() or target:IsMagicImmune() then return end
end

function ebanko_q(keys)
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
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_ebanko_q", {} )
	end
end