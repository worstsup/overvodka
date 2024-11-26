function BaranovActive( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    caster:SetOriginalModel("models/items/hex/sheep_hex/sheep_hex.vmdl")
    caster:SetModelScale(2)
    caster.wearableNames = {} -- In here we'll store the wearable names to revert the change
    caster.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = caster:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil and modelName ~= "" and modelName ~= nil then
                -- Add the original model name to revert later
                table.insert(caster.wearableNames,modelName)
                print("Hidden "..modelName.."")

                -- Set model invisible
                model:SetModel("models/development/invisiblebox.vmdl")
                table.insert(caster.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
            print("Next Peer:" .. model:GetModelName())
        end
    end
    local charge_speed = ability:GetLevelSpecialValueFor("charge_speed", (ability:GetLevel() - 1)) * 1/30

    ability.modifiername = keys.ModifierName
    ability.modifiername_debuff = keys.ModifierName_Debuff

    ability.target = target
    ability.velocity = charge_speed
    ability.life_break_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0
end


function DoDamage(caster, target, ability)
    local caster_health = caster:GetHealth()
    local target_health = target:GetHealth()
    local health_damage = ability:GetLevelSpecialValueFor("health_damage", (ability:GetLevel() - 1))

    local dmg_to_target = target_health * health_damage

    local dmg_table_target = {
                                victim = target,
                                attacker = caster,
                                damage = dmg_to_target,
                                damage_type = DAMAGE_TYPE_PURE
                            }
    ApplyDamage(dmg_table_target)
end

function AutoAttack(caster, target)
        order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:GetEntityIndex(),
            Queue = true
        }

        ExecuteOrderFromTable(order)
end


function OnMotionDone(caster, target, ability)
    local modifiername = ability.modifiername
    local modifiername_debuff = ability.modifiername_debuff
    caster:SetModelScale(1)
    if caster:FindModifierByName(modifiername) then
        caster:RemoveModifierByName(modifiername)
    end
    local model = "models/heroes/monkey_king/monkey_king.vmdl"
    if caster:GetUnitName() == "npc_dota_hero_rubick" then
        model = "models/heroes/rubick/rubick.vmdl"
    end
    caster:SetOriginalModel(model)
    for i,v in ipairs(caster.hiddenWearables) do
        --for index,modelName in ipairs(hero.wearableNames) do
        --  if i==index then
                print("Changed "..v:GetModelName().. " back to "..caster.wearableNames[i])
                v:SetModel(caster.wearableNames[i])
        --  end
        --end
    end
    ability:ApplyDataDrivenModifier(caster, target, modifiername_debuff, {})
    if caster:HasScepter() then
        DoDamage(caster, target, ability)
    end
    AutoAttack(caster, target)
end

function JumpHorizonal( keys )
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel()-1)


    if (target_loc - caster_loc):Length2D() >= max_distance then
    	caster:InterruptMotionControllers(true)
    end

    if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:InterruptMotionControllers(true)

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
        OnMotionDone(caster, target, ability)
    end
end

function JumpVertical( keys )
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target
    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)

    if caster_loc.z < caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

    if ability.traveled < ability.initial_distance/2 then
        ability.life_break_z = ability.life_break_z + ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    elseif caster_loc.z > caster_loc_ground.z then
        ability.life_break_z = ability.life_break_z - ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    end

end