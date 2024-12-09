modifier_golovach_run = class({})
function modifier_golovach_run:IsPurgable() return false end
function modifier_golovach_run:OnCreated(params)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.target = EntIndexToHScript(params.target)
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.targets_table = {}
    self:PlayEffects1()
    local order =
    {
        UnitIndex = self:GetParent():entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        TargetIndex = self.target:entindex()
    }
    ExecuteOrderFromTable(order)
    self:GetParent():SetForceAttackTarget(self.target)
    self:GetParent():MoveToTargetToAttack(self.target)
    self:StartIntervalThink(0.05)
end

function modifier_golovach_run:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Interrupt()
    self:GetParent():SetForceAttackTarget(nil)
    self:GetParent():SetForceAttackTargetAlly(nil)
    if self.target and not self.target:IsNull() and self.target:IsAlive() then
        self:GetParent():MoveToTargetToAttack(self.target)
    else
        self:GetParent():Stop()
    end
end

function modifier_golovach_run:OnIntervalThink()
    if not IsServer() then return end
    if self.target == nil or not self.target:IsAlive() or ( self.target:IsInvisible() and not self:GetParent():CanEntityBeSeenByMyTeam(self.target) ) then
        if not self:IsNull() then
            self:Destroy()
            return
        end
    else
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 100, 0.1, true)
        self:GetParent():MoveToTargetToAttack(self.target)
    end
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit ~= self.target then
            if not self.targets_table[unit:entindex()] then
                self.targets_table[unit:entindex()] = true
                ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility() })
                local direction = (unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin())
                direction.z = 0
                direction = direction:Normalized()
                unit:AddNewModifier(
                    self:GetCaster(),
                    self,
                    "modifier_generic_knockback_lua",
                    {
                        direction_x = direction.x,
                        direction_y = direction.y,
                        distance = 200,
                        height = 50,	
                        duration = 0.5,
                    }
                )
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_POINT_FOLLOW, unit )
                ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
                ParticleManager:ReleaseParticleIndex( particle )
            end
        end
    end
end

function modifier_golovach_run:CheckState()
    return
    {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_golovach_run:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end



function modifier_golovach_run:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("speed")
end
function modifier_golovach_run:PlayEffects1()
    local particle_cast = "particles/muerta_ultimate_form_screen_effect_new.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector(1,0,0) )

    -- buff particle
    self:AddParticle(
        effect_cast,
        false, -- bDestroyImmediately
        false, -- bStatusEffect
        -1, -- iPriority
        false, -- bHeroEffect
        false -- bOverheadEffect
    )
end