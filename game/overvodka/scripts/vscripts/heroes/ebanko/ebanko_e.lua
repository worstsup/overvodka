function Anim( keys )
    local caster = keys.caster
    if not keys.caster:IsMoving() then
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    else
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    end
end