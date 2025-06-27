serega_song = class({})
LinkLuaModifier( "modifier_serega_song", "heroes/pirat/modifier_serega_song", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_debuff", "heroes/pirat/modifier_serega_song_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_scepter", "heroes/pirat/modifier_serega_song_scepter", LUA_MODIFIER_MOTION_NONE )

function serega_song:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	local modifier = caster:AddNewModifier(
		caster,
		self,
		"modifier_serega_song",
		{ duration = duration }
	)
	local ability = caster:FindAbilityByName( "serega_song_end" )
	if not ability then
		ability = caster:AddAbility( "serega_song_end" )
		ability:SetStolen( true )
	end
	ability:SetLevel( 1 )
	ability.modifier = modifier
	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)
	ability:StartCooldown( ability:GetCooldown( 1 ) )
end

serega_song_end = class({})
function serega_song_end:IsStealable() return false end
function serega_song_end:OnSpellStart()
	self.modifier:End()
	self.modifier = nil
end