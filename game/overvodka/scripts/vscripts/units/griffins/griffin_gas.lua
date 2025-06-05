LinkLuaModifier("modifier_griffin_gas", "units/griffins/griffin_gas.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_griffin_gas_effect", "units/griffins/griffin_gas.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_griffin_gas_thinker", "units/griffins/griffin_gas.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_griffin_gas_casting", "units/griffins/griffin_gas.lua", LUA_MODIFIER_MOTION_NONE)

griffin_gas = class({})

function griffin_gas:GetIntrinsicModifierName()
    return "modifier_griffin_gas"
end

modifier_griffin_gas = class({})

function modifier_griffin_gas:IsHidden() return true end
function modifier_griffin_gas:IsPurgable() return false end

function modifier_griffin_gas:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.3)
        self.gas_used = false
    end
end

function modifier_griffin_gas:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility()

    if parent:GetHealthPercent() <= 25 and not self.gas_used and ability:IsCooldownReady() then
        self:StartCastingSequence()
    end
end

function modifier_griffin_gas:StartCastingSequence()
    local parent = self:GetParent()
    local ability = self:GetAbility()

    self.gas_used = true

    parent:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    parent:AddNewModifier(parent, ability, "modifier_griffin_gas_casting", {duration = 1})

    Timers:CreateTimer(1, function()
        if not parent:IsAlive() then return end
        self:ReleaseGas()
    end)
end


function modifier_griffin_gas:ReleaseGas()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local duration = ability:GetSpecialValueFor("duration")
    local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

    local sounds = {
        "peter_fart1",
        "peter_fart2",
        "peter_fart3"
    }
    local random_index = RandomInt(1, #sounds)
    EmitSoundOn(sounds[random_index], parent)

    CreateModifierThinker(
        parent,
        ability,
        "modifier_griffin_gas_thinker",
        {duration = duration},
        parent:GetAbsOrigin(),
        parent:GetTeamNumber(),
        false
    )

    ability:StartCooldown(cooldown)
    self.gas_used = true

    Timers:CreateTimer(cooldown, function()
        self.gas_used = false
    end)
end


modifier_griffin_gas_casting = class({})

function modifier_griffin_gas_casting:IsHidden() return true end
function modifier_griffin_gas_casting:IsPurgable() return false end

function modifier_griffin_gas_casting:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
end

modifier_griffin_gas_thinker = class({})

function modifier_griffin_gas_thinker:IsHidden() return true end
function modifier_griffin_gas_thinker:IsPurgable() return false end

function modifier_griffin_gas_thinker:OnCreated(params)
    if IsServer() then
        local ability = self:GetAbility()
        self.radius = ability:GetSpecialValueFor("radius")
        self:StartIntervalThink(0.5)

        self.particle = ParticleManager:CreateParticle("particles/griffin_gas.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, 0, 0))
    end
end

function modifier_griffin_gas_thinker:OnIntervalThink()
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        local modifier = enemy:FindModifierByName("modifier_griffin_gas_effect")
        if modifier then
            modifier:SetDuration(1.1, true)
        else
            enemy:AddNewModifier(
                self:GetCaster(),
                self:GetAbility(),
                "modifier_griffin_gas_effect",
                {duration = 1.1}
            )
        end
    end
end

function modifier_griffin_gas_thinker:OnDestroy()
    if IsServer() and self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

modifier_griffin_gas_effect = class({})

function modifier_griffin_gas_effect:IsHidden() return false end
function modifier_griffin_gas_effect:IsDebuff() return true end
function modifier_griffin_gas_effect:IsPurgable() return true end

function modifier_griffin_gas_effect:OnCreated()
    if IsServer() then
        self:StartIntervalThink(1.0)
        self.damage_per_sec = self:GetAbility():GetSpecialValueFor("damage_per_second")
    end
    self.damage_increase_pct = 5
end

function modifier_griffin_gas_effect:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_sec,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })
end

function modifier_griffin_gas_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function modifier_griffin_gas_effect:GetModifierIncomingDamage_Percentage()
    return self.damage_increase_pct
end
