serega_opa = class({})
LinkLuaModifier( "modifier_serega_opa", "heroes/pirat/serega_opa", LUA_MODIFIER_MOTION_NONE )

function serega_opa:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_serega_opa", { duration = self:GetSpecialValueFor("duration") } )
	EmitSoundOn( "serega_opa", caster )
end

modifier_serega_opa = class({})

function modifier_serega_opa:IsHidden() return false end
function modifier_serega_opa:IsPurgable() return false end

function modifier_serega_opa:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("silence_duration")
	self.mana_cost_damage_pct = self:GetAbility():GetSpecialValueFor("mana_cost_damage_pct")
end

function modifier_serega_opa:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_serega_opa:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_absorb")
end

function modifier_serega_opa:GetAbsorbSpell( params )
	if IsServer() then
		if (not self:GetParent():IsIllusion()) and params.ability:GetCaster() ~= self:GetParent() and params.ability:GetAbilityName() ~= "rubick_spell_steal" then
			local enemy = params.ability:GetCaster()
			local abilityLevel = math.max(params.ability:GetLevel() - 1, 0)
			local manaCost = params.ability:GetManaCost(abilityLevel)
			local damage = manaCost * self.mana_cost_damage_pct / 100

			enemy:AddNewModifier( self:GetParent(), self, "modifier_generic_silenced_lua", { duration = self.duration } )
			if damage > 0 then
				ApplyDamage({
					victim = enemy,
					attacker = self:GetParent(),
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self:GetAbility(),
				})
			end
			self:PlayEffects(true)
			return 1
		end
	end
end

function modifier_serega_opa:GetEffectName()
	return "particles/serega_opa.vpcf"
end
function modifier_serega_opa:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_serega_opa:PlayEffects( bBlock )
	local particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	EmitSoundOn("serega_absorb", self:GetParent())
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end