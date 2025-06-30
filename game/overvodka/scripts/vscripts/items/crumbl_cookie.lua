LinkLuaModifier( "modifier_item_crumbl_cookie", "items/crumbl_cookie", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crumbl_cookie_aura", "items/crumbl_cookie", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crumbl_cookie_barrier", "items/crumbl_cookie", LUA_MODIFIER_MOTION_NONE )

item_crumbl_cookie = class({})

function item_crumbl_cookie:GetIntrinsicModifierName() 
    return "modifier_item_crumbl_cookie"
end

function item_crumbl_cookie:OnAbilityPhaseStart() 
    if not IsServer() then return end
    if self:GetCurrentCharges() <= 0 then
    	return false
    end
    return true
end

function item_crumbl_cookie:OnSpellStart() 
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local bonus_charge = self:GetSpecialValueFor("regen_per_charge")
    local bonus_heal_mana = self:GetCurrentCharges() * bonus_charge
    self:CheckOverheal(target, bonus_heal_mana)
    target:Heal(bonus_heal_mana, self)
    target:GiveMana(bonus_heal_mana)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, bonus_heal_mana, self:GetCaster():GetPlayerOwner())
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, target, bonus_heal_mana, self:GetCaster():GetPlayerOwner())
    self:SetCurrentCharges(0)
    EmitSoundOn("crumble_cookie", target)
  	local particle = ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex(particle)
    local particle2 = ParticleManager:CreateParticle("particles/crumble_cookies.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl( particle2, 0, target:GetAbsOrigin() )
    ParticleManager:SetParticleControl( particle2, 1, target:GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex(particle2)
    local playerID = self:GetCaster():GetPlayerOwnerID()
    if playerID and PlayerResource:IsValidPlayerID(playerID) then
        if Quests and Quests.IncrementQuest then
            Quests:IncrementQuest(playerID, "cookieHeal", bonus_heal_mana)
        end
    end
end

function item_crumbl_cookie:CheckOverheal(target, bonus_heal_mana)
    if not IsServer() then return end
    local overheal = math.max(0, bonus_heal_mana - (target:GetMaxHealth() - target:GetHealth()))
    if overheal > 0 then
        local kv = {}
        kv[ "duration" ] = self:GetSpecialValueFor("overheal_duration")
        kv[ "over" ] = overheal
        target:AddNewModifier(self:GetCaster(), self, "modifier_item_crumbl_cookie_barrier", kv)
    end
end

modifier_item_crumbl_cookie = class({})

function modifier_item_crumbl_cookie:IsHidden() return true end
function modifier_item_crumbl_cookie:IsPurgable() return false end
function modifier_item_crumbl_cookie:IsPurgeException() return false end
function modifier_item_crumbl_cookie:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_crumbl_cookie:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("charge_cooldown"))
end

function modifier_item_crumbl_cookie:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():FindAllModifiersByName("modifier_item_crumbl_cookie")[1] ~= self then return end
    if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    	self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    	if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    	end
    end
end

function modifier_item_crumbl_cookie:DeclareFunctions()
    return  
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
    }
end

modifier_item_crumbl_cookie_barrier = class({})

function modifier_item_crumbl_cookie_barrier:IsPurgable() return true end

function modifier_item_crumbl_cookie_barrier:OnCreated(kv)
    if not IsServer() then return end
    self.barrier_max = kv.over
    self.barrier_block = kv.over
    self:SetHasCustomTransmitterData( true )
    self:SendBuffRefreshToClients()
end

function modifier_item_crumbl_cookie_barrier:AddCustomTransmitterData()
    return {
        barrier_max = self.barrier_max,
        barrier_block = self.barrier_block,
    }
end

function modifier_item_crumbl_cookie_barrier:HandleCustomTransmitterData( data )
    self.barrier_max = data.barrier_max
    self.barrier_block = data.barrier_block
end

function modifier_item_crumbl_cookie_barrier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_crumbl_cookie_barrier:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_item_crumbl_cookie_barrier:GetModifierIncomingDamageConstant(params)
    if IsClient() then
		if params.report_max then
			return self.barrier_max
		else
			return self.barrier_block
		end
	end
    if params.damage >= self.barrier_block then
		self:Destroy()
        return self.barrier_block * (-1)
	else
		self.barrier_block = self.barrier_block - params.damage
        self:SendBuffRefreshToClients()
		return params.damage * (-1)
	end
end

function modifier_item_crumbl_cookie_barrier:GetEffectName()
    return "particles/crumble_cookie_effect.vpcf"
end

function modifier_item_crumbl_cookie_barrier:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_crumbl_cookie:GetModifierHealAmplify_PercentageSource()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_heal_pct')
end

function modifier_item_crumbl_cookie:GetModifierHealthBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('health')
end

function modifier_item_crumbl_cookie:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_str')
end

function modifier_item_crumbl_cookie:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_agi')
end

function modifier_item_crumbl_cookie:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('bonus_int')
end

function modifier_item_crumbl_cookie:IsAura()
    return true
end

function modifier_item_crumbl_cookie:GetModifierAura()
    return "modifier_item_crumbl_cookie_aura"
end

function modifier_item_crumbl_cookie:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_item_crumbl_cookie:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_crumbl_cookie:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_crumbl_cookie:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
end

modifier_item_crumbl_cookie_aura = class({})

function modifier_item_crumbl_cookie_aura:IsHidden() return true end
function modifier_item_crumbl_cookie_aura:IsPurgable() return false end
function modifier_item_crumbl_cookie_aura:IsPurgeException() return false end
function modifier_item_crumbl_cookie_aura:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_crumbl_cookie_aura:DeclareFunctions()
    return  
    {
    	MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_item_crumbl_cookie_aura:OnAbilityExecuted( params )
    if IsServer() then
        local hAbility = params.ability

        if hAbility == nil or not ( hAbility:GetCaster() == self:GetParent() ) then
            return 0
        end

        if hAbility:IsToggle() or hAbility:ProcsMagicStick() == false then
            return 0
        end

    	if self:GetAbility():GetCurrentCharges() < self:GetAbility():GetSpecialValueFor("max_charges") then
    		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + 1)
    		if self:GetAbility():GetCurrentCharges() > self:GetAbility():GetSpecialValueFor("max_charges") then
    			self:GetAbility():SetCurrentCharges(self:GetAbility():GetSpecialValueFor("max_charges"))
    		end
    	end
    end    
end