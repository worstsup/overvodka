LinkLuaModifier("modifier_item_bablokrad", "items/item_bablokrad", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bablokrad_cooldown", "items/item_bablokrad", LUA_MODIFIER_MOTION_NONE)

item_bablokrad = class({})

function item_bablokrad:GetIntrinsicModifierName()
    return "modifier_item_bablokrad"
end

function item_bablokrad:CastFilterResultTarget(target)
    if target:HasModifier("modifier_item_bablokrad_cooldown") then
        return UF_FAIL_CUSTOM
    end
    if not target:IsRealHero() or target:GetUnitName() == "npc_hamster" then
        return UF_FAIL_CUSTOM
    end
    local nResult = UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber() )
    if nResult ~= UF_SUCCESS then
        return nResult
    end
    return UF_SUCCESS
end

function item_bablokrad:GetCustomCastErrorTarget(target)
    if target:HasModifier("modifier_item_bablokrad_cooldown") then
        return "#bablokrad_recently_used"
    end
end

function item_bablokrad:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local gold_percent = self:GetSpecialValueFor("gold")
    local gold_base = self:GetSpecialValueFor("gold_b")

    local gold = math.floor(target:GetGold() / 100 * gold_percent)
    local gold_enemy = gold + gold_base
    if target:TriggerSpellAbsorb(self) then return end

	target:EmitSound("bablokrad")
    if self:GetCaster():GetUnitName() == "npc_dota_hero_bounty_hunter" then
        self:GetCaster():EmitSound("bablokrad_mellstroy")
    end
	local midas_particle = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
	SendOverheadEventMessage(self:GetCaster(), OVERHEAD_ALERT_GOLD, self:GetCaster(), gold, nil)
    local newItem = CreateItem( "item_bag_of_gold_bablokrad", nil, nil )
    local newItem2 = CreateItem( "item_bag_of_gold_bablokrad", nil, nil )
    local newItem3 = CreateItem( "item_bag_of_gold_bablokrad", nil, nil )
	local drop = CreateItemOnPositionForLaunch( target:GetAbsOrigin(), newItem )
    local drop2 = CreateItemOnPositionForLaunch( target:GetAbsOrigin(), newItem2 )
    local drop3 = CreateItemOnPositionForLaunch( target:GetAbsOrigin(), newItem3 )
	local tpos = target:GetAbsOrigin()
    local cpos = self:GetCaster():GetAbsOrigin()
    local p1 = self:LootPosWithSideBias(self.LootTargetPosTowardCaster, tpos, cpos, -90 + RandomFloat(-15,15))
    local p2 = self:LootPosWithSideBias(self.LootTargetPosTowardCaster, tpos, cpos,  0  + RandomFloat(-15,15))
    local p3 = self:LootPosWithSideBias(self.LootTargetPosTowardCaster, tpos, cpos,  90 + RandomFloat(-15,15))
    newItem:LaunchLootInitialHeight(false, 0, 500, 0.75, p1)
    newItem2:LaunchLootInitialHeight(false, 0, 500, 0.75, p2)
    newItem3:LaunchLootInitialHeight(false, 0, 500, 0.75, p3)
	newItem:SetContextThink( "KillLoot", function() return OvervodkaGameMode:KillLoot( newItem, drop ) end, 20 )
    newItem2:SetContextThink( "KillLoot", function() return OvervodkaGameMode:KillLoot( newItem2, drop2 ) end, 20 )
    newItem3:SetContextThink( "KillLoot", function() return OvervodkaGameMode:KillLoot( newItem3, drop3 ) end, 20 )

	target:ModifyGold(-gold_enemy, false, 0)

	self:GetCaster():ModifyGold(gold, false, 0)
    local playerID = self:GetCaster():GetPlayerOwnerID()
    if playerID and PlayerResource:IsValidPlayerID(playerID) then
        if Quests and Quests.IncrementQuest then
            Quests:IncrementQuest(playerID, "bablokradAmount", gold_enemy)
        end
    end
    if IsInToolsMode() then return end
    target:AddNewModifier(self:GetCaster(), self, "modifier_item_bablokrad_cooldown", {duration = 30})
    self:SpendCharge(1)
end

function item_bablokrad:LootTargetPosTowardCaster(target_pos, caster_pos)
    local dir = caster_pos - target_pos
    dir.z = 0

    local distToCaster = dir:Length2D()
    if distToCaster < 1 then
        dir = RandomVector(1); dir.z = 0
        distToCaster = 1
    end
    dir = dir:Normalized()

    local t = distToCaster / 600
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end

    local MIN_THROW = 120
    local MAX_THROW = 400

    local base = MIN_THROW + (MAX_THROW - MIN_THROW) * t

    local dist = base + RandomFloat(-25, 25)
    if dist < MIN_THROW then dist = MIN_THROW end
    if dist > MAX_THROW then dist = MAX_THROW end

    local right = Vector(-dir.y, dir.x, 0)

    local minSide = 25
    local maxSide = 110
    local sideMax = minSide + (maxSide - minSide) * t
    local side = RandomFloat(-sideMax, sideMax)

    local forwardJitter = RandomFloat(-dist * 0.05, dist * 0.05)

    local pos = target_pos + dir * (dist + forwardJitter) + right * side
    return GetGroundPosition(pos, nil)
end

function item_bablokrad:LootPosWithSideBias(baseFunc, target_pos, caster_pos, bias)
    local pos = baseFunc(self, target_pos, caster_pos)
    local dir = caster_pos - target_pos; dir.z = 0
    dir = (dir:Length2D() > 0.01) and dir:Normalized() or RandomVector(1)
    local right = Vector(-dir.y, dir.x, 0)
    return GetGroundPosition(pos + right * bias, nil)
end

modifier_item_bablokrad_cooldown = class({})

function modifier_item_bablokrad_cooldown:IsHidden()
    return false
end

function modifier_item_bablokrad_cooldown:IsPurgable()
    return false
end

function modifier_item_bablokrad_cooldown:IsPurgeException()
    return false
end

function modifier_item_bablokrad_cooldown:GetTexture()
    return "bablokrad"
end

modifier_item_bablokrad = class({})

function modifier_item_bablokrad:IsHidden() return true end
function modifier_item_bablokrad:IsPurgable() return false end
function modifier_item_bablokrad:IsPurgeException() return false end
function modifier_item_bablokrad:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bablokrad:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_item_bablokrad:GetModifierAttackSpeedBonus_Constant()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('attackspeed')
end

function modifier_item_bablokrad:GetModifierBonusStats_Strength()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_bablokrad:GetModifierBonusStats_Agility()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end

function modifier_item_bablokrad:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor('atribute')
end