flash_e = class({})
LinkLuaModifier( "modifier_flash_e", "heroes/flash/flash_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_e_debuff", "heroes/flash/flash_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_e_stack", "heroes/flash/flash_e", LUA_MODIFIER_MOTION_NONE )

function flash_e:Precache(context)
    PrecacheResource("particle", "particles/flash_e_gain.vpcf", context)
    PrecacheResource("particle", "particles/flash_e_caster.vpcf", context)
    PrecacheResource("particle", "particles/flash_e_target.vpcf", context)
end

function flash_e:CastFilterResult()
    if self:GetCaster():FindModifierByName("modifier_flash_e"):GetStackCount() == 0 then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function flash_e:GetCustomCastError()
    if self:GetCaster():FindModifierByName("modifier_flash_e"):GetStackCount() == 0 then
        return "#flash_e_no_stacks"
    end
end

function flash_e:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local mod = caster:FindModifierByName("modifier_flash_e")
    if not mod then return end

    local total_stolen = mod:GetStackCount() * self:GetSpecialValueFor("agi_gain")
    if total_stolen <= 0 then return end
    local dmg_mul = self:GetSpecialValueFor("agi_damage")
    local heal = self:GetSpecialValueFor("agi_heal") * total_stolen

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        99999,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        0,
        0,
        false
    )
    for _, enemy in pairs(enemies) do
        if not enemy:IsIllusion() and enemy:HasModifier("modifier_flash_e_debuff") then
            local debuff = enemy:FindModifierByName("modifier_flash_e_debuff")
            local p = ParticleManager:CreateParticle("particles/flash_e_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControlEnt( p, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
            ParticleManager:SetParticleControlEnt( p, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	        ParticleManager:ReleaseParticleIndex(p)
            ApplyDamage({
                victim     = enemy,
                attacker   = caster,
                damage     = dmg_mul * debuff:GetStackCount(),
                damage_type= DAMAGE_TYPE_MAGICAL,
                ability    = self,
            })
            if enemy and not enemy:IsNull() then
                enemy:RemoveModifierByName("modifier_flash_e_debuff")
            end
        end
    end
    caster:HealWithParams(heal, self, false, true, caster, false)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, caster:GetPlayerOwner())
    local p = ParticleManager:CreateParticle("particles/flash_e_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt( p, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex(p)

    mod:SetStackCount(0)
end

function flash_e:GetIntrinsicModifierName()
	return "modifier_flash_e"
end

modifier_flash_e = class({})

function modifier_flash_e:IsHidden() return (self:GetStackCount() == 0) end
function modifier_flash_e:IsDebuff() return false end
function modifier_flash_e:IsPurgable() return false end

function modifier_flash_e:OnCreated( kv )
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.base_interval = self:GetAbility():GetSpecialValueFor("interval")
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self:StartIntervalThink(self.base_interval)
end

function modifier_flash_e:OnRefresh( kv )
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_flash_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

function modifier_flash_e:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
    if not parent:IsAlive() or parent:IsIllusion() or parent:PassivesDisabled() then
        self:StartIntervalThink(self.base_interval)
        return
    end
    local current_speed = parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed(), true)
    if current_speed > 1 and parent:IsMoving() then
        local enemies = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            0,
            0,
            false
        )
        for _,enemy in pairs(enemies) do
            if enemy:IsIllusion() == false then
                local debuff = enemy:AddNewModifier(
                    self:GetParent(),
                    self:GetAbility(),
                    "modifier_flash_e_debuff",
                    {
                        stack_duration = self.duration,
                    }
                )
                self:AddStack( duration )
                self:PlayEffects( enemy )
            end
        end
    end
    local next_interval = self.base_interval
    if current_speed > 1 then
        next_interval = self.base_interval / (current_speed / 300)
        next_interval = math.max(next_interval, 0.1)
    end
    self:StartIntervalThink(next_interval)
end

function modifier_flash_e:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self.agi_gain
end

function modifier_flash_e:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_flash_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_flash_e:RemoveStack()
    if self:GetAbility() then
	    self:DecrementStackCount()
    end
end

function modifier_flash_e:PlayEffects( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/flash_e_gain.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetAbsOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_flash_e_debuff = class({})

function modifier_flash_e_debuff:IsHidden() return false end
function modifier_flash_e_debuff:IsDebuff() return true end
function modifier_flash_e_debuff:IsPurgable() return false end

function modifier_flash_e_debuff:OnCreated( kv )
	self.stat_loss = self:GetAbility():GetSpecialValueFor( "stat_loss" )
	self.duration = kv.stack_duration
	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_flash_e_debuff:OnRefresh( kv )
	self.stat_loss = self:GetAbility():GetSpecialValueFor( "stat_loss" )
	self.duration = kv.stack_duration

	if IsServer() then
		self:AddStack( self.duration )
	end
end

function modifier_flash_e_debuff:OnDestroy( kv )
end

function modifier_flash_e_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

function modifier_flash_e_debuff:GetModifierBonusStats_Agility()
	return self:GetStackCount() * -self.stat_loss
end


function modifier_flash_e_debuff:AddStack( duration )
	local mod = self:GetParent():AddNewModifier(
		self:GetParent(),
		self:GetAbility(),
		"modifier_flash_e_stack",
		{
			duration = self.duration,
		}
	)
	mod.modifier = self
	self:IncrementStackCount()
end

function modifier_flash_e_debuff:RemoveStack()
    if self and not self:IsNull() then
        self:DecrementStackCount()
        if self:GetStackCount() <= 0 then
            self:Destroy()
        end
    end
end

modifier_flash_e_stack = class({})

function modifier_flash_e_stack:IsHidden() return true end
function modifier_flash_e_stack:IsPurgable() return false end
function modifier_flash_e_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flash_e_stack:OnCreated( kv )
end

function modifier_flash_e_stack:OnRemoved()
    if IsServer() then
        if self.modifier and not self.modifier:IsNull() then
            self.modifier:RemoveStack()
        end
    end
end