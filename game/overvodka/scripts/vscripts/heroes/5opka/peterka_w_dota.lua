LinkLuaModifier("modifier_peterka_w_dota", "heroes/5opka/peterka_w_dota", LUA_MODIFIER_MOTION_NONE)

peterka_w_dota = class({})

function peterka_w_dota:GetIntrinsicModifierName()
    return "modifier_peterka_w_dota"
end

function peterka_w_dota:Precache(context)
    PrecacheResource("soundfile", "soundevents/peterka_w.vsndevts", context)
    PrecacheResource("particle", "particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", context)
end

modifier_peterka_w_dota = class({})

function modifier_peterka_w_dota:IsHidden()   return true end
function modifier_peterka_w_dota:IsPurgable() return false end

function modifier_peterka_w_dota:OnCreated()
    if not IsServer() then return end
    if not self:GetParent():IsRealHero() then return end
    if self:GetParent():IsIllusion() then return end
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()
    self.radius  = self.ability:GetSpecialValueFor("radius")
    self:StartIntervalThink(0.2)
end

function modifier_peterka_w_dota:OnRefresh()
    if not IsServer() then return end
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_peterka_w_dota:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_peterka_w_dota:OnDeath(params)
    if not IsServer() then return end
    local victim = params.unit
    local attacker = params.attacker
    if victim:IsRealHero() then return end
    if victim:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end
    if not attacker:IsRealHero() then return end
    if attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if (victim:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() > self.radius then
        return
    end
    if not self.parent:IsAlive() or self.parent:PassivesDisabled() then return end
    if self.ability:GetCooldownTimeRemaining() > 0 then return end
    local bounty = victim:GetGoldBounty() * self:GetAbility():GetSpecialValueFor("gold_mult")
    self.parent:ModifyGold(bounty, true, DOTA_ModifyGold_Unspecified)
    SendOverheadEventMessage(self.parent, OVERHEAD_ALERT_GOLD, self.parent, bounty, nil)
    local damage_pct = self.ability:GetSpecialValueFor("damage")
    local damage_amount = bounty * damage_pct * 0.01
    ApplyDamage({
        victim = attacker,
        attacker = self.parent,
        damage = damage_amount,
        damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability,
    })
    ParticleManager:CreateParticle("particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
    local heal_pct = self.ability:GetSpecialValueFor("heal")
    local heal_amount = bounty * heal_pct * 0.01
    self.parent:Heal(heal_amount, self.ability)
    self.ability:UseResources(false, false, false, true)
    EmitSoundOn("peterka_w", self.parent)
end

function modifier_peterka_w_dota:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent:IsAlive() then return end
    if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
    if self.parent:PassivesDisabled() then return end
    local items = Entities:FindAllByClassnameWithin("dota_item_drop", self.parent:GetAbsOrigin(), self.radius)

    for _, item_entity in pairs(items) do
        if item_entity and item_entity:IsNull() == false then
            local item = item_entity:GetContainedItem()
            if item and item:GetName() == "item_bag_of_gold" then
                local r = 50
                local playerID = self.parent:GetPlayerID()
                local Team = PlayerResource:GetTeam(playerID)
			    local newR = ChangeValueByTeamPlace(r, Team) * self:GetAbility():GetSpecialValueFor("gold_mult")
                local newR2 = ChangeValueByTeamPlace(r, Team)
                self.parent:ModifyGold(newR, true, DOTA_ModifyGold_Unspecified)
                SendOverheadEventMessage( self.parent, OVERHEAD_ALERT_GOLD, self.parent, newR, nil )
                local heroes = FindUnitsInRadius(self.parent:GetTeamNumber(),
                            self.parent:GetAbsOrigin(),
							nil,
							10000,
							DOTA_UNIT_TARGET_TEAM_FRIENDLY,
							DOTA_UNIT_TARGET_HERO,
							DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
							FIND_ANY_ORDER,
							false )
		        for i = 1, #heroes do
                    if heroes[i]:GetUnitName() ~= self.parent:GetUnitName() then
			            playerID = heroes[i]:GetPlayerID()
			            r = 50
			            if heroes[i]:GetUnitName() == "npc_dota_hero_bounty_hunter" and not heroes[i]:IsIllusion() then
				            r = 100
			            end
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
                local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                for _, enemy in pairs(enemies) do
                    local damage = newR * self:GetAbility():GetSpecialValueFor("damage") * 0.01
                    ApplyDamage({
                        victim = enemy,
                        attacker = self.parent,
                        damage = damage,
                        damage_type = self:GetAbility():GetAbilityDamageType(),
                        ability = self:GetAbility()
                    })
                    ParticleManager:CreateParticle("particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                end
                self.parent:Heal(newR * self:GetAbility():GetSpecialValueFor("heal") * 0.01, self:GetAbility())
                self:GetAbility():UseResources(false, false, false, true)
                EmitSoundOn("peterka_w", self.parent)
            end
        end
    end
end