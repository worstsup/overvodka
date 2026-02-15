LinkLuaModifier( "modifier_litvin_bledina", "heroes/litvin/litvin_bledina", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_litvin_bledina_stack", "heroes/litvin/litvin_bledina", LUA_MODIFIER_MOTION_NONE)

litvin_bledina = class({})

function litvin_bledina:Precache(context)
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/bledina.vsndevts", context )
end

function litvin_bledina:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    EmitSoundOn("bledina", caster)

    local dur = self:GetSpecialValueFor("duration")
    local add = self:GetSpecialValueFor("max_attacks")

    if not caster:HasModifier("modifier_litvin_bledina") then
        caster:AddNewModifier(caster, self, "modifier_litvin_bledina", {})
    end

    caster:AddNewModifier(caster, self, "modifier_litvin_bledina_stack", { duration = dur, stacks = add })
end


modifier_litvin_bledina = class({})

function modifier_litvin_bledina:IsPurgable() return false end

function modifier_litvin_bledina:OnCreated()
    self.bat = self:GetAbility():GetSpecialValueFor("bat")
    if not IsServer() then return end

    if (self:GetStackCount() or 0) < 0 then
        self:SetStackCount(0)
    end

    self:PlayEffects1()
    self:RecalcDuration()
end

function modifier_litvin_bledina:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function modifier_litvin_bledina:OnAttack(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if (self:GetStackCount() or 0) <= 0 then
        self:Destroy()
        return
    end

    local parent = self:GetParent()
    local packs = parent:FindAllModifiersByName("modifier_litvin_bledina_stack")
    if not packs or #packs == 0 then
        self:SetStackCount(0)
        self:Destroy()
        return
    end

    local best = nil
    local best_rem = 999999
    for _, m in pairs(packs) do
        if m and (not m:IsNull()) then
            local rem = m:GetRemainingTime()
            if rem < best_rem then
                best_rem = rem
                best = m
            end
        end
    end

    if not best or best:IsNull() then return end

    local s = (best:GetStackCount() or 0) - 1
    if s <= 0 then
        best:SetStackCount(0)
        best:Destroy()
        self:RecalcDuration()
    else
        best:SetStackCount(s)
    end

    self:SetStackCount((self:GetStackCount() or 0) - 1)
    if (self:GetStackCount() or 0) <= 0 then
        self:Destroy()
    end
end

function modifier_litvin_bledina:RecalcDuration()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end

    local packs = parent:FindAllModifiersByName("modifier_litvin_bledina_stack")
    local max_rem = 0.0

    if packs then
        for _, m in pairs(packs) do
            if m and (not m:IsNull()) then
                local rem = m:GetRemainingTime()
                if rem > max_rem then
                    max_rem = rem
                end
            end
        end
    end

    if max_rem <= 0.0 then
        self:SetDuration(0.1, true)
    else
        self:SetDuration(max_rem, true)
    end
end


function modifier_litvin_bledina:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_litvin_bledina:GetModifierAttackSpeedBonus_Constant()
	return 2000
end

function modifier_litvin_bledina:GetModifierProcAttack_Feedback( params )
	self:PlayEffects2( self:GetParent(), params.target )
end

function modifier_litvin_bledina:PlayEffects1()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "eye_l", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "eye_r", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
	ParticleManager:SetParticleControlEnt( effect_cast, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), true )
	self:AddParticle( effect_cast, false, false, -1, false, false )
end

function modifier_litvin_bledina:PlayEffects2( caster, target )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_marci/marci_unleash_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


modifier_litvin_bledina_stack = class({})

function modifier_litvin_bledina_stack:IsHidden() return true end
function modifier_litvin_bledina_stack:IsPurgable() return false end
function modifier_litvin_bledina_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_litvin_bledina_stack:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()
    local add = 0
    if kv and kv.stacks ~= nil then
        add = tonumber(kv.stacks) or 0
    end
    add = math.max(0, math.floor(add))
    self:SetStackCount(add)

    if add <= 0 then
        self:Destroy()
        return
    end

    local main = parent:FindModifierByName("modifier_litvin_bledina")
    if main and (not main:IsNull()) then
        main:SetStackCount((main:GetStackCount() or 0) + add)
		main:RecalcDuration()
    end
end

function modifier_litvin_bledina_stack:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    if not parent or parent:IsNull() or not IsValidEntity(parent) then return end

    local left = math.max(0, self:GetStackCount() or 0)
    if left <= 0 then
        local main = parent:FindModifierByName("modifier_litvin_bledina")
		if main and (not main:IsNull()) then
			main:RecalcDuration()
		end
        if main and (not main:IsNull()) and (main:GetStackCount() or 0) <= 0 then
            main:Destroy()
        end
        return
    end

    local main = parent:FindModifierByName("modifier_litvin_bledina")
    if not main or main:IsNull() then return end

    local new_total = (main:GetStackCount() or 0) - left
    if new_total < 0 then new_total = 0 end
    main:SetStackCount(new_total)

    if new_total <= 0 then
        main:Destroy()
    end
end