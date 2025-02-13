macan_shard = class({})
LinkLuaModifier( "modifier_macan_shard", "heroes/macan/macan_shard", LUA_MODIFIER_MOTION_NONE )

function macan_shard:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/sdvg.vsndevts", context )
end

function macan_shard:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "illusion_duration" )
	local outgoing = self:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incoming = self:GetSpecialValueFor( "illusion_incoming_damage" )
	local distance = 300
	local illusions = CreateIllusions(
		caster,
		caster,
		{
			outgoing_damage = outgoing,
			incoming_damage = incoming,
			duration = duration,
		},
		8,
		distance,
		false,
		true
	)
	EmitSoundOn( "sdvg", self:GetCaster() )
	local illusion = illusions[1]
	self:SetContextThink( DoUniqueString( "macan_shard" ),function()
		illusion:AddNewModifier(
			caster,
			self,
			"modifier_macan_shard",
			{ duration = duration }
		)
		local sound_cast = "Hero_Terrorblade.ConjureImage"
		EmitSoundOn( sound_cast, illusion )
	end, FrameTime()*2)
end

local MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9 = 10001

modifier_macan_shard = class({})

function modifier_macan_shard:IsHidden()
	return true
end
function modifier_macan_shard:IsDebuff()
	return false
end
function modifier_macan_shard:IsStunDebuff()
	return false
end
function modifier_macan_shard:IsPurgable()
	return false
end
function modifier_macan_shard:OnCreated( kv )
	if not IsServer() then return end
end
function modifier_macan_shard:OnRefresh( kv )
end
function modifier_macan_shard:OnRemoved()
end
function modifier_macan_shard:OnDestroy()
end

function modifier_macan_shard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_macan_shard:StatusEffectPriority()
	return MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9
end