modifier_win_condition = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_MIN_HEALTH,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end,
})

function modifier_win_condition:OnCreated()
    self.CanDeath = false
    self.Once = false
end

function modifier_win_condition:GetMinHealth( event )
	if self.CanDeath then
        return 0
    end
    return 1
end

function modifier_win_condition:OnTakeDamage( event )
	if not IsServer() then return end

    local parent = self:GetParent()
    local target = event.unit
    if parent ~= target then return end

    local attacker = event.attacker

    if attacker and parent == target and parent:IsAlive() and parent:GetHealth() == 1 and self.Once == false then
        self.Once = true

        OvervodkaGameMode:EndGame(attacker:GetTeamNumber())

        parent:SetThink(function ()
            self.CanDeath = true
            parent:Kill(nil, attacker)
            return -1
        end, self, DoUniqueString("EndGame"), 0.1)
    end
end