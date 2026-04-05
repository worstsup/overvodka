silvername_q_facet_1 = class({})
LinkLuaModifier( "modifier_silvername_r_facet_1_soldier", "heroes/silvername/silvername_r_facet_1", LUA_MODIFIER_MOTION_NONE)

function silvername_q_facet_1:FindAdditionalTargets(primaryTarget, maxTargets)
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return {} end
    if not primaryTarget or primaryTarget:IsNull() then return {} end

    local extra = maxTargets - 1
    if extra <= 0 then return {} end

    local radius = self:GetCastRange(primaryTarget:GetAbsOrigin(), primaryTarget)

    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        self:GetAbilityTargetTeam(),
        self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(),
        FIND_CLOSEST,
        false
    )

    local candidates = {}
    for _,u in ipairs(units) do
        if u ~= primaryTarget then
            table.insert(candidates, u)
        end
    end

    local sorted = SortUnits_HeroesFirst(candidates)

    local result = {}
    for _,u in ipairs(sorted) do
        if #result >= extra then
            break
        end
        if u and not u:IsNull() and u:IsAlive() then
            table.insert(result, u)
        end
    end

    return result
end

function silvername_q_facet_1:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local primary = self:GetCursorTarget()
    if not caster or caster:IsNull() or not primary or primary:IsNull() then return end

    local maxTargets = self:GetSpecialValueFor("targets")
    local targets = { primary }

    local additional = self:FindAdditionalTargets(primary, maxTargets)
    for _,t in ipairs(additional) do
        table.insert(targets, t)
    end

    local speed = self:GetSpecialValueFor("chaos_bolt_speed")

    for _,target in ipairs(targets) do
        if target and not target:IsNull() then
            local info = {
                Source = caster,
                Target = target,
                Ability = self,
                iMoveSpeed = speed,
                EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
                bDodgeable = true,
                ExtraData = {
                    from_multi = 1,
                },
            }
            ProjectileManager:CreateTrackingProjectile(info)
        end
    end

    caster:EmitSound("Hero_ChaosKnight.ChaosBolt.Cast")
    caster:EmitSound("silvername_q_facet_1_"..RandomInt(1,4))
end

function silvername_q_facet_1:OnProjectileHit_ExtraData(hTarget, vLocation, kv)
    if not IsServer() then return end
    if not hTarget or hTarget:IsNull() then return end
    if hTarget:IsInvulnerable() then return end
    if hTarget:TriggerSpellAbsorb(self) then return end

    local damage_min = self:GetSpecialValueFor("damage_min")
    local damage_max = self:GetSpecialValueFor("damage_max")
    local stun_min   = self:GetSpecialValueFor("stun_min")
    local stun_max   = self:GetSpecialValueFor("stun_max")

    local rand       = RandomFloat(0, 1)
    local damage_act = self:Expand(rand,      damage_min, damage_max)
    local stun_act   = self:Expand(1 - rand,  stun_min,   stun_max)

    hTarget:AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_stunned_lua",
        { duration = stun_act }
    )

    self:PlayEffect2(hTarget, stun_act, damage_act)

    local damage = {
        victim = hTarget,
        attacker = self:GetCaster(),
        damage = damage_act,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
    ApplyDamage(damage)

    self:ApplyRandomCooldownReduction()

    if self:GetCaster():HasShard() and hTarget and not hTarget:IsNull() then
		if hTarget:IsRealHero() and hTarget:IsAlive() then
        	self:SpawnShardSoldier(hTarget)
		end
    end
end

function silvername_q_facet_1:SpawnShardSoldier(target)
    if not IsServer() then return end
    if not target or target:IsNull() or not target:IsAlive() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local shard_duration = self:GetSpecialValueFor("shard_duration") or 0
    if shard_duration <= 0 then return end

    local attack_interval = 1.0
    local r_ability = caster:FindAbilityByName("silvername_r_facet_1")
    if r_ability and not r_ability:IsNull() and r_ability:GetLevel() > 0 then
        attack_interval = r_ability:GetSpecialValueFor("attack_interval") or 1.0
	else
		return
    end

    local target_pos  = target:GetAbsOrigin()
    local caster_pos  = caster:GetAbsOrigin()
    local dir         = (target_pos - caster_pos)
    if dir:Length2D() < 1 then
        dir = Vector(1, 0, 0)
    end
    dir = dir:Normalized()

    local offset      = 150
    local spawn_pos   = target_pos - dir * offset
    local ground_pos  = GetGroundPosition(spawn_pos, caster)

    local team = caster:GetTeamNumber()

    local soldier = CreateUnitByName(
        "npc_dota_silvername_clone",
        ground_pos,
        false,
        caster,
        caster,
        team
    )

    if not soldier then return end

    soldier:SetOwner(caster)
    soldier:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    soldier:SetHasInventory(false)
    soldier:RemoveModifierByName("modifier_fountain_invulnerability")
    soldier:SetCanSellItems(false)
    soldier:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    soldier.IsRealHero      = function() return false end
    soldier.IsMainHero      = function() return false end
    soldier.IsTempestDouble = function() return true end
    soldier:SetRenderColor(255, 255, 0)

    local damage_min = caster:GetBaseDamageMin() * (r_ability:GetSpecialValueFor("damage") / 100)
    local damage_max = caster:GetBaseDamageMax() * (r_ability:GetSpecialValueFor("damage") / 100) 
    soldier:SetBaseDamageMin(damage_min)
    soldier:SetBaseDamageMax(damage_max)

    self:CopyAttackItemsForShard(caster, soldier)

    soldier:AddNewModifier(caster, self, "modifier_silvername_r_facet_1_soldier", {
        duration               = shard_duration,
        radius                 = 80,
        angle                  = RandomFloat(0, 360),
        attack_interval        = attack_interval,
        follow_target_entindex = target:entindex(),
        run_out_duration       = 0.0,
    })
end

function silvername_q_facet_1:CopyAttackItemsForShard(fromHero, toHero)
    if not fromHero or fromHero:IsNull() or not toHero or toHero:IsNull() then return end

    for itemSlot = 0,16 do
        local itemName = fromHero:GetItemInSlot(itemSlot)
        if itemName then 
            if itemName:GetName() ~= "item_rapier" and itemName:GetName() ~= "item_ward_dispenser" and itemName:GetName() ~= "item_gem" and itemName:GetName() ~= "item_refresher" and itemName:GetName() ~= "item_lesh" and itemName:GetName() ~= "item_moon_shard" and itemName:GetName() ~= "item_hand_of_midas" and itemName:GetName() ~= "item_bablokrad" and itemName:IsPermanent() then
                local newItem = CreateItem(itemName:GetName(), nil, nil)
                toHero:AddItem(newItem)
                if itemName and itemName:GetCurrentCharges() > 0 and newItem and not newItem:IsNull() then
                    newItem:SetCurrentCharges(itemName:GetCurrentCharges())
                end
                if newItem and not newItem:IsNull() then
                    toHero:SwapItems(newItem:GetItemSlot(), itemSlot)
                end
                newItem:SetSellable(false)
                newItem:SetDroppable(false)
                newItem:SetShareability( ITEM_FULLY_SHAREABLE )
                newItem:SetPurchaser( nil )
            end
        end
    end
end

function silvername_q_facet_1:ApplyRandomCooldownReduction()
    local cd_min = self:GetSpecialValueFor("cd_min") or 0
    local cd_max = self:GetSpecialValueFor("cd_max") or 0

    if cd_max <= 0 then return end

    local reduce = RandomFloat(cd_min, cd_max)
    local remaining = self:GetCooldownTimeRemaining()

    if remaining <= 0 then
        return
    end

    local new_remaining = math.max(0, remaining - reduce)

    self:EndCooldown()
    if new_remaining > 0 then
        self:StartCooldown(new_remaining)
    end
end

function silvername_q_facet_1:Expand( value, min, max )
	return (max-min)*value + min
end

function silvername_q_facet_1:PlayEffect2( target, stun, damage )
	local digit = 4
	if damage < 100 then digit = 3 end
	local digit1 = damage%10
	local digit2 = math.floor((damage%100)/10)
	local digit3 = math.floor((damage%1000)/100)
	local number = digit3*100 + digit2*10 + digit1

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
	ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0, number, 3 ) )
	ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 2, digit, 0 ) )
	ParticleManager:SetParticleControl( nFXIndex, 3, Vector( 0,	stun, 4 ) )
	ParticleManager:SetParticleControl( nFXIndex, 4, Vector( 2,	2, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_ChaosKnight.ChaosBolt.Impact", target )
end