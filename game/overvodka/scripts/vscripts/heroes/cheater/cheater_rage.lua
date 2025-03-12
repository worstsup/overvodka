cheater_rage = class({})
LinkLuaModifier( "modifier_cheater_rage", "heroes/cheater/modifier_cheater_rage", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function cheater_rage:OnSpellStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
	local duration = self:GetDuration()
	caster:AddNewModifier(
		caster,
		self,
		"modifier_cheater_rage",
		{
			duration = duration,
		}
	)
	local sound_cast = "scar_start"
	EmitSoundOn( sound_cast, caster )
end