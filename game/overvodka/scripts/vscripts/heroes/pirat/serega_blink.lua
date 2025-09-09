LinkLuaModifier( "modifier_serega_blink", "heroes/pirat/serega_blink", LUA_MODIFIER_MOTION_NONE )

serega_blink = class({})

function serega_blink:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("blink_range")
	end
end

function serega_blink:Precache(context)
	PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", context )
	PrecacheResource( "particle", "particles/antimage_manavoid_basher_cast_gold_new.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/serega_blink.vsndevts", context )
end

function serega_blink:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()
	local max_range = self:GetSpecialValueFor("blink_range")
	local direction = (point - origin)
	ProjectileManager:ProjectileDodge(caster)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end
	FindClearSpaceForUnit( caster, origin + direction, true )
	self:PlayEffects( origin, direction )
	caster:AddNewModifier( caster, self, "modifier_serega_blink", { duration = 4 } )
end

function serega_blink:PlayEffects( origin, direction )
	local particle_cast_a = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf"
	local particle_cast_b = "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf"
	local sound_cast_b = "serega_blink"
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_b, self:GetCaster() )
end

modifier_serega_blink = class({})

function modifier_serega_blink:IsPurgable() return false end
function modifier_serega_blink:IsHidden() return true end

function modifier_serega_blink:OnCreated()
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
			if self.t >= 1 then return end
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