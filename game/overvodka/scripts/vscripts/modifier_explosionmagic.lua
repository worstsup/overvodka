modifier_ExplosionMagic = class({})

-----------------------------------------------------------------------------

function modifier_ExplosionMagic:OnCreated( kv )
	if IsServer() then
		self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    	local ability_level = 0
    	if self:GetCaster():GetUnitName() == "npc_dota_hero_invoker" then
			ability_level = self:GetCaster():FindAbilityByName("dvoreckov_w"):GetLevel() + self:GetCaster():FindAbilityByName("dvoreckov_q"):GetLevel() + self:GetCaster():FindAbilityByName("dvoreckov_e"):GetLevel() - 1
		else
			ability_level = self:GetCaster():GetLevel() / 3
		end
		self.blast_damage = self:GetAbility():GetLevelSpecialValueFor("blast_damage", ability_level)
		
		self:StartIntervalThink( self.delay )

		local nFXIndex = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.delay, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

-----------------------------------------------------------------------------

function modifier_ExplosionMagic:OnIntervalThink()
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( self.radius, self.radius, self.radius ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn( "Hero_Techies.Suicide", self:GetParent() )
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false then
				local damageInfo =
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.blast_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self:GetAbility(),
				}
				
				ApplyDamage( damageInfo )
				local knockbackProperties =
				{
					center_x = 0,
					center_y = 0,
					center_z = 0,
					duration = 0.2,
					knockback_duration = 0.2,
					knockback_distance = 200,
					knockback_height = 200
				}
				if not enemy:HasModifier("modifier_knockback") and not enemy:HasModifier("modifier_black_king_bar_immune") and not enemy:IsMagicImmune() then
					enemy:AddNewModifier( enemy, nil, "modifier_knockback", knockbackProperties )
				end
			end
		end

		UTIL_Remove( self:GetParent() )
	end
end

-----------------------------------------------------------------------------
