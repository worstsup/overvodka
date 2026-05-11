LinkLuaModifier("modifier_peterka_w", "heroes/5opka/peterka_w", LUA_MODIFIER_MOTION_NONE)

peterka_w = class({})

function peterka_w:GetIntrinsicModifierName()
    return "modifier_peterka_w"
end

function peterka_w:Precache(context)
    PrecacheResource("soundfile", "soundevents/peterka_w.vsndevts", context)
    PrecacheResource("particle", "particles/peterka_money_ring.vpcf", context)
    PrecacheResource("particle", "particles/5opka_money_hit.vpcf", context)
    PrecacheResource("particle", "particles/5opka_coins.vpcf", content)
    PrecacheResource("particle", "particles/items3_fx/fish_bones_active.vpcf", context)
end

modifier_peterka_w = class({})

function modifier_peterka_w:IsHidden() return true end
function modifier_peterka_w:IsPurgable() return false end

function modifier_peterka_w:OnCreated()
    if not IsServer() then return end
    if GetMapName() == "overvodka_5x5" then return end
    if not self:GetParent():IsRealHero() then return end
    if self:GetParent():IsIllusion() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self:StartIntervalThink(0.2)
end

function modifier_peterka_w:OnRefresh()
    if not IsServer() then return end
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_peterka_w:OnIntervalThink()
    if not IsServer() then return end
    if GetMapName() == "overvodka_5x5" then return end
    if not self.parent:IsAlive() then return end
    local ability = self.ability
    if ability:GetCooldownTimeRemaining() ~= 0 then return end
    if self.parent:PassivesDisabled() then return end
    local parent = self.parent
    local parent_origin = parent:GetAbsOrigin()
    local items = Entities:FindAllByClassnameWithin("dota_item_drop", parent_origin, self.radius)

    for _, item_entity in pairs(items) do
        if item_entity and item_entity:IsNull() == false then
            local item = item_entity:GetContainedItem()
            if item and item:GetName() == "item_bag_of_gold" then
                local gold_mult = ability:GetSpecialValueFor("gold_mult")
                local damage_pct = ability:GetSpecialValueFor("damage")
                local heal_pct = ability:GetSpecialValueFor("heal")
                local damage_type = ability:GetAbilityDamageType()
                local r = 300
                local playerID = parent:GetPlayerID()
                local Team = PlayerResource:GetTeam(playerID)
			    local newR = ChangeValueByTeamPlace(r, Team) * gold_mult
                local newR2 = ChangeValueByTeamPlace(r, Team)
                parent:ModifyGold(newR, true, DOTA_ModifyGold_Unspecified)
                SendOverheadEventMessage( parent, OVERHEAD_ALERT_GOLD, parent, newR, nil )
                local heroes = FindUnitsInRadius(parent:GetTeamNumber(),
                            parent_origin,
								nil,
								10000,
								DOTA_UNIT_TARGET_TEAM_FRIENDLY,
							DOTA_UNIT_TARGET_HERO,
							DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
							FIND_ANY_ORDER,
							false )
			        for i = 1, #heroes do
                    if heroes[i]:GetUnitName() ~= parent:GetUnitName() then
				            playerID = heroes[i]:GetPlayerID()
				            r = 300
				            if heroes[i]:GetUnitName() == "npc_dota_hero_skeleton_king" and heroes[i]:IsTempestDouble() then
					        r = 0
			            end
			            Team = PlayerResource:GetTeam(playerID)
			            newR2 = ChangeValueByTeamPlace(r, Team)
			            PlayerResource:ModifyGold( playerID, newR2, false, 0 )
			            SendOverheadEventMessage( heroes[i], OVERHEAD_ALERT_GOLD, heroes[i], newR2, nil )
                    end
			        end
                item_entity:RemoveSelf()
                local enemies = FindUnitsInRadius(parent:GetTeamNumber(), parent_origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                local damage = newR * damage_pct * 0.01
                local damage_table = {
                    attacker = parent,
                    damage = damage,
                    damage_type = damage_type,
                    ability = ability
                }
                for _, enemy in pairs(enemies) do
                    local d = ParticleManager:CreateParticle("particles/5opka_money_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                    ParticleManager:SetParticleControlEnt(d, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
                    ParticleManager:ReleaseParticleIndex(d)
                    damage_table.victim = enemy
                    ApplyDamage(damage_table)
                end
                local h = newR * heal_pct * 0.01
                if h > 0 then
                    parent:HealWithParams(h, ability, false, true, parent, false)
                    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, h, nil)
                    local particle = ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                    ParticleManager:ReleaseParticleIndex(particle)
                end
                ability:UseResources(false, false, false, true)
                local p = ParticleManager:CreateParticle("particles/peterka_money_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                ParticleManager:SetParticleControl(p, 1, Vector(self.radius, 0, 0))
                ParticleManager:ReleaseParticleIndex(p)
                local c = ParticleManager:CreateParticle("particles/5opka_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                ParticleManager:ReleaseParticleIndex(c)
                EmitSoundOn("peterka_w", parent)
            end
        end
    end
end