amor_scepter = class({})

function amor_scepter:IsRefreshable() return false end

function amor_scepter:Precache(ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf", ctx)
end

function amor_scepter:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    for i = 0, DOTA_MAX_ABILITIES - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability and ability ~= self and ability.IsRefreshable and ability:IsRefreshable() then
            ability:EndCooldown()
            ability:RefreshCharges()
        end
    end

    for i = 0, DOTA_ITEM_MAX - 1 do
        local item = caster:GetItemInSlot(i)
        if item and item.IsRefreshable and item:IsRefreshable() then
            item:EndCooldown()
            item:RefreshCharges()
        end
    end
    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/clock_overclock_buff_recharge.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(nFXIndex)
	ParticleManager:DestroyParticle(nFXIndex, false)
    caster:EmitSound("DOTA_Item.Refresher.Activate")
    caster:EmitSound("amor_scepter")
end