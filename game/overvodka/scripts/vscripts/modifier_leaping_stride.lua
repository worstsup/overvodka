modifier_leaping_stride = class({})

function modifier_leaping_stride:IsHidden() return true end
function modifier_leaping_stride:IsPurgable() return false end
function modifier_leaping_stride:RemoveOnDeath() return false end

function modifier_leaping_stride:OnCreated()
    if not IsServer() then return end
    self.jumping_active = false -- Start with jumping enabled
    self:StartIntervalThink(0.03) -- Frequent checks for movement input
    self:GetParent():SetTurnRate(100)
    k = 0
end

function modifier_leaping_stride:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():HasModifier("modifier_custom_critical_strike") or self:GetParent():HasModifier("modifier_custom_vision_aura_lol") or self:GetParent():HasModifier("modifier_lol_slow") then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local playerID = parent:GetPlayerOwnerID()

    -- Check if the player has left the game
    local connection_state = PlayerResource:GetConnectionState(playerID)
    if connection_state == DOTA_CONNECTION_STATE_DISCONNECTED or connection_state == DOTA_CONNECTION_STATE_ABANDONED then
        self.jumping_active = false -- Stop jumping
        return
    end
    if parent:IsStunned() or parent:IsRooted() then
        return -- Stop further logic if the hero is stunned or rooted
    end
    if not self.jumping_active then
        return -- Stop if jumping is disabled
    end
    -- Get the hero's current movement direction
    local velocity = parent:GetForwardVector()
    local move_speed = parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed(), false)

    -- Calculate jump interval (lower speed = slower jumps)
    local jump_interval = 0.65 -- Adjust the constant as needed

    if not self.next_jump_time then
        self.next_jump_time = GameRules:GetGameTime()
    end

    if GameRules:GetGameTime() >= self.next_jump_time and parent:IsAlive() then
        -- Perform the jump
        self:PerformJump(velocity, move_speed)
        self.next_jump_time = GameRules:GetGameTime() + jump_interval
    end
end

function modifier_leaping_stride:PerformJump(direction, speed)
    local parent = self:GetParent()
    k = k + 1
    -- Jump parameters
    local jump_distance = 100 + speed * 0.4 -- Adjust distance scaling with speed
    local jump_height = 150 -- Adjust height
    local jump_duration = 0.65 -- Adjust duration

    -- Target position for the jump
    local start_pos = parent:GetAbsOrigin()
    local end_pos = start_pos + direction * jump_distance
    parent:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    -- Apply the motion modifier
    parent:AddNewModifier(
        parent, -- Caster
        self:GetAbility(), -- Ability source
        "modifier_generic_motion", -- Motion modifier
        {
            duration = jump_duration,
            height = jump_height,
            target_position_x = end_pos.x, -- Pass x component
            target_position_y = end_pos.y, -- Pass y component
            target_position_z = end_pos.z  -- Pass z component
        }
    )

    -- Play jump sound or particle effect
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
    if self:GetParent():HasModifier("modifier_windranger_focus_fire_lua") then return end
    if self:GetParent():HasModifier("modifier_custom_critical_strike") then return end
    self:GetParent():EmitSound("scout")
end
function modifier_leaping_stride:OnOrder(keys)
    if not IsServer() then return end

    local parent = self:GetParent()

    -- Check if the order was issued to this hero
    if keys.unit == parent then
        if keys.order_type == DOTA_UNIT_ORDER_STOP or keys.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
            -- Pause jumping on "Cancel" or "Hold Position"
            self.jumping_active = false
        elseif keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION or keys.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or keys.order_type == DOTA_UNIT_ORDER_PICKUP_RUNE or keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM or keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
            -- Resume jumping on "Move" commands
            self.jumping_active = true
        end
    end
end