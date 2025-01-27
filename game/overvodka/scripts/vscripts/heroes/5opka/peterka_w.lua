LinkLuaModifier("modifier_peterka_w", "heroes/5opka/peterka_w", LUA_MODIFIER_MOTION_NONE)

peterka_w = class({})

function peterka_w:GetIntrinsicModifierName()
    return "modifier_peterka_w"
end
function peterka_w:Precache(context)
    PrecacheResource("soundfile", "soundevents/peterka_w.vsndevts", context)
    PrecacheResource("particle", "particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", context)
end
modifier_peterka_w = class({})

function modifier_peterka_w:IsHidden() return true end
function modifier_peterka_w:IsPurgable() return false end

function modifier_peterka_w:OnCreated()
    if not IsServer() then return end
    if not self:GetParent():IsRealHero() then return end
    if self:GetParent():IsIllusion() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.parent = self:GetParent()
    self:StartIntervalThink(0.2)
end

function modifier_peterka_w:OnRefresh()
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_peterka_w:OnIntervalThink()
    if not IsServer() then return end
    if not self.parent:IsAlive() then return end
    if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
    local items = Entities:FindAllByClassnameWithin("dota_item_drop", self.parent:GetAbsOrigin(), self.radius)

    for _, item_entity in pairs(items) do
        if item_entity and item_entity:IsNull() == false then
            local item = item_entity:GetContainedItem()
            if item and item:GetName() == "item_bag_of_gold" then
                local r = 300
                local playerID = self.parent:GetPlayerID()
                local Team = PlayerResource:GetTeam(playerID)
			    local newR = ChangeValueByTeamPlace(r, Team)
                self.parent:ModifyGold(newR, true, DOTA_ModifyGold_Unspecified)
                SendOverheadEventMessage( self.parent, OVERHEAD_ALERT_GOLD, self.parent, newR, nil )
                item_entity:RemoveSelf()
                if self:GetParent():HasModifier("modifier_item_aghanims_shard") then
                    local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                    for _, enemy in pairs(enemies) do
                        local damage = newR * self:GetAbility():GetSpecialValueFor("damage") * 0.01
                        ApplyDamage({
                            victim = enemy,
                            attacker = self.parent,
                            damage = damage,
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            ability = self:GetAbility()
                        })
                        ParticleManager:CreateParticle("particles/centaur_ti6_warstomp_gold_ring_glow_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                    end
                end
                self.parent:Heal(newR * self:GetAbility():GetSpecialValueFor("heal") * 0.01, self:GetAbility())
                self:GetAbility():UseResources(false, false, false, true)
                EmitSoundOn("peterka_w", self.parent)
            end
        end
    end
end