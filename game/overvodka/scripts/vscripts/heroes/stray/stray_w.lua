LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_stray_w_damage", "heroes/stray/stray_w", LUA_MODIFIER_MOTION_BOTH )
stray_w = class({})
k = 0
function stray_w:Precache(context)
    PrecacheResource("particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", context)
    PrecacheResource("soundfile", "soundevents/stray_w_1.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_w_2.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/stray_w_3.vsndevts", context)
end

function stray_w:OnSpellStart()
    if not IsServer() then return end
    local target = self:GetCursorTarget()
    local target_origin = target:GetAbsOrigin()
    if target:TriggerSpellAbsorb(self) then return end
    self:PlayEffects( target )
    if k == 0 then
        EmitSoundOn("stray_w_1", self:GetCaster())
        k = 1
    elseif k == 1 then
        EmitSoundOn("stray_w_2", self:GetCaster())
        k = 2
    elseif k == 2 then
        EmitSoundOn("stray_w_3", self:GetCaster())
        k = 0
    end
    local damage = self:GetSpecialValueFor("damage")

    local vector = (target_origin-self:GetCaster():GetOrigin())
    local dist = vector:Length2D() + 30
    vector.z = 0
    vector = vector:Normalized()

    local duration = 0.1

    if dist > 300 then
        duration = 0.3
    end

    local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = vector.x,
            direction_y = vector.y,
            distance = dist,
            duration = duration,
            height = 30,
            IsStun = true,
            IsFlail = false,
        }
    )

    local particle = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    knockback:AddParticle(particle, false, false, -1, false, false)

    local modifier_stray_w_damage = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_stray_w_damage", {duration = duration, target = target:entindex()})

    local callback = function( bInterrupted )
        if bInterrupted then return end
        target:EmitSound("Hero_Riki.Attack")
        self:GetCaster():SetForwardVector(vector)
        self:GetCaster():FaceTowards(target:GetAbsOrigin())
        ApplyDamage({ victim = target, attacker = self:GetCaster(), ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
        FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)
    end
    knockback:SetEndCallback( callback )
end

function stray_w:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
	local sound_cast = "Hero_Lion.FingerOfDeathImpact"
	local caster = self:GetCaster()
	local direction = (caster:GetOrigin()-target:GetOrigin()):Normalized()

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, caster )
	local attach = "attach_attack1"
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		caster,
		PATTACH_POINT_FOLLOW,
		attach,
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:SetParticleControl( effect_cast, 2, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 3, target:GetOrigin() + direction )
	ParticleManager:SetParticleControlForward( effect_cast, 3, -direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, target )
end

modifier_stray_w_damage = class({})
function modifier_stray_w_damage:IsPurgable() return false end
function modifier_stray_w_damage:IsPurgeException() return false end
function modifier_stray_w_damage:IsHidden() return true end
function modifier_stray_w_damage:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target)
    self.targets = {}
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self:StartIntervalThink(FrameTime())
end
function modifier_stray_w_damage:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _, unit in pairs(units) do
        if unit and unit ~= self.target and self.targets[unit:entindex()] == nil then
            self.targets[unit:entindex()] = true
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL })
        end
    end
end