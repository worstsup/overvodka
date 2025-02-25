modifier_c4_bomb = class({})

function modifier_c4_bomb:IsHidden() return false end
function modifier_c4_bomb:IsPurgable() return false end

function modifier_c4_bomb:OnCreated(kv)
    if not IsServer() then return end
    EmitGlobalSound("bomb_planted")
    EmitSoundOn( "c4", self:GetParent() )
    self.radius = 300
    self.defuse_time = 6
    self.detonation_time = 41
    self.timer = 0
    self.detonation_timer = 0
    self.tick = 6
    self:StartIntervalThink(1)
end

function modifier_c4_bomb:OnIntervalThink()
    if not IsServer() then return end
    self.detonation_timer = self.detonation_timer + 1
    if self.detonation_timer >= self.detonation_time then
        self:ExplodeBomb()
        return
    end
    local enemies_in_range = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    if #enemies_in_range > 0 then
        if self.timer == 0 then
            EmitSoundOn( "bomb_defusing", self:GetParent())
        end
        self.timer = self.timer + 1
        self.tick = self.tick - 1.0
        if self.tick>0 then
            self:PlayEffects()
        end
        if self.timer >= self.defuse_time then
            self:DefuseBomb()
        end
    else
        self.timer = 0
        self.tick = 6
    end
end

function modifier_c4_bomb:DefuseBomb()
    if not IsServer() then return end
    local bomb = self:GetParent()
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
        FIND_CLOSEST,
        false
    )
    if #enemies_in_range > 0 then
        defuser = enemies_in_range[1]
    end
    if defuser and defuser:IsHero() then
        defuser:ModifyGold(500, true, DOTA_ModifyGold_Unspecified)
        SendOverheadEventMessage(defuser, OVERHEAD_ALERT_GOLD, defuser, 500, nil)
    end
    bomb:RemoveModifierByName("modifier_c4_bomb")
    bomb:ForceKill(false)
end

function modifier_c4_bomb:ExplodeBomb()
    if not IsServer() then return end
    local bomb = self:GetParent()
    local explosion_particle = "particles/c4_explosion.vpcf"
    local explosion_radius = 1200
    local half_radius = 1800
    local damage = 50000
    local enemies_in_explosion = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        explosion_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
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
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, enemy in pairs(enemies_in_heavy) do
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
    local global_enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        bomb:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,  -- Global radius
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for _, enemy in pairs(global_enemies) do
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
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, bomb)
    bomb:ForceKill(false)
end
function modifier_c4_bomb:PlayEffects()
    local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
    local time = math.floor( self.tick )
    local mid = 1
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
    ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

    if time<1 then
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
    end

    ParticleManager:ReleaseParticleIndex( effect_cast )
end