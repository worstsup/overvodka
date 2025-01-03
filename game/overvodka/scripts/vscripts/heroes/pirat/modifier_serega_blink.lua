modifier_serega_blink = class({})
--------------------------------------------------------------------------------
function modifier_serega_blink:IsPurgable()
	return false
end
function modifier_serega_blink:IsHidden()
	return true
end
function modifier_serega_blink:OnCreated( kv )
	k = 0
	self:StartIntervalThink( 1.1 )
	self:OnIntervalThink()
end

--------------------------------------------------------------------------------
function modifier_serega_blink:OnIntervalThink()
	-- load data
	self.duration = self:GetAbility():GetSpecialValueFor( "illusion_duration" )
	self.outgoing = self:GetAbility():GetSpecialValueFor( "illusion_outgoing_damage" )
	self.incoming = self:GetAbility():GetSpecialValueFor( "illusion_incoming_damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.mana_burn = self:GetAbility():GetSpecialValueFor( "mana_burn" )
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor("mana_void_damage_per_mana")
	self.distance = 72
	if k == 1 then
		local illusions = CreateIllusions(
			self:GetParent(), -- hOwner
			self:GetParent(), -- hHeroToCopy
			{
				outgoing_damage = self.outgoing,
				incoming_damage = self.incoming,
				duration = self.duration,
			}, -- hModiiferKeys
			2, -- nNumIllusions
			self.distance, -- nPadding
			false, -- bScramblePosition
			true -- bFindClearSpace
		)
	end
	if k == 2 then
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,enemy in pairs(enemies) do
			self.mana_pct = enemy:GetMaxMana() * self.mana_burn * 0.01
			enemy:Script_ReduceMana( self.mana_pct, self:GetAbility() )
			self:PlayEffects(enemy)
		end
	end
	if k == 3 then
		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0,	-- int, flag filter
			FIND_CLOSEST,	-- int, order filter
			false	-- bool, can grow cache
		)
		t = 0
		for _,enemy in pairs(enemies) do
			if t == 1 then return end
			self.mana_damage = (enemy:GetMaxMana() - enemy:GetMana()) * self.mana_damage_pct
			local damageTable = {
				victim = enemy,
				attacker = self:GetParent(),
				damage = self.mana_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self, --Optional.
			}
			ApplyDamage(damageTable)
			self:PlayEffectsNew(enemy)
			t = t + 1
		end
	end
	k = k + 1
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

--------------------------------------------------------------------------------

function modifier_serega_blink:PlayEffects(target)
	local particle_cast = "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_serega_blink:PlayEffectsNew(target)
	local particle_cast = "particles/antimage_manavoid_basher_cast_gold_new.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 500, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end