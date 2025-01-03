cheater_rage = class({})
LinkLuaModifier( "modifier_cheater_rage", "heroes/cheater/modifier_cheater_rage", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function cheater_rage:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
	-- load data
	local duration = self:GetDuration()
		-- add modifier to new targets
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_cheater_rage", -- modifier name
		{
			duration = duration,
		} -- kv
	)
	local sound_cast = "scar_start"
	EmitSoundOn( sound_cast, caster )
end