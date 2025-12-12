LinkLuaModifier("modifier_item_shemelis", "items/shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_movement", "items/shemelis", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_shemelis_debuff", "items/shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_movement_damage", "items/shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_movement_listener", "items/shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shemelis_barrier", "items/shemelis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

item_shemelis = class({})

function item_shemelis:GetIntrinsicModifierName()
    return "modifier_item_shemelis"
end

function item_shemelis:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:TriggerSpellAbsorb(self) then return end
    local point = target:GetAbsOrigin()
    if point == self:GetCaster():GetAbsOrigin() then
        point = point + self:GetCaster():GetForwardVector()
    end
    local direction = point - self:GetCaster():GetAbsOrigin()
    local length = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local speed = self:GetSpecialValueFor("speed")
    local distance = math.min(length, self:GetSpecialValueFor("range"))
    EmitSoundOn("shemelis_whoosh", self:GetCaster())
    target:AddNewModifier(self:GetCaster(), self, "modifier_item_shemelis_debuff", {duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_shemelis_movement", {duration = distance/speed})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_shemelis_movement_listener", {duration = distance/speed})
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = distance,
            duration = distance/speed,
        }
    )
end

modifier_item_shemelis_movement = class({})
function modifier_item_shemelis_movement:IsPurgable() return false end
function modifier_item_shemelis_movement:IsHidden() return true end
function modifier_item_shemelis_movement:IsAura() return true end
function modifier_item_shemelis_movement:GetAuraDuration() return 0 end
function modifier_item_shemelis_movement:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_shemelis_movement:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_item_shemelis_movement:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_shemelis_movement:GetModifierAura() return "modifier_item_shemelis_movement_damage" end
function modifier_item_shemelis_movement:GetAuraRadius() return 100 end

function modifier_item_shemelis_movement:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/shemelis_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_item_shemelis_movement:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    ExecuteOrderFromTable({
        UnitIndex = self:GetCaster():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = self:GetCaster():GetAbsOrigin(),
        Queue = true,
    })
end

modifier_item_shemelis_movement_damage = class({})
function modifier_item_shemelis_movement_damage:IsPurgable() return false end
function modifier_item_shemelis_movement_damage:IsHidden() return true end

function modifier_item_shemelis_movement_damage:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
	local duration = self:GetAbility():GetSpecialValueFor("duration")
    parent:AddNewModifier(caster, self:GetAbility(), "modifier_item_shemelis_debuff", { duration = duration * (1 - parent:GetStatusResistance()) })
    local hit_blood = ParticleManager:CreateParticle("particles/shemelis_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(hit_blood, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_blood)
    caster:PerformAttack(parent, true, true, true, true, false, false, true)
end

modifier_item_shemelis_debuff = class({})

function modifier_item_shemelis_debuff:IsPurgable()
    return true
end

function modifier_item_shemelis_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_shemelis_debuff:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("slow_movespeed")
end

function modifier_item_shemelis_debuff:GetEffectName()
    return "particles/items_fx/diffusal_slow.vpcf"
end

function modifier_item_shemelis_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_item_shemelis = class({})

function modifier_item_shemelis:IsHidden() return true end
function modifier_item_shemelis:IsPurgable() return false end
function modifier_item_shemelis:IsPurgeException() return false end
function modifier_item_shemelis:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_shemelis:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_shemelis:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('agi')
end

function modifier_item_shemelis:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('int')
end

function modifier_item_shemelis:GetModifierPreAttack_BonusDamage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('dmg')
end

function modifier_item_shemelis:GetModifierEvasion_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('ev')
end

function modifier_item_shemelis:GetModifierAttackSpeedPercentage()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('attack')
end

function modifier_item_shemelis:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsWard() then return end
	if params.target:IsMagicImmune() then return end
	if self:GetParent():FindAllModifiersByName("modifier_item_shemelis")[1] ~= self then return end
	if self:GetParent():HasModifier("modifier_item_bloodthorn_arena") then return end
	
    local target = params.target

	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	local manaBurn = self:GetAbility():GetSpecialValueFor("mana_per_hit")
	local manaDamage = self:GetAbility():GetSpecialValueFor("damage_per_burn")

	local damageTable = {}
	damageTable.attacker = self:GetParent()
	damageTable.victim = target
	damageTable.damage_type = DAMAGE_TYPE_PHYSICAL
	damageTable.ability = self:GetAbility()

	if(target:GetMana() >= manaBurn) then
		damageTable.damage = manaBurn * manaDamage
		if not self:GetParent():IsIllusion() then
			target:Script_ReduceMana(manaBurn, self:GetAbility())
		else
			target:Script_ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"), self:GetAbility())
		end
	else
		damageTable.damage = target:GetMana() * manaDamage
		if not self:GetParent():IsIllusion() then
			target:Script_ReduceMana(manaBurn, self:GetAbility())
		else
			target:Script_ReduceMana(self:GetAbility():GetSpecialValueFor("mana_per_hit_illusion"), self:GetAbility())
		end
	end

	ApplyDamage(damageTable)
end

modifier_item_shemelis_movement_listener = class({})

function modifier_item_shemelis_movement_listener:IsHidden() return true end
function modifier_item_shemelis_movement_listener:IsPurgable() return false end

function modifier_item_shemelis_movement_listener:OnCreated(kv)
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.barrier_pct = self.ability:GetSpecialValueFor("barrier_pct") or 0
    self.barrier_duration = self.ability:GetSpecialValueFor("barrier_duration") or nil
end

function modifier_item_shemelis_movement_listener:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_item_shemelis_movement_listener:OnTakeDamage(params)
    if not IsServer() then return end
    if not params.attacker or params.attacker ~= self.parent then return end
    if not params.unit or params.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if not params.damage or params.damage <= 0 then return end

    if params.inflictor ~= nil then
        return
    end

    if params.damage_flags and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then return end

    local damageDone = params.damage
    local barrier_value = damageDone * self.barrier_pct / 100.0
    if barrier_value <= 0 then return end
    barrier_value = math.floor(barrier_value + 0.5)

    local kv = { barrier_value = barrier_value }
    if self.barrier_duration and self.barrier_duration > 0 then kv.duration = self.barrier_duration end

    self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_shemelis_barrier", kv)
end

modifier_item_shemelis_barrier = class({})

function modifier_item_shemelis_barrier:IsPurgable() return true end
function modifier_item_shemelis_barrier:IsDebuff() return false end

function modifier_item_shemelis_barrier:OnCreated(kv)
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.parent  = self:GetParent()

    local initial = tonumber(kv and kv.barrier_value) or 0
    self.barrier_max = initial
    self.barrier_block = initial

    if kv and kv.duration then
        self:SetDuration(tonumber(kv.duration), true)
    end

    self:SetHasCustomTransmitterData(true)
    self:SendBuffRefreshToClients()
end

function modifier_item_shemelis_barrier:OnRefresh(kv)
    if not IsServer() then return end
    local add = tonumber(kv and kv.barrier_value) or 0
    if add > 0 then
        self.barrier_max = (self.barrier_max or 0) + add
        self.barrier_block = (self.barrier_block or 0) + add
    end

    if kv and kv.duration then
        self:SetDuration(tonumber(kv.duration), true)
    end

    self:SendBuffRefreshToClients()
end

function modifier_item_shemelis_barrier:OnDestroy()
    if not IsServer() then return end
end

function modifier_item_shemelis_barrier:AddCustomTransmitterData()
    self._txData = self._txData or {}
    self._txData.barrier_max   = self.barrier_max or 0
    self._txData.barrier_block = self.barrier_block or 0
    return self._txData
end

function modifier_item_shemelis_barrier:HandleCustomTransmitterData(data)
    if data.barrier_max ~= nil then self.barrier_max = data.barrier_max end
    if data.barrier_block ~= nil then self.barrier_block = data.barrier_block end
end

function modifier_item_shemelis_barrier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    }
end

function modifier_item_shemelis_barrier:GetModifierIncomingDamageConstant(params)
    if not params or not params.damage then return 0 end

    if IsClient() then
        if params.report_max then
            return self.barrier_max or 0
        else
            return self.barrier_block or 0
        end
    end

    local damage = params.damage
    if damage <= 0 then return 0 end

    if damage >= (self.barrier_block or 0) then
        local blocked = self.barrier_block or 0
        self:Destroy()
        return -blocked
    else
        self.barrier_block = (self.barrier_block or 0) - damage
        self:SendBuffRefreshToClients()
        return -damage
    end
end