LinkLuaModifier("modifier_royale_megaknight", "heroes/royale/royale_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_royale_megaknight_jump", "heroes/royale/royale_r", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_overvodka_creep", "modifiers/modifier_overvodka_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)

royale_r = class({})

function royale_r:Precache(context)
    PrecacheResource("soundfile", "soundevents/royale_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/megaknight_attack.vpcf", context)
    PrecacheUnitByNameSync("npc_megaknight", context)
end

function royale_r:GetAOERadius()
	return self:GetSpecialValueFor( "spawn_radius" )
end

function royale_r:OnAbilityPhaseStart()
    EmitSoundOn("Royale.Cast", self:GetCaster())
    return true
end

function royale_r:OnAbilityPhaseInterrupted()
    StopSoundOn("Royale.Cast", self:GetCaster())
end

function royale_r:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")
    local base_damage = self:GetSpecialValueFor("base_dmg")
    local base_hp = self:GetSpecialValueFor("base_hp")
    local gold = self:GetSpecialValueFor("gold")
    local xp = self:GetSpecialValueFor("xp")

    local mega = CreateUnitByName("npc_megaknight", point, true, caster, nil, caster:GetTeamNumber())
    mega:SetOwner(caster)
    mega:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    mega:SetBaseMaxHealth(base_hp)
    mega:SetMaxHealth(base_hp)
    mega:SetHealth(base_hp)
    mega:SetBaseDamageMin(base_damage)
    mega:SetBaseDamageMax(base_damage)
    mega:SetMinimumGoldBounty(gold)
    mega:SetMaximumGoldBounty(gold)
    mega:SetDeathXP(xp)
    mega:AddNewModifier(caster, self, "modifier_royale_megaknight", {})
    mega:AddNewModifier(caster, self, "modifier_overvodka_creep", {})
    EmitSoundOnLocationWithCaster(point, "MegaKnight.Deploy", caster)
end


modifier_royale_megaknight = class({})

function modifier_royale_megaknight:IsHidden() return true end
function modifier_royale_megaknight:IsPurgable() return false end

function modifier_royale_megaknight:OnCreated(kv)
    if not IsServer() then return end
    local parent  = self:GetParent()
    local caster  = self:GetCaster()
    local ability = self:GetAbility()
    self.preparing = false
    local spawnRadius = ability:GetSpecialValueFor("spawn_radius")
    local spawnDamage = ability:GetSpecialValueFor("spawn_dmg")
    local units = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, spawnRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _,unit in pairs(units) do
        ApplyDamage({victim=unit, attacker=caster, damage=spawnDamage,damage_type=DAMAGE_TYPE_MAGICAL, ability=ability})
        unit:AddNewModifier(caster, ability, "modifier_knockback", {
            center_x = parent:GetAbsOrigin().x,
            center_y = parent:GetAbsOrigin().y,
            center_z = parent:GetAbsOrigin().z,
            duration = 0.4,
            knockback_duration = 0.4,
            knockback_distance = spawnRadius,
            knockback_height = 200,
        })
    end
    self:StartIntervalThink(0.25)
end

function modifier_royale_megaknight:OnIntervalThink()
    if not IsServer() then return end
    if self.preparing then return end
    local parent = self:GetParent()
    if not parent:IsAlive() or parent:IsStunned() or parent:IsHexed() or parent:IsSilenced() or parent:HasModifier("modifier_royale_megaknight_jump") then return end
    local ability = self:GetAbility()
    local jumpMin = ability:GetSpecialValueFor("jump_min_range")
    local jumpMax = ability:GetSpecialValueFor("jump_max_range")
    local prepareTime = ability:GetSpecialValueFor("jump_prepare_time")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), parent:GetAbsOrigin(), nil,
                       jumpMax, DOTA_UNIT_TARGET_TEAM_ENEMY,
                       DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                       DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #enemies > 0 then
        local sortedEnemies = SortUnits_HeroesFirst(enemies)
        for _,unit in pairs(sortedEnemies) do
            local dist = (unit:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
            if dist >= jumpMin then
                EmitSoundOn("MegaKnight.Jump.Prepare", parent)
                self.preparing = true
                parent:Stop()
                parent:StartGesture(ACT_DOTA_CAST_ABILITY_2)
                parent:FaceTowards(unit:GetAbsOrigin())
                Timers:CreateTimer(prepareTime, function()
                    local kv = {
                        target_x = unit:GetAbsOrigin().x,
                        target_y = unit:GetAbsOrigin().y,
                        target_z = unit:GetAbsOrigin().z,
                    }
                    parent:AddNewModifier(parent, ability, "modifier_royale_megaknight_jump", kv)
                    self.preparing = false
                end)
                return
            else
                if unit:IsAlive() and not unit:IsAttackImmune() then
                    parent:MoveToTargetToAttack(unit)
                    return
                end
            end
        end
    else
        local owner = self:GetCaster()
	    local owner_pos = owner:GetAbsOrigin()
        local mega_pos = parent:GetAbsOrigin()
        local distance = ( owner_pos - mega_pos ):Length2D()
        local owner_dir = owner:GetForwardVector()
        local dir = owner_dir * RandomInt( 110, 140 )
        if distance > 350 then
			local right = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, RandomInt( 150, 300 ) * -1, 0 ), dir ) + owner_pos
			local left = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, RandomInt( 150, 300 ), 0 ), dir ) + owner_pos
			if ( mega_pos - right ):Length2D() > ( mega_pos - left ):Length2D() then
				parent:MoveToPosition( left )
			else
				parent:MoveToPosition( right )
			end
		elseif distance < 100 then
			parent:MoveToPosition( owner_pos + ( mega_pos - owner_pos ):Normalized() * RandomInt( 110, 230 ) )
		end
    end
end

function modifier_royale_megaknight:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND }
end

function modifier_royale_megaknight:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    local splashRadius = self:GetAbility():GetSpecialValueFor("attack_splash_radius")
    local splashDmg = self:GetParent():GetAverageTrueAttackDamage(nil)
    if self:GetAbility():GetSpecialValueFor("evo_knockback_distance") > 0 then
        local dir = (params.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_generic_knockback_lua", {
            duration = 0.4,
            distance = self:GetAbility():GetSpecialValueFor("evo_knockback_distance"),
            height = 250,
            direction_x = dir.x, direction_y = dir.y,
        })
    end
    local targetPos = params.target:GetAbsOrigin()
    local p = ParticleManager:CreateParticle( "particles/megaknight_attack.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(p, 0, targetPos)
    ParticleManager:SetParticleControl(p, 1, targetPos)
    ParticleManager:ReleaseParticleIndex(p)
    for _,unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), targetPos, nil,
                       splashRadius, DOTA_UNIT_TARGET_TEAM_ENEMY,
                       DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                       DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
        if unit ~= params.target then
            ApplyDamage({victim=unit, attacker=self:GetParent(), damage=splashDmg, damage_type=DAMAGE_TYPE_PHYSICAL, ability=self:GetAbility()})
        end
    end
end

function modifier_royale_megaknight:GetAttackSound()
	return "MegaKnight.Attack"
end

modifier_royale_megaknight_jump = class({})
function modifier_royale_megaknight_jump:IsHidden() return true end
function modifier_royale_megaknight_jump:IsPurgable() return false end
function modifier_royale_megaknight_jump:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_royale_megaknight_jump:OnCreated(kv)
    if not IsServer() then return end
    local parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()

    self.startPos = parent:GetAbsOrigin()
    self.endPos = Vector(kv.target_x, kv.target_y, kv.target_z)
    self.duration = self.ability:GetSpecialValueFor("jump_duration")
    self.height = self.ability:GetSpecialValueFor("jump_height")

    self.direction = (self.endPos - self.startPos):Normalized()
    self.distance = (self.endPos - self.startPos):Length2D()
    self.speedH = self.distance / self.duration
    self.v0 = (4 * self.height) / self.duration
    self.g = (8 * self.height) / (self.duration ^ 2)

    self.elapsed = 0
    parent:StartGesture(ACT_DOTA_CAST_ABILITY_2)
    EmitSoundOn("MegaKnight.Jump.Cast", parent)

    if not self:ApplyHorizontalMotionController() or not self:ApplyVerticalMotionController() then
        self:Destroy()
    end
end

function modifier_royale_megaknight_jump:UpdateHorizontalMotion(parent, dt)
    if not IsServer() then return end
    self.elapsed = self.elapsed + dt
    local progress = math.min(self.elapsed / self.duration, 1)
    local newXY = self.startPos + self.direction * self.speedH * self.elapsed
    local currentZ = parent:GetAbsOrigin().z
    parent:SetAbsOrigin(Vector(newXY.x, newXY.y, currentZ))

    if progress >= 1 then
        parent:InterruptMotionControllers(true)
        self:FinishJump()
        self:Destroy()
    end
end

function modifier_royale_megaknight_jump:UpdateVerticalMotion(parent, dt)
    if not IsServer() then return end
    local z = self.startPos.z + self.v0 * self.elapsed - 0.5 * self.g * (self.elapsed ^ 2)
    local pos = parent:GetAbsOrigin()
    parent:SetAbsOrigin(Vector(pos.x, pos.y, z))
end

function modifier_royale_megaknight_jump:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    parent:RemoveHorizontalMotionController(self)
    parent:RemoveVerticalMotionController(self)
end

function modifier_royale_megaknight_jump:FinishJump()
    local parent = self:GetParent()
    parent:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
    EmitSoundOn("MegaKnight.Jump.Land", parent)
    local jumpRadius = self.ability:GetSpecialValueFor("spawn_radius")
    local jumpDmg = self.ability:GetSpecialValueFor("spawn_dmg")
    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), parent:GetAbsOrigin(), nil,
                       jumpRadius, DOTA_UNIT_TARGET_TEAM_ENEMY,
                       DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                       DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(enemies) do
        ApplyDamage({victim=unit, attacker=self.caster, damage=jumpDmg, damage_type=DAMAGE_TYPE_MAGICAL, ability=self.ability})
        unit:AddNewModifier(self.caster, self.ability, "modifier_knockback", {
            center_x = parent:GetAbsOrigin().x,
            center_y = parent:GetAbsOrigin().y,
            center_z = parent:GetAbsOrigin().z,
            duration = 0.4,
            knockback_duration = 0.4,
            knockback_distance = jumpRadius,
            knockback_height = 200,
        })
    end
end
