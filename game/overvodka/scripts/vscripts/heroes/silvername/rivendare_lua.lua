rivendare_lua = class({})
LinkLuaModifier( "modifier_rivendare_lua", "heroes/silvername/rivendare_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rivendare_lua_debuff", "heroes/silvername/rivendare_lua", LUA_MODIFIER_MOTION_NONE )

function rivendare_lua:Precache(context)
	PrecacheResource( "particle", "particles/doom_bringer_doom_new.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context )
end

function rivendare_lua:GetIntrinsicModifierName()
	return "modifier_rivendare_lua"
end

modifier_rivendare_lua = class({})

function modifier_rivendare_lua:IsHidden()
	return false
end

function modifier_rivendare_lua:IsDebuff()
	return false
end

function modifier_rivendare_lua:IsPurgable()
	return false
end

function modifier_rivendare_lua:OnCreated( kv )
	if not IsServer() then return end
	self.k = 0
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.health_increments = 1
	self.hero_attack_multiplier = 1
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnRefresh( kv )
	if not IsServer() then return end
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.interval = self:GetAbility():GetSpecialValueFor( "interval" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local nFXIndex = ParticleManager:CreateParticle( "particles/doom_bringer_doom_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, self.radius ) )
	self:AddParticle( nFXIndex, false, false, -1, false, false )
end

function modifier_rivendare_lua:OnDestroy( kv )
end

function modifier_rivendare_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
        MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end
function modifier_rivendare_lua:OnAttackLanded(keys)
    if not IsServer() then return end
    if keys.target == self:GetParent() then
        if keys.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            if self:GetParent():GetHealthPercent() > 50 then
                self:GetParent():SetHealth(self:GetParent():GetHealth() - 10)
            else 
                self:GetParent():Kill(nil, keys.attacker)
            end
            return
        end
        local new_health = self:GetParent():GetHealth() - self.health_increments
        if keys.attacker:IsRealHero() then
            new_health = self:GetParent():GetHealth() - (self.health_increments * self.hero_attack_multiplier)
        end
        new_health = math.floor(new_health)
        if new_health <= 0 then
            self:GetParent():Kill(nil, keys.attacker)
        else
            self:GetParent():SetHealth(new_health)
        end
    end
end

function modifier_rivendare_lua:GetDisableHealing()
    return 1
end

function modifier_rivendare_lua:GetModifierHealthBarPips()
    return self:GetParent():GetMaxHealth()
end

function modifier_rivendare_lua:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_rivendare_lua:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_rivendare_lua:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_rivendare_lua:OnIntervalThink()
	if self:GetParent():IsAlive() and not self:GetParent():IsInvisible() and not self:GetParent():IsOutOfGame() then
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),
			self:GetParent():GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			0,
			0,
			false
		)
		for _,enemy in pairs(enemies) do
			local debuff = enemy:AddNewModifier(
				self:GetParent(),
				self:GetAbility(),
				"modifier_rivendare_lua_debuff",
				{
					duration = self.duration,
				}
			)
			local Talented = self:GetParent():GetOwner():FindAbilityByName("special_bonus_unique_phoenix_dive_damage")
			if Talented:GetLevel() == 1 then
				if self.k % 10 == 0 then
					self.damage = enemy:GetMaxHealth() * 8 * 0.01
					ApplyDamage({ attacker = self:GetParent(), victim = enemy, damage = self.damage, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility() })
				end
				self.k = self.k + 1
			end
		end
	end
end

modifier_rivendare_lua_debuff = class({})

function modifier_rivendare_lua_debuff:IsHidden()
	return false
end

function modifier_rivendare_lua_debuff:IsDebuff()
	return true
end

function modifier_rivendare_lua_debuff:IsStunDebuff()
	return false
end

function modifier_rivendare_lua_debuff:IsPurgable()
	return false
end

function modifier_rivendare_lua_debuff:OnCreated( kv )
	if self:GetCaster():IsAlive() == 0 then return end
	if IsServer() then
		self:GetParent():SetForceAttackTarget( self:GetCaster())
		self:GetParent():MoveToTargetToAttack( self:GetCaster())
	end
end


function modifier_rivendare_lua_debuff:OnRefresh( kv )
end

function modifier_rivendare_lua_debuff:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_rivendare_lua_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_rivendare_lua_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

function modifier_rivendare_lua_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end