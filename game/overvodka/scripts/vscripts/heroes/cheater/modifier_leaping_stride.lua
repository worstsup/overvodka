modifier_leaping_stride = class({})

function modifier_leaping_stride:IsHidden() return true end
function modifier_leaping_stride:IsPurgable() return false end
function modifier_leaping_stride:RemoveOnDeath() return false end

function modifier_leaping_stride:OnCreated()
    if not IsServer() then return end
    self.jumping_active = false
    self:StartIntervalThink(0.03)
    k = 0
end

function modifier_leaping_stride:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_custom_critical_strike") or self:GetParent():HasModifier("modifier_custom_vision_aura_lol") or self:GetParent():IsChanneling() or self:GetParent():HasModifier("modifier_teleporting") or self:GetParent():HasModifier("modifier_invincible_r_debuff") then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local playerID = parent:GetPlayerOwnerID()

    local connection_state = PlayerResource:GetConnectionState(playerID)
    if connection_state == DOTA_CONNECTION_STATE_DISCONNECTED or connection_state == DOTA_CONNECTION_STATE_ABANDONED then
        self.jumping_active = false
        return
    end
    if parent:IsStunned() or parent:IsRooted() or parent:IsCommandRestricted() then
        return
    end
    if not self.jumping_active then
        return
    end
    local velocity = parent:GetForwardVector()
    local move_speed = parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed(), false)
    local jump_interval = 0.65

    if not self.next_jump_time then
        self.next_jump_time = GameRules:GetGameTime()
    end

    if GameRules:GetGameTime() >= self.next_jump_time and parent:IsAlive() then
        self:PerformJump(velocity, move_speed)
        self.next_jump_time = GameRules:GetGameTime() + jump_interval
    end
end
function modifier_leaping_stride:PerformJump(direction, speed)
    local parent = self:GetParent()
    k = k + 1
    local jump_distance = 100 + speed * 0.4
    local jump_height = 150
    local jump_duration = 0.65
    local start_pos = parent:GetAbsOrigin()
    local end_pos = start_pos + direction * jump_distance
    parent:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    parent:AddNewModifier(
        parent,
        self:GetAbility(),
        "modifier_generic_motion",
        {
            duration = jump_duration,
            height = jump_height,
            target_position_x = end_pos.x,
            target_position_y = end_pos.y,
            target_position_z = end_pos.z
        }
    )
    if k % 3 == 0 then
        EmitSoundOn("jump", parent)
    end
    if k % 3 == 1 then
        EmitSoundOn("jump_2", parent)
    end
    if k % 3 == 2 then
        EmitSoundOn("jump_3", parent)
    end
end
function modifier_leaping_stride:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ATTACK,
    }
end
function modifier_leaping_stride:CheckState()
    local state = {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
    }

    return state
end

function modifier_leaping_stride:OnAttack( params )
    if params.attacker~=self:GetParent() then return end
    if self:GetParent():HasModifier("modifier_cheater_rage") then return end
    if self:GetParent():HasModifier("modifier_custom_critical_strike") then return end
    self:GetParent():EmitSound("scout")
end
function modifier_leaping_stride:OnOrder(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    if keys.unit == parent then
        if keys.order_type == DOTA_UNIT_ORDER_STOP or keys.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
            self.jumping_active = false
        elseif keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION or keys.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or keys.order_type == DOTA_UNIT_ORDER_PICKUP_RUNE or keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM or keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
            self.jumping_active = true
        end
    end
end