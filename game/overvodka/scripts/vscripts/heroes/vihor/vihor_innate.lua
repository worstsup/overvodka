LinkLuaModifier("modifier_vihor_innate", "heroes/vihor/vihor_innate", LUA_MODIFIER_MOTION_NONE)

vihor_innate = class({})

function vihor_innate:GetIntrinsicModifierName()
    return "modifier_vihor_innate"
end

modifier_vihor_innate = class({})

function modifier_vihor_innate:IsHidden() return true end
function modifier_vihor_innate:IsPurgable() return false end
function modifier_vihor_innate:RemoveOnDeath() return false end

function modifier_vihor_innate:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_vihor_innate:OnAttackLanded(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() then return end
    if params.attacker ~= parent then return end

    if parent:PassivesDisabled() or parent:IsIllusion() then return end

    local target = params.target
    if not target or target:IsNull() or (not target:IsAlive()) then return end
    if target:GetTeamNumber() == parent:GetTeamNumber() then return end

    if target:IsBuilding() or target:IsOther() then return end

    local innate = self:GetAbility()
    if not innate or innate:IsNull() then return end

    local q = parent:FindAbilityByName("vihor_q")
    if not q or q:IsNull() or q:GetLevel() <= 0 then return end

    local duration_pct = innate:GetSpecialValueFor("duration_pct")
    local damage_pct = innate:GetSpecialValueFor("damage_pct")

    if duration_pct <= 0 and damage_pct <= 0 then return end

    local base_duration = q:GetSpecialValueFor("duration")
    local base_damage = q:GetSpecialValueFor("damage")

    local dur = base_duration * (duration_pct / 100.0)
    local dmg = base_damage * (damage_pct / 100.0)

    local p = ParticleManager:CreateParticle("particles/vihor_innate.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p)

	local enemies = FindUnitsInRadius(parent:GetTeamNumber(), target:GetAbsOrigin(),
		nil, innate:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	for _,enemy in ipairs(enemies) do
		if (enemy and not enemy:IsNull()) and (enemy:IsAlive()) then
			if dur > 0 then
				enemy:AddNewModifier(parent, q, "modifier_vihor_q_slow", {duration = dur * (1 - enemy:GetStatusResistance())})
			end

			if dmg > 0 then
				ApplyDamage({victim = enemy, attacker = parent, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = q})
			end
		end
	end
end
