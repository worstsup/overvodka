LinkLuaModifier("modifier_ashab_shard_vision", "heroes/ashab/ashab_shard", LUA_MODIFIER_MOTION_NONE)

ashab_shard = class({})

function ashab_shard:Precache(context)
    PrecacheResource("particle", "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_crosshair.vpcf", context)
end

function ashab_shard:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_ANY_ORDER,
        false
    )

    local target = nil
    local max_dist = -1

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then
            local dist = (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
            if dist > max_dist then
                max_dist = dist
                target = enemy
            end
        end
    end

    if not target then return end

    target:AddNewModifier(caster, self, "modifier_ashab_shard_vision", {
        duration = self:GetSpecialValueFor("duration"),
    })

    caster:EmitSound("DOTA_Item.DustOfAppearance.Activate")
end

modifier_ashab_shard_vision = class({})

function modifier_ashab_shard_vision:IsHidden() return true end
function modifier_ashab_shard_vision:IsPurgable() return false end
function modifier_ashab_shard_vision:IsDebuff() return true end

function modifier_ashab_shard_vision:OnCreated()
    self.radius = 250
    self.interval = 0.1

    if not IsServer() then return end

    local ability = self:GetAbility()
    local caster = self:GetCaster()
    if ability and not ability:IsNull() then
        self.radius = ability:GetSpecialValueFor("vision_radius")
        self.interval = ability:GetSpecialValueFor("vision_interval")
    end

    if not caster or caster:IsNull() then
        self:Destroy()
        return
    end

    self.team = caster:GetTeamNumber()

    self.particle = ParticleManager:CreateParticle(
        "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_crosshair.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        self:GetParent()
    )
    self:AddParticle(self.particle, false, false, -1, false, true)

    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_ashab_shard_vision:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not parent:IsAlive() then
        self:Destroy()
        return
    end

    AddFOWViewer(self.team, parent:GetAbsOrigin(), self.radius, self.interval + 0.03, false)
end
