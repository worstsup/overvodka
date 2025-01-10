LinkLuaModifier("modifier_dota_ability_xp_granter", "abilities/xp_granter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_get_xp", "abilities/xp_granter", LUA_MODIFIER_MOTION_NONE)

dota_ability_xp_granter_base = class({})

dota_ability_xp_granter = dota_ability_xp_granter_base or class({})
dota_ability_xp_granter2 = dota_ability_xp_granter_base or class({})

function dota_ability_xp_granter_base:GetIntrinsicModifierName()
    return "modifier_dota_ability_xp_granter"
end

modifier_dota_ability_xp_granter = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
    IsPermanent             = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end,

    IsAura                  = function(self) return true end,
    GetAuraDuration         = function(self) return 0 end,
    GetAuraRadius           = function(self) return self.Radius or 0 end,
    GetModifierAura         = function(self) return "modifier_get_xp" end,
    GetAuraSearchTeam       = function(self) return DOTA_UNIT_TARGET_TEAM_BOTH end,
    GetAuraSearchType       = function(self) return DOTA_UNIT_TARGET_HERO end,
    GetAuraSearchFlags      = function(self) return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end,

    CheckState              = function (self)
        return {
            [MODIFIER_STATE_UNSELECTABLE]=true,
            [MODIFIER_STATE_NO_HEALTH_BAR]=true,
            [MODIFIER_STATE_INVULNERABLE]=true,
            [MODIFIER_STATE_OUT_OF_GAME]=true,
            [MODIFIER_STATE_NO_UNIT_COLLISION]=true,
            [MODIFIER_STATE_NOT_ON_MINIMAP]=true,
        }
    end
})

function modifier_dota_ability_xp_granter:OnCreated()
    local Ability = self:GetAbility()
    if Ability then
        self.Radius = Ability:GetSpecialValueFor("radius")
        self.Xp = Ability:GetSpecialValueFor("xp")
        self.Gold = Ability:GetSpecialValueFor("gold")

        if IsServer() then
            self:StartIntervalThink(0.5)
        end
    end
end

function modifier_dota_ability_xp_granter:OnIntervalThink()
    local Units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0,0,0), nil, self.Radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
    for _, Unit in ipairs(Units) do
        local Gold = self.Gold
        local Xp = self.Xp

        local Team = Unit:GetTeamNumber()

        local newGold = ChangeValueByTeamPlace(Gold, Team)
        local newXp = ChangeValueByTeamPlace(Gold, Team)

        Unit:ModifyGold(newGold, false, DOTA_ModifyGold_GameTick)
        Unit:AddExperience(newXp, DOTA_ModifyXP_Unspecified, false, false)
    end
end

modifier_get_xp = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,

    GetTexture              = function(self) return "custom_games_xp_coin" end,
})