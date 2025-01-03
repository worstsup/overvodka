modifier_c4_bomb = class({})

function modifier_c4_bomb:IsHidden() return false end
function modifier_c4_bomb:IsPurgable() return false end

function modifier_c4_bomb:OnCreated(kv)
    if not IsServer() then return end
    EmitGlobalSound("bomb_planted")
    EmitSoundOn( "c4", self:GetParent() )
    self.radius = 300  -- Radius to defuse the bomb
    self.defuse_time = 6  -- Time required to defuse the bomb in seconds
    self.detonation_time = 41  -- Time before the bomb explodes (in seconds)
    self.timer = 0  -- Track how long the enemy is within the radius
    self.detonation_timer = 0  -- Timer for the bomb detonation
    self.tick = 6
    -- Start checking every second for the bomb detonation and defuse
    self:StartIntervalThink(1)
end

function modifier_c4_bomb:OnIntervalThink()
    if not IsServer() then return end

    -- Increase the detonation timer
    self.detonation_timer = self.detonation_timer + 1

    -- Check if the bomb should explode (after 40 seconds)
    if self.detonation_timer >= self.detonation_time then
        self:ExplodeBomb()
        return
    end

    -- Find all enemy units within the 300 radius of the bomb
    local enemies_in_range = FindUnitsInRadius(
        self:GetCaster():GetTeam(),              -- Team of the bomb caster (your team)
        self:GetParent():GetAbsOrigin(),         -- The position of the bomb
        nil,                                     -- No specific target unit
        self.radius,                             -- The radius within which to detect enemies
        DOTA_UNIT_TARGET_TEAM_ENEMY,             -- Only look for enemy units
        DOTA_UNIT_TARGET_HERO,                   -- Targets heroes
        DOTA_UNIT_TARGET_FLAG_NONE,              -- No specific targeting flags
        FIND_ANY_ORDER,                          -- Find any unit in range
        false
    )

    -- Check if there are enemies in range
    if #enemies_in_range > 0 then
        if self.timer == 0 then
            EmitSoundOn( "bomb_defusing", self:GetParent())
        end
        -- If the enemy is inside the radius, we increase the timer
        self.timer = self.timer + 1
        self.tick = self.tick - 1.0
        if self.tick>0 then
            self:PlayEffects()
        end
        -- If the timer reaches the defuse time, defuse the bomb
        if self.timer >= self.defuse_time then
            self:DefuseBomb()
        end
    else
        -- Reset the timer if no enemy is in range
        self.timer = 0
        self.tick = 6
    end
end

function modifier_c4_bomb:DefuseBomb()
    if not IsServer() then return end
    local bomb = self:GetParent()

    -- Play defuse sound and particle effect (optional)
    local defuse_particle = "particles/units/heroes/hero_techies/techies_defuse.vpcf"
    local sound_defuse = "c4_defused"
    StopSoundOn( "c4", self:GetParent() )
    EmitSoundOn(sound_defuse, bomb)
    local defuser = nil
    local enemies_in_range = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST, -- Prioritize the closest unit
        false
    )
    if #enemies_in_range > 0 then
        defuser = enemies_in_range[1] -- Assume the first hero in range is the defuser
    end

    -- Reward the defuser
    if defuser and defuser:IsHero() then
        defuser:ModifyGold(500, true, DOTA_ModifyGold_Unspecified) -- Add 1000 gold
        SendOverheadEventMessage(defuser, OVERHEAD_ALERT_GOLD, defuser, 500, nil) -- Display gold overhead
    end

    -- Remove the bomb's planting modifier (it is now defused)
    bomb:RemoveModifierByName("modifier_c4_bomb")

    -- Destroy the bomb (it has been defused)
    bomb:ForceKill(false)
end

function modifier_c4_bomb:ExplodeBomb()
    if not IsServer() then return end
    local bomb = self:GetParent()

    -- Play explosion sound and particle effect
    local explosion_particle = "particles/c4_explosion.vpcf"

    -- Create an explosion effect (pure damage in 1200 radius)
    local explosion_radius = 1200  -- Explosion radius (can be 1000 or 1200 as per your original request)
    local half_radius = 1800
    local damage = 50000  -- Pure damage (adjust this based on your desired damage)

    -- Deal damage to units in the explosion radius
    local enemies_in_explosion = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        explosion_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies_in_explosion) do
        ApplyDamage({
            victim = enemy,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()
        })
    end
     local enemies_in_heavy = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        half_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, enemy in pairs(enemies_in_heavy) do
        -- Skip units that have already taken lethal damage
        if not table.contains(enemies_in_explosion, enemy) then
            local damage = enemy:GetMaxHealth() * 0.5
            ApplyDamage({
                victim = enemy,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self:GetAbility()
            })
        end
    end

    -- Global: 25% of Max HP
    local global_enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,  -- Global radius
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, enemy in pairs(global_enemies) do
        -- Skip units that have already taken lethal or heavy damage
        if not table.contains(enemies_in_lethal, enemy) and not table.contains(enemies_in_heavy, enemy) then
            local damage = enemy:GetMaxHealth() * 0.25
            ApplyDamage({
                victim = enemy,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self:GetAbility()
            })
        end
    end
    local particle_cast = "particles/c4_explosion.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, bomb)
    -- Remove the bomb unit after the explosion
    bomb:ForceKill(false)
end
function modifier_c4_bomb:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"

    -- Get data
    local time = math.floor( self.tick )
    local mid = 1

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

    if time<1 then
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
    end

    ParticleManager:ReleaseParticleIndex( effect_cast )
end