modifier_golovach_run = class({})
function modifier_golovach_run:IsPurgable() return false end
function modifier_golovach_run:OnCreated(params)
    if not IsServer() then return end
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.target = EntIndexToHScript(params.target)
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.debuff_immune = self:GetAbility():GetSpecialValueFor("debuff_immune")
    self.talent = false
    if self.debuff_immune == 1 then
        self.talent = true
    end
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
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent_origin = parent:GetAbsOrigin()
    if self.target == nil or self.target:IsNull() then
        self:Destroy()
        return
    end
    local target_origin = self.target:GetAbsOrigin()
    local distance = (target_origin - parent_origin):Length2D()
    if not self.target:IsAlive() or ( self.target:IsInvisible() and not parent:CanEntityBeSeenByMyTeam(self.target) ) or distance > 3000 then
        if not self:IsNull() then
            self:Destroy()
            return
        end
    else
        AddFOWViewer(caster:GetTeamNumber(), target_origin, 100, 0.1, true)
        parent:MoveToTargetToAttack(self.target)
    end
    if self.radius > 0 and self.damage > 0 then
        local units = FindUnitsInRadius(caster:GetTeamNumber(), parent_origin, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        local damage_table = {
            attacker = caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = ability,
        }
        local knockback_properties = {
            center_x = parent_origin.x,
            center_y = parent_origin.y,
            center_z = parent_origin.z,
            duration = 0.6,
            knockback_duration = 0.6,
            knockback_distance = 200,
            knockback_height = 50
        }
        for _, unit in pairs(units) do
            if unit ~= self.target then
                if not self.targets_table[unit:entindex()] then
                    self.targets_table[unit:entindex()] = true
                    damage_table.victim = unit
                    ApplyDamage(damage_table)
                    if unit and not unit:IsNull() then
                        unit:AddNewModifier(
                            caster,
                            self,
                            "modifier_knockback",
                            knockback_properties
                        )
                        local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_POINT_FOLLOW, unit )
                        ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
                        ParticleManager:ReleaseParticleIndex( particle )
                    end
                end
            end
        end
    end
end

function modifier_golovach_run:CheckState()
    return
    {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_DEBUFF_IMMUNE] = self.talent,
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

    local effect_cast = ParticleManager:CreateParticleForPlayer( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector(1,0,0) )

    self:AddParticle(
        effect_cast,
        false,
        false,
        -1,
        false,
        false
    )
end