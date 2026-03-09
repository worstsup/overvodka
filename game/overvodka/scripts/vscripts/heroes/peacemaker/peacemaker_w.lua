LinkLuaModifier("modifier_peacemaker_w_armor", "heroes/peacemaker/peacemaker_w", LUA_MODIFIER_MOTION_NONE)

peacemaker_w = class({})

function peacemaker_w:Precache(ctx)
    PrecacheResource("particle", "particles/peacemaker_w.vpcf", ctx)
    PrecacheResource("particle", "particles/sven_ti10_hgs_ringvpcf_new.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_wraithfireblast_explosion.vpcf", ctx)
    PrecacheResource("particle", "particles/events/crownfall/survivors/abilities/techies/remote_mines/techies_land_mine_ball_explosion.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/peacemaker_sounds.vsndevts", ctx)
end

function peacemaker_w:GetAbilityDamageType()
    if self:GetCaster():HasAbility("peacemaker_deagle") then
        return DAMAGE_TYPE_PHYSICAL
	end
    return DAMAGE_TYPE_MAGICAL
end

function peacemaker_w:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("peacemaker_w_cast")
    return true
end

function peacemaker_w:OnAbilityPhaseInterrupted()
    self:GetCaster():StopSound("peacemaker_w_cast")
end

function peacemaker_w:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local origin      = caster:GetAbsOrigin()
    local radius      = self:GetSpecialValueFor("radius")
    local damage      = self:GetSpecialValueFor("damage")
    local armor_per   = self:GetSpecialValueFor("armor_per_hero")
    local buff_dur    = self:GetSpecialValueFor("buff_duration")
    local knock_dist  = self:GetSpecialValueFor("push_distance")
    local knock_dur   = self:GetSpecialValueFor("push_duration")

    --caster:EmitSound("peacemaker_w")

    local p = ParticleManager:CreateParticle("particles/sven_ti10_hgs_ringvpcf_new.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(p, 0, origin)
    ParticleManager:ReleaseParticleIndex(p)

    local p2 = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_wraithfireblast_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p2, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(p2, 3, caster, PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(p2)

    local p3 = ParticleManager:CreateParticle("particles/peacemaker_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(p3, 0, origin)
    ParticleManager:ReleaseParticleIndex(p3)

    local p4 = ParticleManager:CreateParticle("particles/events/crownfall/survivors/abilities/techies/remote_mines/techies_land_mine_ball_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(p4, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(p4)
    
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    local heroes_hit = 0

    local damageTable = {
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self,
    }

    local knockback = {
        center_x = origin.x, center_y = origin.y, center_z = origin.z,
        duration = knock_dur, knockback_duration = knock_dur,
        knockback_distance = knock_dist, knockback_height = 50,
    }

    for _,enemy in ipairs(enemies) do
        if enemy and not enemy:IsNull() and enemy:IsAlive() then

            if not enemy:IsDebuffImmune() and knock_dist > 0 and knock_dur > 0 then
                enemy:RemoveModifierByName("modifier_knockback")
                enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)
            end

            if enemy:IsRealHero() and not enemy:IsIllusion() then
                heroes_hit = heroes_hit + 1
            end

            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end
    end

    if heroes_hit > 0 and armor_per > 0 then
        local total_armor = heroes_hit * armor_per

        local buff = caster:FindModifierByName("modifier_peacemaker_w_armor")
        if not buff then
            buff = caster:AddNewModifier(caster, self, "modifier_peacemaker_w_armor", { duration = buff_dur })
        end

        if buff then
            buff:SetDuration(buff_dur, true)
            buff:AddStacks(total_armor)
        end
    end
end


modifier_peacemaker_w_armor = class({})

function modifier_peacemaker_w_armor:IsHidden()   return false end
function modifier_peacemaker_w_armor:IsPurgable() return true end
function modifier_peacemaker_w_armor:IsDebuff()   return false end
function modifier_peacemaker_w_armor:IsBuff()     return true end

function modifier_peacemaker_w_armor:OnCreated(kv)
    self.armor_bonus = 0

    if IsServer() then
        self:SetStackCount(0)
    end
end

function modifier_peacemaker_w_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_peacemaker_w_armor:GetModifierPhysicalArmorBonus()
    return self:GetStackCount()
end

function modifier_peacemaker_w_armor:AddStacks(armor_add)
    armor_add = armor_add or 0
    if armor_add == 0 then return end

    local new = (self:GetStackCount() or 0) + armor_add
    self:SetStackCount(new)
end
