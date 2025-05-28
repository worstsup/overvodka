kolyan_w = class({})
LinkLuaModifier( "modifier_kolyan_w", "heroes/kolyan/kolyan_w", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kolyan_w_stack", "heroes/kolyan/kolyan_w", LUA_MODIFIER_MOTION_NONE )

function kolyan_w:Precache(context)
    PrecacheResource("particle", "particles/kolyan_w.vpcf", context)
    PrecacheResource("particle", "particles/kolyan_w_hit.vpcf", context)
    PrecacheResource("soundfile", "soundevents/kolyan_w.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context)
end

function kolyan_w:OnSpellStart()
    local caster = self:GetCaster()
    local origin = caster:GetOrigin()
    local forward = caster:GetForwardVector()
    local radius = self:GetSpecialValueFor("radius")
    local stack_damage = self:GetSpecialValueFor("quill_stack_damage")
    local base_damage = self:GetSpecialValueFor("quill_base_damage")
    local max_damage = self:GetSpecialValueFor("max_damage")
    local stack_duration = self:GetSpecialValueFor("quill_stack_duration")
    local cone_half_angle = self:GetSpecialValueFor("angle") / 2
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        origin,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    local damageTable = {
        attacker = caster,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self,
    }

    for _, enemy in pairs(enemies) do
        local direction = (enemy:GetOrigin() - origin):Normalized()
        local angle = math.deg(math.acos(math.max(-1, math.min(1, forward:Dot(direction)))))
        if angle <= cone_half_angle then
            local modifier = enemy:FindModifierByNameAndCaster("modifier_kolyan_w", caster)
            local stack = modifier and modifier:GetStackCount() or 0
            damageTable.victim = enemy
            damageTable.damage = math.min(base_damage + stack * stack_damage, max_damage)
            ApplyDamage(damageTable)
            enemy:AddNewModifier(
                caster,
                self,
                "modifier_kolyan_w",
                { stack_duration = stack_duration }
            )
            self:PlayEffects2(enemy)
        end
    end
    self:PlayEffects1()
end

function kolyan_w:GetAT()
	if self.abilityTable==nil then
		self.abilityTable = {}
	end
	return self.abilityTable
end

function kolyan_w:GetATEmptyKey()
	local table = self:GetAT()
	local i = 1
	while table[i]~=nil do
		i = i+1
	end
	return i
end

function kolyan_w:AddATValue( value )
	local table = self:GetAT()
	local i = self:GetATEmptyKey()
	table[i] = value
	return i
end

function kolyan_w:RetATValue( key )
	local table = self:GetAT()
	local ret = table[key]
	table[key] = nil
	return ret
end

function kolyan_w:PlayEffects1()
	local particle_cast = "particles/kolyan_w.vpcf"
    local sound_cast = "kolyan_w_"..RandomInt(1,3)
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function kolyan_w:PlayEffects2( target )
	local sound_cast = "Hero_Bristleback.QuillSpray.Target"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

modifier_kolyan_w = class({})

function modifier_kolyan_w:IsHidden()
	return false
end

function modifier_kolyan_w:IsDebuff()
	return true
end

function modifier_kolyan_w:IsPurgable()
	return false
end

function modifier_kolyan_w:DestroyOnExpire()
	return false
end

function modifier_kolyan_w:OnCreated( kv )
	if IsServer() then
		local at = self:GetAbility():AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_kolyan_w_stack",
			{
				duration = kv.stack_duration,
				modifier = at,
			}
		)
		self:SetStackCount( 1 )
	end
end

function modifier_kolyan_w:OnRefresh( kv )
	if IsServer() then
		local at = self:GetAbility():AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_kolyan_w_stack",
			{
				duration = kv.stack_duration,
				modifier = at,
			}
		)
		self:IncrementStackCount()
	end
end

function modifier_kolyan_w:OnDestroy( kv )
end

function modifier_kolyan_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_kolyan_w:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_kolyan_w:GetModifierPhysicalArmorBonus()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_kolyan_w:RemoveStack( kv )
	self:DecrementStackCount()
	if self:GetStackCount()<1 then
		self:Destroy()
	end
end

function modifier_kolyan_w:GetEffectName()
	return "particles/kolyan_w_hit.vpcf"
end

function modifier_kolyan_w:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_kolyan_w_stack = class({})

function modifier_kolyan_w_stack:IsHidden()
	return true
end

function modifier_kolyan_w_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_kolyan_w_stack:IsPurgable()
	return false
end

function modifier_kolyan_w_stack:OnCreated( kv )
	if IsServer() then
		self.parent = self:GetAbility():RetATValue( kv.modifier )
	end
end

function modifier_kolyan_w_stack:OnRefresh( kv )
end

function modifier_kolyan_w_stack:OnDestroy( kv )
	if IsServer() then
		self.parent:RemoveStack()
	end
end