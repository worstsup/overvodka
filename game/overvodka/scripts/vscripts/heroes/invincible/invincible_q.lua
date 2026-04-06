LinkLuaModifier("modifier_invincible_q_debuff", "heroes/invincible/invincible_q", LUA_MODIFIER_MOTION_HORIZONTAL)

invincible_q = class({})

function invincible_q:Precache(context)
    PrecacheResource("particle", "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_muerta/muerta_spell_fear_debuff.vpcf", context)
    PrecacheResource("particle", "particles/invincible_q.vpcf", context)
	PrecacheResource("particle", "particles/invincible_q_arcana.vpcf", context)
    PrecacheResource("soundfile", "soundevents/invincible_q.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context)
end

function invincible_q:GetAbilityTextureName()
    if self:GetCaster():HasArcana() then
        return "invincible_q_arcana"
    end
    return "invincible_q"
end

function invincible_q:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function invincible_q:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function invincible_q:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function invincible_q:OnAbilityPhaseInterrupted()
	StopSoundOn( "invincible_q_start", self:GetCaster() )
end

function invincible_q:OnAbilityPhaseStart()
	EmitSoundOn( "invincible_q_start", self:GetCaster() )
	return true
end

function invincible_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end
    local target = self:GetCursorTarget()
    if not target or target:IsNull() then return end

    local particle = "particles/invincible_q.vpcf"
    local sound = "invincible_q"
    if caster:HasArcana() then
        particle = "particles/invincible_q_arcana.vpcf"
        sound = "invincible_q_arcana"
    end

    local info =
    {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = particle,
        iMoveSpeed = 1400,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iVisionRadius = 150,
        ExtraData = {
            caster_entindex = caster:entindex(),
        }
    }

    ProjectileManager:CreateTrackingProjectile(info)

    if caster:HasScepter() then
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self:GetCastRange(caster:GetAbsOrigin(), target),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        local thrown = 0
        for _, enemy in pairs(enemies) do
            if enemy ~= target then
                info.Target = enemy
                ProjectileManager:CreateTrackingProjectile(info)
                thrown = thrown + 1
            end
            if thrown >= 2 then break end
        end
    end

    EmitSoundOn(sound, caster)
end

function invincible_q:OnProjectileHit_ExtraData(hTarget, vLocation, extra)
	local target = hTarget
    if not target or target:IsNull() then return end
    local caster = nil
    if extra and extra.caster_entindex then
        caster = EntIndexToHScript(tonumber(extra.caster_entindex))
    end
    if not caster or caster:IsNull() then
        return
    end
	if target:TriggerSpellAbsorb( self ) then return end
	target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
	local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
	local fear_duration = self:GetSpecialValueFor("fear_duration")
	if not target:IsAttackImmune() then
		local damage_base = self:GetSpecialValueFor("damage_base")
		local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) / 100 * self:GetSpecialValueFor("damage")
		local end_damage = damage + damage_base
		self:GetCaster():PerformAttack( target, true, true, true, false, false, true, true )
		ApplyDamage({ victim = target, attacker = self:GetCaster(), damage = end_damage, ability=nil, damage_type = DAMAGE_TYPE_PHYSICAL })
	end
	if target and not target:IsNull() then
		if target:IsAlive() then
			target:AddNewModifier( self:GetCaster(), self, "modifier_invincible_q_debuff", {duration = fear_duration * (1-target:GetStatusResistance()), dir_x = direction.x, dir_y = direction.y})
		end
	end
end

modifier_invincible_q_debuff = class({})

function modifier_invincible_q_debuff:IsHidden() return false end
function modifier_invincible_q_debuff:IsDebuff() return true end
function modifier_invincible_q_debuff:IsPurgable() return true end
function modifier_invincible_q_debuff:RemoveOnDeath() return true end

function modifier_invincible_q_debuff:OnCreated(kv)
    if not IsServer() then return end
    self.dir = Vector(kv.dir_x or 0, kv.dir_y or 0, 0):Normalized()
	self.target = self:GetParent()
	if not self.target:IsDebuffImmune() and not self.target:IsMagicImmune() and not self.target:IsInvulnerable() then
    	self.target:MoveToPosition( self.target:GetAbsOrigin() + self.dir * 200 )
	end
	self:StartIntervalThink(0.1)
end

function modifier_invincible_q_debuff:OnIntervalThink()
	if not IsServer() then return end
	if not self.target or self.target:IsNull() then return end
    if not self:GetCaster() or self:GetCaster():IsNull() then return end
    if not self.target:IsAlive() then return end
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), 150, 0.15, false)
	if not self.target:IsDebuffImmune() and not self.target:IsMagicImmune() and not self.target:IsInvulnerable() then
    	self.target:MoveToPosition( self.target:GetAbsOrigin() + self.dir * 200 )
	end
end

function modifier_invincible_q_debuff:OnDestroy()
    if not IsServer() then return end
	if self.target and not self.target:IsNull() and self.target:IsAlive() and self.target:IsMoving() and not self.target:IsChanneling() then
        self.target:Stop()
    end
end

function modifier_invincible_q_debuff:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FEARED] = true,
    }
end

function modifier_invincible_q_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf" end
function modifier_invincible_q_debuff:GetEffectName() return "particles/units/heroes/hero_muerta/muerta_spell_fear_debuff.vpcf" end
function modifier_invincible_q_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end