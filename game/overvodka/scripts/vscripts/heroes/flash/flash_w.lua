LinkLuaModifier( "modifier_flash_w_orb_effect", "heroes/flash/flash_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

flash_w = class({})

function flash_w:Precache(context)
	PrecacheResource("soundfile", "soundevents/flash_sounds.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_spirit_ti8_overload_active_h.vpcf", context)
	PrecacheResource("particle", "particles/econ/events/ti7/maelstorm_ti7.vpcf", context)
end

function flash_w:GetIntrinsicModifierName()
    return "modifier_flash_w_orb_effect"
end

function flash_w:OnOrbImpact( params )
	if not IsServer() then return end
	if not params.target then return end
	EmitSoundOn("flash_w_"..RandomInt(1,2), params.target)
	local p = ParticleManager:CreateParticle("particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt( p, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
    ParticleManager:SetParticleControlEnt( p, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex(p)
	local p = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_spirit_ti8_overload_active_h.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
	ParticleManager:ReleaseParticleIndex(p)
    ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
	if self:GetCaster():HasScepter() and params.target and not params.target:IsNull() then
        local totalDist = 0
		local mod = self:GetCaster():FindModifierByName("modifier_flash_w_orb_effect")
		if not mod or not mod.posHistory or #mod.posHistory < 2 then return end
        for i = 2, #mod.posHistory do
            totalDist = totalDist + (mod.posHistory[i].pos - mod.posHistory[i-1].pos):Length2D()
        end
        local extraDmg = totalDist * self:GetSpecialValueFor("damage_pct") * 0.01

        local knockback = {
            knockback_duration = 0.4,
            duration       = 0.4,
            knockback_distance = self:GetSpecialValueFor("knockback_distance"),
            knockback_height   = 100,
            center_x       = self:GetCaster():GetAbsOrigin().x,
            center_y       = self:GetCaster():GetAbsOrigin().y,
            center_z       = self:GetCaster():GetAbsOrigin().z
        }
		if params.target:HasModifier("modifier_knockback") then
			params.target:RemoveModifierByName("modifier_knockback")
		end
        params.target:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)
		params.target:AddNewModifier(self:GetCaster(), self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor("stun_duration")})
        ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = extraDmg, damage_type= self:GetAbilityDamageType(),ability = self})
    end
end

modifier_flash_w_orb_effect = class({})

function modifier_flash_w_orb_effect:IsHidden()
	return true
end

function modifier_flash_w_orb_effect:IsDebuff()
	return false
end

function modifier_flash_w_orb_effect:IsPurgable()
	return false
end

function modifier_flash_w_orb_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_flash_w_orb_effect:OnCreated( kv )
	self.ability = self:GetAbility()
	self.cast = false
	self.records = {}
	self.posHistory = {}
    self:StartIntervalThink(0.1)
end

function modifier_flash_w_orb_effect:OnRefresh( kv )
end

function modifier_flash_w_orb_effect:OnDestroy( kv )
end

function modifier_flash_w_orb_effect:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local now = GameRules:GetGameTime()
    table.insert(self.posHistory, { pos = parent:GetAbsOrigin(), t = now })
    while #self.posHistory > 0 and now - self.posHistory[1].t > self:GetAbility():GetSpecialValueFor("time_damage") do
        table.remove(self.posHistory, 1)
    end
end

function modifier_flash_w_orb_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}

	return funcs
end

function modifier_flash_w_orb_effect:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if params.no_attack_cooldown then return end
	if self:ShouldLaunch( params.target ) then
		self.ability:UseResources( true, true, false, true )
		self.records[params.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire( params ) end
	end

	self.cast = false
end

function modifier_flash_w_orb_effect:GetModifierProcAttack_Feedback( params )
	if self.records[params.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
	end
end

function modifier_flash_w_orb_effect:OnAttackFail( params )
	if self.records[params.record] then
        self:GetParent():PerformAttack(params.target, true, true, true, true, false, false, true)
        if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
        self.records[params.record] = nil
	end
end

function modifier_flash_w_orb_effect:OnAttackRecordDestroy( params )
	self.records[params.record] = nil
end

function modifier_flash_w_orb_effect:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.ability then
		if params.ability==self:GetAbility() then
			self.cast = true
			return
		end

		local pass = false
		local behavior = params.ability:GetBehaviorInt()
		if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL ) or 
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT ) or
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL )
		then
			local pass = true
		end

		if self.cast and (not pass) then
			self.cast = false
		end
	else
		if self.cast then
			if self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET )	or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_STOP ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION )
			then
				self.cast = false
			end
		end
	end
end

function modifier_flash_w_orb_effect:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end

	if self:ShouldLaunch( self:GetCaster():GetAggroTarget() ) then
		return self.ability:GetProjectileName()
	end
end

function modifier_flash_w_orb_effect:ShouldLaunch( target )
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget~=CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget( target )==UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(
				target,
				self.ability:GetAbilityTargetTeam(),
				self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(),
				self:GetCaster():GetTeamNumber()
			)
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end

	if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
		return true
	end

	return false
end

function modifier_flash_w_orb_effect:FlagExist(a,b)
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end