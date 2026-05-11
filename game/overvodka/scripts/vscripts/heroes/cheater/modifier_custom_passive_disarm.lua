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
    local ability = self:GetAbility()
    if not parent:IsAlive() or not ability:IsCooldownReady() then return end
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

    local damage_table = {
        attacker = parent,
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
    }
    local stun_kv = {duration = self.disarm_duration}
    for _, enemy in ipairs(enemies) do
        if RollPercentage(self.chance) then
            EmitSoundOn("tazer", parent)
            local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/disruptor/disruptor_2022_immortal/disruptor_2022_immortal_static_storm_lightning_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
            damage_table.victim = enemy
            ApplyDamage(damage_table)
            if enemy and not enemy:IsNull() then
                enemy:AddNewModifier(parent, ability, "modifier_generic_stunned_lua", stun_kv)
            end
            ability:StartCooldown(self.cooldown)
            break
        end
    end
end