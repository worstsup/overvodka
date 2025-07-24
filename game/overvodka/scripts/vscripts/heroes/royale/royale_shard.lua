LinkLuaModifier("modifier_royale_shard_ai", "heroes/royale/royale_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)

royale_shard = class({})

function royale_shard:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/sparky_proj.vpcf", context)
    PrecacheResource( "particle", "particles/royale_die.vpcf", context )
    PrecacheResource("particle", "particles/sparky_charge_1.vpcf", context)
    PrecacheResource("particle", "particles/sparky_charge_2.vpcf", context)
    PrecacheResource("particle", "particles/sparky_charge_3.vpcf", context)
    PrecacheUnitByNameSync("npc_sparky", context)
end

function royale_shard:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_shard:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_shard:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")

    local sparky = CreateUnitByName("npc_sparky", point, true, caster, nil, caster:GetTeamNumber())
    sparky:SetOwner(caster)
    sparky:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    sparky:SetBaseMaxHealth(base_hp)
    sparky:SetMaxHealth(base_hp)
    sparky:SetHealth(base_hp)
    sparky:SetMinimumGoldBounty(gold)
    sparky:SetMaximumGoldBounty(gold)
    sparky:SetDeathXP(xp)

    EmitSoundOnLocationWithCaster(point, "Sparky.Deploy", caster)
    Timers:CreateTimer(0.4, function()
        sparky:AddNewModifier(caster, self, "modifier_royale_shard_ai", {duration = duration})
    end)
end

function royale_shard:OnProjectileHit(target, location)
    if not target or target:IsNull() then return end
    local base_dmg = self:GetSpecialValueFor("base_dmg")
    local pct_dmg = self:GetSpecialValueFor("pct_dmg")
    local splash_radius = self:GetSpecialValueFor("splash_radius")
    for _,unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil,
                       splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
                       DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                       DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
                        local dmg = base_dmg + unit:GetMaxHealth() * pct_dmg * 0.01
                        ApplyDamage({victim=unit, attacker=self:GetCaster(), damage=dmg, damage_type=DAMAGE_TYPE_MAGICAL, ability=self})
                       end
    EmitSoundOn("Sparky.Hit", target)
end

modifier_royale_shard_ai = class({})

function modifier_royale_shard_ai:IsHidden() return true end
function modifier_royale_shard_ai:IsPurgable() return false end

function modifier_royale_shard_ai:OnCreated()
    if not IsServer() then return end
    self.ability      = self:GetAbility()
    self.parent       = self:GetParent()
    self.charge_time  = self.ability:GetSpecialValueFor("charge_time")
    self.attack_range = self.ability:GetSpecialValueFor("attack_range")
    self.knockback    = self.ability:GetSpecialValueFor("knockback")
    self.elapsed      = 0
    self.time_to_wait = 0
    self.particle_once_1 = false
    self.particle_once_2 = false
    self.particle_once_3 = false
    self:StartIntervalThink(0.1)
end

function modifier_royale_shard_ai:OnIntervalThink()
    if not IsServer() or not self.parent:IsAlive() then return end
    if not self:GetAbility() then
        self:Destroy()
        return
    end
    if self.time_to_wait > 0 then
        self.time_to_wait = self.time_to_wait - 0.1
        if self.time_to_wait <= 0 then
            self.elapsed = 0
            self.particle_once_1 = false
            self.particle_once_2 = false
            self.particle_once_3 = false
        end
        return
    end
    local parent = self.parent
    if parent:IsStunned() or parent:IsHexed() or parent:IsDisarmed() then
        self:SparkyStop()
        return
    end
    if self.elapsed == 0 then
        EmitSoundOn("Sparky.Charge", parent)
    end
    if not self.currentTarget or not self.currentTarget:IsAlive() or (self.currentTarget:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > self.attack_range then
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(), parent:GetAbsOrigin(), nil,
            1200,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_CLOSEST,
            false)
        if #enemies > 0 then
            local sortedEnemies = SortUnits_HeroesFirst(enemies)
            self.currentTarget = sortedEnemies[1]
        else
            self.currentTarget = nil
            local owner = self:GetCaster()
            local owner_pos = owner:GetAbsOrigin()
            local sparky_pos = parent:GetAbsOrigin()
            local distance = ( owner_pos - sparky_pos ):Length2D()
            local owner_dir = owner:GetForwardVector()
            local dir = owner_dir * RandomInt( 110, 140 )
            if distance > 350 then
                local right = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, RandomInt( 150, 300 ) * -1, 0 ), dir ) + owner_pos
                local left = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, RandomInt( 150, 300 ), 0 ), dir ) + owner_pos
                if ( sparky_pos - right ):Length2D() > ( sparky_pos - left ):Length2D() then
                    parent:MoveToPosition( left )
                else
                    parent:MoveToPosition( right )
                end
            elseif distance < 100 then
                parent:MoveToPosition( owner_pos + ( sparky_pos - owner_pos ):Normalized() * RandomInt( 110, 230 ) )
            end
        end
    end

    if self.currentTarget then
        parent:FaceTowards(self.currentTarget:GetAbsOrigin())
        if (self.currentTarget:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > self.attack_range * 0.8 then
            parent:MoveToTargetToAttack(self.currentTarget)
        end
    end

    self.elapsed = self.elapsed + 0.1
    if parent:HasModifier("modifier_royale_e_rage") then
        self.elapsed = self.elapsed + 0.1
    end
    if self.elapsed > 0.1 and not self.particle_once_1 then
        self.particle_once_1 = true
        self.p1 = ParticleManager:CreateParticle("particles/sparky_charge_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.p1, 3, parent, PATTACH_POINT_FOLLOW, "attach_circle1", parent:GetAbsOrigin(), true)
        self:AddParticle(self.p1, false, false, -1, false, false)
    end
    if self.elapsed > 1.1 and not self.particle_once_2 then
        self.particle_once_2 = true
        self.p2 = ParticleManager:CreateParticle("particles/sparky_charge_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.p2, 3, parent, PATTACH_POINT_FOLLOW, "attach_circle2", parent:GetAbsOrigin(), true)
        self:AddParticle(self.p2, false, false, -1, false, false)
    end
    if self.elapsed > 2.1 and not self.particle_once_3 then
        self.particle_once_3 = true
        self.p3 = ParticleManager:CreateParticle("particles/sparky_charge_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.p3, 3, parent, PATTACH_POINT_FOLLOW, "attach_circle3", parent:GetAbsOrigin(), true)
        self:AddParticle(self.p3, false, false, -1, false, false)
    end
    if self.elapsed < self.charge_time then return end

    if self.currentTarget and self.currentTarget:IsAlive() and (self.currentTarget:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() <= self.attack_range * 1.1 then
        local info = {
            Target = self.currentTarget,
            Source = parent,
            Ability = self.ability,
            EffectName = "particles/sparky_proj.vpcf",
            iMoveSpeed = 1200,
            bDodgeable = false,
            bProvidesVision = false,
        }
        local dir = (parent:GetAbsOrigin() - self.currentTarget:GetAbsOrigin()):Normalized()
        Timers:CreateTimer(0.2, function()
            ProjectileManager:CreateTrackingProjectile(info)
            EmitSoundOn("Sparky.Shot", parent)
            parent:AddNewModifier(parent, self.ability, "modifier_generic_knockback_lua", {
                duration = 0.3,
                distance = self.knockback,
                height   = 0,
                direction_x = dir.x,
                direction_y = dir.y,
            })
        end)
        self:SparkyStop()
        self.time_to_wait = 0.5
    end
end

function modifier_royale_shard_ai:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("Sparky.Charge", self.parent)
    EmitSoundOn("Royale.Death", self.parent)
    local p = ParticleManager:CreateParticle("particles/royale_die.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(p, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)
    UTIL_Remove(self.parent)
end

function modifier_royale_shard_ai:SparkyStop()
    if not IsServer() then return end
    StopSoundOn("Sparky.Charge", self.parent)
    if self.particle_once_1 then
        ParticleManager:DestroyParticle(self.p1, false)
        self.particle_once_1 = false
    end
    if self.particle_once_2 then
        ParticleManager:DestroyParticle(self.p2, false)
        self.particle_once_2 = false
    end
    if self.particle_once_3 then
        ParticleManager:DestroyParticle(self.p3, false)
        self.particle_once_3 = false
    end
    self.elapsed = 0
end