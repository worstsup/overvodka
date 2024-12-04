modifier_custom_passive_disarm = class({})

function modifier_custom_passive_disarm:IsHidden() return true end
function modifier_custom_passive_disarm:IsDebuff() return false end
function modifier_custom_passive_disarm:IsPurgable() return false end

function modifier_custom_passive_disarm:OnCreated()
    if not IsServer() then return end

    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
    self.disarm_duration = self:GetAbility():GetSpecialValueFor( "duration" )     -- Disarm duration
    self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
    self.cooldown = 10         -- Cooldown duration
    self:StartIntervalThink(0.5) -- Interval for checking enemies
end

function modifier_custom_passive_disarm:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()

    -- Check if the ability is on cooldown
    if not parent:IsAlive() or not self:GetAbility():IsCooldownReady() then return end

    -- Find nearby enemies
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
        -- Trigger based on chance
        if RollPercentage(self.chance) then
            -- Apply damage
            EmitSoundOn("tazer", self:GetParent())
            local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/disruptor/disruptor_2022_immortal/disruptor_2022_immortal_static_storm_lightning_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
            ApplyDamage({
                victim = enemy,
                attacker = parent,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility()
            })

            -- Apply disarm
            enemy:AddNewModifier(parent, self:GetAbility(), "modifier_generic_stunned_lua", {duration = self.disarm_duration})

            -- Start cooldown
            self:GetAbility():StartCooldown(self.cooldown)

            -- Break after triggering once
            break
        end
    end
end