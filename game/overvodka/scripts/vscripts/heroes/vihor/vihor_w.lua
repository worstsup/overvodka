vihor_w = class({})
LinkLuaModifier("modifier_vihor_w", "heroes/vihor/vihor_w", LUA_MODIFIER_MOTION_NONE )

function vihor_w:Precache(context)
	PrecacheResource( "soundfile", "soundevents/vihor_w.vsndevts", context )
end

function vihor_w:OnSpellStart()
	local target  = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	self.duration = self:GetSpecialValueFor("duration")
	self.outgoing = self:GetSpecialValueFor("illusion_outgoing_damage")
	self.incoming = self:GetSpecialValueFor("illusion_incoming_damage")
	self.damage_percent = self:GetSpecialValueFor("damage_percent")
	self.damage = target:GetMaxHealth() * self.damage_percent * 0.01
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS, ability = self})
	EmitSoundOn("vihor_w", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_vihor_w", {duration = self.duration})
	self.illusions = CreateIllusions(
		self:GetCaster(),
		target,
		{
			outgoing_damage = self.outgoing,
			incoming_damage = self.incoming,
			duration = self.duration,
		},
		1,
		0,
		false,
		true
	)
	illusion = self.illusions[1]
	self.facet = self:GetSpecialValueFor("facet")
	illusion:SetAbsOrigin(self:GetCaster():GetAbsOrigin())
	ProjectileManager:ProjectileDodge(self:GetCaster())
	self:GetCaster():SetAbsOrigin(target:GetAbsOrigin())
	if self.facet == 1 then
		self.illusions_facet = CreateIllusions(
			self:GetCaster(),
			self:GetCaster(),
			{
				outgoing_damage = self.outgoing,
				incoming_damage = self.incoming,
				duration = self.duration,
			},
			1,
			0,
			false,
			true
		)
	end
	FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin(), false)
end


modifier_vihor_w = class({})

function modifier_vihor_w:IsPurgable() return false end

function modifier_vihor_w:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end


function modifier_vihor_w:OnDestroy()
	if illusion and illusion:IsAlive() then
		illusion:Kill(self:GetAbility(), self:GetCaster())
	end
	StopSoundOn("vihor_w", self:GetCaster())
end

function modifier_vihor_w:OnRemoved()
end

function modifier_vihor_w:OnIntervalThink()
    if not illusion:IsAlive() then
        self:Destroy()
    end
end
function modifier_vihor_w:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
	return state
end

function modifier_vihor_w:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_vihor_w:GetModifierInvisibilityLevel()
	return 1
end
function modifier_vihor_w:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		self:Destroy()
	end
end
function modifier_vihor_w:OnAttack( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end
