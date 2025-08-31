LinkLuaModifier( "modifier_bikov_e_orb_effect", "heroes/bikov/bikov_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bikov_e_evo", "heroes/bikov/bikov_e", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bikov_e_fu", "heroes/bikov/bikov_e", LUA_MODIFIER_MOTION_NONE )

bikov_e = class({})

function bikov_e:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/bikov_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/bikov_attack_e.vpcf", ctx)
	PrecacheResource("particle", "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_burst.vpcf", ctx)
	PrecacheResource("particle", "particles/items_fx/chain_lightning.vpcf", ctx)
end

function bikov_e:GetIntrinsicModifierName()
	return "modifier_bikov_e_orb_effect"
end

function bikov_e:GetCastRange(vLocation, hTarget)
    local base  = self:GetCaster():Script_GetAttackRange()
    local bonus = self:GetSpecialValueFor("bonus_range") or 0
    if IsClient() then
        return base + bonus
    end
    if self:GetAutoCastState() then
        return base
    end
    return base + bonus
end

function bikov_e:GetProjectileName()
	return "particles/bikov_attack_e.vpcf"
end

function bikov_e:OnOrbFire( params )
    self.random = RandomInt(1, 2)
    local sound_cast
    if self.random == 1 then
        sound_cast = "bikov_e_evo"
    else
        sound_cast = "bikov_e_fu"
    end
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function bikov_e:OnOrbImpact(params)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = params.target
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

    local duration = self:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())
    local mod = (self.random == 1) and "modifier_bikov_e_evo" or "modifier_bikov_e_fu"
    target:AddNewModifier(caster, self, mod, { duration = duration })

    local p = ParticleManager:CreateParticle(
        "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_burst.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, target
    )
    ParticleManager:SetParticleControlEnt(p, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)

    local ability_damage = self:GetSpecialValueFor("damage")
        + self:GetSpecialValueFor("int_damage") * caster:GetIntellect(false) * 0.01

    ApplyDamage({
        victim      = target,
        attacker    = caster,
        damage      = ability_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability     = self,
    })

    if self:GetSpecialValueFor("bounce_enabled") <= 0 then return end

    local search_radius = self:GetSpecialValueFor("search_radius")
    if search_radius <= 0 then return end

    local attack_part = caster:GetAverageTrueAttackDamage(target)

    local total_first_hit = ability_damage + math.max(0, attack_part)
    local bounce_pct      = self:GetSpecialValueFor("bounce_pct")
    local bounce_damage   = math.max(0, math.floor(total_first_hit * bounce_pct * 0.01))

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        target:GetAbsOrigin(),
        nil,
        search_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    local second = nil
    for _,e in ipairs(enemies) do
        if e ~= target and e:IsAlive() then
            second = e
            break
        end
    end
    if not second then return end

    local proj_speed = caster.GetProjectileSpeed and caster:GetProjectileSpeed() or 900

    ProjectileManager:CreateTrackingProjectile({
        Target = second,
        Source = target,
        Ability = self,
        EffectName = self:GetProjectileName(),
        iMoveSpeed = proj_speed,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        ExtraData = {
            bikov_bounce = 1,
            damage = bounce_damage,
        }
    })
end


function bikov_e:OnProjectileHit_ExtraData(hTarget, vLoc, extra)
    if not IsServer() then return end
    if not extra or tonumber(extra.bikov_bounce or 0) ~= 1 then return end
    if not hTarget or hTarget:IsNull() or not hTarget:IsAlive() then return end

    local caster = self:GetCaster()
    local dmg = tonumber(extra.damage or 0) or 0
    if dmg > 0 then
        ApplyDamage({
            victim      = hTarget,
            attacker    = caster,
            damage      = dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability     = self,
        })
    end

    local p2 = ParticleManager:CreateParticle(
        "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_burst.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, hTarget
    )
    ParticleManager:SetParticleControlEnt(p2, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p2)

    return true
end



modifier_bikov_e_evo = class({})

function modifier_bikov_e_evo:IsPurgable() return true end

function modifier_bikov_e_evo:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_bikov_e_evo:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end


modifier_bikov_e_fu = class({})

function modifier_bikov_e_fu:IsPurgable() return true end

function modifier_bikov_e_fu:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
    }
end

function modifier_bikov_e_fu:GetModifierStatusResistance()
    return self:GetAbility():GetSpecialValueFor("status_resist")
end


modifier_bikov_e_orb_effect = class({})

function modifier_bikov_e_orb_effect:IsHidden()
	return true
end

function modifier_bikov_e_orb_effect:IsDebuff()
	return false
end

function modifier_bikov_e_orb_effect:IsPurgable()
	return false
end

function modifier_bikov_e_orb_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_bikov_e_orb_effect:OnCreated( kv )
	self.ability = self:GetAbility()
	self.cast = false
	self.records = {}
end

function modifier_bikov_e_orb_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}

	return funcs
end

function modifier_bikov_e_orb_effect:GetModifierAttackRangeBonus()
    if not IsServer() then return end
    local ab = self.ability
    if not ab or ab:IsNull() then return 0 end
    if ab:GetAutoCastState() and ab:IsFullyCastable() and not self:GetParent():IsSilenced() then
        return ab:GetSpecialValueFor("bonus_range")
    end
    return 0
end

function modifier_bikov_e_orb_effect:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if params.no_attack_cooldown then return end
	if self:ShouldLaunch( params.target ) then
		self.ability:UseResources( true, true, false, true )
		self.records[params.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire( params ) end
	end

	self.cast = false
end
function modifier_bikov_e_orb_effect:GetModifierProcAttack_Feedback( params )
	if self.records[params.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
	end
end
function modifier_bikov_e_orb_effect:OnAttackFail( params )
	if self.records[params.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail( params ) end
	end
end
function modifier_bikov_e_orb_effect:OnAttackRecordDestroy( params )
	self.records[params.record] = nil
end

function modifier_bikov_e_orb_effect:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.ability then
		if params.ability==self:GetAbility() then
			self.cast = true
			return
		end
		local pass = false
		local behavior = params.ability:GetBehaviorInt()
		if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL ) or 
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT ) or
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL )
		then
			local pass = true
		end

		if self.cast and (not pass) then
			self.cast = false
		end
	else
		if self.cast then
			if self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET )	or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_STOP ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION )
			then
				self.cast = false
			end
		end
	end
end

function modifier_bikov_e_orb_effect:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end

	if self:ShouldLaunch( self:GetCaster():GetAggroTarget() ) then
		return self.ability:GetProjectileName()
	end
end

function modifier_bikov_e_orb_effect:ShouldLaunch( target )
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget~=CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget( target )==UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(
				target,
				self.ability:GetAbilityTargetTeam(),
				self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(),
				self:GetCaster():GetTeamNumber()
			)
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end

	if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
		return true
	end

	return false
end

function modifier_bikov_e_orb_effect:FlagExist(a,b)
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end