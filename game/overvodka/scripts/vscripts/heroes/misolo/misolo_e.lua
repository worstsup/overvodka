LinkLuaModifier("modifier_misolo_e", "heroes/misolo/misolo_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_misolo_e_manta_frame", "heroes/misolo/misolo_e", LUA_MODIFIER_MOTION_NONE)

misolo_e = class({})

modifier_misolo_e = class({})
modifier_misolo_e_manta_frame = class({})

function misolo_e:Precache(context)
    PrecacheResource("particle", "particles/items2_fx/orchid.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/manta_phase.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_items.vsndevts", context)
end

function misolo_e:GetIntrinsicModifierName()
    return "modifier_misolo_e"
end

function misolo_e:OnToggle()
	if not IsServer() then return end
	self:EndCooldown()
end

function modifier_misolo_e:IsHidden() return true end
function modifier_misolo_e:IsPurgable() return false end
function modifier_misolo_e:RemoveOnDeath() return false end

function modifier_misolo_e:OnCreated()
    self.scan_interval = self:GetAbility():GetSpecialValueFor("scan_interval")
    self.next_scan_time = 0
    self.dodge_queue = {}
    self.dodge_lock = 0

    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end

    self.filter = FilterManager:AddTrackingProjectileFilter(self.ProjectileFilter, self)
    self:StartIntervalThink(0.03)
end

function modifier_misolo_e:OnRefresh()
    if not IsValid(self:GetAbility()) then return end
    self.scan_interval = self:GetAbility():GetSpecialValueFor("scan_interval")
end

function modifier_misolo_e:OnDestroy()
    if not IsServer() then return end
    if not self.filter then return end

    FilterManager:RemoveTrackingProjectileFilter(self.filter)
end

function modifier_misolo_e:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    local game_time = GameRules:GetGameTime()

    if not IsValid(parent, ability) then
        self:Destroy()
        return
    end

    if game_time >= self.next_scan_time then
        self.next_scan_time = game_time + math.max(self.scan_interval, 0.03)

        local can_auto_silence = ability:GetLevel() > 0 and not parent:IsIllusion() and parent:IsAlive() and not parent:PassivesDisabled() and not ability:GetToggleState()
        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            ability:GetSpecialValueFor("trigger_radius"),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_CLOSEST,
            false
        )

        local auto_silence_duration = ability:GetSpecialValueFor("auto_silence_duration")
        for _, enemy in ipairs(enemies) do
            if can_auto_silence and ability:IsCooldownReady() and enemy:IsRealHero() and not enemy:IsIllusion() and not enemy:IsInvulnerable() and not enemy:IsOutOfGame() and not enemy:IsMagicImmune() and not enemy:IsDebuffImmune() then
                enemy:AddNewModifier(parent, ability, "modifier_generic_silenced_lua", {
                    duration = auto_silence_duration,
                    particle = "particles/items2_fx/orchid.vpcf",
                })

                EmitSoundOn("DOTA_Item.Orchid.Activate", enemy)
                ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
                break
            end
        end
    end

    if #self.dodge_queue == 0 then return end

    for i = #self.dodge_queue, 1, -1 do
        local dodge = self.dodge_queue[i]
        if game_time >= dodge.time then
            if parent:IsAlive() and not parent:IsIllusion() and not parent:PassivesDisabled() and game_time >= self.dodge_lock then
                self.dodge_lock = game_time + 0.12

                ProjectileManager:ProjectileDodge(parent)
                parent:AddNewModifier(parent, ability, "modifier_misolo_e_manta_frame", {duration = ability:GetSpecialValueFor("manta_invuln_duration")})
                parent:Purge(false, true, false, false, false)

                for _, illusion in ipairs(ability.manta_illusions or {}) do
                    if IsValid(illusion) then
                        illusion:AddNoDraw()
                        illusion:ForceKill(false)
                    end
                end

                ability.manta_illusions = {}

                local outgoing = ability:GetSpecialValueFor("illusion_outgoing_damage") - 100
                local incoming = ability:GetSpecialValueFor("illusion_incoming_damage") - 100
                local illusions = OvervodkaCreateIllusions(parent, parent, {
                    outgoing_damage = outgoing,
                    incoming_damage = incoming,
                    duration = ability:GetSpecialValueFor("illusion_duration"),
                }, 2, 108, false, true)

                for _, illusion in ipairs(illusions or {}) do
                    if IsValid(illusion) then
                        illusion:SetOwner(parent)
                        illusion:SetControllableByPlayer(parent:GetPlayerOwnerID(), true)
                        illusion:AddNewModifier(parent, ability, "modifier_phased", {duration = 0.1})
                        FindClearSpaceForUnit(illusion, parent:GetAbsOrigin() + RandomVector(RandomInt(80, 140)), true)
                        table.insert(ability.manta_illusions, illusion)
                    end
                end

                EmitSoundOn("DOTA_Item.Manta.Activate", parent)
                EmitSoundOn("misolo_e", parent)
            end

            table.remove(self.dodge_queue, i)
        end
    end
end

function modifier_misolo_e:ProjectileFilter(data)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not IsValid(parent, ability) or ability:GetLevel() <= 0 then return true end
    if parent:IsIllusion() or parent:PassivesDisabled() or not parent:IsAlive() then return true end

    local is_attack = data.is_attack == true or data.is_attack == 1 or data.is_attack == "1"
    if is_attack then return true end
    if not data.entindex_target_const or not data.entindex_source_const or not data.entindex_ability_const then return true end

    local target = EntIndexToHScript(tonumber(data.entindex_target_const) or data.entindex_target_const)
    if target ~= parent then return true end

    local source = EntIndexToHScript(tonumber(data.entindex_source_const) or data.entindex_source_const)
    local projectile_ability = EntIndexToHScript(tonumber(data.entindex_ability_const) or data.entindex_ability_const)
    if not IsValid(source, projectile_ability) or source:GetTeamNumber() == parent:GetTeamNumber() then return true end

    local behavior = projectile_ability:GetBehaviorInt()
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == 0 then return true end
    if RandomInt(1, 100) > ability:GetSpecialValueFor("projectile_dodge_chance") then return true end

    local delay = 0.03
    local speed = tonumber(data.move_speed) or 0
    if speed > 0 then
        delay = math.max((source:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() / speed - 0.08, 0.03)
    end

    self.dodge_queue[#self.dodge_queue + 1] = {time = GameRules:GetGameTime() + delay}

    return true
end

function modifier_misolo_e_manta_frame:IsHidden() return true end
function modifier_misolo_e_manta_frame:IsPurgable() return false end

function modifier_misolo_e_manta_frame:OnCreated()
    if not IsServer() then return end

    local particle = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_misolo_e_manta_frame:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
