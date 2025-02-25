modifier_serega_blink = class({})

function modifier_serega_blink:IsPurgable()
	return false
end
function modifier_serega_blink:IsHidden()
	return true
end

function modifier_serega_blink:OnCreated( kv )
	if not IsServer() then return end
	self.k = 0
	self:StartIntervalThink( 1.1 )
	self:OnIntervalThink()
end

function modifier_serega_blink:OnIntervalThink()
	self.duration = self:GetAbility():GetSpecialValueFor( "illusion_duration" )
	self.outgoing = self:GetAbility():GetSpecialValueFor( "illusion_outgoing_damage" )
	self.incoming = self:GetAbility():GetSpecialValueFor( "illusion_incoming_damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.mana_burn = self:GetAbility():GetSpecialValueFor( "mana_burn" )
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor("mana_void_damage_per_mana")
	self.distance = 72
	if self.k == 1 then
		local illusions = CreateIllusions(
			self:GetCaster(),
			self:GetCaster(),
			{
				outgoing_damage = self.outgoing,
				incoming_damage = self.incoming,
				duration = self.duration,
			},
			2,
			self.distance,
			false,
			true
		)
	end
	if self.k == 2 then
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			0,
			0,
			false
		)
		for _,enemy in pairs(enemies) do
			self.mana_pct = enemy:GetMaxMana() * self.mana_burn * 0.01
			enemy:Script_ReduceMana( self.mana_pct, self:GetAbility() )
			self:PlayEffects(enemy)
		end
	end
	if self.k == 3 then
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			0,
			FIND_CLOSEST,
			false
		)
		self.t = 0
		for _,enemy in pairs(enemies) do
			if self.t == 1 then return end
			self.mana_damage = (enemy:GetMaxMana() - enemy:GetMana()) * self.mana_damage_pct
			local damageTable = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = self.mana_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
			}
			ApplyDamage(damageTable)
			self:PlayEffectsNew(enemy)
			self.t = self.t + 1
		end
	end
	self.k = self.k + 1
end

function modifier_serega_blink:OnRemoved()
end
function modifier_serega_blink:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_serega_blink:OnRemoved()
end

function modifier_serega_blink:OnDestroy()
end

function modifier_serega_blink:PlayEffects(target)
	local particle_cast = "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_serega_blink:PlayEffectsNew(target)
	local particle_cast = "particles/antimage_manavoid_basher_cast_gold_new.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 500, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end