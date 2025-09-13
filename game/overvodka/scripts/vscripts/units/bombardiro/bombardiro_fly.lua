LinkLuaModifier("modifier_bombardiro_fly", "units/bombardiro/bombardiro_fly", LUA_MODIFIER_MOTION_HORIZONTAL)

bombardiro_fly = class({})
function bombardiro_fly:GetIntrinsicModifierName()
    return "modifier_bombardiro_fly"
end

modifier_bombardiro_fly = class({})

function modifier_bombardiro_fly:IsHidden() return true end
function modifier_bombardiro_fly:IsPurgable() return false end
function modifier_bombardiro_fly:RemoveOnDeath() return false end

function modifier_bombardiro_fly:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local spawn_pos = parent:GetAbsOrigin()
    local center = Vector(RandomFloat(-500, 500), RandomFloat(-500, 500), spawn_pos.z)
    local rel = spawn_pos - center
    local opposite = center - rel
    self.center = Vector(center.x, center.y, spawn_pos.z)
    self.opposite = Vector(opposite.x, opposite.y, spawn_pos.z)
    self.phase = 1
    Timers:CreateTimer(0.1, function()
        self:MoveTo(self.center)
    end)
    EmitSoundOn("bombardiro", parent)
    EmitSoundOn("bombardiro_plane_sound", parent)
    self.ALL_TEAMS = {
    	DOTA_TEAM_CUSTOM_1,
    	DOTA_TEAM_CUSTOM_2,
    	DOTA_TEAM_CUSTOM_3,
    	DOTA_TEAM_CUSTOM_4,
    	DOTA_TEAM_CUSTOM_5,
    	DOTA_TEAM_CUSTOM_6,
    	DOTA_TEAM_CUSTOM_7,
    	DOTA_TEAM_CUSTOM_8,
    	DOTA_TEAM_GOODGUYS,
    	DOTA_TEAM_BADGUYS
	}
    self:StartIntervalThink(0.05)
end

function modifier_bombardiro_fly:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end
function modifier_bombardiro_fly:GetModifierMoveSpeed_Absolute()
    return 900
end

function modifier_bombardiro_fly:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

function modifier_bombardiro_fly:MoveTo(pos)
    local parent = self:GetParent()
    ExecuteOrderFromTable({
        UnitIndex = parent:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = pos
    })
end

function modifier_bombardiro_fly:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local pos = parent:GetAbsOrigin()
    for _, team in ipairs(self.ALL_TEAMS) do
        AddFOWViewer( team, pos, 400, 0.1, false )
    end
    local bombardiro_bombs = parent:FindAbilityByName("bombardiro_bombs")
    if bombardiro_bombs and bombardiro_bombs:IsCooldownReady() then
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            pos,
            nil,
            700,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS,
            FIND_ANY_ORDER,
            false
        )
        if #enemies > 0 then
            for _, enemy in ipairs(enemies) do
                if enemy and enemy:IsAlive() then
                    parent:CastAbilityOnPosition(enemy:GetAbsOrigin(), bombardiro_bombs, -1)
                end
            end
        end
    end
    if self.phase == 1 and (pos - self.center):Length2D() < 50 then
        self.phase = 2
        self:MoveTo(self.opposite)
    elseif self.phase == 2 and (pos - self.opposite):Length2D() < 50 then
        parent:ForceKill(false)
        self:Destroy()
    end
end