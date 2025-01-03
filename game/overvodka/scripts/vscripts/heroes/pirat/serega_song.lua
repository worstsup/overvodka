serega_song = class({})
LinkLuaModifier( "modifier_serega_song", "heroes/pirat/modifier_serega_song", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_debuff", "heroes/pirat/modifier_serega_song_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_serega_song_scepter", "heroes/pirat/modifier_serega_song_scepter", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function serega_song:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- create aura
	local modifier = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_serega_song", -- modifier name
		{ duration = duration } -- kv
	)

	-- check sister ability
	local ability = caster:FindAbilityByName( "serega_song_end" )
	if not ability then
		ability = caster:AddAbility( "serega_song_end" )
		ability:SetStolen( true )
	end

	-- check ability level
	ability:SetLevel( 1 )

	-- give info about modifier
	ability.modifier = modifier

	-- switch ability layout
	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)

	-- set cooldown
	ability:StartCooldown( ability:GetCooldown( 1 ) )
end

--------------------------------------------------------------------------------
-- Cancel ability
--------------------------------------------------------------------------------
serega_song_end = class({})
function serega_song_end:IsStealable()
	return false
end
function serega_song_end:OnSpellStart()
	-- kill modifier
	self.modifier:End()
	self.modifier = nil
end