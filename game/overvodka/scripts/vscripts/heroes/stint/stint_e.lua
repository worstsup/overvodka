LinkLuaModifier( "modifier_inator_stint", "heroes/stint/stint_e", LUA_MODIFIER_MOTION_NONE )

stint_e = class({})

function stint_e:Precache(context)
    PrecacheResource("model", "models/stint/inator.vmdl", context)
end

function stint_e:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function stint_e:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function stint_e:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function stint_e:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function stint_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local position = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local inator = CreateUnitByName("npc_inator", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    local playerID = caster:GetPlayerID()
    inator:SetControllableByPlayer(playerID, true)
    inator:SetOwner(caster)
    inator:AddNewModifier( self:GetCaster(), self, "modifier_inator_stint", {} )
    inator:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
end

modifier_inator_stint = class({})

function modifier_inator_stint:OnCreated()
    if not IsServer() then return end
    self.hit_destroy = self:GetAbility():GetSpecialValueFor("hit_destroy")
    self.pct_damage = self:GetAbility():GetSpecialValueFor("pct_damage")
    self:GetParent():SetBaseMaxHealth(self.hit_destroy)
    self:GetParent():SetMaxHealth(self.hit_destroy)
    self:GetParent():SetHealth(self.hit_destroy)
    self:StartIntervalThink(0.5)
end

function modifier_inator_stint:IsHidden() return true end
function modifier_inator_stint:IsPurgable() return false end

function modifier_inator_stint:CheckState()
    return 
    {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
    }
end

function modifier_inator_stint:DeclareFunctions()
    local decFuncs = 
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING
    }
    return decFuncs
end

function modifier_inator_stint:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target ~= self:GetParent() then return end
    local new_health = self:GetParent():GetHealth() - 1
    if new_health <= 0 then
        self:GetParent():Kill(nil, params.attacker)
    else
        self:GetParent():SetHealth(new_health)
    end
end

function modifier_inator_stint:GetDisableHealing()
    return 1
end

function modifier_inator_stint:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_inator_stint:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_inator_stint:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_inator_stint:GetAbsoluteNoDamagePure()
    return 1
end


function modifier_inator_stint:OnIntervalThink()
    if not IsServer() then return end
end