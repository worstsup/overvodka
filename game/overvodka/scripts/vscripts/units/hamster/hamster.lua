hamster = class({})
LinkLuaModifier( "modifier_hamster", "units/hamster/hamster", LUA_MODIFIER_MOTION_NONE )

function hamster:GetIntrinsicModifierName()
	return "modifier_hamster"
end

modifier_hamster = class({})

function modifier_hamster:IsHidden()
	return true
end
function modifier_hamster:IsDebuff()
	return false
end
function modifier_hamster:IsStunDebuff()
	return false
end
function modifier_hamster:IsPurgable()
	return false
end

function modifier_hamster:OnCreated()
	if not IsServer() then return end
	self.gold = 200
	self.spawn_pos = self:GetParent():GetAbsOrigin()
    self.max_radius = 1000
	self.flee_radius = 700
	self.gold_cooldowns = {}
	self:StartIntervalThink(0.2)
	k = 0
end

function modifier_hamster:OnRemoved()
end

function modifier_hamster:OnDestroy()
end

function modifier_hamster:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
    local current_pos = parent:GetAbsOrigin()
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        current_pos,
        nil,
        self.flee_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
	if #enemies > 0 then
        local flee_dir = Vector(0,0,0)
        for _,enemy in ipairs(enemies) do
            local dir = (current_pos - enemy:GetAbsOrigin()):Normalized()
            flee_dir = flee_dir + dir
        end
        flee_dir = flee_dir:Normalized()
        local desired_pos = current_pos + flee_dir * 300
        local dist_to_spawn = (desired_pos - self.spawn_pos):Length2D()
        if dist_to_spawn > self.max_radius then
            desired_pos = self.spawn_pos + (desired_pos - self.spawn_pos):Normalized() * self.max_radius
        end
        parent:MoveToPosition(desired_pos)
    else
        if parent:IsMoving() then
			parent:Stop()
		end
    end
	k = k + 1
	local current_time = GameRules:GetGameTime()
	for entindex, last_time in pairs(self.gold_cooldowns) do
		if current_time - last_time > 1 then
			self.gold_cooldowns[entindex] = nil
		end
	end
	local ALL_TEAMS = {
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
	local caster = self:GetParent()
    local caster_position = caster:GetAbsOrigin()
    if (k % 15 == 0) then
    	for _, team in ipairs(ALL_TEAMS) do
        	MinimapEvent(
            	team,
            	caster,
            	caster_position.x,
            	caster_position.y,
            	DOTA_MINIMAP_EVENT_HINT_LOCATION,
            	3
        	)
    	end
    end
	for _, team in ipairs(ALL_TEAMS) do
		AddFOWViewer( team, caster_position, 400, 1, false )
	end
end

function modifier_hamster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_hamster:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_hamster:OnTakeDamage( params )
    if not IsServer() then return end
    if params.unit ~= self:GetParent() then return end

    local attacker = params.attacker
    if attacker:IsRealHero() and not attacker:IsIllusion() then
        local current_time = GameRules:GetGameTime()
        local entindex = attacker:entindex()
        if attacker:GetUnitName() == "npc_dota_hero_slark" then
            return
        else
            if not self.gold_cooldowns[entindex] or (current_time - self.gold_cooldowns[entindex]) >= 0.8 then
                attacker:ModifyGold(self.gold, true, 0)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, attacker, self.gold, nil)
                self.gold_cooldowns[entindex] = current_time
                local slark_gold = math.floor(self.gold * 0.5)
                local all_heroes = HeroList:GetAllHeroes()
                for _, hero in ipairs(all_heroes) do
                    if hero:IsRealHero() and not hero:IsIllusion() and hero:GetUnitName() == "npc_dota_hero_slark" then
                        hero:ModifyGold(slark_gold, true, 0)
                        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hero, slark_gold, nil)
                    end
                end
            end
        end
    end
end

function modifier_hamster:GetEffectName()
	return "particles/econ/events/ti10/aegis_lvl_1000_ambient_ti10.vpcf"
end

function modifier_hamster:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end