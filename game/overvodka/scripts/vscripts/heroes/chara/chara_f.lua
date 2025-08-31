LinkLuaModifier("modifier_chara_f", "heroes/chara/chara_f", LUA_MODIFIER_MOTION_NONE)

chara_f = class({})

function chara_f:GetIntrinsicModifierName()
    return "modifier_chara_f"
end

modifier_chara_f = class({})

function modifier_chara_f:IsHidden() return false end
function modifier_chara_f:IsPurgable() return false end
function modifier_chara_f:RemoveOnDeath() return false end
function modifier_chara_f:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_chara_f:OnCreated(kv)
    local a = self:GetAbility()
    self.movespeed_gain = 0
    self.agi_gain       = 0
    self.as_gain        = 0
    self.max_gain       = 0

    if a then
        self.movespeed_gain = a:GetSpecialValueFor("movespeed_gain")
        self.agi_gain       = a:GetSpecialValueFor("agi_gain")
        self.as_gain        = a:GetSpecialValueFor("as_gain")
        self.max_gain       = a:GetSpecialValueFor("max_gain")
    else
        self.movespeed_gain = tonumber(kv.ms_gain or 0) or 0
        self.agi_gain       = tonumber(kv.agi_gain or 0) or 0
        self.as_gain        = tonumber(kv.as_gain or 0) or 0
        self.max_gain       = tonumber(kv.max_gain or 0) or 0
    end

    if IsServer() then
        if self:GetStackCount()==0 then self:SetStackCount(0) end
        if self:GetParent():IsIllusion() then
            local pid = self:GetParent():GetPlayerOwnerID()
            if pid ~= nil and PlayerResource then
                local real = PlayerResource:GetSelectedHeroEntity(pid)
                if real and not real:IsNull() then
                    self:SetStackCount(real._chara_f_stacks or self:GetStackCount())
                end
            end
        end
    end
end


function modifier_chara_f:OnRefresh()
    local a = self:GetAbility()
    if not a then return end
    self.movespeed_gain = a:GetSpecialValueFor("movespeed_gain")
    self.agi_gain       = a:GetSpecialValueFor("agi_gain")
    self.as_gain        = a:GetSpecialValueFor("as_gain")
    self.max_gain       = a:GetSpecialValueFor("max_gain")
end

function modifier_chara_f:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_chara_f:OnHeroKilled(k)
    if not IsServer() then return end
    local parent = self:GetParent()
    if k.attacker ~= parent then return end
    if parent:IsIllusion() then return end

    local target = k.target
    if not target or target:GetTeamNumber()==parent:GetTeamNumber() then return end
    if not target:IsRealHero() then return end
    if target.IsReincarnating and target:IsReincarnating() then return end

    local stacks = self:GetStackCount()
    if stacks >= (self.max_gain or 0) then return end
    if target and not target:IsNull() then
        local p = ParticleManager:CreateParticle("particles/chara_face2.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p, 0, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p)
    end
    stacks = stacks + 1
    self:SetStackCount(stacks)

    parent._chara_f_stacks = stacks

    self:SyncIllusionsStacks(stacks)
end

function modifier_chara_f:SyncIllusionsStacks(stacks)
    local parent = self:GetParent()
    local pid    = parent:GetPlayerOwnerID()
    local team   = parent:GetTeamNumber()

    local units = FindUnitsInRadius(
        team,
        parent:GetAbsOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
        FIND_ANY_ORDER,
        false
    )

    for _,u in ipairs(units) do
        if u and not u:IsNull()
           and u:IsIllusion()
           and u:GetPlayerOwnerID()==pid then

            local mod = u:FindModifierByName("modifier_chara_f")
            if not mod then
                u:AddNewModifier(parent, self:GetAbility(), "modifier_chara_f", {
                    ms_gain  = self.movespeed_gain,
                    agi_gain = self.agi_gain,
                    as_gain  = self.as_gain,
                    max_gain = self.max_gain,
                })
                mod = u:FindModifierByName("modifier_chara_f")
            end
            if mod then
                mod:SetStackCount(stacks)
            end
        end
    end
end

function modifier_chara_f:GetGenocideMult()
    local parent = self:GetParent()
    if parent and parent:HasModifier("modifier_chara_ultimate") then
        return self:GetAbility():GetSpecialValueFor("mult")
    end
    return 1.0
end

function modifier_chara_f:GetModifierMoveSpeedBonus_Constant()
    local stacks = self:GetStackCount() or 0
    return (self.movespeed_gain or 0) * stacks * self:GetGenocideMult()
end

function modifier_chara_f:GetModifierAttackSpeedBonus_Constant()
    local stacks = self:GetStackCount() or 0
    return (self.as_gain or 0) * stacks * self:GetGenocideMult()
end

function modifier_chara_f:GetModifierBonusStats_Agility()
    local stacks = self:GetStackCount() or 0
    return (self.agi_gain or 0) * stacks * self:GetGenocideMult()
end