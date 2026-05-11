LinkLuaModifier("modifier_kolibri_w_slow", "heroes/kolibri/kolibri_w", LUA_MODIFIER_MOTION_NONE)

kolibri_w = class({})

function kolibri_w:Precache(ctx)
    PrecacheResource("particle", "particles/kolibri_w_land.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/beastmaster/bm_weapon_2021/bm_weapon_2021_immortal_hawk_tail.vpcf", ctx)
    PrecacheResource("particle", "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_concussive_shot_slow_debuff.vpcf", ctx)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", ctx)
end

function kolibri_w:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetSpecialValueFor("cast_range")
	end
end

function kolibri_w:GetAOERadius()
    return self:GetSpecialValueFor( "radius" )
end

function kolibri_w:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end

    local point = self:GetCursorPosition()
    local origin = caster:GetAbsOrigin()

    local duration = self:GetSpecialValueFor("fly_time")
    local direction = (point - origin)
    local max_range = self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
    if direction:Length2D() > max_range then
        direction = direction:Normalized() * max_range
    end

    local distance = direction:Length2D()
    point = origin + direction

    caster:EmitSound("kolibri_w")
    local p = ParticleManager:CreateParticle("particles/econ/items/beastmaster/bm_weapon_2021/bm_weapon_2021_immortal_hawk_tail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local arc = caster:AddNewModifier(
        caster, self, "modifier_generic_arc_lua",
        {
            target_x = point.x, target_y = point.y, duration = duration, distance = distance,
            height = 50, start_offset = 0, end_offset = 0, fix_end = 0, fix_duration = 1, 
            fix_height = 0, isStun = 1, isRestricted = 0, isForward = 1, activity = 2,
        }
    )
    if arc then
        arc:SetEndCallback(function(interrupted)
            if not IsServer() then return end
            if p then
                ParticleManager:DestroyParticle(p, false)
            end
            if interrupted then return end

            local landing_pos = GetGroundPosition(point, caster)
            GridNav:DestroyTreesAroundPoint(landing_pos, 200, false)
            if caster:GetUnitName() ~= "npc_dota_hero_nyx_assassin" then
                FindClearSpaceForUnit(caster, landing_pos, true)
            end

            caster:EmitSound("Hero_Beastmaster.Hawk.Target")
            local stun_duration = self:GetSpecialValueFor("stun_duration")
            local radius = self:GetSpecialValueFor("radius")
            local damage = self:GetSpecialValueFor("damage")
            local slow_duration = self:GetSpecialValueFor("slow_duration")

            local particle = ParticleManager:CreateParticle("particles/kolibri_w_land.vpcf", PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl(particle, 0, Vector(landing_pos.x,landing_pos.y,landing_pos.z))
            local units = FindUnitsInRadius(caster:GetTeamNumber(), landing_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

            local damage_table = {attacker = caster, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL}
            for _,enemy in ipairs(units) do
                enemy:AddNewModifier(caster, self, "modifier_kolibri_w_slow", {duration = slow_duration * (1 - enemy:GetStatusResistance())})
                damage_table.victim = enemy
                ApplyDamage(damage_table)
            end
        end)
    end
end

modifier_kolibri_w_slow = class({})

function modifier_kolibri_w_slow:IsHidden() return false end
function modifier_kolibri_w_slow:IsPurgable() return true end
function modifier_kolibri_w_slow:GetEffectName() return "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_concussive_shot_slow_debuff.vpcf" end

function modifier_kolibri_w_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_kolibri_w_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow_pct")
end

function modifier_kolibri_w_slow:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("slow_as")
end