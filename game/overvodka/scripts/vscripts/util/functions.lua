function CDOTA_BaseNPC:HasTalent(talentName)
    talentName = string.lower(talentName)
    if self:HasAbility(talentName) then
        local ability = self:FindAbilityByName(talentName)
        if ability and ability:GetLevel() > 0 then
            return true
        end
    end
    return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
    talentName = string.lower(talentName)
    if self:HasTalent(talentName) then
        local value_name = key or "value"
        return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
    end
    return 0
end

function CDOTA_BaseNPC:HasShard()
    if self:HasModifier("modifier_item_aghanims_shard") then
        return true
    end
    return false
end

function CDOTA_BaseNPC:HasArcana()
    if self:HasModifier("modifier_sans_arcana") then
        return true
    end
    return false
end

function CDOTABaseAbility:ToggleAltCast()
    ExecuteOrderFromTable({
        UnitIndex = self:GetCaster():GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TOGGLE_ALT,
        AbilityIndex = self:GetEntityIndex()
    })
end

function CDOTABaseAbility:GetAltCastState()
    return self.alt_casted or false
end