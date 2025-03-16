LinkLuaModifier("modifier_papich_q_self_thinker", "heroes/papich/papich_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_papich_q", "heroes/papich/papich_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_silenced_lua", "modifier_generic_silenced_lua.lua", LUA_MODIFIER_MOTION_NONE)
papich_q							= class({})
modifier_papich_q_self_thinker	= class({})
modifier_papich_q				= class({})
papich_q_end						= class({})

function papich_q:Precache( context )
	PrecacheResource( "particle", "particles/papich_q.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/question1.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/question2.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/question3.vsndevts", context )
end

function papich_q:GetAssociatedSecondaryAbilities()
	return "papich_q_end"
end

function papich_q:OnUpgrade()
	if not IsServer() then return end
	
	local illuminate_end = self:GetCaster():FindAbilityByName("papich_q_end")
	
	if illuminate_end then
		illuminate_end:SetLevel(self:GetLevel())
	end
end

function papich_q:OnSpellStart()
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

	self.caster		= self:GetCaster()
	self.position	= self:GetCursorPosition()
	
	self.caster:AddNewModifier(self.caster, self, "modifier_papich_q_self_thinker", {duration = self:GetSpecialValueFor("max_channel_time")})
end

function papich_q:OnChannelThink()
end

function papich_q:OnChannelFinish(bInterrupted)
end

function modifier_papich_q_self_thinker:IsPurgable()	return false end

function modifier_papich_q_self_thinker:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function modifier_papich_q_self_thinker:GetStatusEffectName()
	return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

function modifier_papich_q_self_thinker:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.damage_per_second				= self.ability:GetSpecialValueFor("damage_per_second")
	self.max_channel_time				= self.ability:GetSpecialValueFor("max_channel_time")
	self.range							= self.ability:GetSpecialValueFor("range")
	self.speed							= self.ability:GetSpecialValueFor("speed")
	self.vision_radius					= self.ability:GetSpecialValueFor("vision_radius")
	self.vision_duration				= self.ability:GetSpecialValueFor("vision_duration")
	self.channel_vision_radius			= self.ability:GetSpecialValueFor("channel_vision_radius")
	self.channel_vision_interval		= self.ability:GetSpecialValueFor("channel_vision_interval")
	self.channel_vision_duration		= self.ability:GetSpecialValueFor("channel_vision_duration")
	self.channel_vision_step			= self.ability:GetSpecialValueFor("channel_vision_step")
	self.total_damage					= self.ability:GetSpecialValueFor("total_damage")
	self.transient_form_ms_reduction	= self.ability:GetSpecialValueFor("transient_form_ms_reduction")
	self.caster_location	= self.caster:GetAbsOrigin()
	self.position			= self.ability.position
	self.vision_node_distance	= self.channel_vision_radius * 0.5
	
	if not IsServer() then return end
	self.direction	= (self.position - self.caster_location):Normalized()
	self.game_time_start		= GameRules:GetGameTime()
	self.vision_counter 		= 1
	self.vision_time_count		= GameRules:GetGameTime()
	self.weapon_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/kotl_illuminate_cast.vpcf", PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.weapon_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", self.caster:GetAbsOrigin(), true)
	self:AddParticle(self.weapon_particle, false, false, -1, false, false)
	self.caster:SwapAbilities("papich_q", "papich_q_end", false, true)
	local horse_thinker = CreateUnitByName("npc_dummy_unit", self.caster_location, false, self.caster, self.caster, self.caster:GetTeamNumber())
	horse_thinker:AddNewModifier(self.caster, self.ability, "modifier_kill", {duration = self.max_channel_time})
	self.spirit = horse_thinker
	horse_thinker:SetForwardVector(self.direction)
	
	self:StartIntervalThink(FrameTime())
end

function modifier_papich_q_self_thinker:OnIntervalThink()
	if not IsServer() then return end
	if GameRules:GetGameTime() - self.vision_time_count >= self.channel_vision_interval then
		self.vision_time_count = GameRules:GetGameTime()
		self.ability:CreateVisibilityNode(self.caster_location + (self.direction * self.channel_vision_step * self.vision_counter), self.channel_vision_radius, self.channel_vision_duration)
		self.vision_counter = self.vision_counter + 1
	end
	self:SetStackCount(math.min((GameRules:GetGameTime() - self.game_time_start + self.ability:GetCastPoint()) * self.damage_per_second, self.total_damage))
end

function modifier_papich_q_self_thinker:OnDestroy()
	if not IsServer() then return end
	self.direction					= (self.position - self.caster_location):Normalized()
	self.duration 					= self.range / self.speed
	self.game_time_end				= GameRules:GetGameTime()
	local random_chance = RandomInt(1, 3)
	if random_chance == 1 then
		self.caster:EmitSound("question1")
	end
	if random_chance == 2 then
		self.caster:EmitSound("question2")
	end
	if random_chance == 3 then
		self.caster:EmitSound("question3")
	end
	self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
	
	CreateModifierThinker(self.caster, self.ability, "modifier_papich_q", {
		duration		= self.range / self.speed,
		direction_x 	= self.direction.x,
		direction_y 	= self.direction.y,
		channel_time 	= self.game_time_end - self.game_time_start
	}, 
	self.caster_location, self.caster:GetTeamNumber(), false)
	self.caster:SwapAbilities("papich_q_end", "papich_q", false, true)
	if self.spirit then
		self.spirit:RemoveSelf()
	end
end

function modifier_papich_q_self_thinker:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return decFuncs
end

function modifier_papich_q_self_thinker:GetModifierMoveSpeedBonus_Percentage()
	if not self.caster:HasScepter() then
		return self.transient_form_ms_reduction * (-1)
	end
end

function modifier_papich_q_self_thinker:CheckState()
	if IsServer() and not self.ability:IsChanneling() then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end

function modifier_papich_q:OnCreated( params )
	if not IsServer() then return end

	self.ability	= self:GetAbility()
	self.parent		= self:GetParent()
	self.caster		= self:GetCaster()
	self.damage_mana = self.ability:GetSpecialValueFor("damage_mana")
	self.damage_per_second			= self.ability:GetSpecialValueFor("damage_per_second")
	self.radius						= self.ability:GetSpecialValueFor("radius")
	self.speed						= self.ability:GetSpecialValueFor("speed")
	self.total_damage				= self.ability:GetSpecialValueFor("total_damage")
	self.silence_duration			= self.ability:GetSpecialValueFor("silence_duration")
	self.duration			= params.duration
	self.direction			= Vector(params.direction_x, params.direction_y, 0)
	self.direction_angle	= math.deg(math.atan2(self.direction.x, self.direction.y))
	self.channel_time		= params.channel_time
	self.particle = ParticleManager:CreateParticle("particles/papich_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 1, self.direction * self.speed)
	ParticleManager:SetParticleControl(self.particle, 3, self.parent:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)
	self.hit_targets = {}
	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end

function modifier_papich_q:OnIntervalThink()
	if not IsServer() then return end

	local targets 	= FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local damage	= math.min((self.channel_time + self.ability:GetCastPoint()) * self.damage_per_second, self.total_damage)
	
	local valid_targets	=	{}
	for _, target in pairs(targets) do
		local target_pos 	= target:GetAbsOrigin()
		local target_angle	= math.deg(math.atan2((target_pos.x - self.parent:GetAbsOrigin().x), target_pos.y - self.parent:GetAbsOrigin().y))
		
		local difference = math.abs(self.direction_angle - target_angle)
		if difference <= 90 or difference >= 270 then
			table.insert(valid_targets, target)
		end
	end
	for _, target in pairs(valid_targets) do
	
		local hit_already = false
	
		for _, hit_target in pairs(self.hit_targets) do
			if hit_target == target then
				hit_already = true
				break
			end
		end
		
		if not hit_already then
			if target:GetTeam() ~= self.caster:GetTeam() then
				local damage_type	= DAMAGE_TYPE_MAGICAL
				local dmg = damage + self.damage_mana * self.caster:GetMaxMana() * 0.01
				local damageTable = {
					victim 			= target,
					damage 			= dmg,
					damage_type		= damage_type,
					damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
					attacker 		= self.caster,
					ability 		= self.ability
				}
				
				ApplyDamage(damageTable)
				target:AddNewModifier(
					caster,
					self,
					"modifier_generic_silenced_lua",
					{
						duration = self.silence_duration,
					}
				)
			end
			target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target")
			target:EmitSound("Hero_KeeperOfTheLight.Illuminate.Target.Secondary")
			local particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact_small.vpcf"
			if target:IsHero() then
				particle_name = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf"
			end
			
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
			table.insert(self.hit_targets, target)
		end
	end
	self.parent:SetAbsOrigin(self.parent:GetAbsOrigin() + (self.direction * self.speed * FrameTime()))
end

function modifier_papich_q:OnDestroy()
	if not IsServer() then return end

	self.parent:RemoveSelf()
end


function papich_q_end:GetAssociatedPrimaryAbilities()
	return "papich_q"
end

function papich_q_end:ProcsMagicStick() return false end
function papich_q_end:IsStealable() return false end
function papich_q_end:OnSpellStart()
	if not IsServer() then return end

	self.caster	= self:GetCaster()
	local illuminate	= self.caster:FindAbilityByName("papich_q")
	
	if illuminate then
		local illuminate_self_thinker = self.caster:FindModifierByName("modifier_papich_q_self_thinker")
		if illuminate_self_thinker then
			illuminate_self_thinker:Destroy()
		end
	end
end