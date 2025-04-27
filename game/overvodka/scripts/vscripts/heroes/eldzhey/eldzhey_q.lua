eldzhey_q = class({})
LinkLuaModifier( "modifier_eldzhey_q", "heroes/eldzhey/eldzhey_q", LUA_MODIFIER_MOTION_NONE )

function eldzhey_q:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", context )
	PrecacheResource( "particle", "particles/eldzhey_q_illusions.vpcf", context)
	PrecacheResource( "soundfile", "soundevents/tima.vsndevts", context )
end

function eldzhey_q:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "illusion_duration" )
	if GetMapName() == "overvodka_5x5" then
		duration = duration + self:GetSpecialValueFor( "dota_bonus_duration" )
	end
	local outgoing = self:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = self:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 72
	local num = self:GetSpecialValueFor( "num" )
	local illusions = CreateIllusions(
		caster,
		caster,
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		},
		num,
		distance,
		false,
		true
	)
	local illusion = illusions[1]
	self:SetContextThink( DoUniqueString( "eldzhey_q" ),function()
		illusion:AddNewModifier(
			caster,
			self,
			"modifier_eldzhey_q",
			{ duration = duration }
		)

		local sound_cast = "tima"
		EmitSoundOn( sound_cast, illusion )

	end, FrameTime()*2)
	if num == 2 then
		local illusion_1 = illusions[2]
		self:SetContextThink( DoUniqueString( "eldzhey_q" ),function()
			illusion_1:AddNewModifier(
				caster,
				self,
				"modifier_eldzhey_q",
				{ duration = duration }
			)

			local sound_cast = "tima"
			EmitSoundOn( sound_cast, illusion )

		end, FrameTime()*2)
	end
end

local MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9 = 10001

modifier_eldzhey_q = class({})

function modifier_eldzhey_q:IsHidden()
	return true
end

function modifier_eldzhey_q:IsDebuff()
	return false
end

function modifier_eldzhey_q:IsStunDebuff()
	return false
end

function modifier_eldzhey_q:IsPurgable()
	return false
end

function modifier_eldzhey_q:OnCreated( kv )
	if not IsServer() then return end
end

function modifier_eldzhey_q:OnRefresh( kv )
end

function modifier_eldzhey_q:OnRemoved()
end

function modifier_eldzhey_q:OnDestroy()
end

function modifier_eldzhey_q:GetEffectName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf"
end

function modifier_eldzhey_q:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_eldzhey_q:GetStatusEffectName()
	return "particles/eldzhey_q_illusions.vpcf"
end

function modifier_eldzhey_q:StatusEffectPriority()
	return MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9
end
