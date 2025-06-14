LinkLuaModifier("modifier_mazellov_r", "heroes/mazellov/mazellov_r", LUA_MODIFIER_MOTION_NONE)

mazellov_r = class({})

function mazellov_r:Precache(context)
    PrecacheResource( "particle", "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf", context )
    PrecacheResource( "particle", "particles/mazellov_r_immune.vpcf", context )
end

function mazellov_r:IsRefreshable() return false end

function mazellov_r:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	
	local target = self:GetCursorTarget()
	local targetself = target:GetPlayerOwnerID()
	local player = caster:GetPlayerOwnerID()
	target:SetControllableByPlayer(targetself, false)
	target:SetControllableByPlayer(player, true)
	if target:HasInventory() then
		for i=0, 9, 1 do
			local current_item = target:GetItemInSlot(i)
			if current_item ~= nil then
				current_item:SetDroppable(false)
			end
		end
	end
	target:AddNewModifier(caster, self,"modifier_mazellov_r", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
end

modifier_mazellov_r = class ({})
function modifier_mazellov_r:IsHidden() return false end
function modifier_mazellov_r:IsPurgable() return false end
function modifier_mazellov_r:IsDebuff() return true end
function modifier_mazellov_r:RemoveOnDeath() return true end
function modifier_mazellov_r:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_mazellov_r:GetModifierProvidesFOWVision()
	return 1
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
		[MODIFIER_STATE_PROVIDES_VISION] = true,
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
    local ultimate = self:GetParent():GetAbilityByIndex(5)
    if ultimate and not self.caster:HasScepter() then
        ultimate:SetActivated(false)
    end
    EmitSoundOn("mazellov_r_"..RandomInt(1,2), self:GetParent())
end

function modifier_mazellov_r:OnTakeDamage(event)
    local target = event.unit
    local attacker = event.attacker
    if target == self:GetParent() then
        if target:GetHealth() <= 0 then
            target:RemoveModifierByName("modifier_mazellov_r")
            target:SetHealth(1)
            local player = self.caster:GetPlayerOwnerID()
            target:SetControllableByPlayer(player, true)
            target:SetControllableByPlayer(target:GetPlayerOwnerID(), true)
            target:Kill(self.caster:FindAbilityByName("mazellov_r"), self.caster)    
        end
    else
        if attacker == self:GetParent() and target:IsRealHero() and not target:IsIllusion() then
            if target:GetHealth() <= 0 then
                target:SetHealth(1)
                local player = self.caster:GetPlayerOwnerID()
                target:Kill(self.caster:FindAbilityByName("mazellov_r"), self.caster)
            end
        end
    end
end

function modifier_mazellov_r:GetEffectName() return "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf" end
function modifier_mazellov_r:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW  end
function modifier_mazellov_r:StatusEffectPriority() return MODIFIER_PRIORITY_HIGH end

function modifier_mazellov_r:OnDestroy()
if not IsServer() then return end    
    local caster = self.caster
    local target = self:GetParent()
    local player = caster:GetPlayerOwnerID()    
    if self:GetParent():HasModifier("modifier_kolyan_e_abilities") then
        self:GetParent():RemoveModifierByName("modifier_kolyan_e_abilities")
    end
    local ultimate = self:GetParent():GetAbilityByIndex(5)
    if ultimate and not ultimate:IsActivated() then
        ultimate:SetActivated(true)
    end
    target:SetControllableByPlayer(player, false)
    target:SetControllableByPlayer(target:GetPlayerOwnerID(), true)
    
    if self:GetParent():HasInventory() then
        for i=0, 9, 1 do
            local current_item = self:GetParent():GetItemInSlot(i)
            if current_item ~= nil then
                current_item:SetDroppable(true)
            end
        end
    end    
end