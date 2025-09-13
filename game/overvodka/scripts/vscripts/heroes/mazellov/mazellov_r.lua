LinkLuaModifier("modifier_mazellov_r", "heroes/mazellov/mazellov_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_r_hidden", "heroes/mazellov/mazellov_r", LUA_MODIFIER_MOTION_NONE)

mazellov_r = class({})

function mazellov_r:Precache(context)
    PrecacheResource( "particle", "particles/mazellov_r_effect.vpcf", context )
    PrecacheResource( "particle", "particles/mazellov_r_immune.vpcf", context )
    PrecacheResource( "particle", "particles/mazellov_r.vpcf", context )
end

function mazellov_r:IsRefreshable() return false end

function mazellov_r:CastFilterResultTarget( hTarget )
	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
		self:GetCaster():GetTeamNumber()
	)
    if hTarget:HasModifier("modifier_mazellov_r") or hTarget:HasModifier("modifier_papich_r") then
        return "Хуй тебе а не маньякич"
    end
	if nResult ~= UF_SUCCESS then
		return nResult
	end
	return UF_SUCCESS
end

function mazellov_r:OnAbilityUpgrade( hAbility )
    if not IsServer() then return end
    local result = self.BaseClass.OnAbilityUpgrade( self, hAbility )
    if hAbility == self then
        local ability = self:GetCaster():FindAbilityByName("mazellov_f")
        if ability then
            ability:SetLevel(ability:GetLevel() + 1)
        end
    end
    return result
end

function mazellov_r:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    if target:HasModifier("modifier_item_lotus_orb_active") then
        target:RemoveModifierByName("modifier_item_lotus_orb_active")
    end
    if target:TriggerSpellAbsorb( self ) then return end
	local clone = CreateUnitByName( target:GetUnitName(), target:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
    if clone then
        self.clone = clone
        clone:AddNewModifier(self:GetCaster(), self, "modifier_mazellov_r", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
        clone:SetUnitCanRespawn(true)
        clone:SetRespawnsDisabled(true)
        clone:SetForwardVector(target:GetForwardVector())
        clone:RemoveModifierByName("modifier_fountain_invulnerability")
        clone.IsRealHero = function() return true end
        clone.IsMainHero = function() return false end
        clone.IsTempestDouble = function() return true end
        clone:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
        clone:SetRenderColor(100, 100, 255)
        clone:SetAbilityPoints(0)
        clone:SetPlayerID(self:GetCaster():GetPlayerOwnerID())
        clone:SetHasInventory(false)
        clone:SetCanSellItems(false)
        if target:HasModifier("modifier_item_ultimate_scepter_consumed") then
            clone:AddNewModifier(caster, self, "modifier_item_ultimate_scepter_consumed", {duration = -1})
        end
        if target:HasShard() then
            clone:AddNewModifier(caster, self, "modifier_item_aghanims_shard", {duration = -1})
        end
        Timers:CreateTimer(FrameTime(), function()
            clone:RemoveModifierByName("modifier_fountain_invulnerability")
        end)
        for itemSlot = 0,16 do
            local itemName = target:GetItemInSlot(itemSlot)
            if itemName then
                if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_gem" and itemName:IsPermanent() then
                    local newItem = CreateItem(itemName:GetName(), nil, nil)
                    clone:AddItem(newItem)
                    if itemName and itemName:GetCurrentCharges() > 0 and newItem and not newItem:IsNull() then
                        newItem:SetCurrentCharges(itemName:GetCurrentCharges())
                    end
                    if newItem and not newItem:IsNull() then
                        clone:SwapItems(newItem:GetItemSlot(), itemSlot)
                    end
                    newItem:SetSellable(false)
                    newItem:SetDroppable(false)
                    newItem:SetShareability( ITEM_FULLY_SHAREABLE )
                    newItem:SetPurchaser( nil )
                end
            end
        end
        while clone:GetLevel() < target:GetLevel() do
            clone:HeroLevelUp( false )
            clone:SetAbilityPoints(0)
        end
        for i = 0, 24 do
            local ability = target:GetAbilityByIndex(i)
            if ability then
                local clone_ability = clone:FindAbilityByName(ability:GetAbilityName())
                if i == 5 then
                    if not self:GetCaster():HasScepter() and clone_ability then
                        clone_ability:SetActivated(false)
                    else
                        if clone_ability then
                            clone_ability:SetLevel(ability:GetLevel())
                        end
                    end
                else
                    if clone_ability then
                        clone_ability:SetLevel(ability:GetLevel())
                    end
                end
            end
        end
        clone:CalculateStatBonus(true)
        clone:SetHealth(target:GetHealth())
        clone:SetMana(target:GetMana())
    end
	target:AddNewModifier(caster, self,"modifier_mazellov_r_hidden", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance()) - 0.03})
end

modifier_mazellov_r = class ({})
function modifier_mazellov_r:IsHidden() return false end
function modifier_mazellov_r:IsPurgable() return false end
function modifier_mazellov_r:IsDebuff() return true end
function modifier_mazellov_r:RemoveOnDeath() return true end
function modifier_mazellov_r:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_LIFETIME_FRACTION,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_mazellov_r:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end

function modifier_mazellov_r:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end

function modifier_mazellov_r:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end

function modifier_mazellov_r:CheckState()
	return {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = self.talent,
	}
end

function modifier_mazellov_r:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetCaster()
    self.talent = self.caster:HasTalent("special_bonus_unique_mazellov_7")
    if self.talent then
        local p = ParticleManager:CreateParticle("particles/mazellov_r_immune.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(p, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(p, 1, self:GetParent():GetAbsOrigin())
        self:AddParticle(p, false, false, -1, false, false)
    end
    if self:GetParent():HasModifier("modifier_kolyan_e_abilities") then
        self:GetParent():RemoveModifierByName("modifier_kolyan_e_abilities")
    end
    for i = 0, DOTA_MAX_ABILITIES -1 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability then
            if (ability:GetAbilityIndex() ~= 5 and not self.caster:HasScepter()) or (ability:GetAbilityIndex() == 5 and self.caster:HasScepter()) then
                ability:EndCooldown()
                ability:RefreshCharges()
            end
		end
	end
    local forbidden_items = {"item_aeon_disk","item_lesh","item_refresher", "item_onehp"}
	for i = 0, DOTA_ITEM_MAX -1 do
		local item = self:GetParent():GetItemInSlot(i)
		if(item) and not table.contains(forbidden_items, item:GetName()) then
			item:EndCooldown()
			item:RefreshCharges()
		end
        if item and item:GetName() == "item_tpscroll" then
            self:GetParent():RemoveItem(item)
        end
	end
    self.particle = ParticleManager:CreateParticle("particles/mazellov_r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetDuration(),0,0))
	self:AddParticle(self.particle, false, false, 1, false, false)

    -- тупейший костыль, но что поделать
    Timers:CreateTimer(0.03, function()
        for i = 0, 4 do
            local ability = self:GetParent():GetAbilityByIndex(i)
            if ability then
                ability:RefreshCharges()
            end
        end
    end)

    EmitSoundOn("mazellov_r_"..RandomInt(1,2), self:GetParent())
end

function modifier_mazellov_r:GetUnitLifetimeFraction( params )
	return ( ( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration() )
end

function modifier_mazellov_r:OnTakeDamage(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end
    if self:GetParent():GetHealth() > 1 then return end
    self:Destroy()
end

function modifier_mazellov_r:GetMinHealth()
    return 1
end

function modifier_mazellov_r:GetEffectName() return "particles/mazellov_r_effect.vpcf" end
function modifier_mazellov_r:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW  end
function modifier_mazellov_r:StatusEffectPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_mazellov_r:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Stop()
    for _, mod in pairs(self:GetParent():FindAllModifiers()) do
        if mod ~= self then
            mod:Destroy()
        end
    end
    local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _, unit in pairs(units) do
        if unit ~= self:GetParent() then
            if unit:IsRealHero() and not unit:IsTempestDouble() then
                for _, mod in pairs(unit:FindAllModifiers()) do
                    if mod and not mod:IsNull() and mod:GetCaster() and not mod:GetCaster():IsNull() then
                        if mod:GetCaster() == self:GetParent() then
                            mod:Destroy()
                        end
                    end
                end
            end
        end
    end
    if self:GetAbility() and not self:GetAbility():IsNull() then
        self:GetAbility().clone = nil
    end

    if self:GetParent() and not self:GetParent():IsNull() then
        UTIL_Remove(self:GetParent())
    end
end

modifier_mazellov_r_hidden = class ({})

function modifier_mazellov_r_hidden:IsPurgable() return false end
function modifier_mazellov_r_hidden:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():AddEffects( EF_NODRAW )
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
end

function modifier_mazellov_r_hidden:OnIntervalThink()
    if not IsServer() then return end
    if self:GetAbility() then
        local clone = self:GetAbility().clone
        if clone == nil then
            self:GetParent():RemoveEffects( EF_NODRAW )
            self:GetParent():RemoveNoDraw()
            if self:GetRemainingTime() > 0.05 then
                self:GetParent():Kill( self:GetAbility(), self:GetCaster() )
            end
            self:Destroy()
            return
        end
        self:GetParent():SetAbsOrigin(clone:GetAbsOrigin())
        self:GetParent():SetForwardVector(clone:GetForwardVector())
        self:GetParent():SetHealth(clone:GetHealth())
        self:GetParent():SetMana(clone:GetMana())
        for i = 0, 5 do
            local clone_ability = clone:GetAbilityByIndex(i)
            local parent_ability = self:GetParent():GetAbilityByIndex(i)
            if clone_ability and parent_ability then
                if bit.band(clone_ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_PASSIVE) == 0 then
                    if clone_ability:GetCooldownTimeRemaining() > 0 then
                        parent_ability:StartCooldown(clone_ability:GetCooldownTimeRemaining())
                    else
                        parent_ability:EndCooldown()
                    end
                end
            end
        end
        for itemSlot = 0, 5 do
            local clone_item = clone:GetItemInSlot(itemSlot)
            local parent_item = self:GetParent():GetItemInSlot(itemSlot)
            if clone_item and parent_item then
                if clone_item:GetCooldownTimeRemaining() > 0 then
                    parent_item:StartCooldown(clone_item:GetCooldownTimeRemaining())
                else
                    parent_item:EndCooldown()
                end
            end
        end
    end
end

function modifier_mazellov_r_hidden:OnDestroy( kv )
    if not IsServer() then return end
    if not self:GetAbility() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    self:GetParent():RemoveEffects( EF_NODRAW )
    self:GetParent():RemoveNoDraw()
end

function modifier_mazellov_r_hidden:CheckState()
    local state = 
    {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true, 
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
    return state
end

function modifier_mazellov_r_hidden:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end

function modifier_mazellov_r_hidden:GetModifierAvoidDamage(params)
    return 1
end

function modifier_mazellov_r_hidden:GetDisableHealing()
    return 1
end

function modifier_mazellov_r_hidden:GetModifierTotalDamageOutgoing_Percentage()
    return -100
end