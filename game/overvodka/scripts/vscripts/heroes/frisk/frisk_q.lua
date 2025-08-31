LinkLuaModifier( "modifier_frisk_q_tea", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_legendary", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_cowboy", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_pan", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_dog", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_temmie", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_medallion", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_knife", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frisk_q_pie", "heroes/frisk/frisk_q", LUA_MODIFIER_MOTION_NONE )

frisk_q = class({})

function frisk_q:Precache(context)
    PrecacheResource("particle", "particles/econ/events/ti10/fountain_regen_ti10_lvl3.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_armor_buff.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_army_cast_burst.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/treant_protector/ti7_shoulder/treant_ti7_crimson_livingarmor.vpcf", context)
    PrecacheResource("particle", "particles/frisk_medallion.vpcf", context)
    PrecacheResource("soundfile", "soundevents/frisk_sounds.vsndevts", context)
    PrecacheResource("model", "models/items/ursa/hat_alpine.vmdl", context)
    PrecacheResource("model", "models/heroes/ringmaster/ringmaster_weighted_pie.vmdl", context)
end

function frisk_q:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function frisk_q:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if not caster or caster:IsNull() or not target or target:IsNull() then return end

    local duration = self:GetSpecialValueFor("duration")

    local temmie_chance    = self:GetSpecialValueFor("temmie_chance")
    local medallion_chance = self:GetSpecialValueFor("medallion_chance")
    local knife_chance     = self:GetSpecialValueFor("knife_chance")
    local pie_chance       = self:GetSpecialValueFor("pie_chance")
    local total_special    = temmie_chance + medallion_chance + knife_chance + pie_chance

    local NORMAL_KEYS = { "norm_tea", "norm_legendary", "norm_noodles", "norm_cowboy", "norm_pan", "norm_dog" }

    EmitSoundOn("frisk_q", target)

    local function RollSingle(exclude_key)
        local roll = RandomInt(1, 100)
        if roll <= total_special then
            local specials = {}
            if temmie_chance > 0 and exclude_key ~= "sp_temmie"    then specials["sp_temmie"]    = temmie_chance    end
            if medallion_chance > 0 and exclude_key ~= "sp_medallion" then specials["sp_medallion"] = medallion_chance end
            if knife_chance > 0 and exclude_key ~= "sp_knife"    then specials["sp_knife"]    = knife_chance    end
            if pie_chance > 0 and exclude_key ~= "sp_pie"        then specials["sp_pie"]      = pie_chance      end

            local total_after_exclude = 0
            for _, w in pairs(specials) do total_after_exclude = total_after_exclude + w end

            if total_after_exclude > 0 then
                local pick = RandomInt(1, total_after_exclude)
                local acc = 0
                for k, w in pairs(specials) do
                    acc = acc + w
                    if pick <= acc then
                        return k
                    end
                end
            end
        end

        local normals = {}
        for _, k in ipairs(NORMAL_KEYS) do
            if k ~= exclude_key then
                table.insert(normals, k)
            end
        end
        if #normals == 0 then
            local fallback_specials = {}
            if temmie_chance > 0 and exclude_key ~= "sp_temmie"    then table.insert(fallback_specials, "sp_temmie")    end
            if medallion_chance > 0 and exclude_key ~= "sp_medallion" then table.insert(fallback_specials, "sp_medallion") end
            if knife_chance > 0 and exclude_key ~= "sp_knife"    then table.insert(fallback_specials, "sp_knife")    end
            if pie_chance > 0 and exclude_key ~= "sp_pie"        then table.insert(fallback_specials, "sp_pie")      end
            if #fallback_specials > 0 then
                return fallback_specials[ RandomInt(1, #fallback_specials) ]
            end
            return nil
        end

        return normals[ RandomInt(1, #normals) ]
    end

    local function ApplyEffect(key)
        if not key then return end

        if key == "sp_temmie" then
            target:AddNewModifier(caster, self, "modifier_frisk_q_temmie", { duration = duration })
        elseif key == "sp_medallion" then
            target:AddNewModifier(caster, self, "modifier_frisk_q_medallion", { duration = duration })
        elseif key == "sp_knife" then
            target:AddNewModifier(caster, self, "modifier_frisk_q_knife", { duration = duration })
        elseif key == "sp_pie" then
            local heal = self:GetSpecialValueFor("pie_heal_pct") * target:GetMaxHealth() / 100
            target:HealWithParams(heal, self, false, true, caster, false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, caster and caster:GetPlayerOwner())
            target:AddNewModifier(caster, self, "modifier_frisk_q_pie", { duration = duration })
        elseif key == "norm_tea" then
            local heal = self:GetSpecialValueFor("tea_regen")
            target:HealWithParams(heal, self, false, true, caster, false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, caster and caster:GetPlayerOwner())
            target:AddNewModifier(caster, self, "modifier_frisk_q_tea", { duration = duration })
        elseif key == "norm_legendary" then
            local heal = self:GetSpecialValueFor("legendary_regen")
            target:HealWithParams(heal, self, false, true, caster, false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, caster and caster:GetPlayerOwner())
            target:AddNewModifier(caster, self, "modifier_frisk_q_legendary", { duration = duration })
        elseif key == "norm_noodles" then
            local heal_min = self:GetSpecialValueFor("noodles_heal_min")
            local heal_max = self:GetSpecialValueFor("noodles_heal_max")
            local heal = RandomInt(heal_min, heal_max)
            target:HealWithParams(heal, self, false, true, caster, false)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, caster and caster:GetPlayerOwner())
            local p = ParticleManager:CreateParticle("particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_army_cast_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(p, 0, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(p)
        elseif key == "norm_cowboy" then
            target:AddNewModifier(caster, self, "modifier_frisk_q_cowboy", { duration = duration })
        elseif key == "norm_pan" then
            target:AddNewModifier(caster, self, "modifier_frisk_q_pan", { duration = duration })
        elseif key == "norm_dog" then
            EmitSoundOn("frisk_q_dog", target)
            target:AddNewModifier(caster, self, "modifier_frisk_q_dog", { duration = duration })
        end
    end

    local give_count = (caster:HasScepter() and 2) or 1

    if give_count == 1 then
        local k = RollSingle(nil)
        ApplyEffect(k)
    else
        local first = RollSingle(nil)
        local second = RollSingle(first)
        if not second then
            local attempts = 0
            repeat
                second = RollSingle(first)
                attempts = attempts + 1
            until second or attempts >= 8
        end
        if not second then
            local normals = {}
            for _, k in ipairs(NORMAL_KEYS) do
                if k ~= first then table.insert(normals, k) end
            end
            if #normals > 0 then second = normals[ RandomInt(1, #normals) ] end
        end
        ApplyEffect(first)
        ApplyEffect(second)
    end
end


modifier_frisk_q_tea = class({})

function modifier_frisk_q_tea:IsHidden() return false end
function modifier_frisk_q_tea:IsPurgable() return true end

function modifier_frisk_q_tea:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_frisk_q_tea:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("tea_ms")
end

function modifier_frisk_q_tea:GetEffectName()
    return "particles/econ/events/ti10/fountain_regen_ti10_lvl3.vpcf"
end

function modifier_frisk_q_tea:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_frisk_q_legendary = class({})

function modifier_frisk_q_legendary:IsHidden() return false end
function modifier_frisk_q_legendary:IsPurgable() return true end

function modifier_frisk_q_legendary:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_frisk_q_legendary:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("legendary_damage")
end

function modifier_frisk_q_legendary:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_armor_buff.vpcf"
end

function modifier_frisk_q_legendary:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_frisk_q_cowboy = class({})

function modifier_frisk_q_cowboy:IsHidden() return false end
function modifier_frisk_q_cowboy:IsPurgable() return true end

function modifier_frisk_q_cowboy:OnCreated()
    if not IsServer() then return end
    self.hat = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/ursa/hat_alpine.vmdl"})
    self.hat:FollowEntityMerge(self:GetParent(), "attach_head")
    if self:GetParent():GetUnitName() == "npc_dota_hero_templar_assassin" then
        self.hat:SetModelScale(0.5)
    end
end

function modifier_frisk_q_cowboy:OnDestroy()
    if not IsServer() then return end
    if self.hat and not self.hat:IsNull() then
        self.hat:RemoveSelf()
        self.hat = nil
    end
end

function modifier_frisk_q_cowboy:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_frisk_q_cowboy:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("cowboy_as")
end

function modifier_frisk_q_cowboy:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("cowboy_armor")
end


modifier_frisk_q_pan = class({})

function modifier_frisk_q_pan:IsHidden() return false end
function modifier_frisk_q_pan:IsPurgable() return true end

function modifier_frisk_q_pan:DeclareFunctions()
    return {MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE}
end

function modifier_frisk_q_pan:GetModifierHealAmplify_PercentageSource()
    return self:GetAbility():GetSpecialValueFor("pan_heal_amp")
end

function modifier_frisk_q_pan:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf"
end

function modifier_frisk_q_pan:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_frisk_q_dog = class({})

function modifier_frisk_q_dog:IsHidden() return false end
function modifier_frisk_q_dog:IsPurgable() return true end


modifier_frisk_q_temmie = class({})

function modifier_frisk_q_temmie:IsHidden() return false end
function modifier_frisk_q_temmie:IsPurgable() return true end

function modifier_frisk_q_temmie:OnCreated()
    if not IsServer() then return end
    local p = ParticleManager:CreateParticle("particles/econ/items/treant_protector/ti7_shoulder/treant_ti7_crimson_livingarmor.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(p, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(p, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(p, false, false, -1, false, false)
end

function modifier_frisk_q_temmie:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_frisk_q_temmie:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("temmie_armor")
end

function modifier_frisk_q_temmie:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("temmie_hp")
end


modifier_frisk_q_medallion = class({})

function modifier_frisk_q_medallion:IsHidden() return false end
function modifier_frisk_q_medallion:IsPurgable() return true end

function modifier_frisk_q_medallion:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_frisk_q_medallion:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("medallion_resist")
end

function modifier_frisk_q_medallion:GetEffectName()
    return "particles/frisk_medallion.vpcf"
end

function modifier_frisk_q_medallion:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


modifier_frisk_q_knife = class({})

function modifier_frisk_q_knife:IsHidden() return false end
function modifier_frisk_q_knife:IsPurgable() return true end

function modifier_frisk_q_knife:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_frisk_q_knife:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("knife_damage")
end

function modifier_frisk_q_knife:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_frisk_q_knife:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_frisk_q_pie = class({})

function modifier_frisk_q_pie:IsHidden() return false end
function modifier_frisk_q_pie:IsPurgable() return true end

function modifier_frisk_q_pie:OnCreated()
    if not IsServer() then return end
    self.pie = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/ringmaster/ringmaster_weighted_pie.vmdl"})
    self.pie:FollowEntityMerge(self:GetParent(), "attach_attack2")
    if self:GetParent():GetUnitName() == "npc_dota_hero_templar_assassin" then
        self.pie:SetModelScale(0.3)
    end
end

function modifier_frisk_q_pie:OnDestroy()
    if not IsServer() then return end
    if self.pie and not self.pie:IsNull() then
        self.pie:RemoveSelf()
        self.pie = nil
    end
end