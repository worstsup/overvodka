Megumin_ExplosionMagic = class({})
LinkLuaModifier( "modifier_ExplosionMagic", "modifier_ExplosionMagic.lua", LUA_MODIFIER_MOTION_NONE )
-- LinkLuaModifier( "modifier_ExplosionMagic_immunity", "modifier_ExplosionMagic_immunity.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ExplosionMagic_debuff", "modifier_ExplosionMagic_debuff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ExplosionMagic_nonchanneled", "explosionmagic.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:GetChannelAnimation()
    if self:GetCaster():HasScepter() then
        return ACT_DOTA_IDLE
    end
    return ACT_DOTA_CHANNEL_ABILITY_4
end

function Megumin_ExplosionMagic:GetChannelTime()
    if self:GetCaster():HasScepter() then
        return 0
    end
    return self:GetSpecialValueFor("channel_duration")
end

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnAbilityPhaseStart()
    if IsServer() then
        self.channel_duration = self:GetSpecialValueFor("channel_duration")
        self.immune_duration = self:GetCaster():HasScepter() and self.channel_duration or (self.channel_duration + self:GetCastPoint())
        
        --self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ExplosionMagic_immunity", { duration = self.immune_duration })

        self.nPreviewFX = ParticleManager:CreateParticle("particles/booom/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true)
        ParticleManager:SetParticleControl(self.nPreviewFX, 1, Vector(250, 250, 250))
        ParticleManager:SetParticleControl(self.nPreviewFX, 15, Vector(176, 224, 230))
    end
    return true
end

--------------------------------------------------------------------------------

function Megumin_ExplosionMagic:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle(self.nPreviewFX, false)
        EmitSoundOn("vpis", self:GetCaster())

        if self:GetCaster():HasScepter() then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ExplosionMagic_nonchanneled", {
                duration = self:GetSpecialValueFor("channel_duration")
            })
        else
            self.effect_radius = self:GetSpecialValueFor("effect_radius")
            self.interval = self:GetSpecialValueFor("interval")
            self.lastExplosionTime = GameRules:GetGameTime()
        end
    end
end

function Megumin_ExplosionMagic:OnChannelThink(flInterval)
    if IsServer() and not self:GetCaster():HasScepter() then
        self:HandleExplosionEffects()
    end
end
function Megumin_ExplosionMagic:OnChannelFinish()
	StopSoundOn("vpis", self:GetCaster())
end
-- Updated explosion logic with precise timing
function Megumin_ExplosionMagic:HandleExplosionEffects()
    local currentTime = GameRules:GetGameTime()
    
    -- Check if enough time has passed since last explosion
    if currentTime - self.lastExplosionTime >= self:GetSpecialValueFor("interval") then
        -- Apply knockback and effects to enemies
        local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), 
            self:GetCaster():GetAbsOrigin(), 
            nil, 
            300, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
            FIND_ANY_ORDER, 
            false)
        
        for _, unit in pairs(targets) do
            local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
            local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
            local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 250)
            local knockbackProperties = {
                center_x = bump_point.x,
                center_y = bump_point.y,
                center_z = bump_point.z,
                duration = 0.2,
                knockback_duration = 0.2,
                knockback_distance = 100,
                knockback_height = 0
            }
            
            if not unit:HasModifier("modifier_knockback") and not unit:HasModifier("modifier_black_king_bar_immune") and not unit:IsMagicImmune() then
                unit:AddNewModifier(unit, nil, "modifier_knockback", knockbackProperties)
                unit:AddNewModifier(self:GetCaster(), nil, "modifier_ExplosionMagic_debuff", { duration = 1 })
                ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_CUSTOMORIGIN, nil)
            end
        end

        -- Create explosion thinker
        local vPos = self:GetCaster():GetOrigin() + RandomVector(RandomInt(50, self.effect_radius))
        CreateModifierThinker(self:GetCaster(), self, "modifier_ExplosionMagic", {}, vPos, self:GetCaster():GetTeamNumber(), false)
        
        self.lastExplosionTime = currentTime
    end
end

modifier_ExplosionMagic_nonchanneled = class({})
function modifier_ExplosionMagic_nonchanneled:IsHidden() return false end
function modifier_ExplosionMagic_nonchanneled:IsPurgable() return false end

function modifier_ExplosionMagic_nonchanneled:GetTexture()
    return "vpiska"
end
function modifier_ExplosionMagic_nonchanneled:OnCreated(params)
    if IsServer() then
        self.ability = self:GetAbility()
        self.interval = self.ability:GetSpecialValueFor("interval")
        self.effect_radius = self.ability:GetSpecialValueFor("effect_radius")
        self:StartIntervalThink(self.interval)
        self.lastExplosionTime = GameRules:GetGameTime()
    end
end
function modifier_ExplosionMagic_nonchanneled:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_ExplosionMagic_nonchanneled:GetModifierMoveSpeedBonus_Percentage()
    return -50
end

function modifier_ExplosionMagic_nonchanneled:OnIntervalThink()
    if IsServer() then
		if self:GetCaster():IsStunned() or self:GetCaster():IsSilenced() then
			self:Destroy()
		end
        self.ability:HandleExplosionEffects()
    end
end

function modifier_ExplosionMagic_nonchanneled:OnDestroy()
    if IsServer() then
        -- self:GetParent():RemoveModifierByName("modifier_ExplosionMagic_immunity")
        self:GetParent():StopSound("vpis")
    end
end

function modifier_ExplosionMagic_nonchanneled:IsHidden() return true end
function modifier_ExplosionMagic_nonchanneled:IsPurgable() return false end