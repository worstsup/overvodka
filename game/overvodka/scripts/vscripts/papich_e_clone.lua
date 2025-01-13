LinkLuaModifier( "modifier_birzha_stunned", "modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_birzha_stunned_purge", "modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_papich_e_clone_thinker", "papich_e_clone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_e_clone_debuff", "papich_e_clone", LUA_MODIFIER_MOTION_NONE)

papich_e_clone = class({})

function papich_e_clone:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function papich_e_clone:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function papich_e_clone:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function papich_e_clone:OnUpgrade()
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("papich_e_clone_slam")
    end
    
    if self.release_ability and not self.release_ability:IsTrained() then
        self.release_ability:SetLevel(1)
    end
end

function papich_e_clone:OnSpellStart()
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end
    EmitSoundOn("papich_e_clone_start", self:GetCaster())
    local velocity  = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * 1500
    self.ice_blast_dummy = CreateModifierThinker(self:GetCaster(), self, "modifier_papich_e_clone_thinker", {x = velocity.x, y = velocity.y}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

    local linear_projectile = {
        Ability             = self,
        vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
        fDistance           = math.huge,
        fStartRadius        = 0,
        fEndRadius          = 0,
        Source              = self:GetCaster(),
        bDrawsOnMinimap     = true,
        bVisibleToEnemies   = false,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = GameRules:GetGameTime() + 30.0,
        bDeleteOnHit        = false,
        vVelocity           = Vector(velocity.x, velocity.y, 0),
        bProvidesVision     = true,
        iVisionRadius       = 650,
        iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
        
        ExtraData           =
        {
            direction_x     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).x,
            direction_y     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).y,
            direction_z     = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()).z,
            ice_blast_dummy = self.ice_blast_dummy:entindex(),
        }
    }

    self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
    
    if not self.release_ability then
        self.release_ability = self:GetCaster():FindAbilityByName("papich_e_clone_slam")
    end 
    
    if self.release_ability then
        self:GetCaster():SwapAbilities(self:GetName(), self.release_ability:GetName(), false, true)
    end
end

function papich_e_clone:OnProjectileThink_ExtraData(location, data)
    if data.ice_blast_dummy then
        EntIndexToHScript(data.ice_blast_dummy):SetAbsOrigin(location)
    end
    
    if not self:GetCaster():IsAlive() and self.release_ability then
        self.release_ability:OnSpellStart()
    end
end

function papich_e_clone:OnProjectileHit_ExtraData(target, location, data)
    if not target and data.ice_blast_dummy then
        local ice_blast_thinker_modifier = EntIndexToHScript(data.ice_blast_dummy):FindModifierByNameAndCaster("modifier_papich_e_clone_thinker", self:GetCaster())
        
        if ice_blast_thinker_modifier and not ice_blast_thinker_modifier:IsNull() then
            ice_blast_thinker_modifier:Destroy()
        end
    end
end

modifier_papich_e_clone_thinker = class({})

function modifier_papich_e_clone_thinker:IsPurgable()    return false end

function modifier_papich_e_clone_thinker:OnCreated(params)
    if not IsServer() then return end
    local ice_blast_particle = ParticleManager:CreateParticleForTeam("particles/ancient_apparition_ice_blast_initial_ti5_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
    ParticleManager:SetParticleControl(ice_blast_particle, 1, Vector(params.x, params.y, 0))
    self:AddParticle(ice_blast_particle, false, false, -1, false, false)
end

function modifier_papich_e_clone_thinker:OnDestroy()
    if not IsServer() then return end
    self.release_ability = self:GetCaster():FindAbilityByName("papich_e_clone_slam")
    if self:GetAbility() and self:GetAbility():IsHidden() and self.release_ability then 
        self:GetCaster():SwapAbilities("papich_e_clone_slam", "papich_e_clone", false, true)
    end
    self:GetParent():RemoveSelf()
end

papich_e_clone_slam = class({})

function papich_e_clone_slam:OnSpellStart()
    if not self.ice_blast_ability then
        self.ice_blast_ability  = self:GetCaster():FindAbilityByName("papich_e_clone")
    end
    
    if self.ice_blast_ability then
        if self.ice_blast_ability.ice_blast_dummy and self.ice_blast_ability.initial_projectile then
            local vector    = self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
            local velocity  = vector:Normalized() * math.max(vector:Length2D() / 2, 25000)
            local final_radius  = math.min(400 + ((vector:Length2D() / 1500) * 50), 1200)
            self:GetCaster():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast")
            AddFOWViewer(self:GetCaster():GetTeamNumber(), self.ice_blast_ability.ice_blast_dummy:GetAbsOrigin(), 650, 4, false)
            local linear_projectile = {
                Ability             = self,
                vSpawnOrigin        = self:GetCaster():GetAbsOrigin(),
                fDistance           = vector:Length2D(),
                fStartRadius        = 300,
                fEndRadius          = 300,
                Source              = self:GetCaster(),
                bHasFrontalCone     = false,
                bReplaceExisting    = false,
                iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_NONE,
                iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime         = GameRules:GetGameTime() + 10.0,
                bDeleteOnHit        = true,
                vVelocity           = velocity,
                bProvidesVision     = true,
                iVisionRadius       = 500,
                iVisionTeamNumber   = self:GetCaster():GetTeamNumber(),
                
                ExtraData           =
                {
                    marker_particle = marker_particle,
                    final_radius    = final_radius
                }
            }

            self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
            self.ice_blast_ability.ice_blast_dummy:Destroy()
            ProjectileManager:DestroyLinearProjectile(self.ice_blast_ability.initial_projectile)
            self.ice_blast_ability.ice_blast_dummy      = nil
            self.ice_blast_ability.initial_projectile   = nil
        end
        --self:GetCaster():SwapAbilities(self:GetName(), self.ice_blast_ability:GetName(), false, true)
    end
end

function papich_e_clone_slam:OnProjectileThink_ExtraData(location, data)
    if self.ice_blast_ability then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 500, 3, false)
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        local duration      = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration")
        local stun_duration      = self.ice_blast_ability:GetSpecialValueFor("duration")
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_papich_e_clone_debuff", 
                    {
                        duration = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_papich_e_clone_debuff", 
                    {
                        duration = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end
        end
    end
end

function papich_e_clone_slam:OnProjectileHit_ExtraData(target, location, data)
    if not target and self.ice_blast_ability then
        EmitSoundOnLocationWithCaster(location, "papich_e_clone_exp", self:GetCaster())

        local particle = ParticleManager:CreateParticle("particles/shredder_whirling_death_new.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 0, location)
        ParticleManager:ReleaseParticleIndex(particle)
    
        if data.marker_particle then
            ParticleManager:DestroyParticle(data.marker_particle, false)
            ParticleManager:ReleaseParticleIndex(data.marker_particle)
        end

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, data.final_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    
        local damageTable = {
            victim          = nil,
            damage          = self.ice_blast_ability:GetSpecialValueFor("damage"),
            damage_type     = self.ice_blast_ability:GetAbilityDamageType(),
            damage_flags    = DOTA_DAMAGE_FLAG_NONE,
            attacker        = self:GetCaster(),
            ability         = self
        }
        local duration = self.ice_blast_ability:GetSpecialValueFor("frostbite_duration")
        local stun_duration = self.ice_blast_ability:GetSpecialValueFor("duration")
        for _, enemy in pairs(enemies) do
            local ice_blast_modifier = nil
            if enemy:IsInvulnerable() then
                ice_blast_modifier = enemy:AddNewModifier(enemy, self.ice_blast_ability, "modifier_papich_e_clone_debuff", 
                    {
                        duration = duration * (1 - enemy:GetStatusResistance()),
                        caster_entindex = self:GetCaster():entindex()
                    }
                )
            else
                ice_blast_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_papich_e_clone_debuff", 
                    {
                        duration = duration * (1 - enemy:GetStatusResistance()),
                    }
                )
            end
            if not enemy:IsMagicImmune() then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
                enemy:AddNewModifier( self:GetCaster(), self.ice_blast_ability, "modifier_birzha_stunned_purge", { duration = stun_duration * (1-enemy:GetStatusResistance()) } )
            end
        end
    end
end

modifier_papich_e_clone_debuff = class({})

function modifier_papich_e_clone_debuff:IsDebuff()      return true end
function modifier_papich_e_clone_debuff:IsPurgable()    return false end
function modifier_papich_e_clone_debuff:IsPurgeException()    return true end

function modifier_papich_e_clone_debuff:GetEffectName()
    return "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf"
end

function modifier_papich_e_clone_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_papich_e_clone_debuff:OnCreated(params)
    if not IsServer() then return end
    self.dot_damage = self:GetAbility():GetSpecialValueFor("dot_damage")
    self.kill_percent = self:GetAbility():GetSpecialValueFor("kill_percent")
    if params.caster_entindex then
        self.caster = EntIndexToHScript(params.caster_entindex)
    else
        self.caster = self:GetCaster()
    end
    
    self.damage_table   = 
    {
        victim          = self:GetParent(),
        damage          = self.dot_damage,
        damage_type     = DAMAGE_TYPE_MAGICAL,
        damage_flags    = DOTA_DAMAGE_FLAG_NONE,
        attacker        = self.caster,
        ability         = self:GetAbility()
    }
    
    self:StartIntervalThink(1)
end

function modifier_papich_e_clone_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_papich_e_clone_debuff:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Tick")
    ApplyDamage(self.damage_table)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.dot_damage, nil)
    if self:GetParent():GetHealthPercent() <= self.kill_percent then
        self:GetParent():Kill(self:GetAbility(), self:GetCaster())
        EmitSoundOn("papich_e_clone_success", self:GetCaster())
        self:Destroy()
    end
end

function modifier_papich_e_clone_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_HEALING,
    }
end

function modifier_papich_e_clone_debuff:GetDisableHealing()
    return 1
end