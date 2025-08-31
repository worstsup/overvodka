LinkLuaModifier( "modifier_bikov_w",          "heroes/bikov/bikov_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bikov_w_fatigue",  "heroes/bikov/bikov_w", LUA_MODIFIER_MOTION_NONE )

bikov_w = class({})

function bikov_w:Precache(ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_obsidian_destroyer.vsndevts", ctx)
    PrecacheResource("soundfile", "soundevents/bikov_sounds.vsndevts", ctx)
    PrecacheResource("particle", "particles/bikov_w.vpcf", ctx)
	PrecacheResource("particle", "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf", ctx)
    PrecacheResource("particle", "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_ring.vpcf", ctx)
end

function bikov_w:CastFilterResultTarget(t)
	if not t then return UF_FAIL_CUSTOM end
	local c = self:GetCaster()
	local allies = (t:GetTeamNumber()==c:GetTeamNumber())
	if allies and self:GetSpecialValueFor("both_teams")<=0 then
		self._err = "#dota_hud_error_cant_cast_on_ally"
		return UF_FAIL_CUSTOM
	end
	if (not allies) and t:IsMagicImmune() then
		return UF_FAIL_MAGIC_IMMUNE_ENEMY
	end
	return UF_SUCCESS
end

function bikov_w:GetCustomCastErrorTarget() return self._err end

function bikov_w:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()
	if t:TriggerSpellAbsorb(self) then return end

	local allies    = (t:GetTeamNumber()==c:GetTeamNumber())
	local canAllies = self:GetSpecialValueFor("both_teams")>0
	local is_ally   = (allies and canAllies) and 1 or 0

	local dur = self:GetSpecialValueFor("prison_duration") * (1 - t:GetStatusResistance())
	t:AddNewModifier(c, self, "modifier_bikov_w", { duration = dur, is_ally = is_ally })

	if is_ally==1 then
		self:EndCooldown()
		local base = self:GetCooldown(self:GetLevel()-1)
		self:StartCooldown(base * 0.5 * c:GetCooldownReduction())
	end
    EmitSoundOn("bikov_w_"..RandomInt(1, 3), t)
	EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.Cast", c)
end


modifier_bikov_w = class({})

function modifier_bikov_w:IsHidden() return false end
function modifier_bikov_w:IsDebuff() return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() end
function modifier_bikov_w:IsStunDebuff() return true end
function modifier_bikov_w:IsPurgable() return false end
function modifier_bikov_w:IsPurgeException() return false end
function modifier_bikov_w:RemoveOnDeath() return false end

function modifier_bikov_w:OnCreated(kv)
    self.is_ally = (tonumber(kv.is_ally or 0)==1)
	self.aoe_radius = self:GetAbility():GetSpecialValueFor("radius")
	local dmg = self:GetAbility():GetSpecialValueFor("damage")
	self.damageTable = {
		attacker = self:GetCaster(),
		damage = dmg,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}
    self._added = false
	if not IsServer() then return end

    if (self.is_ally) or not (self:GetParent():IsDebuffImmune()) then
        ProjectileManager:ProjectileDodge(self:GetParent())
	    self:GetParent():AddNoDraw()
        local p1 = ParticleManager:CreateParticle("particles/bikov_w.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p1, 0, self:GetParent():GetOrigin())
        self:AddParticle(p1, false, false, -1, false, false)
        local p2 = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_ring.vpcf", PATTACH_WORLDORIGIN, nil, self:GetCaster():GetTeamNumber())
        ParticleManager:SetParticleControl(p2, 0, self:GetParent():GetOrigin())
        self:AddParticle(p2, false, false, -1, false, false)
        self._added = true
    else
        self:StartIntervalThink(0.05)
    end
end

function modifier_bikov_w:OnIntervalThink()
    if not IsServer() then return end
    if not self._added and ((self.is_ally) or not (self:GetParent():IsDebuffImmune())) then
        ProjectileManager:ProjectileDodge(self:GetParent())
	    self:GetParent():AddNoDraw()
        local p1 = ParticleManager:CreateParticle("particles/bikov_w.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(p1, 0, self:GetParent():GetOrigin())
        self:AddParticle(p1, false, false, -1, false, false)
        local p2 = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_ring.vpcf", PATTACH_WORLDORIGIN, nil, self:GetCaster():GetTeamNumber())
        ParticleManager:SetParticleControl(p2, 0, self:GetParent():GetOrigin())
        self:AddParticle(p2, false, false, -1, false, false)
        self._added = true
        self:StartIntervalThink(-1)
    end
end

function modifier_bikov_w:OnDestroy()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()

	parent:RemoveNoDraw()
	EmitSoundOnLocationWithCaster(parent:GetOrigin(), "Hero_ObsidianDestroyer.AstralImprisonment.End", caster)

	local enemies = {}
	local rad = self.aoe_radius or 0

	if rad > 0 then
		enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), parent:GetOrigin(), nil, rad,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
		)
	else
		if not self.is_ally and parent:IsAlive() then
			enemies = { parent }
		end
	end

	if #enemies > 0 then
		local fdur = self:GetAbility():GetSpecialValueFor("fatigue_duration")

		for _,v in ipairs(enemies) do
			if v and not v:IsNull() and v:IsAlive() then
				self.damageTable.victim = v
				ApplyDamage(self.damageTable)

				v:AddNewModifier(caster, self:GetAbility(), "modifier_bikov_w_fatigue", {
					duration = fdur * (1 - v:GetStatusResistance()),
				})
			end
		end
	end
end

function modifier_bikov_w:CheckState()
    return {
        [MODIFIER_STATE_OUT_OF_GAME]                     = true,
        [MODIFIER_STATE_INVULNERABLE]                    = true,
        [MODIFIER_STATE_STUNNED]                         = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]               = true,
        [MODIFIER_STATE_UNTARGETABLE]                    = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP]                  = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES]      = true,
    }
end


modifier_bikov_w_fatigue = class({})

function modifier_bikov_w_fatigue:IsDebuff() return true end
function modifier_bikov_w_fatigue:IsPurgable() return true end

function modifier_bikov_w_fatigue:OnCreated()
    local ability     = self:GetAbility()
    self.ms_slow_pct  = ability and ability:GetSpecialValueFor("fatigue_moveslow_pct") or 0
    self.as_slow      = ability and ability:GetSpecialValueFor("fatigue_attackspeed") or 0
end

function modifier_bikov_w_fatigue:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_bikov_w_fatigue:GetModifierMoveSpeedBonus_Percentage() return -(self.ms_slow_pct or 0) end
function modifier_bikov_w_fatigue:GetModifierAttackSpeedBonus_Constant()  return -(self.as_slow or 0) end

function modifier_bikov_w_fatigue:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function modifier_bikov_w_fatigue:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end