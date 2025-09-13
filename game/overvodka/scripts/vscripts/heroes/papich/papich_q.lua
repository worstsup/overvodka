LinkLuaModifier("modifier_papich_q", "heroes/papich/papich_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua.lua", LUA_MODIFIER_MOTION_NONE)

papich_q = class({})
modifier_papich_q = class({})

function papich_q:Precache(context)
    PrecacheResource("particle", "particles/papich_q.vpcf", context)
    PrecacheResource("soundfile","soundevents/question1.vsndevts", context)
    PrecacheResource("soundfile","soundevents/question2.vsndevts", context)
    PrecacheResource("soundfile","soundevents/question3.vsndevts", context)
end

function papich_q:OnSpellStart()
    if not IsServer() then return end
    local caster   = self:GetCaster()
    local targetPt = self:GetCursorPosition()
    if targetPt == caster:GetAbsOrigin() then
        targetPt = caster:GetAbsOrigin() + caster:GetForwardVector()
    end

    local origin   = caster:GetAbsOrigin()
    local dir      = (targetPt - origin); dir.z = 0
    if dir:Length2D() < 1 then dir = caster:GetForwardVector() end
    dir = dir:Normalized()

    local range    = self:GetSpecialValueFor("range")
    local speed    = self:GetSpecialValueFor("speed")
    local radius   = self:GetSpecialValueFor("radius")

    local total_damage = self:GetSpecialValueFor("total_damage")
    local dmg_pct_mana = self:GetSpecialValueFor("damage_mana")
    local final_damage = total_damage + caster:GetMaxMana() * (dmg_pct_mana * 0.01)

    local step_dist   = self:GetSpecialValueFor("channel_vision_step")
    local vis_radius  = self:GetSpecialValueFor("channel_vision_radius")
    local vis_time    = self:GetSpecialValueFor("vision_duration")
    local steps = math.floor(range / math.max(1, step_dist))
    for i = 1, steps do
        local pos = origin + dir * (i * step_dist)
        self:CreateVisibilityNode(pos, vis_radius, vis_time)
    end

    local r = RandomInt(1,3)
    if r == 1 then caster:EmitSound("question1")
    elseif r == 2 then caster:EmitSound("question2")
    else caster:EmitSound("question3") end

    CreateModifierThinker(
        caster, self, "modifier_papich_q",
        {
            duration     = range / math.max(1, speed),
            direction_x  = dir.x,
            direction_y  = dir.y,
            damage       = final_damage,
            radius       = radius,
            speed        = speed,
        },
        origin,
        caster:GetTeamNumber(),
        false
    )
end

function modifier_papich_q:IsHidden() return true end
function modifier_papich_q:IsPurgable() return false end

function modifier_papich_q:OnCreated(kv)
    if not IsServer() then return end
    self.ability  = self:GetAbility()
    self.parent   = self:GetParent()
    self.caster   = self:GetCaster()

    self.dir      = Vector(kv.direction_x or 0, kv.direction_y or 0, 0)
    if self.dir:Length2D() < 0.01 then self.dir = self.caster:GetForwardVector() end
    self.dir      = self.dir:Normalized()

    self.speed    = tonumber(kv.speed)  or self.ability:GetSpecialValueFor("speed")
    self.radius   = tonumber(kv.radius) or self.ability:GetSpecialValueFor("radius")
    self.damage   = tonumber(kv.damage) or self.ability:GetSpecialValueFor("total_damage")
    self.silence  = self.ability:GetSpecialValueFor("silence_duration")

    self.dir_angle = math.deg(math.atan2(self.dir.x, self.dir.y))

    self.fx = ParticleManager:CreateParticle("particles/papich_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.fx, 1, self.dir * self.speed)
    ParticleManager:SetParticleControl(self.fx, 3, self.parent:GetAbsOrigin())
    self:AddParticle(self.fx, false, false, -1, false, false)

    self.hit_targets = {}
    self:StartIntervalThink(FrameTime())
end

function modifier_papich_q:OnIntervalThink()
    if not IsServer() then return end

    local pos = self.parent:GetAbsOrigin()

    local targets = FindUnitsInRadius(
        self.caster:GetTeamNumber(), pos, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
    )

    local valid = {}
    for _,t in pairs(targets) do
        local tpos  = t:GetAbsOrigin()
        local tang  = math.deg(math.atan2((tpos.x - pos.x), tpos.y - pos.y))
        local diff  = math.abs(self.dir_angle - tang)
        if diff <= 90 or diff >= 270 then
            table.insert(valid, t)
        end
    end

    for _,t in pairs(valid) do
        if not t:IsNull() then
            local id = t:entindex()
            if not self.hit_targets[id] then
                self.hit_targets[id] = true

                if t:GetTeam() ~= self.caster:GetTeam() then
                    ApplyDamage({
                        victim      = t,
                        attacker    = self.caster,
                        damage      = self.damage,
                        damage_type = self.ability:GetAbilityDamageType(),
                        ability     = self.ability
                    })
                    if self.silence > 0 then
                        t:AddNewModifier(self.caster, self.ability, "modifier_generic_silenced_lua", { duration = self.silence })
                    end
                end

                t:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target")
                t:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target.Secondary")
                local pname = t:IsHero()
                    and "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf"
                    or  "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact_small.vpcf"
                local p = ParticleManager:CreateParticle(pname, PATTACH_ABSORIGIN_FOLLOW, t)
                ParticleManager:SetParticleControl(p, 1, t:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(p)
            end
        end
    end

    self.parent:SetAbsOrigin(pos + self.dir * self.speed * FrameTime())
end

function modifier_papich_q:OnDestroy()
    if not IsServer() then return end
    self.parent:RemoveSelf()
end
