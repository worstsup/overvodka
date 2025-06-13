LinkLuaModifier("modifier_mazellov_e_channel", "heroes/mazellov/mazellov_e.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mazellov_e_slow", "heroes/mazellov/mazellov_e.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_ring_lua", "modifier_generic_ring_lua", LUA_MODIFIER_MOTION_NONE )

mazellov_e = class({})

function mazellov_e:Precache(context)
    PrecacheResource("model", "models/gingerbread_house/domik.vmdl", context)
end

-- Добавляем эту функцию для определения времени каста
function mazellov_e:GetChannelTime()
    return self:GetSpecialValueFor("AbilityChannelTime") -- Убедитесь, что у вас есть это значение в ability specials
end

function mazellov_e:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_mazellov_e_channel", { duration = self:GetChannelTime() })
    
    -- Добавляем звук или частицы при начале каста, если нужно
    caster:EmitSound("mazellov_e_start")
end

function mazellov_e:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    caster:RemoveModifierByName("modifier_mazellov_e_channel")
end 

modifier_mazellov_e_channel = class({})

function modifier_mazellov_e_channel:IsHidden() return true end
function modifier_mazellov_e_channel:IsPurgable() return false end

function modifier_mazellov_e_channel:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

function modifier_mazellov_e_channel:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    self.original_model = parent:GetModelName()
    parent:SetModel("models/gingerbread_house/domik.vmdl")
    parent:SetOriginalModel("models/gingerbread_house/domik.vmdl")
    self.radius = ability:GetSpecialValueFor("wave_radius")
    self.interval = ability:GetSpecialValueFor("wave_interval")
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_mazellov_e_channel:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetParent()
    self:GetAbility():FireRing()
    -- Волна визуала
    local particle = ParticleManager:CreateParticle("particles/mazellov_e.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end

function mazellov_e:FireRing()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local pulse = caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_ring_lua",
		{
			end_radius = self:GetSpecialValueFor("wave_radius"),
			speed = 450,
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY,
			target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}
	)
	pulse:SetCallback( function( enemy )
		self:OnHit( enemy )
	end)
end

function mazellov_e:OnHit( enemy )
    enemy:AddNewModifier(self:GetCaster(), self, "modifier_mazellov_e_slow", { duration = self:GetSpecialValueFor("wave_slow_duration") })
    ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("wave_damage"), damage_type = DAMAGE_TYPE_MAGICAL })
end

function modifier_mazellov_e_channel:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if self.original_model then
        parent:SetModel(self.original_model)
        parent:SetOriginalModel(self.original_model)
    end
    
    -- Удаляем частицы
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

modifier_mazellov_e_slow = class({})

function modifier_mazellov_e_slow:IsDebuff() return true end
function modifier_mazellov_e_slow:IsPurgable() return true end

function modifier_mazellov_e_slow:OnCreated()
    self.slow = self:GetAbility():GetSpecialValueFor("wave_slow_amount")
end

function modifier_mazellov_e_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_mazellov_e_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end