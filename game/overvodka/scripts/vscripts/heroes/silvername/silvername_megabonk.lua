LinkLuaModifier( "modifier_silvername_megabonk", "heroes/silvername/silvername_megabonk", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_silvername_megabonk_use", "heroes/silvername/silvername_megabonk", LUA_MODIFIER_MOTION_NONE )

silvername_megabonk = class({})

function silvername_megabonk:GetIntrinsicModifierName()
	return "modifier_silvername_megabonk"
end

modifier_silvername_megabonk = class({})

function modifier_silvername_megabonk:IsPurgable() return false end
function modifier_silvername_megabonk:IsHidden() return true end

function modifier_silvername_megabonk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_silvername_megabonk:OnCreated()
    self.chance_2 = self:GetAbility():GetSpecialValueFor( "multicast_2_times" )
	self.chance_3 = self:GetAbility():GetSpecialValueFor( "multicast_3_times" )
	self.chance_4 = self:GetAbility():GetSpecialValueFor( "multicast_4_times" )
    self.useless_abilities = 
    {
        ["item_bag_of_gold"] = true,
        ["item_bag_of_gold_2"] = true,
        ["item_bag_of_gold_bablokrad"] = true,
        ["item_treasure_chest"] = true,
        ["item_zhenya_present"] = true,
        ["item_moon_shard"] = true,
        ["prince_q"] = true,
    }
end

function modifier_silvername_megabonk:OnAbilityFullyCast( params )
    if not IsServer() then return end
	if params.unit~=self:GetCaster() then return end
	if params.ability==self:GetAbility() then return end
	if self:GetCaster():PassivesDisabled() then return end
    if not self:GetCaster():HasAbility(params.ability:GetAbilityName()) then return end

	if not params.target then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET ) ~= 0 then return end
	if bit.band( params.ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_CHANNELLED ) ~= 0 then return end

    if self.useless_abilities[params.ability:GetAbilityName()] then
        return
    end

	local target = params.target
	local multicast_multi = 1

	if RollPseudoRandomPercentage(self.chance_4, 7, self:GetParent()) then 
		multicast_multi = 4 
	else 
		if RollPseudoRandomPercentage(self.chance_3, 8, self:GetParent()) then
			multicast_multi = 3 
		else
			if RollPseudoRandomPercentage(self.chance_2, 9, self:GetParent()) then
				multicast_multi = 2 
			end
		end
	end

	local delay = FrameTime()
	local single = false
	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_silvername_megabonk_use", { ability = params.ability:entindex(), target = target:entindex(), multicast = multicast_multi, delay = delay, single = single, } )
end

modifier_silvername_megabonk_use = class({})

function modifier_silvername_megabonk_use:IsHidden() return true end
function modifier_silvername_megabonk_use:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_silvername_megabonk_use:IsPurgable() return false end
function modifier_silvername_megabonk_use:IsPurgeException() return false end
function modifier_silvername_megabonk_use:RemoveOnDeath() return false end

function modifier_silvername_megabonk_use:OnCreated( kv )
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.ability = EntIndexToHScript( kv.ability )
	self.target = EntIndexToHScript( kv.target )
	self.multicast = kv.multicast
	self.delay = kv.delay
	self.single = kv.single==1
	self.buffer_range = 600
	self:SetStackCount( self.multicast )

	self.casts = 0
	if self.multicast==1 then
		self:Destroy()
		return
	end

	self.targets = {}
	self.targets[self.target] = true
	self.radius = self.ability:GetCastRange( self.target:GetOrigin(), self.target ) + self.buffer_range
	self.target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY

	if self.target:GetTeamNumber()~=self.caster:GetTeamNumber() then
		self.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	self.target_type = self.ability:GetAbilityTargetType()
	if self.target_type==DOTA_UNIT_TARGET_CUSTOM then
		self.target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	end

	self.target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	if bit.band( self.ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES ) ~= 0 then
		self.target_flags = self.target_flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	self:PlayEffects( self.multicast )
	self:StartIntervalThink( self.delay )
end

function modifier_silvername_megabonk_use:OnIntervalThink()
	local current_target = nil

	if self.single then
		current_target = self.target
	else
		local units = FindUnitsInRadius( self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.radius, self.target_team, self.target_type, self.target_flags, FIND_CLOSEST, false )
		if #units <= 0 then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
		
		local unit = units[RandomInt(1, #units)]

		local filter = false
		if self.ability.CastFilterResultTarget then
			filter = self.ability:CastFilterResultTarget( unit ) == UF_SUCCESS
		else
			filter = true
		end

		if filter then
			current_target = unit
		end


		if not current_target then
			self:StartIntervalThink( -1 )
			self:Destroy()
			return
		end
	end

	self.caster:SetCursorCastTarget( current_target )
	self.ability:OnSpellStart()

	self.casts = self.casts + 1
	if self.casts>=( self.multicast - 1 ) then
		self:StartIntervalThink( -1 )
		self:Destroy()
	end
end

function modifier_silvername_megabonk_use:PlayEffects( value )
	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_eggbeater_jackpot_multicast_secondstyle.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( value, 1, 3 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	self:GetParent():EmitSound( "Hero_OgreMagi.Fireblast.x"..(value - 1) )
end