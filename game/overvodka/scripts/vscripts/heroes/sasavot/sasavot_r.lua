sasavot_r = class({})
LinkLuaModifier( "modifier_sasavot_r", "heroes/sasavot/modifier_sasavot_r", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function sasavot_r:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
 	if self:GetCaster():HasScepter() then
 		behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
 	end
 	return behavior
end

function sasavot_r:GetCooldown( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cooldown_scepter" )
	end

	return self.BaseClass.GetCooldown( self, level )
end

function sasavot_r:OnSpellStart()
	-- get references
	local bonus_duration = self:GetSpecialValueFor("duration")

	-- Purge
	self:GetCaster():Purge(false, true, false, true, false)

	-- Add buff modifier
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_sasavot_r",
		{ duration = bonus_duration }
	)

	-- play effects
	self:PlayEffects()
end

function sasavot_r:PlayEffects()
	-- get resources
	local sound_cast = "sasavot_r"

	-- play sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end