LinkLuaModifier("modifier_mellstroy_business", "heroes/mellstroy/mellstroy_business", LUA_MODIFIER_MOTION_NONE)

mellstroy_business = class({})

function mellstroy_business:Precache(context)
    PrecacheResource("particle", "particles/mellstroy_business.vpcf", context)
    PrecacheResource("soundfile", "soundevents/biznes.vsndevts", context ) 
end

function mellstroy_business:OnSpellStart()
    if not IsServer() then return end
    local gold_cost = self:GetSpecialValueFor( "gold_cost" ) + self:GetSpecialValueFor("shield_from_gold")  * PlayerResource:GetGold(self:GetCaster():GetPlayerID()) * 0.01
    local player_id = self:GetCaster():GetPlayerID()
    PlayerResource:SpendGold(player_id, gold_cost, 4)
    local duration = self:GetSpecialValueFor("duration")
    local modifier_mellstroy_business = self:GetCaster():FindModifierByName("modifier_mellstroy_business")
    if modifier_mellstroy_business then
        modifier_mellstroy_business:Destroy()
    end
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mellstroy_business", {duration = duration})
    self:GetCaster():EmitSound("biznes")
end

modifier_mellstroy_business = class({})

function modifier_mellstroy_business:IsPurgable() return true end

function modifier_mellstroy_business:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local gold = PlayerResource:GetGold(caster:GetPlayerID())
        if self:GetCaster():HasScepter() then
            gold = gold * 1.5
        end
        self.barrier_max = ability:GetSpecialValueFor("shield") + ability:GetSpecialValueFor("shield_from_gold") * gold * 0.01
        self.barrier_block = ability:GetSpecialValueFor("shield") + ability:GetSpecialValueFor("shield_from_gold") * gold * 0.01
        self:SetHasCustomTransmitterData( true )
        self:SendBuffRefreshToClients()
    end
end

function modifier_mellstroy_business:AddCustomTransmitterData()
    return {
        barrier_max = self.barrier_max,
        barrier_block = self.barrier_block,
    }
end

function modifier_mellstroy_business:HandleCustomTransmitterData( data )
    self.barrier_max = data.barrier_max
    self.barrier_block = data.barrier_block
end

function modifier_mellstroy_business:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_mellstroy_business:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_mellstroy_business:GetModifierIncomingDamageConstant(params)
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

function modifier_mellstroy_business:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_mellstroy_business:GetEffectName()
    return "particles/mellstroy_business.vpcf"
end

function modifier_mellstroy_business:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
