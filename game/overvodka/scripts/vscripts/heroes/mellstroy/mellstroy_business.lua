LinkLuaModifier("modifier_mellstroy_business", "heroes/mellstroy/mellstroy_business", LUA_MODIFIER_MOTION_NONE)

mellstroy_business = class({})

function mellstroy_business:Precache(context)
    PrecacheResource("particle", "particles/mellstroy_business.vpcf", context)
    PrecacheResource("particle", "particles/mellstroy_arcana/mellstroy_business_arcana.vpcf", context)
    PrecacheResource("soundfile", "soundevents/biznes.vsndevts", context ) 
end

function mellstroy_business:GetAbilityTextureName()
    if self:GetCaster():HasMellstroyArcanaSkin() then
        return "biznes_arcana"
    end
    return "biznes"
end

function mellstroy_business:GetGoldCost(iLevel)
    local base = self:GetSpecialValueFor("gold_cost")

    local low = tonumber(self:GetCaster()._low_gold) or 0
    if low == 1 then
        return math.floor(base * 0.75 + 0.5)
    end

    return base
end

function mellstroy_business:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local gold_cost = self:GetSpecialValueFor( "gold_cost" ) + self:GetSpecialValueFor("shield_from_gold")  * PlayerResource:GetGold(caster:GetPlayerID()) * 0.01
    local player_id = caster:GetPlayerID()
    PlayerResource:SpendGold(player_id, gold_cost, 4)
    local duration = self:GetSpecialValueFor("duration")
    local modifier_mellstroy_business = caster:FindModifierByName("modifier_mellstroy_business")
    if modifier_mellstroy_business then
        modifier_mellstroy_business:Destroy()
    end
    local sound = "biznes"
    if caster:HasMellstroyArcanaSkin() then
        sound = "biznes_arcana"
    end
    caster:AddNewModifier(caster, self, "modifier_mellstroy_business", {duration = duration})
    caster:EmitSound(sound)
end

modifier_mellstroy_business = class({})

function modifier_mellstroy_business:IsPurgable() return true end

function modifier_mellstroy_business:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local gold = PlayerResource:GetGold(caster:GetPlayerID())
        if caster:HasScepter() then
            gold = gold * 1.5
        end
        local particle = "particles/mellstroy_business.vpcf"
        if caster:HasMellstroyArcanaSkin() then
            particle = "particles/mellstroy_arcana/mellstroy_business_arcana.vpcf"
        end
        local p = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
        self:AddParticle(p, false, false, -1, false, false)
        self.barrier_max = ability:GetSpecialValueFor("shield") + ability:GetSpecialValueFor("shield_from_gold") * gold * 0.01
        self.barrier_block = ability:GetSpecialValueFor("shield") + ability:GetSpecialValueFor("shield_from_gold") * gold * 0.01
        self:SetHasCustomTransmitterData( true )
        self:SendBuffRefreshToClients()
    end
end

function modifier_mellstroy_business:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.barrier_max   = self.barrier_max or 0
    self._txData.barrier_block = self.barrier_block or 0
    return self._txData
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