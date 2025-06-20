LinkLuaModifier("modifier_chef_e", "heroes/chef/chef_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chef_e_blood", "heroes/chef/chef_e", LUA_MODIFIER_MOTION_NONE)

chef_e = class({})

function chef_e:Precache(context)
    PrecacheResource("soundfile", "soundevents/chef_e.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context)
    PrecacheResource("particle", "particles/chef_e.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf", context)
    PrecacheResource("particle", "particles/bloodseeker_rupture_new.vpcf", context)
    PrecacheResource("model", "models/heroes/dragon_knight_persona/dk_persona_weapon_full.vmdl", context)
end

function chef_e:OnSpellStart()
    local caster = self:GetCaster()
    caster.carapaced_units = {}
    local reflect_duration = self:GetSpecialValueFor("reflect_duration")
    caster:AddNewModifier(caster, self, "modifier_chef_e", { duration = reflect_duration })
    EmitSoundOn("chef_e", caster)
end

modifier_chef_e = class({})

function modifier_chef_e:IsPurgable() return false end
function modifier_chef_e:IsHidden() return false end
function modifier_chef_e:IsDebuff() return false end

function modifier_chef_e:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    self.knife = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/heroes/dragon_knight_persona/dk_persona_weapon_full.vmdl"
    })
    self.knife:FollowEntity(self:GetParent(), true)
    self.knife:SetParent(self:GetParent(), "attach_weapon1")
    self.knife:SetLocalOrigin(Vector(1, -1, 0))
	self.knife:SetLocalAngles(0, 0, 0)
end

function modifier_chef_e:OnDestroy()
    if not IsServer() then return end
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    if self.knife and not self.knife:IsNull() then
        self.knife:RemoveSelf()
        self.knife = nil
    end
end

function modifier_chef_e:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MAX_ATTACK_RANGE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
end

function modifier_chef_e:OnAttackLanded(event)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = event.target
    local attacker = event.attacker
    if attacker ~= parent or target:IsBuilding() or target:IsWard() or target:IsDebuffImmune() then return end
    if target:GetTeamNumber() ~= parent:GetTeamNumber() then
        target:AddNewModifier(parent, self:GetAbility(), "modifier_chef_e_blood", { duration = self:GetAbility():GetSpecialValueFor("blood_duration") })
    end
end

function modifier_chef_e:GetModifierMaxAttackRange()
    return self:GetAbility():GetSpecialValueFor("attack_range")
end

function modifier_chef_e:GetAttackSound()
    return "Hero_BountyHunter.Attack"
end

function modifier_chef_e:GetEffectName()
    return "particles/chef_e.vpcf"
end

function modifier_chef_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_chef_e:OnTakeDamage(event)
    if not IsServer() then return end
    local parent = self:GetParent()
    local attacker = event.attacker
    if event.damage_flags and bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then
        return
    end
    if event.unit == parent and attacker:GetTeamNumber() ~= parent:GetTeamNumber() and not attacker:IsBuilding() then
        if not parent.carapaced_units[ attacker:entindex() ] and self.stun_duration > 0 then
            attacker:AddNewModifier(parent, self:GetAbility(), "modifier_generic_stunned_lua", { duration = self.stun_duration })
            parent.carapaced_units[ attacker:entindex() ] = attacker
        end
        ApplyDamage({victim = attacker,attacker = parent,damage = event.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility(),damage_flags  = DOTA_DAMAGE_FLAG_REFLECTION})
        local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 3, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end

modifier_chef_e_blood = class({})
function modifier_chef_e_blood:IsPurgable() return true end
function modifier_chef_e_blood:IsHidden() return false end
function modifier_chef_e_blood:IsDebuff() return true end
function modifier_chef_e_blood:OnCreated()
    if not IsServer() then return end
    self.interval = 0.5
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_chef_e_blood:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local damage = self:GetAbility():GetSpecialValueFor("blood_damage")
    local dmg = damage * parent:GetMaxHealth() / 100 * self.interval
    ApplyDamage({victim = parent,attacker = self:GetCaster(),damage = dmg, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility(),})
end

function modifier_chef_e_blood:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_chef_e_blood:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("blood_damage")
end

function modifier_chef_e_blood:GetEffectName()
    return "particles/bloodseeker_rupture_new.vpcf"
end

function modifier_chef_e_blood:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end