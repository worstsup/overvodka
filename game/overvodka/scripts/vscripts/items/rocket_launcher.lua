LinkLuaModifier("modifier_bombardiro_fly_rocket_launcher", "items/rocket_launcher", LUA_MODIFIER_MOTION_HORIZONTAL)

item_rocket_launcher = class({})

function item_rocket_launcher:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    EmitSoundOnLocationWithCaster(point, "rocket_launcher", caster)
    local effect = ParticleManager:CreateParticle("particles/rocket_launcher.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect, 0, point)
    ParticleManager:SetParticleControl(effect, 2, point)
    Timers:CreateTimer(1.5, function()
        local spawnPoints = {
            Vector(4000, 4000, 0),
            Vector(-4000, 4000, 0),
            Vector(4000, -4000, 0),
            Vector(-4000, -4000, 0)
        }
        if GetMapName() == "dota" then
            spawnPoints = {
                Vector(8000, 8000, 0),
                Vector(-8000, 8000, 0),
                Vector(8000, -8000, 0),
                Vector(-8000, -8000, 0)
            }
        end
        local spawnLocation = spawnPoints[RandomInt(1, #spawnPoints)]
        bombardiro = CreateUnitByName("npc_bombardiro", spawnLocation, true, undefined, undefined, self:GetCaster():GetTeamNumber())
        bombardiro:FindAbilityByName("bombardiro_fly"):SetLevel(0)
        bombardiro:AddNewModifier(self:GetCaster(), self, "modifier_bombardiro_fly_rocket_launcher", {point_x = point.x, point_y = point.y})
        bombardiro:FindAbilityByName("bombardiro_bombs"):SetLevel(1)
        ParticleManager:DestroyParticle(effect, false)
        ParticleManager:ReleaseParticleIndex(effect)
        self:SpendCharge(1)
    end)
end

modifier_bombardiro_fly_rocket_launcher = class({})

function modifier_bombardiro_fly_rocket_launcher:IsHidden() return true end
function modifier_bombardiro_fly_rocket_launcher:IsPurgable() return false end
function modifier_bombardiro_fly_rocket_launcher:RemoveOnDeath() return false end

function modifier_bombardiro_fly_rocket_launcher:OnCreated(kv)
    if not IsServer() then return end
    local parent = self:GetParent()
    local spawn_pos = parent:GetAbsOrigin()
    local center = Vector(kv.point_x, kv.point_y, 0)
    local rel = spawn_pos - center
    local opposite = center - rel
    self.center = Vector(center.x, center.y, spawn_pos.z)
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

function modifier_bombardiro_fly_rocket_launcher:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end
function modifier_bombardiro_fly_rocket_launcher:GetModifierMoveSpeed_Absolute()
    if GetMapName() == "dota" then
        return 1200
    end
    return 900
end

function modifier_bombardiro_fly_rocket_launcher:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

function modifier_bombardiro_fly_rocket_launcher:MoveTo(pos)
    local parent = self:GetParent()
    ExecuteOrderFromTable({
        UnitIndex = parent:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = pos
    })
end

function modifier_bombardiro_fly_rocket_launcher:OnIntervalThink()
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
            DOTA_UNIT_TARGET_FLAG_NONE,
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
        self:MoveTo(self.center + self:GetParent():GetForwardVector() * 4000)
    elseif self.phase == 2 and (pos - self.center):Length2D() > 4000 then
        parent:ForceKill(false)
        self:Destroy()
    end
end