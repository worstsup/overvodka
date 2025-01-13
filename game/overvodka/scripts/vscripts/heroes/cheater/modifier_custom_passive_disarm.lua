modifier_custom_passive_disarm = class({})

function modifier_custom_passive_disarm:IsHidden() return true end
function modifier_custom_passive_disarm:IsDebuff() return false end
function modifier_custom_passive_disarm:IsPurgable() return false end

function modifier_custom_passive_disarm:OnCreated()
    if not IsServer() then return end

    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.disarm_duration = self:GetAbility():GetSpecialValueFor( "duration" )
    self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
    self.cooldown = 10
    self:StartIntervalThink(0.5)
end

function modifier_custom_passive_disarm:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent:IsAlive() or not self:GetAbility():IsCooldownReady() then return end
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        if RollPercentage(self.chance) then
            EmitSoundOn("tazer", self:GetParent())
            local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/disruptor/disruptor_2022_immortal/disruptor_2022_immortal_static_storm_lightning_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ApplyDamage({
                victim = enemy,
                attacker = parent,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility()
            })
            enemy:AddNewModifier(parent, self:GetAbility(), "modifier_generic_stunned_lua", {duration = self.disarm_duration})
            self:GetAbility():StartCooldown(self.cooldown)
            break
        end
    end
end