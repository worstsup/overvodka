amor_scepter = class({})

function amor_scepter:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    for i = 0, DOTA_MAX_ABILITIES - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability and ability ~= self and ability.IsRefreshable and ability:IsRefreshable() then
            ability:EndCooldown()
            if ability.RefreshCharges then
                ability:RefreshCharges()
            end
        end
    end

    for i = 0, DOTA_ITEM_MAX - 1 do
        local item = caster:GetItemInSlot(i)
        if item and item.IsRefreshable and item:IsRefreshable() then
            item:EndCooldown()
            if item.RefreshCharges then
                item:RefreshCharges()
            end
        end
    end

    caster:EmitSound("DOTA_Item.Refresher.Activate")
end
