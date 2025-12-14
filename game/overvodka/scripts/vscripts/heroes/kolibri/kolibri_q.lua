LinkLuaModifier("modifier_kolibri_q_movement", "heroes/kolibri/kolibri_q", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kolibri_q_movement_damage", "heroes/kolibri/kolibri_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )

kolibri_q = class({})

function kolibri_q:Precache(context)
    PrecacheResource("soundfile", "soundevents/kolibri_sounds.vsndevts", context)
    PrecacheResource("particle", "particles/econ/events/fall_2021/force_staff_fall_2021.vpcf", context)
end

function kolibri_q:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local range = self:GetSpecialValueFor("range")
    local speed = self:GetSpecialValueFor("speed")
    local direction = caster:GetForwardVector()
    direction.z = 0
    direction = direction:Normalized()
    local distance = range
    local duration = distance / speed
    EmitSoundOn("kolibri_q", caster)
    caster:AddNewModifier(caster, self, "modifier_kolibri_q_movement", {duration = duration})
    caster:AddNewModifier(
        caster, self, "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = distance,
            duration = duration,
        }
    )
    self:StartCooldown(0.15)
end

modifier_kolibri_q_movement = class({})
function modifier_kolibri_q_movement:IsPurgable() return false end
function modifier_kolibri_q_movement:IsHidden() return true end
function modifier_kolibri_q_movement:IsAura() return true end
function modifier_kolibri_q_movement:GetAuraDuration() return 0 end
function modifier_kolibri_q_movement:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_kolibri_q_movement:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end
function modifier_kolibri_q_movement:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_kolibri_q_movement:GetModifierAura() return "modifier_kolibri_q_movement_damage" end
function modifier_kolibri_q_movement:GetAuraRadius() return 100 end

function modifier_kolibri_q_movement:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/econ/events/fall_2021/force_staff_fall_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(p, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_kolibri_q_movement:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():GetUnitName() ~= "npc_dota_hero_nyx_assassin" then
        FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    end
end

modifier_kolibri_q_movement_damage = class({})
function modifier_kolibri_q_movement_damage:IsPurgable() return false end
function modifier_kolibri_q_movement_damage:IsHidden() return true end

function modifier_kolibri_q_movement_damage:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local hit_blood = ParticleManager:CreateParticle("particles/shemelis_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(hit_blood, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_blood)
    ApplyDamage({victim = parent, attacker = caster, damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL, ability = self:GetAbility()})
    --caster:PerformAttack(parent, true, true, true, true, false, false, true)
end